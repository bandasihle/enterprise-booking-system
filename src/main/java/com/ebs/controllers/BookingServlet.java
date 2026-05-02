package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

/**
 * FIX: doGet now performs a UNION ALL across both the `bookings` table
 * (student seat reservations) and the `lecturer_blocks` table so that
 * admin/bookings.jsp shows every booking type in one table.
 *
 * Each row carries a `booking_type` field ("STUDENT" or "LECTURER") so
 * the JSP can render the correct badge and column values.
 */
@WebServlet("/api/bookings/*")
public class BookingServlet extends HttpServlet {

    // ── GET /api/bookings — return all bookings (students + lecturer blocks) ──
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        StringBuilder sb = new StringBuilder();
        sb.append("{\"bookings\":[");

        /*
         * UNION ALL combines:
         *   1. Student seat bookings  (from `bookings` table)
         *   2. Lecturer lab blocks    (from `lecturer_blocks` table)
         *
         * Both sides produce identical columns so the ResultSet loop below
         * can iterate without branching.  The `booking_type` discriminator
         * column tells the UI which type of record each row is.
         *
         * The outer query orders by created_at DESC so newest records
         * appear at the top regardless of which table they came from.
         */
        String sql =
            "SELECT * FROM (" +

            // ── Student bookings ───────────────────────────────────────────
            "  SELECT " +
            "    'STUDENT'                                          AS booking_type, " +
            "    b.id                                               AS id, " +
            "    u.full_name                                        AS user_name, " +
            "    u.email                                            AS user_email, " +
            "    l.lab_name                                         AS lab_name, " +
            "    s.seat_number                                      AS seat_label, " +
            "    DATE_FORMAT(b.start_time, '%d %b %Y')             AS booking_date, " +
            "    DATE_FORMAT(b.start_time, '%H:%i')                AS booking_time, " +
            "    b.status                                           AS status, " +
            "    b.created_at                                       AS sort_time " +
            "  FROM bookings b " +
            "  LEFT JOIN users u  ON b.user_id  = u.id " +
            "  LEFT JOIN seats s  ON b.seat_id  = s.id " +
            "  LEFT JOIN labs  l  ON s.lab_id   = l.id " +

            "  UNION ALL " +

            // ── Lecturer lab blocks ────────────────────────────────────────
            "  SELECT " +
            "    'LECTURER'                                                                       AS booking_type, " +
            "    lb.id                                                                            AS id, " +
            "    u.full_name                                                                      AS user_name, " +
            "    u.email                                                                          AS user_email, " +
            "    l.lab_name                                                                       AS lab_name, " +
            "    lb.module_code                                                                   AS seat_label, " +
            "    DATE_FORMAT(lb.start_time, '%d %b %Y')                                          AS booking_date, " +
            "    CONCAT(DATE_FORMAT(lb.start_time,'%H:%i'),' - ',DATE_FORMAT(lb.end_time,'%H:%i')) AS booking_time, " +
            "    lb.status                                                                        AS status, " +
            "    lb.created_at                                                                    AS sort_time " +
            "  FROM lecturer_blocks lb " +
            "  LEFT JOIN users u ON lb.lecturer_id = u.id " +
            "  LEFT JOIN labs  l ON lb.lab_id      = l.id " +

            ") combined " +
            "ORDER BY sort_time DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;

                sb.append("{")
                  .append("\"booking_type\":\"").append(escape(rs.getString("booking_type"))).append("\",")
                  .append("\"id\":").append(rs.getLong("id")).append(",")
                  .append("\"user_name\":\"").append(escape(rs.getString("user_name"))).append("\",")
                  .append("\"user_email\":\"").append(escape(rs.getString("user_email"))).append("\",")
                  .append("\"lab_name\":\"").append(escape(rs.getString("lab_name"))).append("\",")
                  .append("\"seat_label\":\"").append(escape(rs.getString("seat_label"))).append("\",")
                  .append("\"booking_date\":\"").append(escape(rs.getString("booking_date"))).append("\",")
                  .append("\"booking_time\":\"").append(escape(rs.getString("booking_time"))).append("\",")
                  .append("\"status\":\"").append(escape(rs.getString("status"))).append("\"")
                  .append("}");
            }

        } catch (Exception e) {
            System.err.println("BookingServlet GET error: " + e.getMessage());
            e.printStackTrace();
        }

        sb.append("]}");
        out.print(sb.toString());
    }

    // ── POST /api/bookings/* — approve or create ──────────────────────────────
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
                        "UPDATE bookings SET status='APPROVED' WHERE id=?"
                    );
                    ps.setInt(1, Integer.parseInt(idStr));
                    int rows = ps.executeUpdate();
                    out.print(rows > 0
                        ? "{\"success\":true}"
                        : "{\"success\":false,\"message\":\"Booking not found\"}");
                }

            } else if ("/create".equals(pathInfo)) {

                // ── Resolve user ID (session first, then JSON body) ────────
                int userId = -1;
                HttpSession session = request.getSession(false);
                if (session != null && session.getAttribute("userId") != null) {
                    Object uid = session.getAttribute("userId");
                    userId = (uid instanceof Long) ? ((Long) uid).intValue() : (int) uid;
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

                    // Auto-lift expired suspension before checking
                    try (PreparedStatement liftPs = conn.prepareStatement(
                            "UPDATE users SET is_suspended = 0, suspended_until = NULL " +
                            "WHERE id = ? AND is_suspended = 1 AND suspended_until < NOW()")) {
                        liftPs.setInt(1, userId);
                        liftPs.executeUpdate();
                    }

                    // Enforce ban / suspension
                    try (PreparedStatement checkPs = conn.prepareStatement(
                            "SELECT is_banned, is_suspended, suspended_until FROM users WHERE id = ?")) {
                        checkPs.setInt(1, userId);
                        ResultSet rs = checkPs.executeQuery();

                        if (rs.next()) {
                            if (rs.getBoolean("is_banned")) {
                                out.print("{\"success\":false,\"reason\":\"banned\"," +
                                          "\"message\":\"Your account has been banned. You cannot make bookings.\"}");
                                return;
                            }
                            if (rs.getBoolean("is_suspended")) {
                                String until = rs.getString("suspended_until");
                                out.print("{\"success\":false,\"reason\":\"suspended\"," +
                                          "\"suspendedUntil\":\"" + (until != null ? until : "") + "\"," +
                                          "\"message\":\"Your account is suspended until " + until +
                                          ". You cannot make bookings during this period.\"}");
                                return;
                            }
                        } else {
                            out.print("{\"success\":false,\"message\":\"User not found\"}");
                            return;
                        }
                    }

                    // Proceed with booking
                    String labId       = extractJson(json, "labId");
                    String seatId      = extractJson(json, "seatId");
                    String bookingDate = extractJson(json, "bookingDate");

                    if (labId.isEmpty() || seatId.isEmpty() || bookingDate.isEmpty()) {
                        out.print("{\"success\":false,\"message\":\"Missing booking details\"}");
                        return;
                    }

                    try (PreparedStatement bookPs = conn.prepareStatement(
                            "INSERT INTO bookings (user_id, seat_id, start_time, end_time, status) " +
                            "VALUES (?, ?, ?, DATE_ADD(?, INTERVAL 1 HOUR), 'PENDING')")) {
                        bookPs.setInt(1, userId);
                        bookPs.setInt(2, Integer.parseInt(seatId.trim()));
                        bookPs.setString(3, bookingDate);
                        bookPs.setString(4, bookingDate);
                        bookPs.executeUpdate();
                    }

                    out.print("{\"success\":true,\"message\":\"Booking created successfully\"}");
                    System.out.println("Booking created for user ID: " + userId);
                }

            } else {
                out.print("{\"success\":false,\"message\":\"Unknown endpoint\"}");
            }

        } catch (Exception e) {
            System.err.println("BookingServlet POST error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setHeader("Access-Control-Allow-Origin",  "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

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
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}
