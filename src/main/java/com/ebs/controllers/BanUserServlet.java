package com.ebs.controllers;

import com.ebs.util.JsonUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/*
 Endpoint:
 PUT /api/admin/users/{id}/ban

 Used by admin to ban a user.
*/

@WebServlet("/api/admin/users/*")
public class BanUserServlet extends HttpServlet {

    protected void doPut(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        String path = request.getPathInfo();

        /*
         Example path:
         /12/ban
        */

        String userId = path.split("/")[1];

        String json =
                "{"
                        + "\"userId\":" + userId + ","
                        + "\"banned\":true,"
                        + "\"message\":\"User banned for 24 hours\""
                        + "}";

        JsonUtil.sendJson(response, json);

    }

}
