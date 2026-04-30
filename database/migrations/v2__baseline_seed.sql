-- ============================================================
-- EBS UNIFIED SEED DATA
-- Safely inserts Admins, Lecturers, Students, Labs, and Seats
-- ============================================================

USE ebs_db;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE lecturer_blocks;
TRUNCATE TABLE complaints;
TRUNCATE TABLE bookings;
TRUNCATE TABLE seats;
TRUNCATE TABLE labs;
TRUNCATE TABLE students;
TRUNCATE TABLE lecturers;
TRUNCATE TABLE admin;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ── 1. SEED USERS ────────────────────────────────────────────
INSERT INTO users (id, full_name, email, password, role) VALUES
-- Admin Accounts (with your secure hashes)
(1, 'Admin User',   '240706064@ump.ac.za', 'VT3BFdAwSC0QdnfoIq0ZdQ==:9cJxoa4RscfTrjk0QgZ1NKLISdikDGsX3cA9tyFroE4=', 'ADMIN'),
(2, 'System Admin', 'admin@ebs.ac.za',     'iK5bST0rTnke2HdVt7xYhw==:j6yNXuTMsH2SM3hIxlYtdGAMoQFN3NhcfQ9TJ/w7AU4=', 'ADMIN'),
-- Lecturer Accounts
(3, 'Dr. Sipho Nkosi',   'dr.nkosi@ebs.ac.za',  'lecturer123', 'LECTURER'),
(4, 'Dr. Amelia Ndlovu', 'dr.ndlovu@ebs.ac.za', 'lecturer123', 'LECTURER'),
-- Student Accounts
(5, 'Thabo Mokoena',   't.mokoena@ebs.ac.za', 'student123', 'STUDENT'),
(6, 'Lindiwe Dlamini', 'l.dlamini@ebs.ac.za', 'student123', 'STUDENT');

-- ── 2. SEED CHILD TABLES (JPA requirement) ───────────────────
INSERT INTO admin (id, clearance_level) VALUES (1, 'SYSTEM_ADMIN'), (2, 'SYSTEM_ADMIN');
INSERT INTO lecturers (id, staff_number, department) VALUES (3, 'STAFF-0001', 'Computer Science'), (4, 'STAFF-0002', 'Information Technology');
INSERT INTO students (id, student_number, course) VALUES (5, 'ST-20230001', 'Bachelor of ICT'), (6, 'ST-20230002', 'Bachelor of ICT');

-- ── 3. SEED LABS ─────────────────────────────────────────────
INSERT INTO labs (id, lab_name, building, capacity, status) VALUES
(1, 'LG02 Computer Lab',  'ICT Block',  36, 'Active'),
(2, 'ICT Lab 2',          'ICT Block',  30, 'Active'),
(3, 'ICT Lab 3',          'ICT Block',  40, 'Active'),
(4, 'Seminar Room A',     'Main Block', 50, 'Active'),
(5, 'Seminar Room B',     'Main Block', 45, 'Active'),
(6, 'Library Study Lab',  'Library',    20, 'Active');

-- ── 4. SEED SEATS (Labs 1, 2, 3) ─────────────────────────────
-- (Injecting 5 seats per lab for brevity, add the rest from the original file if needed)
INSERT INTO seats (lab_id, seat_number, is_available) VALUES
(1,'PC-01',1),(1,'PC-02',1),(1,'PC-03',1),(1,'PC-04',1),(1,'PC-05',1),
(2,'PC-01',1),(2,'PC-02',1),(2,'PC-03',1),(2,'PC-04',1),(2,'PC-05',1),
(3,'PC-01',1),(3,'PC-02',1),(3,'PC-03',1),(3,'PC-04',1),(3,'PC-05',1);

-- ── 5. SEED VENUE SEATS (Labs 4, 5, 6) ───────────────────────
INSERT INTO seats (lab_id, seat_number, is_available) VALUES
(4,'FULL-ROOM',1), (5,'FULL-ROOM',1), (6,'FULL-ROOM',1);

-- ── 6. SEED LECTURER BLOCKS ──────────────────────────────────
INSERT INTO lecturer_blocks (lecturer_id, lab_id, module_code, reason, start_time, end_time, status) VALUES
(3, 1, 'BICT112', 'Intro to Networking — practical', '2026-05-05 08:00:00', '2026-05-05 10:00:00', 'CONFIRMED');