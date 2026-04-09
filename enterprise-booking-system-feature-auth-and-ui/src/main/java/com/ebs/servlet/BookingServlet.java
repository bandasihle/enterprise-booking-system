package com.ebs.servlet;

import com.ebs.dto.LabDTO;
import com.ebs.ejb.BookingService;
import com.ebs.ejb.StudentDashboardService;
import com.ebs.entity.Booking;
import jakarta.ejb.EJB;
import jakarta.ejb.EJBException;
import jakarta.persistence.OptimisticLockException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * GET  /student/booking?labId={id}  — renders seat grid via booking.jsp
 * POST /student/booking             — submits booking; PRG on success
 */
@WebServlet("/student/booking")
public class BookingServlet extends HttpServlet {

    @EJB private StudentDashboardService dashboardService;
    @EJB private BookingService          bookingService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long studentId = getStudentId(req);
        // Redirect to login instead of missing index.html
        if (studentId == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp");
            return;
        }

        String labIdParam = req.getParameter("labId");
        if (labIdParam == null || labIdParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        try {
            Long   labId = Long.parseLong(labIdParam);
            LabDTO lab   = dashboardService.getLabWithSeats(labId);
            req.setAttribute("lab",       lab);
            req.setAttribute("studentId", studentId);
            req.setAttribute("minDate",   LocalDate.now().toString());
            req.setAttribute("today",     LocalDate.now().toString());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        } catch (Exception e) {
            req.setAttribute("loadError", true);
        }

        req.getRequestDispatcher("/student/booking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long studentId = getStudentId(req);
        // Redirect to login instead of missing index.html
        if (studentId == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/student/login.jsp");
            return;
        }

        long   labId   = Long.parseLong(req.getParameter("labId"));
        long   seatId  = Long.parseLong(req.getParameter("seatId"));
        String dateStr = req.getParameter("bookingDate");
        int    startHr = Integer.parseInt(req.getParameter("startHour"));

        LocalDateTime start = LocalDate.parse(dateStr).atTime(startHr, 0);
        LocalDateTime end   = start.plusHours(2);

        try {
            Booking booking = bookingService.bookSeat(studentId, seatId, start, end);

            // PRG — flash message then redirect to My Bookings
            req.getSession().setAttribute("flash",
                    "✅ Booking confirmed! Seat " +
                    booking.getSeat().getSeatNumber() + " is reserved from " +
                    start.toLocalTime() + " – " + end.toLocalTime() + ".");

            resp.sendRedirect(req.getContextPath() + "/student/mybookings");

        } catch (Exception e) {
            Throwable cause = (e instanceof EJBException) ? e.getCause() : e;

            String errorCode;
            if      (cause instanceof SecurityException)       errorCode = "USER_BANNED";
            else if (cause instanceof OptimisticLockException) errorCode = "SEAT_TAKEN";
            else if ("SEAT_TAKEN".equals(cause != null ? cause.getMessage() : "")) errorCode = "SEAT_TAKEN";
            else                                               errorCode = "BOOKING_FAILED";

            try {
                LabDTO lab = dashboardService.getLabWithSeats(labId);
                req.setAttribute("lab", lab);
            } catch (Exception ignored) {}

            req.setAttribute("error",     errorCode);
            req.setAttribute("studentId", studentId);
            req.setAttribute("minDate",   LocalDate.now().toString());
            req.setAttribute("today",     LocalDate.now().toString());
            req.getRequestDispatcher("/student/booking.jsp").forward(req, resp);
        }
    }

    private Long getStudentId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return (s == null) ? null : (Long) s.getAttribute("userId");
    }
}