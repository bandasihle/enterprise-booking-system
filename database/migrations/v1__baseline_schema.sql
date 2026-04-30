-- ============================================================
-- EBS UNIFIED MASTER SCHEMA (Admin + Lecturer Features)
-- Merges Admin columns (suspensions, complaints) with 
-- Lecturer tables (Joined Inheritance, blocks, OTPs)
-- ============================================================

DROP DATABASE IF EXISTS ebs_db;
CREATE DATABASE ebs_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ebs_db;

-- ── 1. USERS (Base Table) ────────────────────────────────────
CREATE TABLE users (
    id                 BIGINT       NOT NULL AUTO_INCREMENT,
    full_name          VARCHAR(255) NOT NULL,
    email              VARCHAR(255) NOT NULL UNIQUE,
    password           VARCHAR(255) NOT NULL,
    role               VARCHAR(31)  NOT NULL,          
    is_banned          TINYINT(1)   NOT NULL DEFAULT 0,
    is_suspended       TINYINT(1)   NOT NULL DEFAULT 0, -- ADMIN FEATURE
    suspended_until    DATETIME     NULL,               -- ADMIN FEATURE
    cancellation_count INT          NOT NULL DEFAULT 0,
    ban_expiry         DATETIME     NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ── 2. ADMINS (Child Table) ──────────────────────────────────
-- Prevents JPA crash when loading Admin users
CREATE TABLE admin (
    id              BIGINT       NOT NULL,
    clearance_level VARCHAR(50)  DEFAULT 'SYSTEM_ADMIN',
    last_audit_date DATETIME     NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_admin_user FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 3. STUDENTS (Child Table) ────────────────────────────────
CREATE TABLE students (
    id             BIGINT       NOT NULL,
    student_number VARCHAR(255) NOT NULL UNIQUE,
    course         VARCHAR(255) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_students_user FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 4. LECTURERS (Child Table) ───────────────────────────────
CREATE TABLE lecturers (
    id           BIGINT       NOT NULL,
    staff_number VARCHAR(255) NOT NULL UNIQUE,
    department   VARCHAR(255) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_lecturers_user FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 5. LABS ──────────────────────────────────────────────────
CREATE TABLE labs (
    id        BIGINT       NOT NULL AUTO_INCREMENT,
    lab_name  VARCHAR(255) NOT NULL,
    building  VARCHAR(255) NOT NULL,
    capacity  INT          NOT NULL,
    status    VARCHAR(50)  DEFAULT 'Active', -- ADMIN FEATURE
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ── 6. SEATS ─────────────────────────────────────────────────
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
CREATE TABLE bookings (
    id         BIGINT      NOT NULL AUTO_INCREMENT,
    user_id    BIGINT      NOT NULL,
    seat_id    BIGINT      NOT NULL,
    start_time DATETIME    NOT NULL,
    end_time   DATETIME    NOT NULL,
    status     VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_bookings_seat FOREIGN KEY (seat_id) REFERENCES seats(id)
) ENGINE=InnoDB;

-- ── 8. COMPLAINTS (Restored Admin Feature) ───────────────────
CREATE TABLE complaints (
    id          BIGINT        NOT NULL AUTO_INCREMENT,
    booking_id  BIGINT        NOT NULL,
    category    VARCHAR(20)   NOT NULL,
    description TEXT          NOT NULL,
    status      VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    resolution  VARCHAR(255)  NULL, -- ADMIN FEATURE
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_complaint_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 9. LECTURER BLOCKS ───────────────────────────────────────
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

-- ── 10. OTP TOKENS ───────────────────────────────────────────
CREATE TABLE otp_tokens (
    id         BIGINT       NOT NULL AUTO_INCREMENT,
    email      VARCHAR(255) NOT NULL,
    token      VARCHAR(255) NOT NULL,
    expires_at DATETIME     NOT NULL,
    used       TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=InnoDB;