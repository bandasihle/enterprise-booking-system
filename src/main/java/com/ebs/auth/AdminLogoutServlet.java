package com.ebs.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;


// This maps the servlet to the URL we linked in the JSP file
@WebServlet("/AdminLogoutServlet")
public class AdminLogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Fetch the current session. The "false" means it won't create a new one if it doesn't exist.
        HttpSession session = request.getSession(false);
        
        // 2. If a session exists, invalidate (destroy) it. This clears the logged-in status.
        if (session != null) {
            session.invalidate(); 
        }
        
        // 3. Redirect the user back to the login page. 
        // Based on your screenshot, the login page is inside /pages/admin/
        String loginPageURL = request.getContextPath() + "/pages/admin/login.html";
        response.sendRedirect(loginPageURL);
    }
}