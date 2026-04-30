-- ============================================================
-- EBS Migration: v6__admin_and_schema_updates.sql
-- Description: Applies missing UI-dependent columns across 
-- complaints, users, and labs, and seeds master Admin accounts.
-- ============================================================

USE ebs_db;

-- ─────────────────────────────────────────────────────────────
-- STEP 1 · SCHEMA UPDATES
-- Adds the columns required for the Admin Dashboard to function
-- ─────────────────────────────────────────────────────────────

-- 1A. Add resolution tracking to complaints
ALTER TABLE complaints 
ADD COLUMN resolution VARCHAR(255) NULL;

-- 1B. Add suspension tracking to users
ALTER TABLE users 
ADD COLUMN is_suspended BOOLEAN DEFAULT FALSE,
ADD COLUMN suspended_until DATETIME NULL;

-- 1C. Add operational status to labs
ALTER TABLE labs 
ADD COLUMN status VARCHAR(50) DEFAULT 'Active';

-- ─────────────────────────────────────────────────────────────
-- STEP 2 · ADMIN SEED DATA
-- Injects the default system administrators safely.
-- ON DUPLICATE KEY ensures this script won't crash if run twice.
-- ─────────────────────────────────────────────────────────────

INSERT INTO users (
    EMAIL, 
    PASSWORD, 
    full_name, 
    role, 
    is_banned, 
    cancellation_count
)
VALUES
    (
        '240706064@ump.ac.za',
        'VT3BFdAwSC0QdnfoIq0ZdQ==:9cJxoa4RscfTrjk0QgZ1NKLISdikDGsX3cA9tyFroE4=',
        'Admin User',
        'ADMIN',
        0, 
        0
    ),
    (
        'admin@ebs.ac.za',
        'iK5bST0rTnke2HdVt7xYhw==:j6yNXuTMsH2SM3hIxlYtdGAMoQFN3NhcfQ9TJ/w7AU4=',
        'System Admin',
        'ADMIN',
        0, 
        0
    )
ON DUPLICATE KEY UPDATE 
    role = VALUES(role),
    is_banned = 0;

    USE ebs_db;

-- Find the users we just created and link their IDs into the admin table
INSERT IGNORE INTO admin (ID, clearance_level)
SELECT ID, 'SYSTEM_ADMIN' 
FROM users 
WHERE role = 'ADMIN';