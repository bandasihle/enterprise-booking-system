package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/*
 * Handles:
 * GET  /api/admin/resources  → returns all labs from database
 * POST /api/admin/resources  → adds a new lab to database
 *
 * This ensures labs always load from the real database,
 * so they persist across page navigation.
 */
@WebServlet("/api/admin/resources")
public class GetLabsServlet extends HttpServlet {

    /*
     * GET — returns all labs as JSON array.
     * Called every time the resources page loads.
     */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");

        try (Connection conn = DatabaseConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "SELECT ID, lab_name, building, capacity, status FROM labs ORDER BY ID ASC"
            );

            ResultSet rs = ps.executeQuery();
            StringBuilder json = new StringBuilder("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

                String status = rs.getString("status");
                if (status == null) status = "Active";

                json.append("{")
                    .append("\"id\":").append(rs.getInt("ID")).append(",")
                    .append("\"labName\":\"").append(safe(rs.getString("lab_name"))).append("\",")
                    .append("\"building\":\"").append(safe(rs.getString("building"))).append("\",")
                    .append("\"capacity\":").append(rs.getInt("capacity")).append(",")
                    .append("\"status\":\"").append(safe(status)).append("\"")
                    .append("}");
            }

            json.append("]");

            System.out.println("✅ Labs loaded from DB");
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            System.out.println("❌ GetLabsServlet error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    /*
     * POST — inserts a new lab into the database.
     * Reads JSON: { "labName": "Lab A", "capacity": 30, "status": "Active" }
     */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json");

        try {
            // Read request body
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) sb.append(line);
            String body = sb.toString();

            System.out.println("📥 AddLab received: " + body);

            // Extract values manually
            String labName  = extractJson(body, "labName");
            String building = extractJson(body, "building");
            String status   = extractJson(body, "status");
            String capStr   = extractJsonNumber(body, "capacity");

            if (labName.isEmpty()) labName = extractJson(body, "lab_name");
            if (building.isEmpty()) building = "Main";
            if (status.isEmpty())   status   = "Active";

            int capacity = capStr.isEmpty() ? 0 : Integer.parseInt(capStr);

            System.out.println("🏫 Adding lab: " + labName + " | " + capacity + " | " + status);

            try (Connection conn = DatabaseConnection.getConnection()) {

                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO labs (lab_name, building, capacity, status) VALUES (?, ?, ?, ?)"
                );
                ps.setString(1, labName);
                ps.setString(2, building);
                ps.setInt(3, capacity);
                ps.setString(4, status);

                boolean success = ps.executeUpdate() > 0;

                if (success) {
                    System.out.println("✅ Lab added: " + labName);
                    response.getWriter().write(
                        "{\"success\":true,\"message\":\"Lab added successfully\"," +
                        "\"labName\":\"" + labName + "\"," +
                        "\"capacity\":" + capacity + "," +
                        "\"status\":\"" + status + "\"}"
                    );
                } else {
                    response.getWriter().write(
                        "{\"success\":false,\"message\":\"Failed to add lab\"}"
                    );
                }
            }

        } catch (Exception e) {
            System.out.println("❌ AddLab error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write(
                "{\"success\":false,\"message\":\"" + e.getMessage() + "\"}"
            );
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

    private String safe(String s) {
        return s == null ? "" : s.replace("\"", "'");
    }

    private String extractJson(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx == -1) return "";
        int colon = json.indexOf(":", idx);
        int start = json.indexOf("\"", colon) + 1;
        int end   = json.indexOf("\"", start);
        if (start <= 0 || end <= 0) return "";
        return json.substring(start, end);
    }

    private String extractJsonNumber(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx == -1) return "";
        int colon = json.indexOf(":", idx) + 1;
        StringBuilder num = new StringBuilder();
        for (int i = colon; i < json.length(); i++) {
            char c = json.charAt(i);
            if (Character.isDigit(c)) num.append(c);
            else if (num.length() > 0) break;
        }
        return num.toString();
    }
}