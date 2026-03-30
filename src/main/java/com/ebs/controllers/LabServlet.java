package com.ebs.controllers;

import com.ebs.services.LabService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;

/*
 * Handles:
 * POST /api/admin/resources  → Add new lab
 * GET  /api/admin/resources  → Confirm API is alive
 */
@WebServlet("/api/admin/resources")
public class LabServlet extends HttpServlet {

    // Using Service layer (professional approach)
    LabService labService = new LabService();

    /*
     * GET - confirms the endpoint is reachable
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        response.getWriter().write("{\"message\":\"Resources API is working\"}");
    }

    /*
     * POST - adds a new lab to the database
     * Expects JSON: { "labName": "...", "building": "...", "capacity": 30 }
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json");

        try {
            // Read incoming JSON from frontend
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            String body = sb.toString();
            System.out.println("📥 ResourceServlet received: " + body);

            // Extract values from JSON manually (no library needed)
            String labName  = extractJson(body, "labName");
            String building = extractJson(body, "building");
            String capStr   = extractJsonNumber(body, "capacity");
            int capacity    = capStr.isEmpty() ? 0 : Integer.parseInt(capStr);

            System.out.println("🏫 Creating lab: " + labName + " | " + building + " | capacity: " + capacity);

            // Call service layer
            boolean success = labService.createLab(labName, building, capacity);

            if (success) {
                response.getWriter().write("{\"success\":true,\"message\":\"Lab added successfully\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to add lab\"}");
            }

        } catch (Exception e) {
            System.out.println("❌ ResourceServlet Error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter()
                .write("{\"success\":false,\"message\":\"Server error: " + e.getMessage() + "\"}");
        }
    }

    /*
     * OPTIONS - handles CORS preflight from browser
     */
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(200);
    }

    // Extracts a string value from JSON
    private String extractJson(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx == -1) return "";
        int colon = json.indexOf(":", idx);
        int start = json.indexOf("\"", colon) + 1;
        int end = json.indexOf("\"", start);
        return json.substring(start, end);
    }

    // Extracts a number value from JSON
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