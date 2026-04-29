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
 * GET /api/users/check-suspension?userId=3
 *
 * Called before a user tries to make a booking.
 * Returns whether the user is suspended or banned.
 * If suspended_until has passed, auto-lifts the suspension.
 */
@WebServlet("/api/users/check-suspension")
public class CheckSuspensionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");

        String userIdParam = request.getParameter("userId");

        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            response.getWriter().write(
                "{\"allowed\":false,\"message\":\"No user ID provided\"}"
            );
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            int userId = Integer.parseInt(userIdParam.trim());

            // Auto-lift if suspension expired
            conn.prepareStatement(
                "UPDATE users SET is_suspended = false, suspended_until = NULL " +
                "WHERE id = " + userId +
                " AND is_suspended = true AND suspended_until < NOW()"
            ).executeUpdate();

            // Check current status
            PreparedStatement ps = conn.prepareStatement(
                "SELECT is_banned, is_suspended, suspended_until FROM users WHERE id = ?"
            );
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                boolean isBanned    = rs.getBoolean("is_banned");
                boolean isSuspended = rs.getBoolean("is_suspended");
                String  until       = rs.getString("suspended_until");

                if (isBanned) {
                    response.getWriter().write(
                        "{\"allowed\":false," +
                        "\"reason\":\"banned\"," +
                        "\"message\":\"Your account has been banned. You cannot make bookings.\"}"
                    );
                } else if (isSuspended) {
                    response.getWriter().write(
                        "{\"allowed\":false," +
                        "\"reason\":\"suspended\"," +
                        "\"suspendedUntil\":\"" + (until != null ? until : "") + "\"," +
                        "\"message\":\"Your account is suspended until " + until +
                        ". You cannot make bookings during this period.\"}"
                    );
                } else {
                    response.getWriter().write(
                        "{\"allowed\":true,\"message\":\"Account is active\"}"
                    );
                }
            } else {
                response.getWriter().write(
                    "{\"allowed\":false,\"message\":\"User not found\"}"
                );
            }

        } catch (Exception e) {
            System.out.println("❌ CheckSuspensionServlet error: " + e.getMessage());
            response.getWriter().write(
                "{\"allowed\":false,\"message\":\"Server error\"}"
            );
        }
    }
}