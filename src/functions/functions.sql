-- postgreSQL
-- file           : functions.sql
-- Module         : Functions
-- Description    : Seminar 3, SQL
--                 
-- Course         : kth IV1351 Data Storage Paradigms
-- Author/Student : Elin Blomquist, Vincent Ferrigan
-- maintainer     : eblomq@kth.se, ferrigan@kth.se,
-- FUNCTIONS

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
