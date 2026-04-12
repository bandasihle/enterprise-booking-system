USE ebs_db;

CREATE INDEX idx_user_role ON users(role);
CREATE INDEX idx_booking_user ON bookings(user_id);
CREATE INDEX idx_booking_time ON bookings(start_time, status);