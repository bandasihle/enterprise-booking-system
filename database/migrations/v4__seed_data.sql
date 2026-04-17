-- 1. CLEAR EXISTING DATA (To prevent duplicate ID errors)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE seats;
TRUNCATE TABLE labs;
SET FOREIGN_KEY_CHECKS = 1;

-- 2. CREATE ALL VENUES
INSERT INTO labs (id, lab_name, building, capacity) VALUES 
(1, 'Lab 1 — LG02', 'ICT Block', 36),
(2, 'Lab 2 — ICT Computer Lab', 'ICT Block', 30),
(3, 'Lab 3 — ICT Computer Lab', 'ICT Block', 40),
(4, 'Lab 4 — Seminar Room A', 'Main Block', 50),
(5, 'Lab 5 — Seminar Room B', 'Main Block', 45),
(6, 'Lab 6 — Study Room', 'Library Block', 20);

-- 3. CREATE SEATS FOR LAB 1 (36 PCs)
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(1, 'PC-01', 1, 0), (1, 'PC-02', 1, 0), (1, 'PC-03', 1, 0), (1, 'PC-04', 1, 0), (1, 'PC-05', 1, 0),
(1, 'PC-06', 1, 0), (1, 'PC-07', 1, 0), (1, 'PC-08', 1, 0), (1, 'PC-09', 1, 0), (1, 'PC-10', 1, 0),
(1, 'PC-11', 1, 0), (1, 'PC-12', 1, 0), (1, 'PC-13', 1, 0), (1, 'PC-14', 1, 0), (1, 'PC-15', 1, 0),
(1, 'PC-16', 1, 0), (1, 'PC-17', 1, 0), (1, 'PC-18', 1, 0), (1, 'PC-19', 1, 0), (1, 'PC-20', 1, 0),
(1, 'PC-21', 1, 0), (1, 'PC-22', 1, 0), (1, 'PC-23', 1, 0), (1, 'PC-24', 1, 0), (1, 'PC-25', 1, 0),
(1, 'PC-26', 1, 0), (1, 'PC-27', 1, 0), (1, 'PC-28', 1, 0), (1, 'PC-29', 1, 0), (1, 'PC-30', 1, 0),
(1, 'PC-31', 1, 0), (1, 'PC-32', 1, 0), (1, 'PC-33', 1, 0), (1, 'PC-34', 1, 0), (1, 'PC-35', 1, 0),
(1, 'PC-36', 1, 0);

-- 4. CREATE SEATS FOR LAB 2 (30 PCs)
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(2, 'PC-01', 1, 0), (2, 'PC-02', 1, 0), (2, 'PC-03', 1, 0), (2, 'PC-04', 1, 0), (2, 'PC-05', 1, 0),
(2, 'PC-06', 1, 0), (2, 'PC-07', 1, 0), (2, 'PC-08', 1, 0), (2, 'PC-09', 1, 0), (2, 'PC-10', 1, 0),
(2, 'PC-11', 1, 0), (2, 'PC-12', 1, 0), (2, 'PC-13', 1, 0), (2, 'PC-14', 1, 0), (2, 'PC-15', 1, 0),
(2, 'PC-16', 1, 0), (2, 'PC-17', 1, 0), (2, 'PC-18', 1, 0), (2, 'PC-19', 1, 0), (2, 'PC-20', 1, 0),
(2, 'PC-21', 1, 0), (2, 'PC-22', 1, 0), (2, 'PC-23', 1, 0), (2, 'PC-24', 1, 0), (2, 'PC-25', 1, 0),
(2, 'PC-26', 1, 0), (2, 'PC-27', 1, 0), (2, 'PC-28', 1, 0), (2, 'PC-29', 1, 0), (2, 'PC-30', 1, 0);

-- 5. CREATE SEATS FOR LAB 3 (40 PCs)
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(3, 'PC-01', 1, 0), (3, 'PC-02', 1, 0), (3, 'PC-03', 1, 0), (3, 'PC-04', 1, 0), (3, 'PC-05', 1, 0),
(3, 'PC-06', 1, 0), (3, 'PC-07', 1, 0), (3, 'PC-08', 1, 0), (3, 'PC-09', 1, 0), (3, 'PC-10', 1, 0),
(3, 'PC-11', 1, 0), (3, 'PC-12', 1, 0), (3, 'PC-13', 1, 0), (3, 'PC-14', 1, 0), (3, 'PC-15', 1, 0),
(3, 'PC-16', 1, 0), (3, 'PC-17', 1, 0), (3, 'PC-18', 1, 0), (3, 'PC-19', 1, 0), (3, 'PC-20', 1, 0),
(3, 'PC-21', 1, 0), (3, 'PC-22', 1, 0), (3, 'PC-23', 1, 0), (3, 'PC-24', 1, 0), (3, 'PC-25', 1, 0),
(3, 'PC-26', 1, 0), (3, 'PC-27', 1, 0), (3, 'PC-28', 1, 0), (3, 'PC-29', 1, 0), (3, 'PC-30', 1, 0),
(3, 'PC-31', 1, 0), (3, 'PC-32', 1, 0), (3, 'PC-33', 1, 0), (3, 'PC-34', 1, 0), (3, 'PC-35', 1, 0),
(3, 'PC-36', 1, 0), (3, 'PC-37', 1, 0), (3, 'PC-38', 1, 0), (3, 'PC-39', 1, 0), (3, 'PC-40', 1, 0);

-- 6. CREATE "VENUE" SEATS FOR SEMINAR & STUDY ROOMS (Labs 4, 5, 6)
-- Since you book these as whole rooms rather than individual chairs
INSERT INTO seats (lab_id, seat_number, is_available, version) VALUES
(4, 'ENTIRE-VENUE', 1, 0),
(5, 'ENTIRE-VENUE', 1, 0),
(6, 'ENTIRE-VENUE', 1, 0);