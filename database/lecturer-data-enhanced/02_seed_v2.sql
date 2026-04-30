-- ============================================================
-- EBS SEED DATA — FIXED (v2)
-- Fix: Removed the ADMIN user row.
--      There is no Admin.java entity in the project, so JPA
--      has no class mapped to discriminator value "ADMIN".
--      Any query that loads User objects crashes with
--      "Missing class for indicator field value [ADMIN]".
--
-- Run this in MySQL Workbench to repopulate cleanly:
--   1. This script wipes and re-inserts all seed data.
--   2. Do NOT run 01_schema.sql again unless you want to
--      drop the entire database.
-- ============================================================

USE ebs_db;

-- ── Wipe existing data (order matters — FK constraints) ──────
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE lecturer_blocks;
TRUNCATE TABLE bookings;
TRUNCATE TABLE otp_tokens;
TRUNCATE TABLE seats;
TRUNCATE TABLE labs;
TRUNCATE TABLE students;
TRUNCATE TABLE lecturers;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ── USERS ────────────────────────────────────────────────────
-- Only STUDENT and LECTURER — the two entities that exist in code.
-- role must exactly match @DiscriminatorValue on each entity:
--   Student  → 'STUDENT'
--   Lecturer → 'LECTURER'
INSERT INTO users (id, full_name, email, password, role, is_banned, cancellation_count) VALUES
(1, 'Dr. Sipho Nkosi',   'dr.nkosi@ebs.ac.za',  'lecturer123', 'LECTURER', 0, 0),
(2, 'Dr. Amelia Ndlovu', 'dr.ndlovu@ebs.ac.za',  'lecturer123', 'LECTURER', 0, 0),
(3, 'Thabo Mokoena',     't.mokoena@ebs.ac.za',  'student123',  'STUDENT',  0, 0),
(4, 'Lindiwe Dlamini',   'l.dlamini@ebs.ac.za',  'student123',  'STUDENT',  0, 0),
(5, 'Mpho Khumalo',      'm.khumalo@ebs.ac.za',  'student123',  'STUDENT',  0, 0);

-- ── LECTURERS ────────────────────────────────────────────────
INSERT INTO lecturers (id, staff_number, department) VALUES
(1, 'STAFF-0001', 'Computer Science'),
(2, 'STAFF-0002', 'Information Technology');

-- ── STUDENTS ─────────────────────────────────────────────────
INSERT INTO students (id, student_number, course) VALUES
(3, 'ST-20230001', 'Bachelor of ICT'),
(4, 'ST-20230002', 'Bachelor of ICT'),
(5, 'ST-20230003', 'Diploma in IT');

-- ── LABS ─────────────────────────────────────────────────────
INSERT INTO labs (id, lab_name, building, capacity) VALUES
(1, 'LG02 Computer Lab',  'ICT Block',  36),
(2, 'ICT Lab 2',          'ICT Block',  30),
(3, 'ICT Lab 3',          'ICT Block',  40),
(4, 'Seminar Room A',     'Main Block', 50),
(5, 'Seminar Room B',     'Main Block', 45),
(6, 'Library Study Lab',  'Library',    20);

-- ── SEATS — Lab 1 (36 PCs) ───────────────────────────────────
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(1,'PC-01',1,0),(1,'PC-02',1,0),(1,'PC-03',1,0),(1,'PC-04',1,0),(1,'PC-05',1,0),
(1,'PC-06',1,0),(1,'PC-07',1,0),(1,'PC-08',1,0),(1,'PC-09',1,0),(1,'PC-10',1,0),
(1,'PC-11',1,0),(1,'PC-12',1,0),(1,'PC-13',1,0),(1,'PC-14',1,0),(1,'PC-15',1,0),
(1,'PC-16',1,0),(1,'PC-17',1,0),(1,'PC-18',1,0),(1,'PC-19',1,0),(1,'PC-20',1,0),
(1,'PC-21',1,0),(1,'PC-22',1,0),(1,'PC-23',1,0),(1,'PC-24',1,0),(1,'PC-25',1,0),
(1,'PC-26',1,0),(1,'PC-27',1,0),(1,'PC-28',1,0),(1,'PC-29',1,0),(1,'PC-30',1,0),
(1,'PC-31',1,0),(1,'PC-32',1,0),(1,'PC-33',1,0),(1,'PC-34',1,0),(1,'PC-35',1,0),
(1,'PC-36',1,0);

-- ── SEATS — Lab 2 (30 PCs) ───────────────────────────────────
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(2,'PC-01',1,0),(2,'PC-02',1,0),(2,'PC-03',1,0),(2,'PC-04',1,0),(2,'PC-05',1,0),
(2,'PC-06',1,0),(2,'PC-07',1,0),(2,'PC-08',1,0),(2,'PC-09',1,0),(2,'PC-10',1,0),
(2,'PC-11',1,0),(2,'PC-12',1,0),(2,'PC-13',1,0),(2,'PC-14',1,0),(2,'PC-15',1,0),
(2,'PC-16',1,0),(2,'PC-17',1,0),(2,'PC-18',1,0),(2,'PC-19',1,0),(2,'PC-20',1,0),
(2,'PC-21',1,0),(2,'PC-22',1,0),(2,'PC-23',1,0),(2,'PC-24',1,0),(2,'PC-25',1,0),
(2,'PC-26',1,0),(2,'PC-27',1,0),(2,'PC-28',1,0),(2,'PC-29',1,0),(2,'PC-30',1,0);

-- ── SEATS — Lab 3 (40 PCs) ───────────────────────────────────
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(3,'PC-01',1,0),(3,'PC-02',1,0),(3,'PC-03',1,0),(3,'PC-04',1,0),(3,'PC-05',1,0),
(3,'PC-06',1,0),(3,'PC-07',1,0),(3,'PC-08',1,0),(3,'PC-09',1,0),(3,'PC-10',1,0),
(3,'PC-11',1,0),(3,'PC-12',1,0),(3,'PC-13',1,0),(3,'PC-14',1,0),(3,'PC-15',1,0),
(3,'PC-16',1,0),(3,'PC-17',1,0),(3,'PC-18',1,0),(3,'PC-19',1,0),(3,'PC-20',1,0),
(3,'PC-21',1,0),(3,'PC-22',1,0),(3,'PC-23',1,0),(3,'PC-24',1,0),(3,'PC-25',1,0),
(3,'PC-26',1,0),(3,'PC-27',1,0),(3,'PC-28',1,0),(3,'PC-29',1,0),(3,'PC-30',1,0),
(3,'PC-31',1,0),(3,'PC-32',1,0),(3,'PC-33',1,0),(3,'PC-34',1,0),(3,'PC-35',1,0),
(3,'PC-36',1,0),(3,'PC-37',1,0),(3,'PC-38',1,0),(3,'PC-39',1,0),(3,'PC-40',1,0);

-- ── SEATS — Seminar/Study rooms (1 full-room seat each) ──────
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(4,'FULL-ROOM',1,0),
(5,'FULL-ROOM',1,0),
(6,'FULL-ROOM',1,0);

-- ── DEMO LECTURER BLOCKS ─────────────────────────────────────
-- lecturer_id 1 = Dr. Nkosi, lecturer_id 2 = Dr. Ndlovu
INSERT INTO lecturer_blocks (lecturer_id, lab_id, module_code, reason, start_time, end_time, status, created_at) VALUES
(1, 1, 'BICT112', 'Intro to Networking — practical session',      '2026-05-05 08:00:00', '2026-05-05 10:00:00', 'CONFIRMED', NOW()),
(1, 2, 'BICT211', 'Database Systems — exam preparation',          '2026-05-06 10:00:00', '2026-05-06 12:00:00', 'CONFIRMED', NOW()),
(2, 3, 'BICT301', 'Software Engineering — group project session', '2026-05-07 13:00:00', '2026-05-07 15:00:00', 'CONFIRMED', NOW());

-- ── CONFIRM after running ─────────────────────────────────────
SELECT id, full_name, email, role FROM users ORDER BY id;
-- Expected: 5 rows — 2 LECTURER, 3 STUDENT (no ADMIN)

SELECT lab_id, COUNT(*) AS seats FROM seats GROUP BY lab_id ORDER BY lab_id;
-- Expected: 1→36, 2→30, 3→40, 4→1, 5→1, 6→1
