-- postgreSQL
-- file           : functions.sql
-- Module         : Functions
-- Description    : Seminar 3, SQL
--                 
-- Course         : kth IV1351 Data Storage Paradigms
-- Author/Student : Elin Blomquist, Vincent Ferrigan
-- maintainer     : eblomq@kth.se, ferrigan@kth.se,
-- FUNCTIONS

-- Insert new person and return their id.
-- OI : Should I make it a procedure!???????????? Don't let function insert!!
CREATE OR REPLACE FUNCTION fn_add_person(
      pid CHAR(13)
    , firstName VARCHAR(100)
    , lastName VARCHAR(100)
    , street VARCHAR(100)
    , zip VARCHAR(10)
    , city VARCHAR(100)
    , phone VARCHAR(50)
    , email VARCHAR(100)
    ) RETURNS INT as $$

-- Variable to hold the newly inserted person ID
DECLARE 
	new_person_id INT;
BEGIN
    -- Insert a the person and capture its ID
    INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
    VALUES (pid, firstName, lastName, street, zip, city, phone, email) 
        RETURNING id INTO new_person_id;
    -- Insert the new person as student
    RETURN new_person_id;
END;
$$  LANGUAGE plpgsql;

-- Return instructor id based on first and last name
CREATE OR REPLACE FUNCTION fn_instructor_id(
       firstName VARCHAR(100), 
       lastName VARCHAR(100)) RETURNS INT AS $$
BEGIN
    RETURN (SELECT "id" FROM "instructor" 
    WHERE "person_id" = (
        SELECT "id" FROM "person" 
        WHERE "first_name" = firstName AND "last_name" = lastName));
END;
$$ LANGUAGE plpgsql;

-- Return instructor id based on first and last name
CREATE OR REPLACE FUNCTION fn_instructor_id(
       firstName VARCHAR(100), 
       lastName VARCHAR(100)) RETURNS INT AS $$
BEGIN
    RETURN (SELECT "id" FROM "instructor" 
    WHERE "person_id" = (
        SELECT "id" FROM "person" 
        WHERE "first_name" = firstName AND "last_name" = lastName));
END;
$$ LANGUAGE plpgsql;

-- Randomly pick an instructor id based on instrument skill
CREATE OR REPLACE FUNCTION fn_instructor_id(
    instrumentName VARCHAR(100)
) RETURNS INT AS $$
DECLARE
    instructorID INT;
BEGIN
    SELECT "instructor_id"
    INTO instructorID
    FROM "instructor_instrument"
    WHERE "instrument_id" = (SELECT "id" FROM "instrument" WHERE "name" = instrumentName)
    ORDER BY RANDOM()
    LIMIT 1;

    RETURN instructorID;
END;
$$ LANGUAGE plpgsql;

-- Randomly pick an instructor id based on free time slot
CREATE OR REPLACE FUNCTION fn_instructor_id(
    startTime TIMESTAMP
    , endTime TIMESTAMP-- or duration
) RETURNS INT AS $$
DECLARE
    instructorID INT;
BEGIN
    SELECT "id"
    INTO instructorID
    FROM "instructor" i
      WHERE NOT EXISTS (
          SELECT 1
          FROM "session" s
          WHERE s."instructor_id" = i."id"
            AND ((startTime, endTime) OVERLAPS (s."start_time", s."end_time"))
      )
    ORDER BY RANDOM()
    LIMIT 1;

    RETURN instructorID;
END;
$$ LANGUAGE plpgsql;

-- Randomly pick an instructor id based on instrument skill and free time slot
CREATE OR REPLACE FUNCTION fn_instructor_id(
    instrumentName VARCHAR(100)
    , startTime TIMESTAMP
    , endTime TIMESTAMP-- or duration
) RETURNS INT AS $$
DECLARE
    instructorID INT;
BEGIN
    SELECT "instructor_id"
    INTO instructorID
    FROM "instructor_instrument" ii
    WHERE ii."instrument_id" = (SELECT "id" FROM "instrument" WHERE "name" = instrumentName)
      AND NOT EXISTS (
          SELECT 1
          FROM "session" s
          WHERE s."instructor_id" = ii."instructor_id"
            AND ((startTime, endTime) OVERLAPS (s."start_time", s."end_time"))
      )
    ORDER BY RANDOM()
    LIMIT 1;

    RETURN instructorID;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_student_id(
      student_personal_identity_number CHAR(13)
) RETURNS INT AS $$
BEGIN
    RETURN (SELECT "id" FROM "student" 
    WHERE "person_id" = (
        SELECT "id" FROM "person" 
        WHERE "personal_identity_number" = student_personal_identity_number));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_student_id(
       firstName VARCHAR(100), 
       lastName VARCHAR(100)) RETURNS INT AS $$
BEGIN
    RETURN (SELECT "id" FROM "student" 
    WHERE "person_id" = (
        SELECT "id" FROM "person" 
        WHERE "first_name" = firstName AND "last_name" = lastName));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_session_id(
    genreName VARCHAR(100),
    startTime TIMESTAMP
) RETURNS INT AS $$
DECLARE
    courseTypeID INT;
    genreID INT;
    sessionID INT;
BEGIN
    -- Retrieve the course type ID for 'ensemble'
    SELECT "id" INTO courseTypeID FROM "course_type" 
    WHERE "name" = 'ensemble';

    -- Retrieve the genre ID
    SELECT "id" INTO genreID FROM "genre" 
    WHERE "name" = genreName;

    -- Retrieve the session ID
    SELECT s."id"
    INTO sessionID
    FROM "session" s
    INNER JOIN "ensemble" e ON s."id" = e."session_id"
    WHERE s."course_type_id" = courseTypeID 
      AND s."start_time" = startTime
      AND e."genre_id" = genreID
    LIMIT 1;

    RETURN sessionID;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_session_id(
    instrumentName VARCHAR(100),
    skillLevel VARCHAR(100),
    startTime TIMESTAMP
) RETURNS INT AS $$
DECLARE
    courseTypeID INT;
    instrumentID INT;
    skillLevelID INT;
    sessionID INT;
BEGIN
    -- Retrieve the course type ID for 'ensemble'
    SELECT "id" INTO courseTypeID FROM "course_type" 
    WHERE "name" = 'group';

    -- Retrieve the instrument ID
    SELECT "id" INTO instrumentID FROM "instrument" 
    WHERE "name" = instrumentName;

    -- Retrieve the skill level ID
    SELECT "id" INTO skillLevelID FROM "skill_level" 
    WHERE "name" = skillLevel;

    -- Retrieve the session ID
    SELECT s."id"
    INTO sessionID
    FROM "session" s
    INNER JOIN "group_lesson" g ON s."id" = g."session_id"
    WHERE s."course_type_id" = courseTypeID 
      AND s."start_time" = startTime
      AND g."instrument_id" = instrumentID
      AND g."skill_level_id" = skillLevelID
    LIMIT 1;

    RETURN sessionID;
END;
$$ LANGUAGE plpgsql;
