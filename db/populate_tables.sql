-- FUNCTIONS
-- Insert new person and return their id.
CREATE OR REPLACE FUNCTION fn_add_person(
    pid CHAR(13),
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    street VARCHAR(100),
    zip VARCHAR(10),
    city VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100)
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
    price FLOAT4,
    skillLevel VARCHAR(100)) AS $$
BEGIN
    INSERT INTO "lesson_price_list" ("course_type_id", "price", "skill_level_id", "valid_start_time", "transaction_start_time")
        VALUES(
            (SELECT "id" FROM "course_type" WHERE "name" = courseType), 
            price, 
            (SELECT "id" FROM "skill_level" WHERE "level" = skillLevel), 
            CURRENT_DATE, 
            CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE p_add_lesson_price(
    courseType VARCHAR(100),
    price FLOAT4,
    skillLevel VARCHAR(100),
    instrumentName VARCHAR(100)) AS $$
BEGIN
    INSERT INTO "lesson_price_list" ("course_type_id", "price", "skill_level_id", "instrument_id", "valid_start_time", "transaction_start_time")
        VALUES(
            (SELECT "id" FROM "course_type" WHERE "name" = courseType), 
            price, 
            (SELECT "id" FROM "skill_level" WHERE "level" = skillLevel), 
            (SELECT "id" FROM "instrument" WHERE "level" = instrumentName), 
            CURRENT_DATE, 
            CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- Add individual lesson/session
-- TODO Change to one that books a session, finds an instructor and timeslot etc
-- You have funcitons to find instructors
-- If individual lesson, it needs to also book for student
-- If group, books time slot for instructor and awaits students?
-- If ensemble, books time slot for instructor and awaits students?
CREATE OR REPLACE PROCEDURE p_add_individual_lesson(
      instrumentName VARCHAR(100)
    , skillLevel VARCHAR(100)
    ) AS $$
BEGIN
    INSERT INTO "lesson" (
          "course_type_id"
        , "instrument_id"
        , "skill_level_id"
        , "min_nr_of_students"
        , "max_nr_of_students"
    ) VALUES (
		  (SELECT "id" FROM "course_type" WHERE "name" = 'individual')
        , (SELECT "id" FROM "instrument" WHERE "name" = instrumentName)
        , (SELECT "id" FROM "skill_level" WHERE "level" = skillLevel)
        , 1
        , 1
    );
END;
$$ LANGUAGE plpgsql;

-- Add ensemble
CREATE OR REPLACE PROCEDURE p_add_ensemble(
      genreName VARCHAR(100)
    , min INT
    , max INT
    ) AS $$
BEGIN
    INSERT INTO "lesson" (
          "course_type_id"
        , "genre_id"
        , "min_nr_of_students"
        , "max_nr_of_students"
    ) VALUES (
		  (SELECT "id" FROM "course_type" WHERE "name" = 'ensemble')
        , (SELECT "id" FROM "genre" WHERE "name" = genreName)
        , min
        , max
    );
END;
$$ LANGUAGE plpgsql;

-- Course Type
INSERT INTO "course_type" ("name") VALUES 
      ('individual')
    , ('group')
    , ('ensembel')
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
INSERT INTO "skill_level" ("level") VALUES
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


-- Define instrument prices and match instrument names with their IDs using a subquery
INSERT INTO "instrument_price_list" ("instrument_id", "price_per_month", "effective_date")
SELECT "i"."id", "p"."price_per_month", TO_DATE("p"."effective_date", 'YYYY-MM-DD')
FROM (
  VALUES
    ('guitar', 50.00, '2023-11-23'),
    ('piano', 60.00, '2023-11-23'),
    ('violin', 70.00, '2023-11-23'),
    ('drums', 40.00, '2023-11-23'),
    ('saxophone', 75.00, '2023-11-23'),
    ('flute', 30.00, '2023-11-23'),
    ('trumpet', 55.00, '2023-11-23'),
    ('bass guitar', 70.00, '2023-11-23'),
    ('clarinet', 45.00, '2023-11-23'),
    ('harp', 80.00, '2023-11-23')
) AS "p" ("instrument_name", "price_per_month", "effective_date")
JOIN "instrument" AS "i" ON "p"."instrument_name" = "i"."name";


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


-- Populate the "ensemble_price" table with ensemble prices and genres
INSERT INTO "ensemble_price" ("genre_id", "price", "effective_date")
SELECT "g"."id", "p"."price_per_month", TO_DATE("p"."effective_date", 'YYYY-MM-DD')
FROM (
  VALUES
    ('gospel', 100.00, '2023-11-23'),
    ('punk', 120.00, '2023-11-23'),
    ('rock', 150.00, '2023-11-23'),
    ('jazz', 110.00, '2023-11-23'),
    ('hip-hop', 130.00, '2023-11-23'),
    ('country', 160.00, '2023-11-23'),
    ('electronic', 140.00, '2023-11-23'),
    ('reggae', 125.00, '2023-11-23'),
    ('blues', 105.00, '2023-11-23'),
    ('classical', 135.00, '2023-11-23')
) AS "p" ("genre_name", "price_per_month", "effective_date")
JOIN "genre" AS "g" ON "p"."genre_name" = "g"."name";

-- Populate the "individual_lesson_price" table with individual lesson prices for all instruments and skill levels
INSERT INTO "individual_lesson_price" ("instrument_id", "skill_level_id", "price", "effective_date")
SELECT "i"."id", "s"."id", "p"."price_per_month", TO_DATE("p"."effective_date", 'YYYY-MM-DD')
FROM (
  VALUES
    ('guitar', 'beginner', 70.00, '2023-11-23'),
    ('guitar', 'intermediate', 70.00, '2023-11-23'),
    ('guitar', 'advanced', 90.00, '2023-11-23'),
    ('piano', 'beginner', 60.00, '2023-11-23'),
    ('piano', 'intermediate', 60.00, '2023-11-23'),
    ('piano', 'advanced', 85.00, '2023-11-23'),
    ('violin', 'beginner', 75.00, '2023-11-23'),
    ('violin', 'intermediate', 75.00, '2023-11-23'),
    ('violin', 'advanced', 100.00, '2023-11-23'),
    ('drums', 'beginner', 55.00, '2023-11-23'),
    ('drums', 'intermediate', 55.00, '2023-11-23'),
    ('drums', 'advanced', 80.00, '2023-11-23'),
    ('saxophone', 'beginner', 85.00, '2023-11-23'),
    ('saxophone', 'intermediate', 85.00, '2023-11-23'),
    ('saxophone', 'advanced', 95.00, '2023-11-23'),
    ('flute', 'beginner', 75.00, '2023-11-23'),
    ('flute', 'intermediate', 75.00, '2023-11-23'),
    ('flute', 'advanced', 85.00, '2023-11-23'),
    ('trumpet', 'beginner', 65.00, '2023-11-23'),
    ('trumpet', 'intermediate', 65.00, '2023-11-23'),
    ('trumpet', 'advanced', 75.00, '2023-11-23'),
    ('bass guitar', 'beginner', 75.00, '2023-11-23'),
    ('bass guitar', 'intermediate', 75.00, '2023-11-23'),
    ('bass guitar', 'advanced', 85.00, '2023-11-23'),
    ('clarinet', 'beginner', 70.00, '2023-11-23'),
    ('clarinet', 'intermediate', 70.00, '2023-11-23'),
    ('harp', 'beginner', 100.00, '2023-11-23')
) AS "p" ("instrument_name", "skill_level_name", "price_per_month", "effective_date")
JOIN "instrument" AS "i" ON "p"."instrument_name" = "i"."name"
JOIN "skill_level" AS "s" ON "p"."skill_level_name" = "s"."level";

-- Populate the "group_lesson_price" table with group lesson prices for all instruments and skill levels (skipping harp and clarinet)
INSERT INTO "group_lesson_price" ("instrument_id", "skill_level_id", "price", "effective_date")
SELECT "i"."id", "s"."id", "p"."price_per_month", TO_DATE("p"."effective_date", 'YYYY-MM-DD')
FROM (
  VALUES
    ('guitar', 'beginner', 45.00, '2023-11-23'),
    ('guitar', 'intermediate', 45.00, '2023-11-23'),
    ('guitar', 'advanced', 65.00, '2023-11-23'),
    ('piano', 'beginner', 50.00, '2023-11-23'),
    ('piano', 'intermediate', 50.00, '2023-11-23'),
    ('piano', 'advanced', 70.00, '2023-11-23'),
    ('violin', 'beginner', 55.00, '2023-11-23'),
    ('violin', 'intermediate', 55.00, '2023-11-23'), -- Set the same price for intermediate and beginner
    ('violin', 'advanced', 75.00, '2023-11-23'),
    ('drums', 'beginner', 35.00, '2023-11-23'),
    ('drums', 'intermediate', 35.00, '2023-11-23'), -- Set the same price for intermediate and beginner
    ('drums', 'advanced', 55.00, '2023-11-23'),
    ('saxophone', 'beginner', 60.00, '2023-11-23'),
    ('saxophone', 'intermediate', 60.00, '2023-11-23'), -- Set the same price for intermediate and beginner
    ('saxophone', 'advanced', 80.00, '2023-11-23'),
    ('flute', 'beginner', 25.00, '2023-11-23'),
    ('flute', 'intermediate', 25.00, '2023-11-23'), -- Set the same price for intermediate and beginner
    ('flute', 'advanced', 45.00, '2023-11-23'),
    ('trumpet', 'beginner', 50.00, '2023-11-23'),
    ('trumpet', 'intermediate', 50.00, '2023-11-23'), -- Set the same price for intermediate and beginner
    ('trumpet', 'advanced', 70.00, '2023-11-23'),
    ('bass guitar', 'beginner', 55.00, '2023-11-23'),
    ('bass guitar', 'intermediate', 55.00, '2023-11-23'), -- Set the same price for intermediate and beginner
    ('bass guitar', 'advanced', 75.00, '2023-11-23')
    -- Skip harp and clarinet
) AS "p" ("instrument_name", "skill_level_name", "price_per_month", "effective_date")
JOIN "instrument" AS "i" ON "p"."instrument_name" = "i"."name"
JOIN "skill_level" AS "s" ON "p"."skill_level_name" = "s"."level"
WHERE "i"."name" NOT IN ('harp', 'clarinet');

-- populate "session" table
INSERT INTO "session" ("start_time", "end_time")
VALUES
    ('2023-02-03 14:00:00', '2023-02-03 15:00:00'), --group lesson, guitar, beginner
    ('2023-01-15 14:30:00', '2023-01-15 15:30:00'), --group lesson, guitar, advanced
    ('2023-02-28 14:15:00', '2023-02-28 15:15:00'), --group lesson, trumpet, intermediate
    ('2023-03-10 17:45:00', '2023-03-10 18:45:00'), --group lesson, violin, advanced
    ('2023-04-05 16:30:00', '2023-04-05 17:30:00'), --individual, piano, beginner
    ('2023-05-20 14:45:00', '2023-05-20 15:45:00'), --individual, drums, intermediate
    ('2023-04-08 15:20:00', '2023-04-08 16:20:00'), --individual, flute, advanced
    ('2023-10-12 18:00:00', '2023-10-12 19:00:00'), --individual, bass guitar, beginner
    ('2023-03-25 14:10:00', '2023-03-25 15:10:00'), --individual, clarinet, beginner
    ('2023-09-03 16:30:00', '2023-09-03 17:30:00'), --individual, drums, beginner
    ('2023-10-15 15:45:00', '2023-10-15 16:45:00'), --individual, trumpet, intermediate
    ('2023-11-20 14:30:00', '2023-11-20 15:30:00'), --individual, clarinet, advanced
    ('2023-11-05 16:20:00', '2023-11-05 17:20:00'), --individual, violin, intermediate
    ('2023-01-08 18:00:00', '2023-01-08 19:00:00'), --individual, saxophone, advanced
    ('2023-02-17 14:45:00', '2023-02-17 15:45:00'), --individual, drums, beginner
    ('2023-03-21 15:30:00', '2023-03-21 16:30:00'), --individual, drums, advanced
    ('2023-04-02 17:15:00', '2023-04-02 18:15:00'), --ensemble, blues
    ('2023-05-10 16:00:00', '2023-05-10 17:00:00'), --ensemble, rock
    ('2023-09-28 14:30:00', '2023-09-28 15:30:00'), --ensemble, jazz
    ('2023-04-15 17:00:00', '2023-04-15 18:00:00'), --ensemble, rock
    ('2023-12-02 14:00:00', '2023-12-02 15:00:00'), --ensemble, rock
    ('2023-12-02 15:30:00', '2023-12-02 16:30:00'), --ensemble, jazz
    ('2023-12-03 16:45:00', '2023-12-03 17:45:00'), --ensemble, blues
    ('2023-12-04 18:00:00', '2023-12-04 19:00:00'), --ensemble, classical
    ('2023-12-04 19:15:00', '2023-12-04 20:15:00'); --ensemble, rock

-- populate group lesson
INSERT INTO "group_lesson" ("session_id", "instrument_id", "skill_level_id", "min_nr_of_students", "max_nr_of_students")
VALUES
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-02-03 14:00:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'guitar'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'beginner'),
     5, 10),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-01-15 14:30:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'guitar'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'advanced'),
     5, 15),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-02-28 14:15:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'trumpet'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'intermediate'),
     5, 15),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-03-10 17:45:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'violin'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'advanced'),
     5, 20);

-- populate individual lesson
INSERT INTO "individual_lesson" ("session_id", "instrument_id", "skill_level_id")
VALUES
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-04-05 16:30:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'piano'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'beginner')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-05-20 14:45:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'drums'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'intermediate')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-04-08 15:20:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'flute'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'advanced')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-10-12 18:00:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'bass guitar'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'beginner')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-03-25 14:10:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'clarinet'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'beginner')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-09-03 16:30:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'drums'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'beginner')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-10-15 15:45:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'trumpet'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'intermediate')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-11-20 14:30:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'clarinet'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'advanced')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-11-05 16:20:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'violin'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'intermediate')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-01-08 18:00:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'saxophone'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'advanced')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-02-17 14:45:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'drums'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'beginner')),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-03-21 15:30:00'),
     (SELECT "id" FROM "instrument" WHERE "name" = 'drums'),
     (SELECT "id" FROM "skill_level" WHERE "level" = 'advanced'));

-- populate ensemble
INSERT INTO "ensemble" ("session_id", "genre_id", "min_nr_of_students", "max_nr_of_students")
VALUES
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-04-02 17:15:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'blues'),
     3, 10),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-05-10 16:00:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'rock'),
     3, 6),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-09-28 14:30:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'jazz'),
     3, 8),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-04-15 17:00:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'rock'),
     3, 6),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-12-02 14:00:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'rock'),
     3, 6),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-12-02 15:30:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'jazz'),
     3, 5),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-12-03 16:45:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'blues'),
     2, 6),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-12-04 18:00:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'classical'),
     3, 10),
    ((SELECT "id" FROM "session" WHERE "start_time" = '2023-12-04 19:15:00'),
     (SELECT "id" FROM "genre" WHERE "name" = 'rock'),
     3, 8);

-- populate instructor_booking
INSERT INTO "instructor_booking" ("session_id", "instructor_id")
VALUES
    (61, 16),
    (62, 19),
    (63, 18),
    (64, 19),
    (65, 17),
    (66, 20),
    (67, 18),
    (68, 20),
    (69, 18),
    (70, 17),
    (71, 18),
    (72, 18),
    (73, 19),
    (74, 18),
    (75, 17),
    (76, 17),
    (77, 20),
    (78, 16),
    (79, 18),
    (80, 20);


-- populate student_booking
INSERT INTO "student_booking" ("session_id", "student_id")
VALUES
    (101, 64),
    (102, 65),
    (103, 66),
    (104, 67),
    (105, 68),
    (101, 69),
    (101, 70),
    (101, 71),
    (102, 72),
    (102, 73),
    (102, 74),
    (102, 75),
    (103, 76),
    (103, 77),
    (103, 78),
    (104, 79),
    (104, 64),
    (105, 80),
    (105, 81),
    (105, 72);