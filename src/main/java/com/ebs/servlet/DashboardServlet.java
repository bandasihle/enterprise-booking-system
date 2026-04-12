package com.ebs.servlet;

import com.ebs.dto.LabDTO;
import com.ebs.dto.StudentProfileDTO;
import com.ebs.ejb.StudentDashboardService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * GET /student/dashboard
 *   Loads all labs + student profile via EJB, forwards to dashboard.jsp.
 */
@WebServlet("/student/dashboard")
public class DashboardServlet extends HttpServlet {

    @EJB
    private StudentDashboardService dashboardService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long studentId = getStudentId(req);
        if (studentId == null) {
            resp.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }

        try {
            StudentProfileDTO profile = dashboardService.getStudentProfile(studentId);
            List<LabDTO>      labs    = dashboardService.getAllLabsWithAvailability();
            req.setAttribute("profile", profile);
            req.setAttribute("labs",    labs);
        } catch (Exception e) {
            req.setAttribute("loadError", true);
        }

        // One-time flash message from a previous redirect
        HttpSession session = req.getSession(false);
        if (session != null) {
            req.setAttribute("flash", session.getAttribute("flash"));
            session.removeAttribute("flash");
        }

        req.getRequestDispatcher("/student/dashboard.jsp").forward(req, resp);
    }

    private Long getStudentId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return (s == null) ? null : (Long) s.getAttribute("userId");
    }
}
