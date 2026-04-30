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

/*
 This servlet handles requests for:
 GET /api/admin/dashboard
 It returns statistics for the admin dashboard.
*/
@WebServlet("/api/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    // Your original service — kept exactly as it was
    AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");

        PrintWriter out = response.getWriter();

        // Your original service call — kept exactly as it was
        int students = adminService.getStudentCount();

        // Real counts from database
        int totalUsers      = 0;
        int totalBookings   = 0;
        int availableLabs   = 0;
        int totalComplaints = 0;

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Table names confirmed from your MySQL Workbench schema:
            // users, bookings, labs, complaints
            totalUsers      = queryCount(conn, "SELECT COUNT(*) FROM users");
            totalBookings   = queryCount(conn, "SELECT COUNT(*) FROM bookings");
            availableLabs   = queryCount(conn, "SELECT COUNT(*) FROM labs WHERE status = 'Active'");
            totalComplaints = queryCount(conn, "SELECT COUNT(*) FROM complaints");

        } catch (Exception e) {
            System.out.println("Dashboard query error: " + e.getMessage());
            e.printStackTrace();
        }

        /*
          Create JSON response.
          Your original todayStats block is kept exactly as it was.
          New fields added alongside it.
         */
        String json =
                "{"
                + "\"todayStats\": {"
                +     "\"activeStudents\":" + students
                + "},"
                + "\"totalUsers\":"      + totalUsers      + ","
                + "\"totalBookings\":"   + totalBookings   + ","
                + "\"availableLabs\":"   + availableLabs   + ","
                + "\"totalComplaints\":" + totalComplaints
                + "}";

        out.print(json);
    }

    /*
     * Helper method — runs a COUNT(*) query and returns the integer result.
     */
    private int queryCount(Connection conn, String sql) {
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            System.out.println("Count query failed [" + sql + "]: " + e.getMessage());
        }
        return 0;
    }

    /*
     * OPTIONS — handles CORS preflight from browser
     */
    @Override
    protected void doOptions(HttpServletRequest request,
                             HttpServletResponse response)
            throws IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(200);
    }
}
