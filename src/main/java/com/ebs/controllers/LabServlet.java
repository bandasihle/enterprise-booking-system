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
                "INSERT INTO seats (lab_id, seat_number, is_available) VALUES (?, ?, ?)"
            );
            // If lab is added as Maintenance, create seats but mark them unavailable
            int avail = "Maintenance".equals(status) ? 0 : 1;
            for (int i = 1; i <= totalPcs; i++) {
                insSeat.setLong(1, newLabId);
                insSeat.setString(2, String.format("PC-%02d", i));
                insSeat.setInt(3, avail);
                insSeat.addBatch();
            }
            insSeat.executeBatch();

            out.print("{\"success\":true,\"message\":\"Lab added successfully\"}");
        }
    }

    /**
     * Updates lab name, capacity, and/or status.
     *
     * - If status changes to Maintenance  → all seats locked (is_available = 0)
     * - If status changes back to Active  → seats with no active booking are unlocked
     * - If capacity increased             → extra PC seats are created
     */
    private void handleUpdate(String body, PrintWriter out) throws Exception {
        String idStr    = extractStr(body, "id");
        String name     = extractStr(body, "name");
        String status   = extractStr(body, "status");
        String totalStr = extractStr(body, "total_pcs");

        if (idStr.isEmpty() || status.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"id and status are required\"}");
            return;
        }

        long labId = Long.parseLong(idStr);

        try (Connection conn = DatabaseConnection.getConnection()) {

            // ── 1. Read current values ──────────────────────────────
            PreparedStatement sel = conn.prepareStatement(
                "SELECT lab_name, capacity, status FROM labs WHERE id = ?");
            sel.setLong(1, labId);
            ResultSet rs = sel.executeQuery();
            if (!rs.next()) {
                out.print("{\"success\":false,\"message\":\"Lab not found\"}");
                return;
            }
            String oldName   = rs.getString("lab_name");
            int    oldCap    = rs.getInt("capacity");
            String oldStatus = rs.getString("status");

            String newName   = name.isEmpty()     ? oldName : name;
            int    newCap    = totalStr.isEmpty()  ? oldCap  : Math.max(1, Integer.parseInt(totalStr));

            // ── 2. Update the lab record ────────────────────────────
            PreparedStatement upd = conn.prepareStatement(
                "UPDATE labs SET lab_name = ?, capacity = ?, status = ? WHERE id = ?");
            upd.setString(1, newName);
            upd.setInt   (2, newCap);
            upd.setString(3, status);
            upd.setLong  (4, labId);
            upd.executeUpdate();

            // ── 3. Add extra seats if capacity increased ────────────
            if (newCap > oldCap) {
                PreparedStatement ins = conn.prepareStatement(
                    "INSERT INTO seats (lab_id, seat_number, is_available) VALUES (?, ?, ?)");
                // New seats respect the target status
                int avail = "Maintenance".equals(status) ? 0 : 1;
                for (int i = oldCap + 1; i <= newCap; i++) {
                    ins.setLong  (1, labId);
                    ins.setString(2, String.format("PC-%02d", i));
                    ins.setInt   (3, avail);
                    ins.addBatch();
                }
                ins.executeBatch();
            }

            // ── 4. Lock / unlock seats based on status change ───────
            boolean wasActive = "Active".equalsIgnoreCase(oldStatus);
            boolean nowActive = "Active".equalsIgnoreCase(status);

            if (!nowActive && wasActive) {
                // Going into Maintenance → lock every seat
                PreparedStatement lock = conn.prepareStatement(
                    "UPDATE seats SET is_available = 0 WHERE lab_id = ?");
                lock.setLong(1, labId);
                lock.executeUpdate();

            } else if (nowActive && !wasActive) {
                // Coming back to Active → only unlock seats with no current booking
                PreparedStatement unlock = conn.prepareStatement(
                    "UPDATE seats SET is_available = 1 " +
                    "WHERE lab_id = ? " +
                    "AND id NOT IN (" +
                    "  SELECT seat_id FROM bookings " +
                    "  WHERE status IN ('CONFIRMED','PENDING') AND end_time > NOW()" +
                    ")");
                unlock.setLong(1, labId);
                unlock.executeUpdate();
            }

            out.print("{\"success\":true}");
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
