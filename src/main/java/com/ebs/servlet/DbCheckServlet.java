package com.ebs.servlet;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;

/**
 * GET /db-check
 *
 * Lightweight database connectivity check servlet.
 * Place this in com.ebs.servlet alongside LoginServlet.
 *
 * HOW TO USE:
 *   1. Add this file to src/main/java/com/ebs/servlet/
 *   2. Deploy the WAR
 *   3. Open: http://localhost:8080/EnterpriseBookingSystem/db-check
 *
 * WHAT IT TESTS:
 *   - EntityManager injection (JPA pool is working)
 *   - A live SQL query against the users table
 *   - Returns a plain-text report showing row counts
 *
 * REMOVE THIS FILE before any production deployment.
 */
@WebServlet("/db-check")
public class DbCheckServlet extends HttpServlet {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Override
    @Transactional
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        out.println("=== EBS Database Connection Check ===");
        out.println("Timestamp: " + LocalDateTime.now());
        out.println();

        // Check 1: EntityManager injected?
        if (em == null) {
            out.println("❌ FAIL — EntityManager is NULL");
            out.println("   Cause: JPA persistence unit 'ebs-PU' not found.");
            out.println("   Fix:   Confirm jdbc/ebsDS JDBC Resource exists in GlassFish (localhost:4848).");
            resp.setStatus(500);
            return;
        }
        out.println("✅ EntityManager injected successfully");
        out.println();

        // Check 2: Can we query the DB?
        try {
            Long userCount = em.createQuery("SELECT COUNT(u) FROM User u", Long.class)
                               .getSingleResult();
            out.println("✅ Database reachable — users table has " + userCount + " row(s)");

            Long labCount = em.createQuery("SELECT COUNT(l) FROM Lab l", Long.class)
                              .getSingleResult();
            out.println("✅ Labs table has " + labCount + " row(s)");

            Long seatCount = em.createQuery("SELECT COUNT(s) FROM Seat s", Long.class)
                               .getSingleResult();
            out.println("✅ Seats table has " + seatCount + " row(s)");

            out.println();
            out.println("=== User list ===");
            // Use native SQL — avoids EclipseLink crashing on unknown
            // discriminator values (e.g. 'ADMIN' with no Admin.java entity)
            em.createNativeQuery("SELECT id, full_name, email, role FROM users ORDER BY id")
              .getResultList()
              .forEach(r -> {
                  Object[] row = (Object[]) r;
                  out.println("  id=" + row[0]
                      + "  role=" + row[3]
                      + "  email=" + row[2]
                      + "  name=" + row[1]);
              });

            out.println();
            out.println("=== RESULT: DATABASE CONNECTION OK ===");
            resp.setStatus(200);

        } catch (Exception e) {
            out.println("❌ FAIL — Could not query database:");
            out.println("   " + e.getMessage());
            out.println();
            out.println("Common causes:");
            out.println("  1. MySQL is not running — start MySQL from Services panel");
            out.println("  2. ebs_db does not exist — run 01_schema.sql in MySQL Workbench");
            out.println("  3. GlassFish pool misconfigured — check ebsPool Ping in localhost:4848");
            out.println("  4. Wrong database name/host/password in the JDBC pool properties");
            resp.setStatus(500);
        }
    }
}
