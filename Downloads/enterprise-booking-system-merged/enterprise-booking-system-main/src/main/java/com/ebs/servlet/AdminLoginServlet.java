package com.ebs.servlet;

import com.ebs.config.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println("AdminLoginServlet HIT — code=" + req.getParameter("adminCode")
            + " email=" + req.getParameter("email")
            + " pw="    + req.getParameter("password"));

        String adminCode = req.getParameter("adminCode");
        String email     = req.getParameter("email");
        String password  = req.getParameter("password");

        if (adminCode == null || email == null || password == null
                || adminCode.isBlank() || email.isBlank() || password.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/pages/admin/login.jsp?error=missing");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "SELECT a.ID, a.email, u.full_name " +
                "FROM admins a " +
                "JOIN users u ON u.ID = a.ID " +
                "WHERE a.admin_code = ? " +
                "  AND a.email = ? " +
                "  AND a.password = ?"
            );
            ps.setString(1, adminCode.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = req.getSession(true);
                session.setAttribute("adminId",    rs.getLong("ID"));
                session.setAttribute("adminEmail", rs.getString("email"));
                session.setAttribute("adminName",  rs.getString("full_name"));
                session.setAttribute("userRole",   "ADMIN");

                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/pages/admin/login.jsp?error=invalid");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/pages/admin/login.jsp?error=server");
        }
    }
}