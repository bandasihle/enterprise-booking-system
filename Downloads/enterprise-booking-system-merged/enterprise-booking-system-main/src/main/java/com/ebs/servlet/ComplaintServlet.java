package com.ebs.servlet;

import com.ebs.ejb.ComplaintService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * POST /submitComplaint — handles complaint form submission from My Bookings.
 */
@WebServlet("/submitComplaint")
public class ComplaintServlet extends HttpServlet {

    @EJB
    private ComplaintService complaintService;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/pages/student/login.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String category     = request.getParameter("category");
        String description  = request.getParameter("description");

        if (bookingIdStr == null || category == null
                || description == null || description.isBlank()) {
            session.setAttribute("flash", "❌ Please fill in all complaint fields.");
            response.sendRedirect(request.getContextPath() + "/student/mybookings");
            return;
        }

        try {
            complaintService.submitComplaint(Long.parseLong(bookingIdStr),
                    category, description.trim());
            session.setAttribute("flash", "✅ Complaint submitted. We'll review it shortly.");
        } catch (IllegalStateException e) {
            session.setAttribute("flash", "⚠️ A complaint already exists for this booking.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("flash", "❌ Booking not found.");
        } catch (Exception e) {
            session.setAttribute("flash", "❌ Could not submit complaint. Please try again.");
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/student/mybookings");
    }
}
