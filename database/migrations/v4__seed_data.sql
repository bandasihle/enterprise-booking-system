USE ebs_db;

INSERT INTO users (student_no, email, password_hash, role)
VALUES 
('ADM001', 'admin@campus.ac.za', 'hashedpass', 'ADMIN'),
('ST1001', 'student1@campus.ac.za', 'hashedpass', 'STUDENT');

INSERT INTO buildings (name, location, type)
VALUES ('Building C', 'Main Campus', 'ICT_LAB');

INSERT INTO labs (building_id, name, capacity, pc_count)
VALUES (1, 'Lab C4', 60, 60);