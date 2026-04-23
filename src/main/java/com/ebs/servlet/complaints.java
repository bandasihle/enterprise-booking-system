package com.ebs.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/submitComplaint")
public class complaints extends HttpServlet {
    
    // FIXED: Added SSL override to prevent GlassFish keystore conflicts
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ebs_db?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "Sihle14!!";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        String bookingIdStr = request.getParameter("bookingId");
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                
                String sql = "INSERT INTO complaints (booking_id, category, description, status) VALUES (?, ?, ?, 'Pending')";
                
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setLong(1, Long.parseLong(bookingIdStr));
                    stmt.setString(2, category);
                    stmt.setString(3, description);
                    
                    stmt.executeUpdate();
                }
            }
            
            // Redirect back with the success banner
            response.sendRedirect(request.getContextPath() + "/student/mybookings?complaint=success");
            
        } catch (Exception e) {
            // IF IT FAILS, PRINT THE EXACT ERROR TO THE BROWSER SCREEN
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<html><body style='font-family: Arial; padding: 20px;'>");
            out.println("<h2 style='color: #dc2626;'>Database Error Occurred</h2>");
            out.println("<p><b>Error Message:</b> " + e.toString() + "</p>");
            out.println("<h3 style='margin-top: 20px;'>Full Stack Trace:</h3>");
            out.println("<pre style='background: #f1f5f9; padding: 15px; border-radius: 8px; overflow-x: auto;'>");
            e.printStackTrace(out);
            out.println("</pre>");
            out.println("<a href='" + request.getContextPath() + "/student/mybookings' style='display: inline-block; margin-top: 20px; padding: 10px 15px; background: #2563eb; color: white; text-decoration: none; border-radius: 8px;'>Go Back</a>");
            out.println("</body></html>");
        }
    }
}