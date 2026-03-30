package com.ebs.controllers;

import com.ebs.services.AdminService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;

/*
 This servlet handles requests for:

 GET /api/admin/dashboard

 It returns statistics for the admin dashboard.
*/

@WebServlet("/api/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");

        PrintWriter out = response.getWriter();

        // Call service layer
        int students = adminService.getStudentCount();

        /*
          Create JSON response
         */

        String json =
                "{ \"todayStats\": {"
                        + "\"activeStudents\":" + students
                        + "}}";


        out.print(json);

    }
}