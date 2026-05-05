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
 * Handles all lab-related API endpoints:
 *
 * GET  /api/labs         → returns all labs from database
 * POST /api/labs/add     → inserts a new lab
 * POST /api/labs/update  → updates lab status (Active/Maintenance)
 *
 * Uses wildcard mapping /api/labs/* to handle all sub-paths.
 */
@WebServlet("/api/labs/*")
public class LabServlet extends HttpServlet {

    /*
     * GET /api/labs
     * Returns all labs as JSON.
     * Called every time resources.jsp loads — ensures labs
     * always reflect the real database, not hardcoded HTML.
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
            StringBuilder labs = new StringBuilder("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) labs.append(",");
                first = false;

                String status = rs.getString("status");
                if (status == null || status.isEmpty()) status = "Active";

                int capacity = rs.getInt("capacity");

                labs.append("{")
                    .append("\"id\":").append(rs.getInt("ID")).append(",")
                    .append("\"name\":\"").append(safe(rs.getString("lab_name"))).append("\",")
                    .append("\"building\":\"").append(safe(rs.getString("building"))).append("\",")
                    .append("\"total_pcs\":").append(capacity).append(",")
                    .append("\"available_pcs\":").append(capacity).append(",")
                    .append("\"status\":\"").append(safe(status)).append("\"")
                    .append("}");
            }

            labs.append("]");

            String json = "{\"labs\":" + labs + "}";
            System.out.println("✅ Labs loaded: " + json);
            response.getWriter().write(json);

        } catch (Exception e) {
            System.out.println("❌ Get labs error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"labs\":[]}");
        }
    }

    /*
     * POST /api/labs/add    → insert new lab
     * POST /api/labs/update → update lab status
     *
     * Reads pathInfo to decide which action to perform.
     */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json");

        String path = request.getPathInfo(); // "/add" or "/update"

        // Read request body
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) sb.append(line);
        String body = sb.toString();

        System.out.println("📥 LabsServlet [" + path + "] body: " + body);

        if ("/add".equals(path)) {
            handleAddLab(body, response);
        } else if ("/update".equals(path)) {
            handleUpdateLab(body, response);
        } else {
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Unknown action: " + path + "\"}"
            );
        }
    }

    /*
     * Inserts a new lab into the labs table.
     * Expects JSON: { "name": "Lab A", "total_pcs": "30", "status": "Active" }
     */
    private void handleAddLab(String body,
                               HttpServletResponse response)
            throws IOException {

        String name     = extractJson(body, "name");
        String status   = extractJson(body, "status");
        String pcsStr   = extractJsonNumber(body, "total_pcs");

        // Fallback field names in case JS sends different keys
        if (name.isEmpty())   name   = extractJson(body, "labName");
        if (name.isEmpty())   name   = extractJson(body, "lab_name");
        if (status.isEmpty()) status = "Active";
        if (pcsStr.isEmpty()) pcsStr = extractJsonNumber(body, "capacity");

        int totalPcs = pcsStr.isEmpty() ? 0 : Integer.parseInt(pcsStr.trim());

        System.out.println("🏫 Adding lab: name=" + name + " pcs=" + totalPcs + " status=" + status);

        if (name.isEmpty()) {
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Lab name is required\"}"
            );
            return;
        }

        if (totalPcs < 1) {
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Total PCs must be at least 1\"}"
            );
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO labs (lab_name, building, capacity, status) VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, name);
            ps.setString(2, "Main");
            ps.setInt(3, totalPcs);
            ps.setString(4, status);

            boolean success = ps.executeUpdate() > 0;

            if (success) {
                System.out.println("✅ Lab added successfully: " + name);
                response.getWriter().write(
                    "{\"success\":true,\"message\":\"Lab added successfully\"}"
                );
            } else {
                response.getWriter().write(
                    "{\"success\":false,\"message\":\"Failed to add lab\"}"
                );
            }

        } catch (Exception e) {
            System.out.println("❌ Add lab error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write(
                "{\"success\":false,\"message\":\"" + e.getMessage() + "\"}"
            );
        }
    }

    /*
     * Updates a lab's status in the database.
     * Expects JSON: { "id": "3", "status": "Maintenance" }
     */
    private void handleUpdateLab(String body,
                                  HttpServletResponse response)
            throws IOException {

        String idStr  = extractJsonNumber(body, "id");
        String status = extractJson(body, "status");

        System.out.println("🔄 Updating lab ID=" + idStr + " status=" + status);

        if (idStr.isEmpty() || status.isEmpty()) {
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Lab ID and status are required\"}"
            );
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE labs SET status = ? WHERE ID = ?"
            );
            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(idStr.trim()));

            boolean success = ps.executeUpdate() > 0;

            if (success) {
                System.out.println("✅ Lab status updated: ID=" + idStr + " → " + status);
                response.getWriter().write(
                    "{\"success\":true,\"message\":\"Lab status updated\"}"
                );
            } else {
                response.getWriter().write(
                    "{\"success\":false,\"message\":\"Lab not found\"}"
                );
            }

        } catch (Exception e) {
            System.out.println("❌ Update lab error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write(
                "{\"success\":false,\"message\":\"" + e.getMessage() + "\"}"
            );
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req,
                              HttpServletResponse res)
            throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }

    /* Extracts a string value from JSON */
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

    /* Extracts a number value from JSON */
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

    private String safe(String s) {
        return s == null ? "" : s.replace("\"", "'");
    }
}
