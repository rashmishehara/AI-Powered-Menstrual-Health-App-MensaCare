-- SQL Dump for Period Tracking App Database
-- Database: period_tracking_app

CREATE DATABASE IF NOT EXISTS period_tracking_app;
USE period_tracking_app;

-- 1. Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    last_menstrual_day DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Cycles Table
CREATE TABLE cycles (
    cycle_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    expected_period_date DATE NOT NULL,
    actual_period_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3. Symptoms Table (updated with real fields + correct data types)
CREATE TABLE symptoms (
    symptom_id INT AUTO_INCREMENT PRIMARY KEY,
    cycle_id INT NOT NULL,
    user_id INT NOT NULL,
    symptom_date DATE NOT NULL,

    -- Lifestyle Symptoms
    sleep_hours INT,
    weight_changes ENUM('Loss', 'Gain', 'Normal'),
    smoking_alcohol BOOLEAN,
    birth_control_use BOOLEAN,
    hair_loss BOOLEAN,

    -- Physical Symptoms
    headache TINYINT,
    lower_back_pain TINYINT,
    pain_during_sex TINYINT,
    flow TINYINT,
    pelvic_pain TINYINT,

    -- Other Symptoms
    acne BOOLEAN,
    fatigue BOOLEAN,
    bloating BOOLEAN,
    nausea BOOLEAN,
    dizziness BOOLEAN,
    hot_flashes BOOLEAN,

    -- Mental Symptoms
    stress TINYINT,
    irritability BOOLEAN,
    forgetfulness BOOLEAN,
    depression BOOLEAN,
    tension BOOLEAN,
    social_withdrawal BOOLEAN,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cycle_id) REFERENCES cycles(cycle_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 4. Notes Table
CREATE TABLE notes (
    note_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    cycle_id INT NULL,
    note_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (cycle_id) REFERENCES cycles(cycle_id) ON DELETE SET NULL
);

-- 5. Notifications Table
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
