package com.ebs.controllers;

import com.ebs.utils.JsonUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/*
 Endpoint:
 PUT /api/admin/complaints/{id}
*/

@WebServlet("/api/admin/complaints/*")
public class UpdateComplaintServlet extends HttpServlet {

    protected void doPut(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        String id = request.getPathInfo().substring(1);

        String json =
                "{"
                        + "\"complaintId\":" + id + ","
                        + "\"status\":\"UPDATED\""
                        + "}";

        JsonUtil.sendJson(response, json);

    }

}