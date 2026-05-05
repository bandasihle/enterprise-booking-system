package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/api/bookings/*")
public class BookingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        StringBuilder sb = new StringBuilder();
        sb.append("{\"bookings\":[");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql =
                "SELECT b.ID as id, " +
                "       u.full_name AS student_name, u.EMAIL AS student_email, " +
                "       l.lab_name AS lab_name, " +
                "       s.seat_number AS seat_label, " + 
                "       b.seat_id, " +  // FIX 1: We must select seat_id so the loop below can find it!
                "       DATE_FORMAT(b.start_time, '%d %b %Y') AS booking_date, " + 
                "       DATE_FORMAT(b.start_time, '%H:%i') AS booking_time, " + // FIX 2: Added formatted time for the UI
                "       b.status " +
                "FROM bookings b " +
                "LEFT JOIN users u ON b.user_id = u.ID " +
                "LEFT JOIN seats s ON b.seat_id = s.ID " + 
                "LEFT JOIN labs l ON s.lab_id = l.ID " +   
                "ORDER BY b.ID DESC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;
                sb.append("{")
                  .append("\"id\":").append(rs.getInt("id")).append(",")
                  .append("\"student_name\":\"").append(escape(rs.getString("student_name"))).append("\",")
                  .append("\"student_email\":\"").append(escape(rs.getString("student_email"))).append("\",")
                  .append("\"lab_name\":\"").append(escape(rs.getString("lab_name"))).append("\",")
                  .append("\"seat_label\":\"").append(escape(rs.getString("seat_label"))).append("\",")
                  .append("\"seat_id\":\"").append(escape(rs.getString("seat_id"))).append("\",")
                  .append("\"booking_date\":\"").append(escape(rs.getString("booking_date"))).append("\",")
                  .append("\"booking_time\":\"").append(escape(rs.getString("booking_time"))).append("\",") // Added time to JSON
                  .append("\"status\":\"").append(escape(rs.getString("status"))).append("\"")
                  .append("}");
            }
        } catch (Exception e) {
            System.out.println("BookingServlet GET error: " + e.getMessage());
            e.printStackTrace();
        }

        sb.append("]}");
        out.print(sb.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();

        try {
            StringBuilder body = new StringBuilder();
            String line;
            java.io.BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) body.append(line);
            String json = body.toString();

            if ("/approve".equals(pathInfo)) {
                String idStr = extractJson(json, "id");
                if (idStr.isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"Booking ID required\"}");
                    return;
                }
                try (Connection conn = DatabaseConnection.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE bookings SET status='Approved' WHERE id=?"
                    );
                    ps.setInt(1, Integer.parseInt(idStr));
                    int rows = ps.executeUpdate();
                    out.print(rows > 0
                        ? "{\"success\":true}"
                        : "{\"success\":false,\"message\":\"Booking not found\"}");
                }

            } else if ("/create".equals(pathInfo)) {
                // ── Extract user ID from request ──────────────────────────────
                // Try session first, fall back to JSON body
                int userId = -1;
                HttpSession session = request.getSession(false);
                if (session != null && session.getAttribute("userId") != null) {
                    userId = (int) session.getAttribute("userId");
                } else {
                    String userIdStr = extractJson(json, "userId");
                    if (!userIdStr.isEmpty()) {
                        userId = Integer.parseInt(userIdStr.trim());
                    }
                }

                if (userId == -1) {
                    out.print("{\"success\":false,\"message\":\"User not logged in\"}");
                    return;
                }

                try (Connection conn = DatabaseConnection.getConnection()) {

                    // ── Step 1: Auto-lift expired suspension ──────────────────
                    PreparedStatement liftPs = conn.prepareStatement(
                        "UPDATE users SET is_suspended = false, suspended_until = NULL " +
                        "WHERE id = ? AND is_suspended = true AND suspended_until < NOW()"
                    );
                    liftPs.setInt(1, userId);
                    liftPs.executeUpdate();

                    // ── Step 2: Check if user is banned or suspended ──────────
                    PreparedStatement checkPs = conn.prepareStatement(
                        "SELECT is_banned, is_suspended, suspended_until FROM users WHERE id = ?"
                    );
                    checkPs.setInt(1, userId);
                    ResultSet rs = checkPs.executeQuery();

                    if (rs.next()) {
                        boolean isBanned    = rs.getBoolean("is_banned");
                        boolean isSuspended = rs.getBoolean("is_suspended");
                        String  until       = rs.getString("suspended_until");

                        if (isBanned) {
                            out.print("{\"success\":false," +
                                      "\"reason\":\"banned\"," +
                                      "\"message\":\"Your account has been banned. You cannot make bookings.\"}");
                            return;
                        }

                        if (isSuspended) {
                            out.print("{\"success\":false," +
                                      "\"reason\":\"suspended\"," +
                                      "\"suspendedUntil\":\"" + (until != null ? until : "") + "\"," +
                                      "\"message\":\"Your account is suspended until " + until +
                                      ". You cannot make bookings during this period.\"}");
                            return;
                        }
                    } else {
                        out.print("{\"success\":false,\"message\":\"User not found\"}");
                        return;
                    }

                    // ── Step 3: User is active — proceed with booking ─────────
                    String labId      = extractJson(json, "labId");
                    String seatId     = extractJson(json, "seatId");
                    String bookingDate = extractJson(json, "bookingDate");

                    if (labId.isEmpty() || seatId.isEmpty() || bookingDate.isEmpty()) {
                        out.print("{\"success\":false,\"message\":\"Missing booking details\"}");
                        return;
                    }

                    PreparedStatement bookPs = conn.prepareStatement(
                        "INSERT INTO bookings (user_id, lab_id, seat_id, booking_date, status) " +
                        "VALUES (?, ?, ?, ?, 'Pending')"
                    );
                    bookPs.setInt(1, userId);
                    bookPs.setInt(2, Integer.parseInt(labId.trim()));
                    bookPs.setInt(3, Integer.parseInt(seatId.trim()));
                    bookPs.setString(4, bookingDate);
                    bookPs.executeUpdate();

                    out.print("{\"success\":true,\"message\":\"Booking created successfully\"}");
                    System.out.println("✅ Booking created for user ID: " + userId);
                }

            } else {
                out.print("{\"success\":false,\"message\":\"Unknown endpoint\"}");
            }

        } catch (Exception e) {
            System.out.println("❌ BookingServlet POST error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }

    private String extractJson(String json, String key) {
        try {
            String pattern = "\"" + key + "\"";
            int idx = json.indexOf(pattern);
            if (idx < 0) return "";
            int colon = json.indexOf(":", idx + pattern.length());
            if (colon < 0) return "";
            int start = json.indexOf("\"", colon + 1);
            if (start < 0) {
                int end = json.indexOf(",", colon + 1);
                if (end < 0) end = json.indexOf("}", colon + 1);
                return json.substring(colon + 1, end).trim();
            }
            int end = json.indexOf("\"", start + 1);
            return json.substring(start + 1, end);
        } catch (Exception e) { return ""; }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","");
    }
}
