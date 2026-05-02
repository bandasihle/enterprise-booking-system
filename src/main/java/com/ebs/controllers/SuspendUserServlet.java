package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/api/users/suspend")
public class SuspendUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json");

        // Read JSON body
        BufferedReader reader = request.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) sb.append(line);
        String body = sb.toString();

        System.out.println("📥 SuspendUserServlet body: " + body);

        // Extract userIds array from JSON
        String[] ids = extractIds(body);

        if (ids == null || ids.length == 0) {
            response.getWriter().write("{\"success\":false,\"message\":\"No user IDs provided\"}");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            suspendUsers(conn, ids);
            response.getWriter().write(
                "{\"success\":true,\"message\":\"Users suspended for 7 days\"}"
            );
            System.out.println("✅ Suspended " + ids.length + " user(s)");

        } catch (Exception e) {
            System.out.println("❌ SuspendUserServlet error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Server error: " + e.getMessage() + "\"}"
            );
        }
    }

    /*
     * Sets is_suspended = true and suspended_until = NOW() + 7 days
     * for each user ID in the array.
     */
    private void suspendUsers(Connection conn, String[] ids) throws Exception {
        String sql = "UPDATE users SET is_suspended = true, " +
                     "suspended_until = DATE_ADD(NOW(), INTERVAL 7 DAY) " +
                     "WHERE id = ?";

        for (String id : ids) {
            try {
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(id.trim()));
                ps.executeUpdate();
                System.out.println("🔒 Suspended user ID: " + id);
            } catch (Exception e) {
                System.out.println("❌ Failed to suspend user ID " + id + ": " + e.getMessage());
            }
        }
    }

    /*
     * Extracts the userIds array from JSON like:
     * {"userIds":["3","7","12"]}
     * Returns String[] of ID values.
     */
    private String[] extractIds(String json) {
        try {
            int start = json.indexOf("[");
            int end   = json.indexOf("]");
            if (start == -1 || end == -1) return new String[0];

            String arr = json.substring(start + 1, end);
            arr = arr.replace("\"", "").replace("'", "").trim();
            if (arr.isEmpty()) return new String[0];

            return arr.split(",");
        } catch (Exception e) {
            return new String[0];
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }
}