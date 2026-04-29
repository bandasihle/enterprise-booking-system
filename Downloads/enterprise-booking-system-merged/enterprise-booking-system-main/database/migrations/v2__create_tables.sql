USE ebs_db;

CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_no VARCHAR(20) UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('STUDENT','LECTURER','ADMIN') NOT NULL,
    is_banned BOOLEAN DEFAULT FALSE,
    ban_expires_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE buildings (
    building_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(150),
    type ENUM('ICT_LAB','AUDITORIUM','SEMINAR') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE labs (
    lab_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    building_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    pc_count INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (building_id)
        REFERENCES buildings(building_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    lab_id BIGINT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status ENUM('CONFIRMED','CANCELLED','EXPIRED','NO_SHOW') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (lab_id) REFERENCES labs(lab_id)
) ENGINE=InnoDB;