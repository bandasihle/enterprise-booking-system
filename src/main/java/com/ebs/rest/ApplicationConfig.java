package com.ebs.rest;


import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

/**
 * JAX-RS Application config.
 * All REST endpoints are accessible under /api/*
 */
@ApplicationPath("/api")
public class ApplicationConfig extends Application {
    // Jakarta EE auto-discovers all @Path annotated classes
}
