package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/api/users/*")
public class AddUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        StringBuilder sb = new StringBuilder();
        sb.append("{\"users\":[");

        try (Connection conn = DatabaseConnection.getConnection()) {
            // FIX: Added is_suspended and suspended_until to the SELECT statement
            String sql = "SELECT id, role, is_banned, is_suspended, " +
                         "DATE_FORMAT(suspended_until, '%d %b %Y %H:%i') AS suspended_until, " +
                         "EMAIL, full_name FROM users ORDER BY id DESC";
                         
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;
                
                int id = rs.getInt("id");
                String role = rs.getString("role");
                boolean banned = rs.getBoolean("is_banned");
                
                // FIX: Extract the new suspension data
                boolean suspended = rs.getBoolean("is_suspended");
                String susUntil = rs.getString("suspended_until");
                
                String email = rs.getString("EMAIL");
                String name = rs.getString("full_name");
                if (name == null) name = "";
                
                sb.append("{")
                  .append("\"id\":").append(id).append(",")
                  .append("\"role\":\"").append(escape(role)).append("\",")
                  .append("\"is_banned\":").append(banned).append(",")
                  .append("\"is_suspended\":").append(suspended).append(",") // Added to JSON
                  .append("\"suspended_until\":").append(susUntil != null ? "\"" + escape(susUntil) + "\"" : "null").append(",") // Added to JSON
                  .append("\"email\":\"").append(escape(email)).append("\",")
                  .append("\"full_name\":\"").append(escape(name)).append("\"")
                  .append("}");
            }
        } catch (Exception e) {
            System.out.println("UserServlet GET error: " + e.getMessage());
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

        String pathInfo = request.getPathInfo(); // "/add" or "/update"

        try {
            StringBuilder body = new StringBuilder();
            String line;
            java.io.BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) body.append(line);
            String json = body.toString();

            if ("/add".equals(pathInfo)) {
                handleAdd(json, out);
            } else if ("/update".equals(pathInfo)) {
                handleUpdate(json, out);
            } else {
                out.print("{\"success\":false,\"message\":\"Unknown endpoint\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleAdd(String json, PrintWriter out) {
        String email    = extractJson(json, "email");
        String password = extractJson(json, "password");
        String role     = extractJson(json, "role");
        String fullName = extractJson(json, "full_name");

        if (email.isEmpty() || password.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Email and password required\"}");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check duplicate email
            PreparedStatement check = conn.prepareStatement("SELECT id FROM users WHERE EMAIL=?");
            check.setString(1, email);
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                out.print("{\"success\":false,\"message\":\"Email already exists\"}");
                return;
            }

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (EMAIL, PASSWORD, role, full_name, is_banned, cancellation_count) VALUES (?,?,?,?,0,0)"
            );
            ps.setString(1, email);
            ps.setString(2, password); // In production, hash this
            ps.setString(3, role.isEmpty() ? "Student" : role);
            ps.setString(4, fullName);
            ps.executeUpdate();
            out.print("{\"success\":true,\"message\":\"User added successfully\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleUpdate(String json, PrintWriter out) {
        String idStr   = extractJson(json, "id");
        String email   = extractJson(json, "email");
        String role    = extractJson(json, "role");
        String fullName= extractJson(json, "full_name");
        String status  = extractJson(json, "status");
        boolean banned = "Inactive".equalsIgnoreCase(status);

        if (idStr.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"User ID required\"}");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE users SET EMAIL=?, role=?, full_name=?, is_banned=? WHERE id=?"
            );
            ps.setString(1, email);
            ps.setString(2, role);
            ps.setString(3, fullName);
            ps.setBoolean(4, banned);
            ps.setInt(5, Integer.parseInt(idStr));
            int rows = ps.executeUpdate();
            if (rows > 0) {
                out.print("{\"success\":true,\"message\":\"User updated\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"User not found\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
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
                // Could be a boolean/number
                int end = json.indexOf(",", colon + 1);
                if (end < 0) end = json.indexOf("}", colon + 1);
                return json.substring(colon + 1, end).trim();
            }
            int end = json.indexOf("\"", start + 1);
            return json.substring(start + 1, end);
        } catch (Exception e) {
            return "";
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
