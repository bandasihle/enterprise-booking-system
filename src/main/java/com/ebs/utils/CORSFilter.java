package com.ebs.utils;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/*
 This filter allows frontend applications
 to access backend APIs.
*/

@WebFilter("/*")
public class CORSFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse res =
                (HttpServletResponse) response;

        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods",
                "GET, POST, PUT, DELETE,OPTIONS");
        res.setHeader("Access-Control-Allow-Headers",
                "Content-Type");

        chain.doFilter(request, response);
    }
}
