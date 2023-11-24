-- postgreSQL
-- file           : create_tables_soundgood_db.sql
-- Module         : task 2
-- Description    : Seminar 2, Conceptual Model
--                 
-- Course         : kth IV1351 Data Storage Paradigms
-- Author/Student : Elin Blomquist, Vincent Ferrigan
-- maintainer     : eblomq@kth.se, ferrigan@kth.se,

CREATE TABLE "person" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "personal_identity_number" CHAR(13) UNIQUE NOT NULL,
  "first_name" VARCHAR(100) NOT NULL,
  "last_name" VARCHAR(100) NOT NULL,
  "street" VARCHAR(100) NOT NULL,
  "zip" VARCHAR(10) NOT NULL,
  "city" VARCHAR(100) NOT NULL,
  "phone" VARCHAR(50) NOT NULL,
  "email" VARCHAR(100) NOT NULL
);

CREATE TABLE "session" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "start_time" TIMESTAMP NOT NULL,
  "end_time" TIMESTAMP NOT NULL
);

CREATE TABLE "instrument" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "name" VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE "skill_level" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "level" VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE "genre" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "name" VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE "brand" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "name" VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE "discount" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "type_of_discount" VARCHAR(100),
  "discount_rate" FLOAT4
);

CREATE TABLE "contact_person" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "first_name" VARCHAR(100) NOT NULL,
  "last_name" VARCHAR(100) NOT NULL,
  "phone" VARCHAR(50) NOT NULL,
  "email" VARCHAR(100) NOT NULL
);

CREATE TABLE "student" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "person_id" INT UNIQUE NOT NULL,
  CONSTRAINT "fk.person"
    FOREIGN KEY ("person_id")
      REFERENCES "person"("id")
      ON DELETE CASCADE
);

CREATE TABLE "sibling" (
  "sibling_1" INT NOT NULL,
  "sibling_2" INT NOT NULL CHECK ("sibling_2" > "sibling_1"),
  CONSTRAINT "fk.student_1"
    FOREIGN KEY ("sibling_1")
      REFERENCES "student"("id")
      ON DELETE CASCADE,
  CONSTRAINT "fk.student_2"
    FOREIGN KEY ("sibling_2")
      REFERENCES "student"("id")
      ON DELETE CASCADE,
  PRIMARY KEY ("sibling_1", "sibling_2")
);

CREATE TABLE "student_contact_person" (
  "student_id" INT NOT NULL,
  "contact_person_id" INT NOT NULL,
  "relation" VARCHAR(100) NOT NULL,
  CONSTRAINT "fk.student"
    FOREIGN KEY ("student_id")
      REFERENCES "student"("id")
      ON DELETE CASCADE,
  CONSTRAINT "fk.contact_person"
    FOREIGN KEY ("contact_person_id")
      REFERENCES "contact_person"("id")
      ON DELETE CASCADE,
  PRIMARY KEY ("student_id", "contact_person_id")
);

CREATE TABLE "instructor" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "person_id" INT UNIQUE NOT NULL,
  CONSTRAINT "fk.person"
    FOREIGN KEY ("person_id")
      REFERENCES "person"("id")
      ON DELETE CASCADE
);

CREATE TABLE "instructor_booking" (
  "instructor_id" INT NOT NULL,
  "session_id" INT NOT NULL,
  CONSTRAINT "fk.instructor"
    FOREIGN KEY ("instructor_id")
      REFERENCES "instructor"("id"),
  CONSTRAINT "fk.session"
    FOREIGN KEY ("session_id")
      REFERENCES "session"("id"),
  PRIMARY KEY ("instructor_id", "session_id")
);

CREATE TABLE "student_booking" (
  "student_id" INT NOT NULL,
  "session_id" INT NOT NULL,
  CONSTRAINT "fk.student"
    FOREIGN KEY ("student_id")
      REFERENCES "student"("id"),
  CONSTRAINT "fk.session"
    FOREIGN KEY ("session_id")
      REFERENCES "session"("id"),
  PRIMARY KEY ("student_id", "session_id")
);

CREATE TABLE "instructor_instrument" (
  "instructor_id" INT NOT NULL,
  "instrument_id" INT NOT NULL,
  CONSTRAINT "fk.instructor"
    FOREIGN KEY ("instructor_id")
      REFERENCES "instructor"("id")
      ON DELETE CASCADE,
  CONSTRAINT "fk.instrument"
    FOREIGN KEY ("instrument_id")
      REFERENCES "instrument"("id")
      ON DELETE CASCADE,
  PRIMARY KEY ("instructor_id", "instrument_id")
);

CREATE TABLE "rentable_instrument" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "instrument_id" INT NOT NULL,
  "brand_id" INT NOT NULL,
  CONSTRAINT "fk.instrument"
    FOREIGN KEY ("instrument_id")
      REFERENCES "instrument"("id"),
  CONSTRAINT "fk.brand"
    FOREIGN KEY ("brand_id")
      REFERENCES "brand"("id")
);

CREATE TABLE "rentals" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "student_id" INT NOT NULL,
  "rentable_instrument_id" INT NOT NULL,
  "time_of_rent" TIMESTAMP NOT NULL,
  "return_time" TIMESTAMP,
  -- return_time is nullable. Is there a way to fix this?
  "lease_end_time" TIMESTAMP NOT NULL,
  -- CHECK if lease_end_time is max 12 months after time_of_rent
  -- default lease_end_time 12 months after time_of_rent
  -- TODO Should it be connected to some kind of business logic table????
  CONSTRAINT "fk.student"
    FOREIGN KEY ("student_id")
      REFERENCES "student"("id"),
  CONSTRAINT "fk.rentable_instrument"
    FOREIGN KEY ("rentable_instrument_id")
      REFERENCES "rentable_instrument"("id")
);

CREATE TABLE "group_lesson" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "session_id" INT NOT NULL,
  "instrument_id" INT NOT NULL,
  "skill_level_id" INT NOT NULL,
  "min_nr_of_students" INT NOT NULL,
  "max_nr_of_students" INT NOT NULL,
  CONSTRAINT "fk.session"
    FOREIGN KEY ("session_id")
      REFERENCES "session"("id"),
  CONSTRAINT "fk.instrument"
    FOREIGN KEY ("instrument_id")
      REFERENCES "instrument"("id"),
  CONSTRAINT "fk.skill_level"
    FOREIGN KEY ("skill_level_id")
      REFERENCES "skill_level"("id")
);


CREATE TABLE "individual_lesson" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "session_id" INT NOT NULL,
  "instrument_id" INT NOT NULL,
  "skill_level_id" INT NOT NULL,
  CONSTRAINT "fk.session"
    FOREIGN KEY ("session_id")
      REFERENCES "session"("id"),
  CONSTRAINT "fk.instrument"
    FOREIGN KEY ("instrument_id")
      REFERENCES "instrument"("id"),
  CONSTRAINT "fk.skill_level"
    FOREIGN KEY ("skill_level_id")
      REFERENCES "skill_level"("id")
);

CREATE TABLE "ensemble" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "session_id" INT NOT NULL,
  "genre_id" INT NOT NULL,
  "min_nr_of_students" INT NOT NULL,
  "max_nr_of_students" INT NOT NULL,
  CONSTRAINT "fk.session"
    FOREIGN KEY ("session_id")
      REFERENCES "session"("id"),
  CONSTRAINT "fk.genre"
    FOREIGN KEY ("genre_id")
      REFERENCES "genre"("id")
);

CREATE TABLE "group_lesson_price" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "instrument_id" INT NOT NULL,
  "skill_level_id" INT NOT NULL,
  -- CURRENCY??
  "price" FLOAT4 NULL,
  "effective_date" DATE NOT NULL,
  -- NULLABLE END DATE???
  CONSTRAINT "fk.instrument"
    FOREIGN KEY ("instrument_id")
      REFERENCES "instrument"("id"),
  CONSTRAINT "fk.skill_level"
    FOREIGN KEY ("skill_level_id")
      REFERENCES "skill_level"("id")
);


CREATE TABLE "individual_lesson_price" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "instrument_id" INT NOT NULL,
  "skill_level_id" INT NOT NULL,
  -- CURRENCY??
  "price" FLOAT4 NULL,
  "effective_date" DATE NOT NULL,
  -- NULLABLE END DATE???
  CONSTRAINT "fk.instrument"
    FOREIGN KEY ("instrument_id")
      REFERENCES "instrument"("id"),
  CONSTRAINT "fk.skill_level"
    FOREIGN KEY ("skill_level_id")
      REFERENCES "skill_level"("id")
);

CREATE TABLE "ensemble_price" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "genre_id" INT NOT NULL,
  -- CURRENCY??
  "price" FLOAT4 NULL,
  "effective_date" DATE NOT NULL,
  -- NULLABLE END DATE???
  CONSTRAINT "fk.genre"
    FOREIGN KEY ("genre_id")
      REFERENCES "genre"("id")
);

CREATE TABLE "instrument_price_list" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "instrument_id" INT NOT NULL,
  -- CURRENCY??
  "price_per_month" FLOAT4 NOT NULL,
  "effective_date" DATE NOT NULL,
  -- NULLABLE END DATE or OUTGOING BOOLEAN???
  CONSTRAINT "fk.instrument"
    FOREIGN KEY ("instrument_id")
      REFERENCES "instrument"("id")
      ON DELETE CASCADE
);
