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
import java.util.List;

/**
 * GET  /student/mybookings              — renders booking history via mybooking.jsp
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
        if (studentId == null) { resp.sendRedirect(req.getContextPath() + "/index.html"); return; }

        try {
            List<BookingDTO> bookings = dashboardService.getStudentBookings(studentId);
            req.setAttribute("bookings", bookings);
        } catch (Exception e) {
            req.setAttribute("loadError", true);
        }

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
        if (studentId == null) { resp.sendRedirect(req.getContextPath() + "/index.html"); return; }

        if ("cancel".equals(req.getParameter("action"))) {
            try {
                Long bookingId = Long.parseLong(req.getParameter("bookingId"));
                bookingService.cancelBooking(bookingId);
                req.getSession().setAttribute("flash", "Booking cancelled successfully.");
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");

            } catch (NumberFormatException e) {
                forwardWithError(req, resp, studentId, "Invalid booking ID.");
            } catch (EJBException e) {
                Throwable cause = e.getCause();
                String msg = (cause instanceof IllegalArgumentException)
                        ? "Booking not found." : "Could not cancel this booking.";
                forwardWithError(req, resp, studentId, msg);
            } catch (Exception e) {
                forwardWithError(req, resp, studentId, "An unexpected error occurred.");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/mybookings");
        }
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp,
                                   Long studentId, String msg)
            throws ServletException, IOException {
        try {
            req.setAttribute("bookings", dashboardService.getStudentBookings(studentId));
        } catch (Exception ignored) {}
        req.setAttribute("error", msg);
        req.getRequestDispatcher("/student/mybooking.jsp").forward(req, resp);
    }

    private Long getStudentId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return (s == null) ? null : (Long) s.getAttribute("userId");
    }
}
