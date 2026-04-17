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

@WebServlet("/student/mybookings")
public class MyBookingsServlet extends HttpServlet {

    @EJB
    private StudentDashboardService dashboardService;

    @EJB
    private BookingService bookingService;

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
            LocalDateTime now = LocalDateTime.now();

            List<BookingDTO> upcoming = all.stream()
                    .filter(b ->
                            "CONFIRMED".equalsIgnoreCase(b.getStatus()) &&
                            b.getStartTime() != null &&
                            b.getStartTime().isAfter(now))
                    .collect(Collectors.toList());

            List<BookingDTO> past = all.stream()
                    .filter(b ->
                            ("CONFIRMED".equalsIgnoreCase(b.getStatus())
                             || "COMPLETED".equalsIgnoreCase(b.getStatus())
                             || "NO_SHOW".equalsIgnoreCase(b.getStatus()))
                            && b.getStartTime() != null
                            && !b.getStartTime().isAfter(now))
                    .collect(Collectors.toList());

            List<BookingDTO> cancelled = all.stream()
                    .filter(b -> "CANCELLED".equalsIgnoreCase(b.getStatus()))
                    .collect(Collectors.toList());

            req.setAttribute("bookings", all);
            req.setAttribute("upcomingBookings", upcoming);
            req.setAttribute("pastBookings", past);
            req.setAttribute("cancelledBookings", cancelled);
            req.setAttribute("totalBookings", all.size());

        } catch (Exception e) {
            req.setAttribute("loadError", true);
            e.printStackTrace();
        }

        HttpSession session = req.getSession(false);
        if (session != null) {
            Object flash = session.getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash);
                session.removeAttribute("flash");
            }
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

        String action = req.getParameter("action");

        if ("cancel".equalsIgnoreCase(action)) {
            try {
                Long bookingId = Long.parseLong(req.getParameter("bookingId"));
                bookingService.cancelBooking(bookingId);

                req.getSession().setAttribute("flash", "Booking cancelled successfully.");
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");
                return;

            } catch (NumberFormatException e) {
                req.getSession().setAttribute("flash", "Invalid booking ID.");
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");
                return;

            } catch (EJBException e) {
                Throwable cause = e.getCause();
                String msg = (cause instanceof IllegalArgumentException)
                        ? "Booking not found."
                        : "Could not cancel this booking.";

                req.getSession().setAttribute("flash", msg);
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");
                return;

            } catch (Exception e) {
                req.getSession().setAttribute("flash", "An unexpected error occurred.");
                resp.sendRedirect(req.getContextPath() + "/student/mybookings");
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/student/mybookings");
    }

    private Long getStudentId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session == null) ? null : (Long) session.getAttribute("userId");
    }
}