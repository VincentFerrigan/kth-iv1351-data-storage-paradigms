-- postgreSQL
-- file           : procedures.sql
-- Module         : Script for stored procedures, 
--                  used for populating data.
--                  It calls functions in src/functions/functions.sql
-- Description    : Seminar 3, SQL
--                 
-- Course         : kth IV1351 Data Storage Paradigms
-- Author/Student : Elin Blomquist, Vincent Ferrigan
-- maintainer     : eblomq@kth.se, ferrigan@kth.se,

-- PROCEDURES
CREATE OR REPLACE PROCEDURE p_add_student(
    pid CHAR(13),
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    street VARCHAR(100),
    zip VARCHAR(10),
    city VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100)
    ) AS $body$
DECLARE
	new_person_id INT;
BEGIN
	new_person_id := fn_add_person(pid, firstName, lastName, street, zip, city, phone, email);
	INSERT INTO "student" ("person_id") VALUES (new_person_id);
END;
$body$  LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE p_add_instructor(
    pid CHAR(13),
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    street VARCHAR(100),
    zip VARCHAR(10),
    city VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100)
    ) AS $body$
DECLARE
	new_person_id INT;
BEGIN
	new_person_id := fn_add_person(pid, firstName, lastName, street, zip, city, phone, email);
	INSERT INTO "instructor" ("person_id") VALUES (new_person_id);
END;
$body$  LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE p_add_instructor_instruments(
        firstName VARCHAR(100), 
        lastName VARCHAR(100), 
        instrumentNames VARCHAR[])
AS $$
DECLARE
	v_name VARCHAR(100);
BEGIN
    FOREACH v_name IN ARRAY instrumentNames
    LOOP
        INSERT INTO "instructor_instrument" ("instructor_id", "instrument_id")
        VALUES
            ((SELECT "id" FROM "instructor" 
                WHERE "person_id" = (
                    SELECT "id" FROM "person" WHERE "first_name" = firstName AND "last_name" = lastName)),
            (SELECT "id" FROM "instrument" WHERE "name" = v_name));
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Populate the "sibling" table based on students with the same last name and address
CREATE OR REPLACE PROCEDURE p_locate_and_populate_siblings_table()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "sibling" ("sibling_1", "sibling_2")
    SELECT DISTINCT s1."id", s2."id"
    FROM "student" s1
    JOIN "student" s2 ON s1."id" < s2."id"  -- Ensure students are different
    JOIN "person" p1 ON s1."person_id" = p1."id"
    JOIN "person" p2 ON s2."person_id" = p2."id"
    WHERE p1."last_name" = p2."last_name"
      AND p1."street" = p2."street"
      AND p1."zip" = p2."zip"
      AND p1."city" = p2."city"
    ON CONFLICT ("sibling_1", "sibling_2")
    DO NOTHING;  -- Skip insert if conflict occurs
END;
$$;

-- Populate the "student_contact_person" table with parent, guardian, and grandparent relationships
CREATE OR REPLACE PROCEDURE p_add_student_contact_person(
    studentFirstName VARCHAR(100),
    studentLastName VARCHAR(100),
    contactFirstName VARCHAR(100),
    contactLastName VARCHAR(100),
    relation VARCHAR(100)) AS $$
BEGIN
    INSERT INTO "student_contact_person" ("student_id", "contact_person_id", "relation")
    VALUES
        ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = studentFirstName AND "last_name" = studentLastName)),
        (SELECT "id" FROM "contact_person" WHERE "first_name" = contactFirstName AND "last_name" = 'Andersson'), 
        relation);
END;
$$ LANGUAGE plpgsql;


-- Add lessons prices with overloading 
-- TODO Add course types
-- TODO Testing
-- TODO procedurer för att skapa lessons, sessions och student bookings. 
-- TODO funktioner som svara på querisarna
CREATE OR REPLACE PROCEDURE p_add_lesson_price(
    courseType VARCHAR(100),
    price FLOAT4) AS $$
BEGIN
    INSERT INTO "lesson_price_list" ("course_type_id", "price", "valid_start_time", "transaction_start_time")
        VALUES(
            (SELECT "id" FROM "course_type" WHERE "name" = courseType), 
            price, 
            CURRENT_DATE, 
            CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE p_add_lesson_price(
    courseType VARCHAR(100),
    skillLevel VARCHAR(100),
    price FLOAT4) AS $$
BEGIN
    INSERT INTO "lesson_price_list" ("course_type_id", "price", "skill_level_id", "valid_start_time", "transaction_start_time")
        VALUES(
            (SELECT "id" FROM "course_type" WHERE "name" = courseType), 
            price, 
            (SELECT "id" FROM "skill_level" WHERE "name" = skillLevel), 
            CURRENT_DATE, 
            CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE p_add_lesson_price(
    courseType VARCHAR(100),
    skillLevel VARCHAR(100),
    instrumentName VARCHAR(100),
    price FLOAT4) AS $$
BEGIN
    INSERT INTO "lesson_price_list" ("course_type_id", "price", "skill_level_id", "instrument_id", "valid_start_time", "transaction_start_time")
        VALUES(
            (SELECT "id" FROM "course_type" WHERE "name" = courseType), 
            price, 
            (SELECT "id" FROM "skill_level" WHERE "name" = skillLevel), 
            (SELECT "id" FROM "instrument" WHERE "name" = instrumentName), 
            CURRENT_DATE, 
            CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE p_add_rental_price(
    instrumentName VARCHAR(100),
    pricePerMonth FLOAT4) AS $$
BEGIN
    INSERT INTO "rental_price_list" ("instrument_id", "price_per_month", "valid_start_time", "transaction_start_time")
        VALUES(
            (SELECT "id" FROM "instrument" WHERE "name" = instrumentName), 
            pricePerMonth,
            CURRENT_DATE, 
            CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE p_book_individual_lesson (
    student_personal_identity_number CHAR(13),
    instrumentName VARCHAR(100),
    skillLevel VARCHAR(100),
    startTime TIMESTAMP,
    endTime TIMESTAMP
) LANGUAGE plpgsql AS $$
DECLARE
    courseTypeID INT;
    instructorID INT;
    studentID    INT;
    instrumentID INT;
    skillLevelID INT;
    sessionID    INT;
BEGIN
    -- Retrieve the course type ID for 'individual'
    SELECT "id" INTO courseTypeID FROM "course_type" 
    WHERE "name" = 'individual';

    -- Find an instructor
    SELECT fn_instructor_id(instrumentName, startTime, endTime) INTO instructorID;

    -- Retrieve the student ID
    SELECT fn_student_id(student_personal_identity_number) INTO studentID;

    -- Retrieve the instrument ID
    SELECT "id" INTO instrumentID FROM "instrument" 
    WHERE "name" = instrumentName;

    -- Retrieve the skill level ID
    SELECT "id" INTO skillLevelID FROM "skill_level" 
    WHERE "name" = skillLevel;

    -- Create a session
    INSERT INTO "session" ("course_type_id", "instructor_id", "start_time", "end_time")
    VALUES (courseTypeID, instructorID, startTime, endTime)
    RETURNING id INTO sessionID;
    
    -- Add the lesson
    INSERT INTO "individual_lesson" ("session_id", "instrument_id", "skill_level_id")
    VALUES (sessionID, instrumentID, skillLevelID);

    -- Book for student
    INSERT INTO "student_booking" ("student_id", "session_id")
    VALUES (studentID, sessionID);
END;
$$;

CREATE OR REPLACE PROCEDURE p_add_group_lesson (
    instrumentName VARCHAR(100),
    skillLevel VARCHAR(100),
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    min INT,
    max INT
) LANGUAGE plpgsql AS $$
DECLARE
    courseTypeID INT;
    instructorID INT;
    instrumentID INT;
    skillLevelID INT;
    sessionID    INT;
BEGIN
    -- Retrieve the course type ID for 'individual'
    SELECT "id" INTO courseTypeID FROM "course_type" 
    WHERE "name" = 'group';

    -- Find an instructor
    SELECT fn_instructor_id(instrumentName, startTime, endTime) INTO instructorID;

    -- Retrieve the instrument ID
    SELECT "id" INTO instrumentID FROM "instrument" 
    WHERE "name" = instrumentName;

    -- Retrieve the skill level ID
    SELECT "id" INTO skillLevelID FROM "skill_level" 
    WHERE "name" = skillLevel;

    -- Create a session
    INSERT INTO "session" ("course_type_id", "instructor_id", "start_time", "end_time")
    VALUES (courseTypeID, instructorID, startTime, endTime)
    RETURNING id INTO sessionID;
    
    -- Add the lesson
    INSERT INTO "group_lesson" ("session_id", "instrument_id", "skill_level_id", "min_nr_of_students", "max_nr_of_students")
    VALUES (sessionID, instrumentID, skillLevelID, min, max);
END;
$$;

CREATE OR REPLACE PROCEDURE p_add_ensemble (
    genreName VARCHAR(100),
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    min INT,
    max INT
) LANGUAGE plpgsql AS $$
DECLARE
    courseTypeID INT;
    instructorID INT;
    genreID      INT;
    sessionID    INT;
BEGIN
    -- Retrieve the course type ID for 'individual'
    SELECT "id" INTO courseTypeID FROM "course_type" 
    WHERE "name" = 'ensemble';

    -- Find an instructor
    SELECT fn_instructor_id(startTime, endTime) INTO instructorID;

    -- Retrieve the genre ID
    SELECT "id" INTO genreID FROM "genre" 
    WHERE "name" = genreName;

    -- Create a session
    INSERT INTO "session" ("course_type_id", "instructor_id", "start_time", "end_time")
    VALUES (courseTypeID, instructorID, startTime, endTime)
    RETURNING id INTO sessionID;
    
    -- Add the lesson
    INSERT INTO "ensemble" ("session_id", "genre_id", "min_nr_of_students", "max_nr_of_students")
    VALUES (sessionID, genreID, min, max);
END;
$$;

CREATE OR REPLACE PROCEDURE p_book_group_lesson_for_student(
    student_personal_identity_number CHAR(13),
    instrumentName VARCHAR(100),
    skillLevel VARCHAR(100),
    startTime TIMESTAMP
) LANGUAGE plpgsql AS $$
DECLARE
    studentID    INT;
    sessionID    INT;
BEGIN
    -- Retrieve the student ID
    SELECT fn_student_id(student_personal_identity_number) INTO studentID;

    -- Retrieve the session ID (if it exists)
    SELECT fn_session_id(instrumentName, skillLevel, startTime) INTO sessionID;

    -- Book for student
    INSERT INTO "student_booking" ("student_id", "session_id")
    VALUES (studentID, sessionID);
END;
$$;

CREATE OR REPLACE PROCEDURE p_book_ensemble_for_student(
    student_personal_identity_number CHAR(13),
    genreName VARCHAR(100),
    startTime TIMESTAMP
) LANGUAGE plpgsql AS $$
DECLARE
    studentID    INT;
    sessionID    INT;
BEGIN
    -- Retrieve the student ID
    SELECT fn_student_id(student_personal_identity_number) INTO studentID;

    -- Retrieve the session ID (if it exists)
    SELECT fn_session_id(genreName, startTime) INTO sessionID;

    -- Book for student
    INSERT INTO "student_booking" ("student_id", "session_id")
    VALUES (studentID, sessionID);
END;
$$;
