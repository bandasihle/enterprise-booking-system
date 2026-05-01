package com.ebs.controllers;

import com.ebs.config.DatabaseConnection;
import com.ebs.service.AdminService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/api/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        int students          = adminService.getStudentCount();
        int totalUsers        = 0;
        int activeUsers       = 0;
        int totalBookings     = 0;
        int todaysBookings    = 0;
        int availableLabs     = 0;
        int totalComplaints   = 0;
        int pendingComplaints = 0;

        try (Connection conn = DatabaseConnection.getConnection()) {

            totalUsers        = queryCount(conn,
                "SELECT COUNT(*) FROM users");

            activeUsers       = queryCount(conn,
                "SELECT COUNT(*) FROM users WHERE is_banned = 0 AND is_suspended = 0");

            totalBookings     = queryCount(conn,
                "SELECT COUNT(*) FROM bookings");

            todaysBookings    = queryCount(conn,
                "SELECT COUNT(*) FROM bookings WHERE DATE(start_time) = CURDATE()");

            availableLabs     = queryCount(conn,
                "SELECT COUNT(*) FROM labs WHERE status = 'Active'");

            totalComplaints   = queryCount(conn,
                "SELECT COUNT(*) FROM complaints");

            pendingComplaints = queryCount(conn,
                "SELECT COUNT(*) FROM complaints WHERE UPPER(status) = 'PENDING'");

        } catch (Exception e) {
            System.err.println("AdminDashboardServlet error: " + e.getMessage());
            e.printStackTrace();
        }

        String json =
            "{"
            + "\"todayStats\":{"
            +     "\"activeStudents\":" + students
            + "},"
            + "\"totalUsers\":"        + totalUsers        + ","
            + "\"activeUsers\":"       + activeUsers       + ","
            + "\"totalBookings\":"     + totalBookings     + ","
            + "\"todaysBookings\":"    + todaysBookings    + ","
            + "\"availableLabs\":"     + availableLabs     + ","
            + "\"totalComplaints\":"   + totalComplaints   + ","
            + "\"pendingComplaints\":" + pendingComplaints
            + "}";

        out.print(json);
    }

    private int queryCount(Connection conn, String sql) {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            System.err.println("Count query failed [" + sql + "]: " + e.getMessage());
            return 0;
        }
    }

    @Override
    protected void doOptions(HttpServletRequest request,
                             HttpServletResponse response)
            throws IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(200);
    }
}