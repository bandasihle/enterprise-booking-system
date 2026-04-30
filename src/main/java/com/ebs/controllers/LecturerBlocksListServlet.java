package com.ebs.controllers;

import com.ebs.util.JsonUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/*
 Endpoint:
 GET /api/lecturer/my-blocks
*/

@WebServlet("/api/lecturer/my-blocks")
public class LecturerBlocksListServlet extends HttpServlet {

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

        String json =
                "{"
                        + "\"blocks\":[]"
                        + "}";

        JsonUtil.sendJson(response, json);

    }

}