package com.ebs.controllers;

import com.ebs.utils.JsonUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/*
 Endpoint:
 POST /api/lecturer/block

 Allows lecturer to block a lab.
*/

@WebServlet("/api/lecturer/block")
public class LecturerBlockServlet extends HttpServlet {

    /**
     *
     * @param request
     * @param response
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws IOException {

        String json =
                "{"
                        + "\"blockId\":1,"
                        + "\"status\":\"CONFIRMED\""
                        + "}";

        JsonUtil.sendJson(response, json);

    }

}