-- ======================================================
-- Lab 2: Advanced DDL Operations (macOS safe version)
-- ======================================================

-- ================================
-- TASK 1: Multiple Database Management
-- ================================

-- Выполнять из базы postgres

-- 1) Main DB
DROP DATABASE IF EXISTS university_main;
CREATE DATABASE university_main
    WITH OWNER = postgres
    ENCODING = 'UTF8';

-- 2) Archive DB
DROP DATABASE IF EXISTS university_archive;
CREATE DATABASE university_archive
    WITH ENCODING = 'UTF8'
    CONNECTION LIMIT = 50;

-- 3) Test DB
DROP DATABASE IF EXISTS university_test;
CREATE DATABASE university_test
    WITH ENCODING = 'UTF8'
    CONNECTION LIMIT = 10;

-- 4) Backup DB
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'university_backup'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS university_backup;
CREATE DATABASE university_backup
    WITH ENCODING = 'UTF8';

-- ================================
-- TASK 2: Create Tables in university_main
-- ================================

-- Переключись в DataGrip на university_main

-- Students
CREATE TABLE IF NOT EXISTS students(
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    middle_name VARCHAR(30),
    email VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(3,2) DEFAULT 0.00,
    is_active BOOLEAN,
    graduation_year SMALLINT,
    student_status VARCHAR(20) DEFAULT 'ACTIVE',
    advisor_id INTEGER
);

-- Professors
CREATE TABLE IF NOT EXISTS professors(
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    hire_date DATE,
    salary NUMERIC(20,2),
    is_tenured BOOLEAN DEFAULT FALSE,
    years_experience SMALLINT,
    department_code CHAR(5),
    research_area TEXT,
    last_promotion_date DATE,
    department_id INTEGER
);

-- Courses
CREATE TABLE IF NOT EXISTS courses(
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(10),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT DEFAULT 3,
    max_enrollment INTEGER,
    course_fee NUMERIC(10,2),
    is_online BOOLEAN,
    created_at TIMESTAMP,
    prerequisite_course_id INTEGER,
    difficulty_level SMALLINT,
    lab_required BOOLEAN DEFAULT FALSE,
    department_id INTEGER
);

-- Class Schedule
CREATE TABLE IF NOT EXISTS class_schedule(
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(30),
    class_date DATE,
    start_time TIME,
    end_time TIME,
    session_type VARCHAR(15),
    room_capacity INTEGER,
    equipment_needed TEXT
);

-- Student Records
CREATE TABLE IF NOT EXISTS student_records(
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_id INTEGER,
    semester VARCHAR(20),
    year INTEGER,
    grade VARCHAR(5),
    attendance_percentage NUMERIC(4,1),
    submission_timestamp TIMESTAMPTZ,
    extra_credit_points NUMERIC(4,1) DEFAULT 0.0,
    final_exam_date DATE
);

-- Departments
CREATE TABLE IF NOT EXISTS departments(
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget NUMERIC(10,2),
    established_year INTEGER
);

-- Grade Scale
CREATE TABLE IF NOT EXISTS grade_scale(
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(4,1),
    max_percentage NUMERIC(4,1),
    gpa_points NUMERIC(3,2),
    description TEXT
);

-- Semester Calendar
CREATE TABLE IF NOT EXISTS semester_calendar(
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN
);

-- Library Books
CREATE TABLE IF NOT EXISTS library_books(
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price NUMERIC(10,2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP
);

-- Student Book Loans
CREATE TABLE IF NOT EXISTS student_book_loans(
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount NUMERIC(10,2),
    loan_status VARCHAR(20)
);

-- ================================
-- TASK 3: Verification Queries
-- ================================

-- Список всех таблиц
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Проверка нескольких таблиц
SELECT * FROM students LIMIT 5;
SELECT * FROM professors LIMIT 5;
SELECT * FROM courses LIMIT 5;
SELECT * FROM departments LIMIT 5;
SELECT * FROM grade_scale LIMIT 5;
SELECT * FROM semester_calendar LIMIT 5;
