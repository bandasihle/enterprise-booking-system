package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/api/users/unsuspend")
public class UnsuspendUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");

        BufferedReader reader = request.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) sb.append(line);

        String[] ids = extractIds(sb.toString());

        if (ids == null || ids.length == 0) {
            response.getWriter().write("{\"success\":false,\"message\":\"No user IDs provided\"}");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE users SET is_suspended = false, suspended_until = NULL WHERE id = ?";
            for (String id : ids) {
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(id.trim()));
                ps.executeUpdate();
            }
            response.getWriter().write("{\"success\":true,\"message\":\"Users unsuspended\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    private String[] extractIds(String json) {
        try {
            int start = json.indexOf("[");
            int end   = json.indexOf("]");
            if (start == -1 || end == -1) return new String[0];
            String arr = json.substring(start + 1, end).replace("\"", "").trim();
            if (arr.isEmpty()) return new String[0];
            return arr.split(",");
        } catch (Exception e) { return new String[0]; }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }
}
