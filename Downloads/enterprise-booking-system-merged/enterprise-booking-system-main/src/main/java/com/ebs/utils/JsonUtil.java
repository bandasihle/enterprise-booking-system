package com.ebs.utils;

import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;

/*
 Utility class used to send JSON responses
 to the frontend or API testing tools like Postman.
*/
public class JsonUtil {

    public static void sendJson(HttpServletResponse response, String json) {

        try {

            response.setContentType("application/json");

            PrintWriter out = response.getWriter();

            out.print(json);

            out.flush();

        } catch (Exception e) {

            e.printStackTrace();

        }

    }

}
