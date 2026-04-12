package com.ebs.servlet;

import com.ebs.dto.BookingDTO;
import com.ebs.ejb.BookingService;
import com.ebs.ejb.StudentDashboardService;
import jakarta.ejb.EJB;
import jakarta.ejb.EJBException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * GET  /student/mybookings              — loads bookings from DB, splits into
 *                                         upcoming / past / cancelled, forwards to mybooking.jsp
 * POST /student/mybookings?action=cancel — cancels a booking; PRG on success
 */
@WebServlet("/student/mybookings")
public class MyBookingsServlet extends HttpServlet {

    @EJB private StudentDashboardService dashboardService;
    @EJB private BookingService          bookingService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long studentId = getStudentId(req);
        if (studentId == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp");
            return;
        }

        try {
            List<BookingDTO> all = dashboardService.getStudentBookings(studentId);
            LocalDateTime now   = LocalDateTime.now();

            // Split into three lists for the three tabs
            List<BookingDTO> upcoming = all.stream()
                    .filter(b -> "CONFIRMED".equals(b.getStatus()) && b.getStartTime().isAfter(now))
                    .collect(Collectors.toList());

            List<BookingDTO> past = all.stream()
                    .filter(b -> ("CONFIRMED".equals(b.getStatus()) || "COMPLETED".equals(b.getStatus())
                                  || "NO_SHOW".equals(b.getStatus()))
                              && !b.getStartTime().isAfter(now))
                    .collect(Collectors.toList());

            List<BookingDTO> cancelled = all.stream()
                    .filter(b -> "CANCELLED".equals(b.getStatus()))
                    .collect(Collectors.toList());

            req.setAttribute("upcomingBookings",  upcoming);
            req.setAttribute("pastBookings",      past);
            req.setAttribute("cancelledBookings", cancelled);
            req.setAttribute("totalBookings",     all.size());

        } catch (Exception e) {
            req.setAttribute("loadError", true);
        }

        // Flash message from previous redirect
        HttpSession session = req.getSession(false);
        if (session != null) {
            req.setAttribute("flash", session.getAttribute("flash"));
            session.removeAttribute("flash");
        }

        req.getRequestDispatcher("/student/mybooking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long studentId = getStudentId(req);
        if (studentId == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp");
            return;
        }

        if ("cancel".equals(req.getParameter("action"))) {
            try {
                Long bookingId = Long.parseLong(req.getParameter("bookingId"));
                bookingService.cancelBooking(bookingId);
                req.getSession().setAttribute("flash", "Booking cancelled successfully.");
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");

            } catch (NumberFormatException e) {
                req.getSession().setAttribute("flash", "Invalid booking ID.");
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");
            } catch (EJBException e) {
                Throwable cause = e.getCause();
                String msg = (cause instanceof IllegalArgumentException)
                        ? "Booking not found."
                        : "Could not cancel this booking.";
                req.getSession().setAttribute("flash", msg);
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");
            } catch (Exception e) {
                req.getSession().setAttribute("flash", "An unexpected error occurred.");
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/mybookings");
        }
    }

    private Long getStudentId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return (s == null) ? null : (Long) s.getAttribute("userId");
    }
}