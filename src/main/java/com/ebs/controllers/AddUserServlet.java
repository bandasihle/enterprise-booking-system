package com.ebs.controllers;

import com.ebs.dao.UserDAO;
import com.ebs.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;

/*
 * Handles:
 * POST /api/admin/users  → Add new user
 * GET  /api/admin/users  → Confirm API is alive
 */
@WebServlet("/api/admin/users")
public class AddUserServlet extends HttpServlet {

    UserDAO dao = new UserDAO();

    /*
     * GET - confirms the endpoint is reachable
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        response.getWriter().write("{\"message\":\"Users API is working\"}");
    }

    /*
     * POST - adds a new user to the database
     * Expects JSON: { "fullName": "...", "email": "...", "password": "...", "role": "..." }
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json");

        try {
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            System.out.println("📥 Received: " + sb.toString());

            // Manual JSON parsing - no library needed
            String body = sb.toString();

            String fullName  = extractJson(body, "fullName");
            String email     = extractJson(body, "email");
            String password  = extractJson(body, "password");
            String role      = extractJson(body, "role");

            System.out.println("👤 Adding user: " + fullName + " | " + email + " | " + role);

            User user = new User(fullName, email, password, role);
            boolean success = dao.addUser(user);

            if (success) {
                response.getWriter().write("{\"success\":true,\"message\":\"User added successfully\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to add user\"}");
            }

        } catch (Exception e) {
            System.out.println("❌ AddUserServlet Error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Server error: " + e.getMessage() + "\"}");
        }
    }

    /*
     * OPTIONS - required for CORS preflight requests from browser
     */
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(200);
    }

    /*
     * Helper: extracts a value from a JSON string manually
     * e.g. extractJson("{\"name\":\"John\"}", "name") → "John"
     */
    private String extractJson(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx == -1) return "";
        int colon = json.indexOf(":", idx);
        int start = json.indexOf("\"", colon) + 1;
        int end = json.indexOf("\"", start);
        return json.substring(start, end);
    }
}