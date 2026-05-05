package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/api/users")
public class GetUsersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        StringBuilder sb = new StringBuilder("{\"users\":[");

        try (Connection conn = DatabaseConnection.getConnection()) {

            String sql =
                "SELECT u.id, " +
                "       u.full_name, " +
                "       u.email, " +
                "       u.role, " +
                "       u.is_banned, " +
                "       u.is_suspended, " +
                "       DATE_FORMAT(u.suspended_until, '%d %b %Y %H:%i') AS suspended_until " +
                "FROM users u " +
                "ORDER BY u.id ASC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;

                boolean isBanned    = rs.getBoolean("is_banned");
                boolean isSuspended = rs.getBoolean("is_suspended");
                String  suspUntil   = rs.getString("suspended_until");

                sb.append("{")
                  .append("\"id\":").append(rs.getLong("id")).append(",")
                  .append("\"full_name\":\"").append(esc(rs.getString("full_name"))).append("\",")
                  .append("\"email\":\"").append(esc(rs.getString("email"))).append("\",")
                  .append("\"role\":\"").append(esc(rs.getString("role"))).append("\",")
                  .append("\"is_banned\":").append(isBanned).append(",")
                  .append("\"is_suspended\":").append(isSuspended).append(",")
                  .append("\"suspended_until\":").append(
                      suspUntil != null ? "\"" + esc(suspUntil) + "\"" : "null")
                  .append("}");
            }

        } catch (Exception e) {
            System.err.println("GetUsersServlet error: " + e.getMessage());
            e.printStackTrace();
        }

        sb.append("]}");
        out.print(sb.toString());
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}