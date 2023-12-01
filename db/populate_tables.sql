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

-- DEBUGG
-- SELECT
--     ri.id AS rentable_instrument_id,
--     i.name AS instrument_name,
--     b.name AS brand_name,
--     ip.price_per_month AS instrument_price
-- FROM
--     "rentable_instrument" AS ri
-- JOIN
--     "instrument" AS i ON ri.instrument_id = i.id
-- JOIN
--     "brand" AS b ON ri.brand_id = b.id
-- JOIN
--     "instrument_price_list" AS ip ON ri.instrument_id = ip.instrument_id
-- ORDER BY
--     ri.id;

-- Insert 5 instructors into the "person" and "instructor" tables
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19620523-0551', 'Erik', 'Eriksson', 'Storgatan 5', '12345', 'Stockholm', '+46 8 123 456 78', 'erik@gmail.com');

INSERT INTO "instructor" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19620523-0551';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19620523-0552', 'Anna', 'Andersson', 'Lillgatan 7', '12345', 'Göteborg', '+46 8 234 567 89', 'anna@yahoo.com');

INSERT INTO "instructor" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19620523-0552';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19620523-0553', 'Björn', 'Borg', 'Turegatan 10', '118 18', 'Malmö', '+46736369741', 'bjorn@gmail.com');

INSERT INTO "instructor" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19620523-0553';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19620523-0554', 'Karin', 'Karlsson', 'Sjögatan 3', '12345', 'Uppsala', '+46 8 345 678 90', 'karin@yahoo.com');

INSERT INTO "instructor" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19620523-0554';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19620523-0555', 'Göran', 'Gustafsson', 'Åsgatan 8', '12345', 'Linköping', '+46 8 456 789 01', 'goran@gmail.com');

INSERT INTO "instructor" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19620523-0555';


-- Insert 5 students into the "person" and "student" tables
-- Students with three siblings sharing the same last name and address
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19901001-1111', 'Oliver', 'Andersson', 'Västergatan 1', '12345', 'Stockholm', '+46 8 111 222 33', 'oliver@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19901001-1111';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19902001-1112', 'Emma', 'Andersson', 'Västergatan 1', '12345', 'Stockholm', '+46 8 222 333 44', 'emma@yahoo.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19902001-1112';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19901007-1113', 'Liam', 'Andersson', 'Västergatan 1', '12345', 'Stockholm', '+46 8 333 444 55', 'liam@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19901007-1113';

-- Students with two siblings sharing the same last name and address
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19901101-2221', 'Mia', 'Björk', 'Solgatan 5', '54321', 'Göteborg', '+46 31 555 666 77', 'mia@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19901101-2221';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19901211-2222', 'Lucas', 'Björk', 'Solgatan 5', '54321', 'Göteborg', '+46 31 666 777 88', 'lucas@yahoo.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19901211-2222';

-- Another set of students with two siblings sharing the same last name and address
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19901201-3331', 'Ella', 'Larsson', 'Rosengatan 2', '65432', 'Malmö', '+46736366661', 'ella@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19901201-3331';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19951201-3332', 'Noah', 'Larsson', 'Rosengatan 2', '65432', 'Malmö', '+46736366662', 'noah@yahoo.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19951201-3332';

-- Insert 40 students into the "person" and "student" tables
-- Students with no siblings
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910222-4441', 'William', 'Gustafsson', 'Mångatan 4', '98765', 'Uppsala', '+46 18 888 999 00', 'william@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910222-4441';

-- Students with a sibling
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910301-5551', 'Lilly', 'Karlsson', 'Björkgatan 6', '34567', 'Stockholm', '+46 8 111 222 33', 'lilly@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910301-5551';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19820301-5552', 'Charlie', 'Karlsson', 'Björkgatan 6', '34567', 'Stockholm', '+46 8 222 333 44', 'charlie@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19820301-5552';

-- Students with two siblings
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910401-6661', 'Sophia', 'Larsson', 'Skogsgatan 7', '54321', 'Göteborg', '+46 31 111 222 33', 'sophia@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910401-6661';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('20010612-6662', 'Aiden', 'Larsson', 'Skogsgatan 7', '54321', 'Göteborg', '+46 31 222 333 44', 'aiden@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '20010612-6662';

-- Students with three siblings
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910501-7771', 'Mila', 'Andersson', 'Sjögatan 5', '43210', 'Malmö', '+46736366663', 'mila@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910501-7771';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('20000912-7772', 'Henry', 'Andersson', 'Sjögatan 5', '43210', 'Malmö', '+46736366664', 'henry@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '20000912-7772';

-- Insert more students with random data
-- Students with no siblings
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910601-8881', 'Isabella', 'Eriksson', 'Åsgatan 3', '12345', 'Stockholm', '+46 8 555 666 77', 'isabella@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910601-8881';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910701-9991', 'Alexander', 'Svensson', 'Lillgatan 9', '54321', 'Göteborg', '+46 31 777 888 99', 'alexander@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910701-9991';

-- Students with a sibling
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910801-1010', 'Elsa', 'Nilsson', 'Bergsgatan 1', '98765', 'Uppsala', '+46 18 123 456 78', 'elsa@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910801-1010';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910802-2010', 'Oscar', 'Nilsson', 'Bergsgatan 1', '98765', 'Uppsala', '+46 18 234 567 89', 'oscar@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910802-2010';

-- Students with two siblings
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19910901-1111', 'Agnes', 'Björk', 'Norrgatan 2', '12345', 'Stockholm', '+46 8 987 654 32', 'agnes@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19910901-1111';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19920201-1111', 'Viktor', 'Björk', 'Norrgatan 2', '12345', 'Stockholm', '+46 8 876 543 21', 'victor@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19920201-1111';

-- Students with three siblings
INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19911001-1211', 'Selma', 'Lundqvist', 'Gatan 3', '43210', 'Malmö', '+46736377771', 'selma@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19911001-1211';

INSERT INTO "person" ("personal_identity_number", "first_name", "last_name", "street", "zip", "city", "phone", "email")
VALUES
    ('19941001-1212', 'Nils', 'Lundqvist', 'Gatan 3', '43210', 'Malmö', '+46736377772', 'nils@gmail.com');

INSERT INTO "student" ("person_id")
SELECT "id" FROM "person" WHERE "personal_identity_number" = '19914001-1212';


-- Populate the "sibling" table based on students with the same last name and address
INSERT INTO "sibling" ("sibling_1", "sibling_2")
SELECT DISTINCT s1."id", s2."id"
FROM "student" s1
JOIN "student" s2 ON s1."id" < s2."id"  -- Ensure students are different
JOIN "person" p1 ON s1."person_id" = p1."id"
JOIN "person" p2 ON s2."person_id" = p2."id"
WHERE p1."last_name" = p2."last_name"
  AND p1."street" = p2."street"
  AND p1."zip" = p2."zip"
  AND p1."city" = p2."city";


-- populate contact_person
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
INSERT INTO "student_contact_person" ("student_id", "contact_person_id", "relation")
VALUES
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Oliver' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Lena' AND "last_name" = 'Andersson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Emma' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Lena' AND "last_name" = 'Andersson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Liam' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Lena' AND "last_name" = 'Andersson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Mia' AND "last_name" = 'Björk')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Lena' AND "last_name" = 'Björk'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Lucas' AND "last_name" = 'Björk')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Lena' AND "last_name" = 'Björk'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Ella' AND "last_name" = 'Larsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Peter' AND "last_name" = 'Larsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Noah' AND "last_name" = 'Larsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Peter' AND "last_name" = 'Larsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Lilly' AND "last_name" = 'Karlsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Peter' AND "last_name" = 'Karlsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Charlie' AND "last_name" = 'Karlsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Peter' AND "last_name" = 'Karlsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Sophia' AND "last_name" = 'Larsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Henrik' AND "last_name" = 'Larsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Aiden' AND "last_name" = 'Larsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Henrik' AND "last_name" = 'Larsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Mila' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Ragnar' AND "last_name" = 'Andersson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Henry' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Ragnar' AND "last_name" = 'Andersson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Elsa' AND "last_name" = 'Nilsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Emma' AND "last_name" = 'Nilsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Oscar' AND "last_name" = 'Nilsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Emma' AND "last_name" = 'Nilsson'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Agnes' AND "last_name" = 'Björk')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Ritva' AND "last_name" = 'Björk'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Viktor' AND "last_name" = 'Björk')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Ritva' AND "last_name" = 'Björk'), 
     'Parent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'William' AND "last_name" = 'Gustafsson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'John' AND "last_name" = 'Doe'), 
     'Grandparent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Selma' AND "last_name" = 'Lundqvist')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Jane' AND "last_name" = 'Smith'), 
     'Grandparent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Isabella' AND "last_name" = 'Eriksson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Robert' AND "last_name" = 'Johnson'), 
     'Grandparent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Oliver' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Sarah' AND "last_name" = 'Wilson'), 
     'Grandparent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Emma' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Sarah' AND "last_name" = 'Wilson'), 
     'Grandparent'),
     ((SELECT "id" FROM "student" WHERE "person_id" = (SELECT "id" FROM "person" WHERE "first_name" = 'Liam' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "contact_person" WHERE "first_name" = 'Sarah' AND "last_name" = 'Wilson'), 
     'Grandparent');


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

-- Populate the "instructor_instrument" table with parent, guardian, and grandparent relationships TODO LOL
INSERT INTO "instructor_instrument" ("instructor_id", "instrument_id")
VALUES
     ((SELECT "id" FROM "instructor" 
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Erik' AND "last_name" = 'Eriksson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'piano')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Erik' AND "last_name" = 'Eriksson')), 
     (SELECT "id" FROM "instrument" WHERE "name" = 'guitar')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Erik' AND "last_name" = 'Eriksson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'harp')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Anna' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'drums')),
     ((SELECT "id" FROM "instructor" 
        WHERE "person_id" = (
            SELECT "id" FROM "person"  WHERE "first_name" = 'Anna' AND "last_name" = 'Andersson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'piano')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Björn' AND "last_name" = 'Borg')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'piano')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Björn' AND "last_name" = 'Borg')),
     (SELECT "id" FROM "instrument"  WHERE "name" = 'saxophone')),
     ((SELECT "id" FROM "instructor" 
        WHERE "person_id" = (
            SELECT "id" FROM "person"  WHERE "first_name" = 'Björn' AND "last_name" = 'Borg')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'flute')),
     ((SELECT "id" FROM "instructor" 
        WHERE "person_id" = (
            SELECT "id" FROM "person"  WHERE "first_name" = 'Björn' AND "last_name" = 'Borg')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'trumpet')),
     ((SELECT "id" FROM "instructor" 
        WHERE "person_id" = (
            SELECT "id" FROM "person"  WHERE "first_name" = 'Björn' AND "last_name" = 'Borg')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'clarinet')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Karin' AND "last_name" = 'Karlsson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'clarinet')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Karin' AND "last_name" = 'Karlsson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'violin')),
     ((SELECT "id" FROM "instructor" 
        WHERE "person_id" = (
            SELECT "id" FROM "person"  WHERE "first_name" = 'Karin' AND "last_name" = 'Karlsson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'guitar')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Göran' AND "last_name" = 'Gustafsson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'clarinet')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Göran' AND "last_name" = 'Gustafsson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'drums')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Göran' AND "last_name" = 'Gustafsson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'trumpet')),
     ((SELECT "id" FROM "instructor"  
        WHERE "person_id" = (
            SELECT "id" FROM "person" WHERE "first_name" = 'Göran' AND "last_name" = 'Gustafsson')),
     (SELECT "id" FROM "instrument" WHERE "name" = 'bass guitar'));


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