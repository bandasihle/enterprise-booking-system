package com.ebs.servlet;

import com.ebs.ejb.LecturerBlockService;
import com.ebs.entity.Lab;
import com.ebs.entity.LecturerBlock;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * Routes:
 *  GET  /lecturer/dashboard  → lecturer/pages/lec_dashboard.jsp
 *  GET  /lecturer/book-lab   → lecturer/pages/book_lab.jsp
 *  POST /lecturer/book-lab   → creates block in DB, redirects to dashboard
 *  GET  /lecturer/bookings   → lecturer/pages/view_bookings.jsp
 *
 * JSP files must be at:
 *   src/main/webapp/lecturer/pages/lec_dashboard.jsp
 *   src/main/webapp/lecturer/pages/book_lab.jsp
 *   src/main/webapp/lecturer/pages/view_bookings.jsp
 *
 * CSS must be at:
 *   src/main/webapp/lecturer/css/lecturer.css
 *
 * Images referenced in JSPs:
 *   src/main/webapp/lecturer/images/lab.jpg
 *   src/main/webapp/lecturer/images/LectureHall.jpg
 *   src/main/webapp/lecturer/images/logooo.jpeg
 */
@WebServlet({
    "/lecturer/dashboard",
    "/lecturer/book-lab",
    "/lecturer/bookings",
    "/lecturer/cancel-booking"
})
public class LecturerServlet extends HttpServlet {

    @EJB
    private LecturerBlockService blockService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long lecturerId = userId(req);
        if (lecturerId == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/lecturer/login.jsp");
            return;
        }

        switch (req.getServletPath()) {
            case "/lecturer/dashboard": dashboard(req, resp, lecturerId); break;
            case "/lecturer/book-lab":  bookLabGet(req, resp, lecturerId); break;
            case "/lecturer/bookings":  viewBookings(req, resp, lecturerId); break;
            case "/lecturer/cancel-booking": cancelBooking(req, resp, lecturerId); break;
            default: resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long lecturerId = userId(req);
        if (lecturerId == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/lecturer/login.jsp");
            return;
        }
        if ("/lecturer/book-lab".equals(req.getServletPath())) {
            bookLabPost(req, resp, lecturerId);
        }
    }

    // ── Handlers ──────────────────────────────────────────────

    private void dashboard(HttpServletRequest req, HttpServletResponse resp, Long id)
            throws ServletException, IOException {
        try {
            req.setAttribute("blocks", blockService.getUpcomingBlocks(id));
            req.setAttribute("labs",   blockService.getAllLabs());
        } catch (Exception e) {
            req.setAttribute("loadError", "Could not load data: " + e.getMessage());
        }
        pullFlash(req);
        // CORRECT:
            req.getRequestDispatcher("/lecturer/pages/lec_dashboard.jsp").forward(req, resp);
    }

    private void bookLabGet(HttpServletRequest req, HttpServletResponse resp, Long id)
            throws ServletException, IOException {
        try {
            req.setAttribute("labs",   blockService.getAllLabs());
            req.setAttribute("blocks", blockService.getUpcomingBlocks(id)); // for clash reference table
            String pre = req.getParameter("labId");
            if (pre != null && !pre.isBlank()) req.setAttribute("preLabId", pre);
        } catch (Exception e) {
            req.setAttribute("loadError", "Could not load labs: " + e.getMessage());
        }
        pullFlash(req);
        req.getRequestDispatcher("/lecturer/pages/book-lab.jsp").forward(req, resp);
    }

    private void viewBookings(HttpServletRequest req, HttpServletResponse resp, Long id)
            throws ServletException, IOException {
        try {
            req.setAttribute("blocks", blockService.getAllBlocks(id));
        } catch (Exception e) {
            req.setAttribute("loadError", "Could not load bookings: " + e.getMessage());
        }
        pullFlash(req);
        req.getRequestDispatcher("/lecturer/pages/view_bookings.jsp").forward(req, resp);
    }

    private void bookLabPost(HttpServletRequest req, HttpServletResponse resp, Long id)
            throws IOException {
        try {
            String labIdStr   = req.getParameter("labId");
            String moduleCode = req.getParameter("moduleCode");
            String reason     = req.getParameter("reason");
            String dateStr    = req.getParameter("date");
            String startStr   = req.getParameter("startTime");
            String endStr     = req.getParameter("endTime");

            if (blank(labIdStr) || blank(moduleCode) || blank(dateStr)
                    || blank(startStr) || blank(endStr)) {
                flash(req, "error", "All required fields must be filled in.");
                resp.sendRedirect(req.getContextPath() + "/lecturer/book-lab");
                return;
            }

            LocalDateTime start = LocalDateTime.of(LocalDate.parse(dateStr), LocalTime.parse(startStr));
            LocalDateTime end   = LocalDateTime.of(LocalDate.parse(dateStr), LocalTime.parse(endStr));

            if (!start.isBefore(end)) {
                flash(req, "error", "End time must be after start time.");
                resp.sendRedirect(req.getContextPath() + "/lecturer/book-lab");
                return;
            }

            blockService.createBlock(id, Long.parseLong(labIdStr), moduleCode, reason, start, end);
            flash(req, "success", "✅ Lab reserved successfully for " + moduleCode + ".");
            resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard");

        } catch (IllegalStateException e) {
            flash(req, "error", "❌ That lab is already blocked for the selected time slot. Choose another time.");
            resp.sendRedirect(req.getContextPath() + "/lecturer/book-lab");
        } catch (Exception e) {
            flash(req, "error", "Reservation failed: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/lecturer/book-lab");
        }
    }
    
    private void cancelBooking(HttpServletRequest req, HttpServletResponse resp, Long id) 
        throws IOException {
    try {
        String bookingIdStr = req.getParameter("id");
        if (!blank(bookingIdStr)) {
            blockService.cancelBlock(Long.parseLong(bookingIdStr));
            flash(req, "success", "Booking cancelled successfully.");
        }
    } catch (Exception e) {
        flash(req, "error", "Failed to cancel: " + e.getMessage());
    }
    resp.sendRedirect(req.getContextPath() + "/lecturer/bookings");
}

    // ── Helpers ───────────────────────────────────────────────

    private Long userId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (Long) s.getAttribute("userId");
    }

    private void flash(HttpServletRequest req, String type, String msg) {
        HttpSession s = req.getSession(true);
        s.setAttribute("flashMsg",  msg);
        s.setAttribute("flashType", type);
    }

    private void pullFlash(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return;
        req.setAttribute("flashMsg",  s.getAttribute("flashMsg"));
        req.setAttribute("flashType", s.getAttribute("flashType"));
        s.removeAttribute("flashMsg");
        s.removeAttribute("flashType");
    }

    private boolean blank(String s) { return s == null || s.isBlank(); }
}
