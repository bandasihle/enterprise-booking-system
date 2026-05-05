package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/api/complaints/*")
public class ComplaintServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        StringBuilder sb = new StringBuilder();
        sb.append("{\"complaints\":[");

        try (Connection conn = DatabaseConnection.getConnection()) {
            /*
             * Adjust column names to match your complaints table schema.
             * Common columns: id, user_id, description, category, status, resolution, created_at
             */
            String sql =
                "SELECT c.ID as id, " +
                "       u.full_name AS student_name, u.EMAIL AS student_email, " +
                "       c.description, c.category, c.status, c.resolution, " +
                "       DATE_FORMAT(c.created_at, '%d %b %Y') AS complaint_date " +
                "FROM complaints c " +
                "LEFT JOIN bookings b ON c.booking_id = b.ID " +
                "LEFT JOIN users u ON b.user_id = u.ID " +
                "ORDER BY c.ID DESC";

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
                  .append("\"description\":\"").append(escape(rs.getString("description"))).append("\",")
                  .append("\"category\":\"").append(escape(rs.getString("category"))).append("\",")
                  .append("\"status\":\"").append(escape(rs.getString("status"))).append("\",")
                  .append("\"resolution\":\"").append(escape(rs.getString("resolution"))).append("\",")
                  .append("\"complaint_date\":\"").append(escape(rs.getString("complaint_date"))).append("\"")
                  .append("}");
            }
        } catch (Exception e) {
            System.out.println("ComplaintsApiServlet GET error: " + e.getMessage());
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

            if ("/resolve".equals(pathInfo)) {
                String idStr     = extractJson(json, "id");
                String resolution = extractJson(json, "resolution");
                updateStatus(Integer.parseInt(idStr), "Resolved", resolution, out);

            } else if ("/resolve-batch".equals(pathInfo)) {
                // Parse array of IDs: {"ids":[1,2,3]}
                int startIdx = json.indexOf("[");
                int endIdx   = json.indexOf("]");
                if (startIdx < 0 || endIdx < 0) {
                    out.print("{\"success\":false,\"message\":\"Invalid ids array\"}");
                    return;
                }
                String[] parts = json.substring(startIdx + 1, endIdx).split(",");
                try (Connection conn = DatabaseConnection.getConnection()) {
                    for (String part : parts) {
                        int id = Integer.parseInt(part.trim());
                        PreparedStatement ps = conn.prepareStatement(
                            "UPDATE complaints SET status='Resolved' WHERE id=?"
                        );
                        ps.setInt(1, id);
                        ps.executeUpdate();
                    }
                }
                out.print("{\"success\":true}");

            } else {
                out.print("{\"success\":false,\"message\":\"Unknown endpoint\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void updateStatus(int id, String status, String resolution, PrintWriter out) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE complaints SET status=?, resolution=? WHERE id=?"
            );
            ps.setString(1, status);
            ps.setString(2, resolution);
            ps.setInt(3, id);
            int rows = ps.executeUpdate();
            out.print(rows > 0
                ? "{\"success\":true}"
                : "{\"success\":false,\"message\":\"Complaint not found\"}");
        } catch (Exception e) {
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
