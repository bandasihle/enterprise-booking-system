USE ebs_db;

CREATE TABLE IF NOT EXISTS complaints (
    id          BIGINT        AUTO_INCREMENT PRIMARY KEY,
    booking_id  BIGINT        NOT NULL,
    category    VARCHAR(20)   NOT NULL,
    description TEXT          NOT NULL,
    status      VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_complaint_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_complaint_booking ON complaints(booking_id);
CREATE INDEX idx_complaint_status  ON complaints(status);
