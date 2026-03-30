package com.ebs.controllers;

import com.ebs.services.ComplaintService;
import com.ebs.utils.JsonUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/*
 Endpoint:
 GET /api/admin/complaints
*/

@WebServlet("/api/admin/complaints")
public class ComplaintServlet extends HttpServlet {

    ComplaintService service = new ComplaintService();

    /**
     *
     * @param request
     * @param response
     * @throws IOException
     */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        int complaints = service.getComplaintCount();

        String json =
                "{"
                        + "\"totalComplaints\":" + complaints
                        + "}";

        JsonUtil.sendJson(response, json);

    }

}