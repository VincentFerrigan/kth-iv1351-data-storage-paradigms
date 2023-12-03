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

-- POPULATE
-- Course Type
INSERT INTO "course_type" ("name") VALUES 
      ('individual')
    , ('group')
    , ('ensemble')
    ;

-- Genre    
INSERT INTO "genre" ("name") VALUES
  ('gospel'),
  ('punk'),
  ('rock'),
  ('jazz'),
  ('hip-hop'),
  ('country'),
  ('electronic'),
  ('reggae'),
  ('blues'),
  ('classical');


-- Skill levels
INSERT INTO "skill_level" ("name") VALUES
  ('beginner'),
  ('intermediate'),
  ('advanced');


-- Insert instrument names
INSERT INTO "instrument" ("name") VALUES
  ('guitar'),
  ('piano'),
  ('violin'),
  ('drums'),
  ('saxophone'),
  ('flute'),
  ('trumpet'),
  ('bass guitar'),
  ('clarinet'),
  ('harp');


-- Insert brand names for instruments
INSERT INTO "brand" ("name") VALUES
  ('gibson'),        -- Known for guitars
  ('fender'),        -- Known for guitars
  ('yamaha'),        -- Known for various instruments, including pianos and keyboards
  ('roland'),        -- Known for electronic musical instruments
  ('korg'),          -- Known for synthesizers and electronic instruments
  ('pearl'),         -- Known for drums and percussion instruments
  ('ludwig'),        -- Known for drums and percussion instruments
  ('martin'),        -- Known for acoustic guitars
  ('taylor'),        -- Known for acoustic guitars
  ('ibanez'),        -- Known for guitars
  ('hohner'),        -- Known for harmonicas, including some models of chord harmonicas
  ('stradivarius'),  -- Known for Stradivarius violins, among the most famous violins in the world
  ('steinway & sons'),-- Known for high-quality pianos, including grand pianos
  ('selmer'),         -- Known for saxophones, including the famous Selmer Mark VI saxophone
  ('celtic harps'),   -- Known for harps, including Celtic-style harps
  ('miyazawa'),       -- Known for high-quality flutes
  ('gemeinhardt'),    -- Known for student and intermediate flutes
  ('muramatsu');      -- Known for professional flutes, especially in the classical music world


-- Define rentable instruments and match them with instrument and brand IDs (five of each)
INSERT INTO "rentable_instrument" ("instrument_id", "brand_id")
SELECT "i"."id", "b"."id"
FROM (
  VALUES
    ('guitar', 'gibson'),
    ('guitar', 'fender'),
    ('guitar', 'ibanez'),
    ('piano', 'yamaha'),
    ('piano', 'steinway & sons'),
    ('violin', 'stradivarius'),
    ('drums', 'pearl'),
    ('drums', 'ludwig'),
    ('saxophone', 'selmer'),
    ('flute', 'miyazawa'),
    ('flute', 'gemeinhardt'),
    ('flute', 'muramatsu'),
    ('trumpet', 'yamaha'),
    ('bass guitar', 'fender'),
    ('clarinet', 'selmer'),
    ('harp', 'celtic harps')
) AS "ri" ("instrument_name", "brand_name")
JOIN "instrument" AS "i" ON "ri"."instrument_name" = "i"."name"
JOIN "brand" AS "b" ON "ri"."brand_name" = "b"."name";

-- Duplicate the entries to have five of each instrument (adjust the number as needed)
INSERT INTO "rentable_instrument" ("instrument_id", "brand_id")
SELECT "instrument_id", "brand_id"
FROM "rentable_instrument"
UNION ALL
SELECT "instrument_id", "brand_id"
FROM "rentable_instrument"
UNION ALL
SELECT "instrument_id", "brand_id"
FROM "rentable_instrument"
UNION ALL
SELECT "instrument_id", "brand_id"
FROM "rentable_instrument";

-- Insert 5 instructors into the "person" and "instructor" tables
call p_add_instructor('19620523-0551', 'Erik', 'Eriksson', 'Storgatan 5', '12345', 'Stockholm', '+46 8 123 456 78', 'erik@gmail.com');
call p_add_instructor('19620523-0552', 'Anna', 'Andersson', 'Lillgatan 7', '12345', 'Göteborg', '+46 8 234 567 89', 'anna@yahoo.com');
call p_add_instructor('19620523-0553', 'Björn', 'Borg', 'Turegatan 10', '118 18', 'Malmö', '+46736369741', 'bjorn@gmail.com');
call p_add_instructor('19620523-0554', 'Karin', 'Karlsson', 'Sjögatan 3', '12345', 'Uppsala', '+46 8 345 678 90', 'karin@yahoo.com');
call p_add_instructor('19620523-0555', 'Göran', 'Gustafsson', 'Åsgatan 8', '12345', 'Linköping', '+46 8 456 789 01', 'goran@gmail.com');

-- Populate the "instructor_instrument" table with instruments
call p_add_instructor_instruments('Erik', 'Eriksson', ARRAY['piano', 'guitar', 'harp']);
call p_add_instructor_instruments('Anna', 'Andersson' ARRAY['drums', 'piano']);
call p_add_instructor_instruments('Björn', 'Borg', ARRAY['piano', 'saxophone', 'flute', 'trumpet', 'clarinet]);
call p_add_instructor_instruments('Karin', 'Karlsson', ARRAY['clarinet', 'violin','guitar']);
call p_add_instructor_instruments('Göran', 'Gustafsson', ARRAY['clarinet', 'drums','trumpet','bass guitar']);

-- Insert 5 students into the "person" and "student" tables
-- Students with three siblings sharing the same last name and address
call p_add_student('19901001-1111', 'Oliver', 'Andersson', 'Västergatan 1', '12345', 'Stockholm', '+46 8 111 222 33', 'oliver@gmail.com');
call p_add_student('19902001-1112', 'Emma', 'Andersson', 'Västergatan 1', '12345', 'Stockholm', '+46 8 222 333 44', 'emma@yahoo.com');
call p_add_student('19901007-1113', 'Liam', 'Andersson', 'Västergatan 1', '12345', 'Stockholm', '+46 8 333 444 55', 'liam@gmail.com');

-- Students with two siblings sharing the same last name and address
call p_add_student('19901101-2221', 'Mia', 'Björk', 'Solgatan 5', '54321', 'Göteborg', '+46 31 555 666 77', 'mia@gmail.com');
call p_add_student('19901211-2222', 'Lucas', 'Björk', 'Solgatan 5', '54321', 'Göteborg', '+46 31 666 777 88', 'lucas@yahoo.com');

-- Another set of students with two siblings sharing the same last name and address
call p_add_student('19901201-3331', 'Ella', 'Larsson', 'Rosengatan 2', '65432', 'Malmö', '+46736366661', 'ella@gmail.com');
call p_add_student('19951201-3332', 'Noah', 'Larsson', 'Rosengatan 2', '65432', 'Malmö', '+46736366662', 'noah@yahoo.com');

-- Students with no siblings
call p_add_student('19910222-4441', 'William', 'Gustafsson', 'Mångatan 4', '98765', 'Uppsala', '+46 18 888 999 00', 'william@gmail.com');

-- Students with a sibling
call p_add_student('19910301-5551', 'Lilly', 'Karlsson', 'Björkgatan 6', '34567', 'Stockholm', '+46 8 111 222 33', 'lilly@gmail.com');
call p_add_student('19820301-5552', 'Charlie', 'Karlsson', 'Björkgatan 6', '34567', 'Stockholm', '+46 8 222 333 44', 'charlie@gmail.com');

-- Students with two siblings
call p_add_student('19910401-6661', 'Sophia', 'Larsson', 'Skogsgatan 7', '54321', 'Göteborg', '+46 31 111 222 33', 'sophia@gmail.com');
call p_add_student('20010612-6662', 'Aiden', 'Larsson', 'Skogsgatan 7', '54321', 'Göteborg', '+46 31 222 333 44', 'aiden@gmail.com');

-- Students with three siblings
call p_add_student('19910501-7771', 'Mila', 'Andersson', 'Sjögatan 5', '43210', 'Malmö', '+46736366663', 'mila@gmail.com');
call p_add_student('20000912-7772', 'Henry', 'Andersson', 'Sjögatan 5', '43210', 'Malmö', '+46736366664', 'henry@gmail.com');

-- Insert more students with random data
-- Students with no siblings
call p_add_student('19910601-8881', 'Isabella', 'Eriksson', 'Åsgatan 3', '12345', 'Stockholm', '+46 8 555 666 77', 'isabella@gmail.com');
call p_add_student('19910701-9991', 'Alexander', 'Svensson', 'Lillgatan 9', '54321', 'Göteborg', '+46 31 777 888 99', 'alexander@gmail.com');

-- Students with a sibling
call p_add_student('19910801-1010', 'Elsa', 'Nilsson', 'Bergsgatan 1', '98765', 'Uppsala', '+46 18 123 456 78', 'elsa@gmail.com');
call p_add_student('19910802-2010', 'Oscar', 'Nilsson', 'Bergsgatan 1', '98765', 'Uppsala', '+46 18 234 567 89', 'oscar@gmail.com');

-- Students with two siblings
call p_add_student('19910901-1111', 'Agnes', 'Björk', 'Norrgatan 2', '12345', 'Stockholm', '+46 8 987 654 32', 'agnes@gmail.com');
call p_add_student('19920201-1111', 'Viktor', 'Björk', 'Norrgatan 2', '12345', 'Stockholm', '+46 8 876 543 21', 'victor@gmail.com');

-- Students with three siblings
call p_add_student('19911001-1211', 'Selma', 'Lundqvist', 'Gatan 3', '43210', 'Malmö', '+46736377771', 'selma@gmail.com');
call p_add_student('19941001-1212', 'Nils', 'Lundqvist', 'Gatan 3', '43210', 'Malmö', '+46736377772', 'nils@gmail.com');

-- Populate the "sibling" table based on students with the same last name and address
call locate_and_populate_siblings_table();

-- Populate contact persons
INSERT INTO "contact_person" ("first_name", "last_name", "phone", "email")
VALUES
    ('John', 'Doe', '+467123456789', 'john.doe@gmail.com'),
    ('Jane', 'Smith', '+467987654321', 'jane.smith@gmail.com'),
    ('Robert', 'Johnson', '+467112233445', 'robert.johnson@gmail.com'),
    ('Sarah', 'Wilson', '+467998877665', 'sarah.wilson@gmail.com'),

    ('Lena', 'Andersson', '+467445566772', 'lena.andersson@gmail.com'),
    ('Lena', 'Björk', '+467445564742', 'lena.bjork@gmail.com'),
    ('Peter', 'Larsson', '+467445546772', 'peter.larsson@gmail.com'),
    ('Peter', 'Karlsson', '+467445144772', 'peter.Karlsson@gmail.com'),
    ('Henrik', 'Larsson', '+469444546772', 'henrik.larsson@gmail.com'),
    ('Ragnar', 'Andersson', '+467445546742', 'ragnar.larsson@gmail.com'),
    ('Emma', 'Nilsson', '+467495546774', 'emma.nilsson@gmail.com'),
    ('Ritva', 'Björk', '+467445596772', 'ritva.bjork@gmail.com');


-- Populate the "student_contact_person" table with parent, guardian, and grandparent relationships
CALL p_add_student_contact_person('Oliver', 'Andersson', 'Lena', 'Andersson', 'Parent');
CALL p_add_student_contact_person('Emma', 'Andersson', 'Lena', 'Andersson', 'Parent');
CALL p_add_student_contact_person('Liam', 'Andersson', 'Lena', 'Andersson', 'Parent');

CALL p_add_student_contact_person('Mia', 'Björk', 'Lena', 'Björk', 'Parent');
CALL p_add_student_contact_person('Lucas', 'Björk', 'Lena', 'Björk', 'Parent');

CALL p_add_student_contact_person('Ella', 'Larsson', 'Peter', 'Larsson', 'Parent');
CALL p_add_student_contact_person('Noah', 'Larsson', 'Peter', 'Larsson', 'Parent');

CALL p_add_student_contact_person('Lilly', 'Karlsson', 'Peter', 'Karlsson', 'Parent');
CALL p_add_student_contact_person('Charlie', 'Karlsson', 'Peter', 'Karlsson', 'Parent');

CALL p_add_student_contact_person('Sophia', 'Larsson', 'Henrik', 'Larsson', 'Parent');
CALL p_add_student_contact_person('Aiden', 'Larsson', 'Henrik', 'Larsson', 'Parent');

CALL p_add_student_contact_person('Mila', 'Andersson', 'Ragnar', 'Andersson', 'Parent');
CALL p_add_student_contact_person('Henry', 'Andersson', 'Ragnar', 'Andersson', 'Parent');

CALL p_add_student_contact_person('Elsa', 'Nilsson', 'Emma', 'Nilsson', 'Parent');
CALL p_add_student_contact_person('Oscar', 'Nilsson', 'Emma', 'Nilsson', 'Parent');

CALL p_add_student_contact_person('Agnes', 'Björk', 'Ritva', 'Björk', 'Parent');
CALL p_add_student_contact_person('Viktor', 'Björk', 'Ritva', 'Björk', 'Parent');

CALL p_add_student_contact_person('William', 'Gustafsson', 'John', 'Doe', 'Grandparent');

CALL p_add_student_contact_person('Selma', 'Lundqvist', 'Jane', 'Smith', 'Grandparent');

CALL p_add_student_contact_person('Isabella', 'Eriksson', 'Robert', 'Johnson', 'Grandparent');

CALL p_add_student_contact_person('Oliver', 'Andersson', 'Sarah', 'Wilson', 'Grandparent');

CALL p_add_student_contact_person('Emma', 'Andersson', 'Sarah', 'Wilson', 'Grandparent');

CALL p_add_student_contact_person('Liam', 'Andersson', 'Sarah', 'Wilson','Grandparent');

-- Populate rental price
CALL p_add_rental_price('guitar', 100);
CALL p_add_rental_price('violin', 75);
CALL p_add_rental_price('drums', 150);
CALL p_add_rental_price('saxophone', 100);
CALL p_add_rental_price('flute', 50);
CALL p_add_rental_price('trumpet', 100.00);
CALL p_add_rental_price('bass guitar', 100);
CALL p_add_rental_price('clarinet', 100);
CALL p_add_rental_price('harp', 200;


-- Populate lesson price list table
CALL p_add_lesson_price('ensemble', 125);
CALL p_add_lesson_price('group', 150);
CALL p_add_lesson_price('group', 'advanced', 150);
CALL p_add_lesson_price('individual', 150);
CALL p_add_lesson_price('individual', 'advanced', 150);

-- populate the session and ensemble table
CALL p_add_ensemble('blues',     '2023-04-02 17:15', '2023-04-02 18:15', 5, 15);
CALL p_add_ensemble('blues',     '2023-12-03 16:45', '2023-12-03 17:45', 5, 15);
CALL p_add_ensemble('classical', '2023-12-04 18:00', '2023-12-04 19:00', 5, 15);
CALL p_add_ensemble('jazz',      '2023-09-28 14:30', '2023-09-28 15:30', 5, 15);
CALL p_add_ensemble('jazz',      '2023-12-02 15:30', '2023-12-02 16:30', 5, 15);
CALL p_add_ensemble('rock',      '2023-04-15 17:00', '2023-04-15 18:00', 5, 15);
CALL p_add_ensemble('rock',      '2023-05-10 16:00', '2023-05-10 17:00', 5, 15);
CALL p_add_ensemble('rock',      '2023-12-02 14:00', '2023-12-02 15:00', 5, 15);
CALL p_add_ensemble('rock',      '2023-12-04 19:15', '2023-12-04 20:15', 5, 15);

-- populate the session and group lesson table
CALL p_add_group_lesson('guitar', 'advanced',     '2023-01-15 14:30', '2023-01-15 15:30', 3, 10);
CALL p_add_group_lesson('guitar', 'beginner',     '2023-02-03 14:00', '2023-02-03 15:00', 3,10); 
CALL p_add_group_lesson('trumpet','intermediate', '2023-02-28 14:15', '2023-02-28 15:15', 3, 10);
CALL p_add_group_lesson('violin', 'advanced', '   2023-03-10 17:45', '2023-03-10 18:45', 3, 10);

-- populate student booking table
CALL p_book_ensemble_for_student('19901001-1111', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19901001-1111', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19901001-1111', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19901001-1111','rock', '2023-12-02 14:00');
CALL p_book_ensemble_for_student('19901007-1113', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19901007-1113', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19901007-1113', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19901007-1113', 'jazz', '2023-12-02 15:30');
CALL p_book_ensemble_for_student('19901007-1113', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19901007-1113', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19901007-1113','rock', '2023-12-02 14:00');
CALL p_book_ensemble_for_student('19901101-2221', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19901101-2221', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19901101-2221', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19901101-2221','rock', '2023-12-02 14:00');
CALL p_book_ensemble_for_student('19901201-3331', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19901201-3331', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19901201-3331', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19901201-3331','rock', '2023-12-02 14:00');
CALL p_book_ensemble_for_student('19901211-2222', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19901211-2222', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19901211-2222', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19901211-2222', 'jazz', '2023-12-02 15:30');
CALL p_book_ensemble_for_student('19901211-2222', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19901211-2222', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19901211-2222','rock', '2023-12-02 14:00');
CALL p_book_ensemble_for_student('19902001-1112', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19902001-1112', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19902001-1112', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19902001-1112','rock', '2023-12-02 14:00');
CALL p_book_ensemble_for_student('19910222-4441', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19910222-4441', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19910222-4441', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19910222-4441','rock', '2023-12-02 14:00');
CALL p_book_ensemble_for_student('19910601-8881', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19910601-8881', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19910601-8881', 'jazz', '2023-12-02 15:30');
CALL p_book_ensemble_for_student('19910601-8881', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19910701-9991', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19910701-9991', 'jazz', '2023-12-02 15:30');
CALL p_book_ensemble_for_student('19910701-9991', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19910701-9991', 'rock', '2023-05-10 16:00');
CALL p_book_ensemble_for_student('19910801-1010', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19910801-1010', 'jazz', '2023-12-02 15:30');
CALL p_book_ensemble_for_student('19910801-1010', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19910801-1010', 'rock', '2023-05-10 16:00');
CALL p_book_ensemble_for_student('19910802-2010', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19910802-2010', 'jazz', '2023-12-02 15:30');
CALL p_book_ensemble_for_student('19910802-2010', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19910802-2010', 'rock', '2023-05-10 16:00');
CALL p_book_ensemble_for_student('19910901-1111', 'blues', '2023-12-03 16:45');
CALL p_book_ensemble_for_student('19910901-1111', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19910901-1111', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19910901-1111', 'rock', '2023-05-10 16:00');
CALL p_book_ensemble_for_student('19911001-1211', 'blues', '2023-12-03 16:45');
CALL p_book_ensemble_for_student('19911001-1211', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19911001-1211', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19911001-1211', 'rock', '2023-05-10 16:00');
CALL p_book_ensemble_for_student('19920201-1111', 'blues', '2023-12-03 16:45');
CALL p_book_ensemble_for_student('19920201-1111', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19920201-1111', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19920201-1111', 'rock', '2023-05-10 16:00');
CALL p_book_ensemble_for_student('19941001-1212', 'blues', '2023-12-03 16:45');
CALL p_book_ensemble_for_student('19941001-1212', 'classical', '2023-12-04 18:00');
CALL p_book_ensemble_for_student('19941001-1212', 'rock', '2023-04-15 17:00');
CALL p_book_ensemble_for_student('19941001-1212', 'rock', '2023-05-10 16:00');
CALL p_book_ensemble_for_student('19951201-3332', 'blues', '2023-04-02 17:15');
CALL p_book_ensemble_for_student('19951201-3332', 'jazz', '2023-09-28 14:30');
CALL p_book_ensemble_for_student('19951201-3332', 'jazz', '2023-12-02 15:30');
CALL p_book_ensemble_for_student('19951201-3332', 'rock', '2023-12-04 19:15');
CALL p_book_ensemble_for_student('19951201-3332','rock', '2023-12-02 14:00');

CALL p_book_group_lesson_for_student('19901001-1111', 'guitar', 'beginner', '2023-02-03 14:00'); 
CALL p_book_group_lesson_for_student('19901001-1111', 'trumpet','intermediate',  '2023-02-28 14:15');
CALL p_book_group_lesson_for_student('19901007-1113', 'guitar', 'advanced', '2023-01-15 14:30');
CALL p_book_group_lesson_for_student('19901007-1113', 'guitar', 'beginner', '2023-02-03 14:00'); 
CALL p_book_group_lesson_for_student('19901007-1113', 'trumpet','intermediate',  '2023-02-28 14:15');
CALL p_book_group_lesson_for_student('19901007-1113', 'violin', 'advanced', '2023-03-10 17:45');
CALL p_book_group_lesson_for_student('19901101-2221', 'guitar', 'beginner', '2023-02-03 14:00'); 
CALL p_book_group_lesson_for_student('19901101-2221', 'trumpet','intermediate',  '2023-02-28 14:15');
CALL p_book_group_lesson_for_student('19901201-3331', 'guitar', 'beginner', '2023-02-03 14:00'); 
CALL p_book_group_lesson_for_student('19901201-3331', 'trumpet','intermediate',  '2023-02-28 14:15');
CALL p_book_group_lesson_for_student('19901211-2222', 'guitar', 'advanced', '2023-01-15 14:30');
CALL p_book_group_lesson_for_student('19901211-2222', 'guitar', 'beginner', '2023-02-03 14:00'); 
CALL p_book_group_lesson_for_student('19901211-2222', 'trumpet','intermediate',  '2023-02-28 14:15');
CALL p_book_group_lesson_for_student('19901211-2222', 'violin', 'advanced', '2023-03-10 17:45');
CALL p_book_group_lesson_for_student('19902001-1112', 'guitar', 'beginner', '2023-02-03 14:00'); 
CALL p_book_group_lesson_for_student('19902001-1112', 'trumpet','intermediate',  '2023-02-28 14:15');
CALL p_book_group_lesson_for_student('19910222-4441', 'guitar', 'advanced', '2023-01-15 14:30');
CALL p_book_group_lesson_for_student('19910222-4441', 'trumpet','intermediate',  '2023-02-28 14:15');
CALL p_book_group_lesson_for_student('19951201-3332', 'guitar', 'advanced', '2023-01-15 14:30');
CALL p_book_group_lesson_for_student('19951201-3332', 'trumpet','intermediate',  '2023-02-28 14:15');

-- populate the student booking, individual lesson and session table
CALL p_book_individual_lesson('19901001-1111', 'piano', 'beginner',      '2023-04-05 16:30', '2023-04-05 17:30');
CALL p_book_individual_lesson('19901007-1113', 'drums', 'beginner',      '2023-02-17 14:45', '2023-02-17 15:45');
CALL p_book_individual_lesson('19901007-1113', 'drums','advanced',       '2023-03-21 15:30', '2023-03-21 16:30');
CALL p_book_individual_lesson('19901007-1113', 'flute',  'advanced',     '2023-04-08 15:20', '2023-04-08 16:20');
CALL p_book_individual_lesson('19901101-2221', 'bass guitar', 'beginner','2023-10-12 18:00', '2023-10-12 19:00');
CALL p_book_individual_lesson('19901201-3331', 'drums',  'beginner',     '2023-09-03 16:30', '2023-09-03 17:30');
CALL p_book_individual_lesson('19901211-2222', 'clarinet',  'beginner',   '2023-03-25 14:10', '2023-03-25 15:10');
CALL p_book_individual_lesson('19901211-2222', 'saxophone', 'advanced',  '2023-01-08 18:00', '2023-01-08 19:00');
CALL p_book_individual_lesson('19902001-1112', 'drums', 'intermediate',  '2023-05-20 14:45', '2023-05-20 15:45');
CALL p_book_individual_lesson('19910222-4441', 'clarinet',  'advanced',  '2023-11-20 14:30', '2023-11-20 15:30');
CALL p_book_individual_lesson('19951201-3332', 'trumpet',  'intermediate','2023-10-15 15:45', '2023-10-15 16:45');
CALL p_book_individual_lesson('19951201-3332', 'violin','intermediate',  '2023-11-05 16:20', '2023-11-05 17:20');