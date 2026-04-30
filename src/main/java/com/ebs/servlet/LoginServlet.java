package com.ebs.servlet;

import com.ebs.entity.User;
import com.ebs.util.PasswordUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;

import java.io.IOException;

/**
 * POST /login  — validates credentials, sets session, redirects to dashboard.
 * GET  /login  — redirects to student login page.
 * POST /logout — invalidates session, redirects to home.
 */
@WebServlet({"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/logout".equals(req.getServletPath())) {
            HttpSession s = req.getSession(false);
            if (s != null) s.invalidate();
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp");
        }
    }

    @Override
    @Transactional
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Handle logout via POST too
        if ("/logout".equals(req.getServletPath())) {
            HttpSession s = req.getSession(false);
            if (s != null) s.invalidate();
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp?error=missing");
            return;
        }

        try {
            User user = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email.trim().toLowerCase())
                    .getSingleResult();

            // Check ban
            if (user.isBanned()) {
                resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp?error=banned");
                return;
            }

            // Verify password — supports both hashed and plain-text (for seeded test users)
            boolean passwordOk;
            String stored = user.getPassword();
            if (stored != null && stored.contains(":")) {
                // Hashed password (salt:hash format from PasswordUtil)
                passwordOk = PasswordUtil.verifyPassword(password, stored);
            } else {
                // Plain-text fallback for test/seed data
                passwordOk = stored != null && stored.equals(password);
            }

            if (!passwordOk) {
                resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp?error=login");
                return;
            }

            // Create session
            HttpSession session = req.getSession(true);
            session.setAttribute("userId",    user.getId());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userName",  user.getFullName());
            session.setAttribute("userRole",  user.getClass().getSimpleName().toUpperCase());

            // Redirect by role
            String role = user.getClass().getSimpleName().toUpperCase();
            switch (role) {
                case "STUDENT":
                    resp.sendRedirect(req.getContextPath() + "/student/dashboard");
                    break;
                case "LECTURER":
                    resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
                    break;

                case "ADMIN":
                    resp.sendRedirect(req.getContextPath() + "/pages/admin/login.jsp");
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/index.jsp");
            }

        } catch (NoResultException e) {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp?error=login");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp?error=login");
        }
    }
}