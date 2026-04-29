package com.ebs.rest;

import com.ebs.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.ws.rs.core.Context;
import com.ebs.service.AuthService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AuthResource {
    
   // Add this near the top of your class with your other injections
    @Context
    private HttpServletRequest httpRequest;

    @Inject
    public AuthService authService;

    // --- Updated Data Records ---
    public record RegisterInitRequest(String email, String studentNo) {}
    public record RegisterRequest(String studentNo, String fullName, String email, String password, String otpCode, String role) {}
    public record LoginRequest(String email, String password) {}

    /**
     * POST /api/auth/register/init
     * Checks if user exists and sends OTP to email.
     */
    @POST
    @Path("/register/init")
    public Response initRegistration(RegisterInitRequest request) {
        try {
            authService.initRegistration(request.email(), request.studentNo());
            return Response.ok("{\"message\": \"OTP sent to email.\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * POST /api/auth/register
     * Verifies OTP and saves user to database.
     */
    @POST
    @Path("/register")
    public Response register(RegisterRequest request) {
        try {
            authService.verifyOtpAndRegister(request);
            return Response.status(Response.Status.CREATED)
                    .entity("{\"message\": \"User successfully registered!\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * POST /api/auth/login
     * Single-step login. Returns JWT immediately.
     */
    @POST
    @Path("/login")
    public Response login(LoginRequest request) {
        try {
            // 1. Authenticate the user and generate the JWT token
            String jwtToken = authService.login(request.email(), request.password());
            
            // 2. Fetch the full User object from the database
            User loggedInUser = authService.getUserByEmail(request.email()); 
            
            // 3. Save the session data so the traditional Servlets know who is logged in
            httpRequest.getSession(true).setAttribute("user", loggedInUser);
            httpRequest.getSession(true).setAttribute("userId", loggedInUser.getId());

            // 4. Read the exact role directly from the entity (e.g., "STUDENT" or "LECTURER")
            String userRole = loggedInUser.getRole().toLowerCase();

            // 5. Send the role and token back to the JavaScript frontend
            return Response.ok("{\"token\": \"" + jwtToken + "\", \"role\": \"" + userRole + "\", \"message\": \"Login successful.\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.UNAUTHORIZED)
                    .entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        }
    }
}