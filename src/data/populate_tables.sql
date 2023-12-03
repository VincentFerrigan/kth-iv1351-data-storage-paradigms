-- postgreSQL
-- file           : populate_tables.sql
-- Module         : Script for populating tables with data
--                  It calls procedures in src/procedures/procedures.sql
-- Description    : Seminar 3, SQL
--                 
-- Course         : kth IV1351 Data Storage Paradigms
-- Author/Student : Elin Blomquist, Vincent Ferrigan
-- maintainer     : eblomq@kth.se, ferrigan@kth.se,

-- CONFIGURATIONS
-- These magic numbers are subject to change or might differ based on business logic,
-- OPEN ISSUE: the script for creating the system_configuration table fits well
-- in a schema or database directory within src/, while the script for inserting
-- configuration keys and values could go into either config/ or a data-seeding
-- directory within src/, depending on how you view these configurations in the
-- context of your application setup and deployment.
INSERT INTO system_configuration (config_key, config_value) 
VALUES ('max_rentables_per_student', 2),
       ('min_siblings_for_discount', 2),
       ('lease_duration_months', 12);

-- Course Type
INSERT INTO "course_type" ("name") 
VALUES ('individual'), ('group'), ('ensemble');

-- Genre    
INSERT INTO "genre" ("name") 
VALUES ('gospel'), ('punk'), ('rock'), ('jazz'), ('hip-hop'), 
('country'),('electronic'), ('reggae'), ('blues'), ('classical');

-- Skill levels
INSERT INTO "skill_level" ("name") 
VALUES ('beginner'), ('intermediate'), ('advanced');

-- Insert instrument names
INSERT INTO "instrument" ("name") VALUES
  ('guitar'), ('piano'), ('violin'), ('drums'), ('saxophone'), ('flute'), 
  ('trumpet'), ('bass guitar'), ('clarinet'), ('harp');

-- Insert brand names for instruments
INSERT INTO "brand" ("name") 
VALUES ('gibson'), ('fender'), ('martin'), ('ibanez'), ('yamaha'), ('roland'),
  ('korg'), ('pearl'), ('ludwig'), ('stradivarius'), ('steinway & sons'),
  ('selmer'), ('celtic harps'), ('miyazawa'), ('gemeinhardt'), ('muramatsu');

-- Populate rentable_instrument
CALL p_add_rentable_instrument('guitar', 'gibson', 5);
CALL p_add_rentable_instrument('guitar', 'fender', 5);
CALL p_add_rentable_instrument('guitar', 'ibanez', 5);
CALL p_add_rentable_instrument('piano', 'yamaha', 5);
CALL p_add_rentable_instrument('piano', 'martin', 5);
CALL p_add_rentable_instrument('piano', 'steinway & sons', 5);
CALL p_add_rentable_instrument('piano', 'roland', 5);
CALL p_add_rentable_instrument('piano', 'korg', 5);
CALL p_add_rentable_instrument('violin', 'stradivarius', 5);
CALL p_add_rentable_instrument('drums', 'pearl', 5);
CALL p_add_rentable_instrument('drums', 'ludwig', 5);
CALL p_add_rentable_instrument('saxophone', 'selmer', 5);
CALL p_add_rentable_instrument('flute', 'miyazawa', 5);
CALL p_add_rentable_instrument('flute', 'gemeinhardt', 5);
CALL p_add_rentable_instrument('flute', 'muramatsu', 5);
CALL p_add_rentable_instrument('trumpet', 'yamaha', 5);
CALL p_add_rentable_instrument('bass guitar', 'fender', 5);
CALL p_add_rentable_instrument('clarinet', 'selmer', 5);
CALL p_add_rentable_instrument('harp', 'celtic harps', 5);

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

-- populate rentals
CALL p_rent_an_instrument('19951201-3332', 'trumpet', 'yamaha');
CALL p_rent_an_instrument('19901001-1111', 'guitar', 'fender');
CALL p_rent_an_instrument('19901001-1111', 'trumpet', 'yamaha');
CALL p_rent_an_instrument('19951201-3332', 'piano', 'yamaha');
CALL p_rent_an_instrument('19901211-2222', 'saxophone', 'selmer');
CALL p_rent_an_instrument('19901211-2222', 'clarinet', 'selmer');
CALL p_rent_an_instrument('19901101-2221', 'bass guitar', 'fender');