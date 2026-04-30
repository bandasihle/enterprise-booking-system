-- ============================================================
-- EBS DATABASE SCHEMA — CLEAN REBUILD
-- Derived directly from entity source files (User.java,
-- Student.java, Lecturer.java, Lab.java, Seat.java,
-- Booking.java, OtpToken.java, LecturerBlock.java)
--
-- HOW TO RUN IN MySQL Workbench:
--   File → Open SQL Script → select this file
--   Click the lightning bolt (Execute All) — Ctrl+Shift+Enter
-- ============================================================

-- 1. Drop and recreate the database (clean slate)
DROP DATABASE IF EXISTS ebs_db;
CREATE DATABASE ebs_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ebs_db;

-- ── 2. USERS (base table — JOINED inheritance) ───────────────
-- Maps to User.java
-- Discriminator column "role" stores: STUDENT | LECTURER | ADMIN
CREATE TABLE users (
    id                 BIGINT       NOT NULL AUTO_INCREMENT,
    full_name          VARCHAR(255) NOT NULL,
    email              VARCHAR(255) NOT NULL,
    password           VARCHAR(255) NOT NULL,
    role               VARCHAR(31)  NOT NULL,          -- JPA discriminator
    is_banned          TINYINT(1)   NOT NULL DEFAULT 0,
    cancellation_count INT          NOT NULL DEFAULT 0,
    ban_expiry         DATETIME     NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

-- ── 3. STUDENTS (joined child of users) ──────────────────────
-- Maps to Student.java — @DiscriminatorValue("STUDENT")
CREATE TABLE students (
    id             BIGINT       NOT NULL,
    student_number VARCHAR(255) NOT NULL,
    course         VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_student_number (student_number),
    CONSTRAINT fk_students_user FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 4. LECTURERS (joined child of users) ─────────────────────
-- Maps to Lecturer.java — @DiscriminatorValue("LECTURER")
CREATE TABLE lecturers (
    id           BIGINT       NOT NULL,
    staff_number VARCHAR(255) NOT NULL,
    department   VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_staff_number (staff_number),
    CONSTRAINT fk_lecturers_user FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 5. LABS ──────────────────────────────────────────────────
-- Maps to Lab.java
CREATE TABLE labs (
    id        BIGINT       NOT NULL AUTO_INCREMENT,
    lab_name  VARCHAR(255) NOT NULL,
    building  VARCHAR(255) NOT NULL,
    capacity  INT          NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ── 6. SEATS ─────────────────────────────────────────────────
-- Maps to Seat.java — has @Version for optimistic locking
CREATE TABLE seats (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    seat_number  VARCHAR(255) NOT NULL,
    is_available TINYINT(1)   NOT NULL DEFAULT 1,
    lab_id       BIGINT       NOT NULL,
    version      BIGINT                DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT fk_seats_lab FOREIGN KEY (lab_id) REFERENCES labs(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 7. BOOKINGS ──────────────────────────────────────────────
-- Maps to Booking.java — status is an @Enumerated(STRING) enum
-- Valid status values: PENDING | CONFIRMED | CANCELLED | COMPLETED | NO_SHOW
CREATE TABLE bookings (
    id         BIGINT      NOT NULL AUTO_INCREMENT,
    user_id    BIGINT      NOT NULL,
    seat_id    BIGINT      NOT NULL,
    start_time DATETIME    NOT NULL,
    end_time   DATETIME    NOT NULL,
    status     VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at DATETIME    NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_bookings_seat FOREIGN KEY (seat_id) REFERENCES seats(id)
) ENGINE=InnoDB;

-- ── 8. OTP TOKENS ────────────────────────────────────────────
-- Maps to OtpToken.java
CREATE TABLE otp_tokens (
    id         BIGINT       NOT NULL AUTO_INCREMENT,
    email      VARCHAR(255) NOT NULL,
    token      VARCHAR(255) NOT NULL,
    expires_at DATETIME     NOT NULL,
    used       TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ── 9. LECTURER BLOCKS ───────────────────────────────────────
-- Maps to LecturerBlock.java (new entity added for lecturer module)
-- Represents a full-lab reservation made by a lecturer
CREATE TABLE lecturer_blocks (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    lecturer_id BIGINT       NOT NULL,
    lab_id      BIGINT       NOT NULL,
    module_code VARCHAR(20)  NOT NULL,
    reason      VARCHAR(500) NULL,
    start_time  DATETIME     NOT NULL,
    end_time    DATETIME     NOT NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'CONFIRMED',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_blocks_lecturer FOREIGN KEY (lecturer_id) REFERENCES users(id),
    CONSTRAINT fk_blocks_lab      FOREIGN KEY (lab_id)      REFERENCES labs(id)
) ENGINE=InnoDB;

-- ── 10. INDEXES (performance) ────────────────────────────────
CREATE INDEX idx_bookings_user       ON bookings(user_id);
CREATE INDEX idx_bookings_seat       ON bookings(seat_id);
CREATE INDEX idx_bookings_start      ON bookings(start_time, status);
CREATE INDEX idx_seats_lab           ON seats(lab_id);
CREATE INDEX idx_otp_email           ON otp_tokens(email);
CREATE INDEX idx_blocks_lecturer     ON lecturer_blocks(lecturer_id);
CREATE INDEX idx_blocks_lab_time     ON lecturer_blocks(lab_id, start_time, end_time);

-- ── Verification query — run this after to confirm all tables ─
-- SELECT table_name, table_rows
-- FROM information_schema.tables
-- WHERE table_schema = 'ebs_db'
-- ORDER BY table_name;
