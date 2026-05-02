package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/api/labs/*")
public class LabServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        StringBuilder sb = new StringBuilder("{\"labs\":[");

        try (Connection conn = DatabaseConnection.getConnection()) {

            String sql =
                "SELECT l.id, " +
                "       l.lab_name, " +
                "       l.building, " +
                "       l.capacity            AS total_pcs, " +
                "       COALESCE(SUM(s.is_available), 0) AS available_pcs, " +
                "       l.status " +
                "FROM labs l " +
                "LEFT JOIN seats s ON s.lab_id = l.id " +
                "GROUP BY l.id, l.lab_name, l.building, l.capacity, l.status " +
                "ORDER BY l.id ASC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;
                sb.append("{")
                  .append("\"id\":").append(rs.getLong("id")).append(",")
                  .append("\"name\":\"").append(esc(rs.getString("lab_name"))).append("\",")
                  .append("\"building\":\"").append(esc(rs.getString("building"))).append("\",")
                  .append("\"total_pcs\":").append(rs.getInt("total_pcs")).append(",")
                  .append("\"available_pcs\":").append(rs.getInt("available_pcs")).append(",")
                  .append("\"status\":\"").append(esc(rs.getString("status"))).append("\"")
                  .append("}");
            }

        } catch (Exception e) {
            System.err.println("LabServlet GET error: " + e.getMessage());
            e.printStackTrace();
        }

        sb.append("]}");
        out.print(sb.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        String path = request.getPathInfo();

        StringBuilder bodySb = new StringBuilder();
        String line;
        java.io.BufferedReader reader = request.getReader();
        while ((line = reader.readLine()) != null) bodySb.append(line);
        String body = bodySb.toString();

        try {
            if ("/add".equals(path)) {
                handleAdd(body, out);
            } else if ("/update".equals(path)) {
                handleUpdate(body, out);
            } else {
                out.print("{\"success\":false,\"message\":\"Unknown endpoint\"}");
            }
        } catch (Exception e) {
            System.err.println("LabServlet POST error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
        }
    }

    private void handleAdd(String body, PrintWriter out) throws Exception {
        String name     = extractStr(body, "name");
        String status   = extractStr(body, "status");
        int    totalPcs = extractInt(body, "total_pcs");

        if (name.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Lab name is required\"}");
            return;
        }
        if (totalPcs < 1) {
            out.print("{\"success\":false,\"message\":\"Total PCs must be at least 1\"}");
            return;
        }
        if (status.isEmpty()) status = "Active";

        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement insLab = conn.prepareStatement(
                "INSERT INTO labs (lab_name, building, capacity, status) VALUES (?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            insLab.setString(1, name);
            insLab.setString(2, "Main");
            insLab.setInt(3, totalPcs);
            insLab.setString(4, status);
            insLab.executeUpdate();

            ResultSet keys = insLab.getGeneratedKeys();
            if (!keys.next()) {
                out.print("{\"success\":false,\"message\":\"Failed to retrieve new lab ID\"}");
                return;
            }
            long newLabId = keys.getLong(1);

            PreparedStatement insSeat = conn.prepareStatement(
                "INSERT INTO seats (lab_id, seat_number, is_available) VALUES (?, ?, 1)"
            );
            for (int i = 1; i <= totalPcs; i++) {
                insSeat.setLong(1, newLabId);
                insSeat.setString(2, String.format("PC-%02d", i));
                insSeat.addBatch();
            }
            insSeat.executeBatch();

            out.print("{\"success\":true,\"message\":\"Lab added successfully\"}");
        }
    }

    private void handleUpdate(String body, PrintWriter out) throws Exception {
        String idStr  = extractStr(body, "id");
        String status = extractStr(body, "status");

        if (idStr.isEmpty() || status.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"id and status are required\"}");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE labs SET status = ? WHERE id = ?"
            );
            ps.setString(1, status);
            ps.setLong(2, Long.parseLong(idStr));
            int rows = ps.executeUpdate();
            out.print(rows > 0
                ? "{\"success\":true}"
                : "{\"success\":false,\"message\":\"Lab not found\"}");
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }

    private String extractStr(String json, String key) {
        try {
            String pattern = "\"" + key + "\"";
            int idx   = json.indexOf(pattern);
            if (idx < 0) return "";
            int colon = json.indexOf(":", idx + pattern.length());
            if (colon < 0) return "";
            int afterColon = colon + 1;
            while (afterColon < json.length() && json.charAt(afterColon) == ' ') afterColon++;
            if (afterColon >= json.length()) return "";
            if (json.charAt(afterColon) == '"') {
                int start = afterColon + 1;
                int end   = json.indexOf("\"", start);
                return end < 0 ? "" : json.substring(start, end);
            } else {
                int end = json.indexOf(",", afterColon);
                if (end < 0) end = json.indexOf("}", afterColon);
                return end < 0 ? "" : json.substring(afterColon, end).trim();
            }
        } catch (Exception e) { return ""; }
    }

    private int extractInt(String json, String key) {
        String val = extractStr(json, key);
        try { return Integer.parseInt(val.trim()); } catch (Exception e) { return 0; }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}
