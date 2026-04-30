-- ============================================================
-- EBS — DATABASE CONNECTION VERIFICATION
-- Run each block in MySQL Workbench to confirm the DB is
-- correctly connected to the NetBeans/GlassFish webapp.
-- ============================================================

USE ebs_db;

-- ── STEP 1: Confirm all tables exist ─────────────────────────
SELECT
    table_name,
    table_rows        AS approx_rows,
    create_time
FROM information_schema.tables
WHERE table_schema = 'ebs_db'
ORDER BY table_name;
-- Expected tables: bookings, labs, lecturer_blocks,
--                  lecturers, otp_tokens, seats, students, users

-- ── STEP 2: Confirm user rows ────────────────────────────────
SELECT id, full_name, email, role, is_banned
FROM ebs_db.users
ORDER BY id;
-- Expected: 6 rows — 1 ADMIN, 2 LECTURER, 3 STUDENT

-- ── STEP 3: Confirm seat counts per lab ──────────────────────
SELECT
    l.lab_name,
    l.building,
    COUNT(s.id) AS total_seats,
    SUM(s.is_available) AS available_seats
FROM labs l
LEFT JOIN seats s ON s.lab_id = l.id
GROUP BY l.id, l.lab_name, l.building
ORDER BY l.id;
-- Expected: Lab1=36, Lab2=30, Lab3=40, Labs4-6=1 each

-- ── STEP 4: Confirm lecturer blocks ──────────────────────────
SELECT
    lb.id,
    u.full_name   AS lecturer,
    l.lab_name,
    lb.module_code,
    lb.start_time,
    lb.end_time,
    lb.status
FROM lecturer_blocks lb
JOIN users u ON u.id = lb.lecturer_id
JOIN labs  l ON l.id = lb.lab_id
ORDER BY lb.start_time;
-- Expected: 3 rows

-- ── STEP 5: JDBC connection test (run in GlassFish terminal) ─
-- After deploying the WAR, open a browser and go to:
--   http://localhost:8080/EnterpriseBookingSystem/db-check
--
-- If you get a 404 → add the DbCheckServlet (see below).
-- If GlassFish logs show "Ping Succeeded" but the app still
-- crashes with NullPointerException on EntityManager → the
-- JNDI name in persistence.xml doesn't match GlassFish.
--
-- Confirm JNDI name:
--   GlassFish Admin Console (localhost:4848)
--   → Resources → JDBC → JDBC Resources
--   → confirm name is exactly:  jdbc/ebsDS
--   (must match <jta-data-source>jdbc/ebsDS</jta-data-source>
--    in persistence.xml)

-- ── STEP 6: Verify LoginServlet can reach the DB ─────────────
-- Open browser: http://localhost:8080/EnterpriseBookingSystem/login
-- POST with:  email=dr.nkosi@ebs.ac.za  password=lecturer123
-- Expected:   redirects to /lecturer/dashboard  (not back to login)
-- If redirects back with ?error=login → DB connected but password
--   mismatch. Check the user row: SELECT password FROM users WHERE id=2;
--   It should read exactly:  lecturer123  (plain text, no colon)

-- ── STEP 7: Quick live insert test ───────────────────────────
-- Run this in Workbench, then immediately check GlassFish logs
-- for EclipseLink SQL output — proves the JPA pool is live:
INSERT INTO otp_tokens (email, token, expires_at, used)
VALUES ('test@ebs.ac.za', '999999', DATE_ADD(NOW(), INTERVAL 10 MINUTE), 0);

-- Confirm it inserted:
SELECT * FROM otp_tokens WHERE email = 'test@ebs.ac.za';

-- Clean up:
DELETE FROM otp_tokens WHERE email = 'test@ebs.ac.za';
