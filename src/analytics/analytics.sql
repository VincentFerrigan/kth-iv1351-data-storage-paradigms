-- postgreSQL
-- file           : analytics.sql
-- Module         : Script for analyzing the business and to create reports.
-- Description    : Seminar 3, SQL
--                 
-- Course         : KTH IV1351 Data Storage Paradigms
-- Author/Student : Elin Blomquist, Vincent Ferrigan
-- maintainer     : eblomq@kth.se, ferrigan@kth.se


-- # Q1 

-- ## VIEW
--    View the number of lessons given per year and month
CREATE OR REPLACE VIEW view_course_type_summary AS
SELECT 
    to_char(s."start_time", 'Mon') AS "Month",
    EXTRACT(YEAR FROM s."start_time") AS "Year",
    COUNT(s.id) AS "Total",
    COUNT(CASE WHEN ct."name" = 'individual' THEN 1 END) AS "Individual",
    COUNT(CASE WHEN ct."name" = 'group' THEN 1 END) AS "Group",
    COUNT(CASE WHEN ct."name" = 'ensemble' THEN 1 END) AS "Ensemble"
FROM "session" s 
JOIN "course_type" ct ON s."course_type_id" = ct."id"
WHERE s."start_time" < CURRENT_TIMESTAMP
GROUP BY to_char(s."start_time", 'Mon'), EXTRACT(YEAR FROM s."start_time");
-- ORDER BY EXTRACT(YEAR FROM s."start_time"), MIN(EXTRACT(MONTH FROM s."start_time"));

-- ## FUNCTION querying/filtering VIEW
--    Show a summary of the number of given lessons per month, filtered by given year, 
--    Example: SELECT * FROM fn_nbr_of_given_lessons_during_given_year(2023)
CREATE OR REPLACE FUNCTION fn_nbr_of_given_lessons_during_given_year(courseYear INT)
RETURNS TABLE(
    "Month" TEXT, 
	"Total" BIGINT, 
    "Individual" BIGINT, 
    "Group" BIGINT, 
    "Ensemble" BIGINT) AS $$
BEGIN
    RETURN QUERY
        SELECT v."Month", v."Total", v."Individual", v."Group", v."Ensemble"
        FROM view_course_type_summary AS v
        WHERE "Year" = courseYear
        ORDER BY (EXTRACT(MONTH FROM TO_DATE(v."Month", 'Mon')));
END;
$$ LANGUAGE plpgsql;

-- ## FUNCTION - QUERY
--    Show the number of lessons given per month during a given year. 
CREATE OR REPLACE FUNCTION fn_get_course_summary_by_year(courseYear INT)
RETURNS TABLE(
    "Month" TEXT, 
    "Total" INT, 
    "Individual" INT, 
    "Group" INT, 
    "Ensemble" INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        to_char(s."start_time", 'Mon') AS "Month",
        COUNT(s.id) AS "Total",
        COUNT(CASE WHEN ct."name" = 'individual' THEN 1 END) AS "Individual",
        COUNT(CASE WHEN ct."name" = 'group' THEN 1 END) AS "Group",
        COUNT(CASE WHEN ct."name" = 'ensemble' THEN 1 END) AS "Ensemble"
    FROM "session" s 
    JOIN "course_type" ct ON s."course_type_id" = ct."id"
    WHERE EXTRACT(YEAR FROM s."start_time") = courseYear
    GROUP BY to_char(s."start_time", 'Mon')
    ORDER BY MIN(EXTRACT(MONTH FROM s."start_time"));
END;
$$ LANGUAGE plpgsql;

-- ## Denormalized data layer for OLAP
--    Data layer
CREATE TABLE "olap_course_type_summary" (
    "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "Year" INT NOT NULL,
    "Month" TEXT NOT NULL,
    "Total" INT NOT NULL,
    "Individual" INT NOT NULL,
    "Group" INT NOT NULL,
    "Ensemble" INT NOT NULL
);

--    Populate table
INSERT INTO "olap_course_type_summary" ("Year", "Month", "Total", "Individual", "Group", "Ensemble")
SELECT 
    EXTRACT(YEAR FROM s."start_time") AS "Year",
    to_char(s."start_time", 'Mon') AS "Month",
    COUNT(s.id) AS "Total",
    COUNT(CASE WHEN ct."name" = 'individual' THEN 1 END) AS "Individual",
    COUNT(CASE WHEN ct."name" = 'group' THEN 1 END) AS "Group",
    COUNT(CASE WHEN ct."name" = 'ensemble' THEN 1 END) AS "Ensemble"
FROM "session" s 
JOIN "course_type" ct ON s."course_type_id" = ct."id"
WHERE s."start_time" < CURRENT_TIMESTAMP
GROUP BY EXTRACT(YEAR FROM s."start_time"), to_char(s."start_time", 'Mon');

SELECT * from olap_course_type_summary

--    Query as function
CREATE OR REPLACE FUNCTION get_olap_summary_for_year(courseYear INT)
RETURNS TABLE(
    "Month" TEXT,
    "Total" INT,
    "Individual" INT,
    "Group" INT,
    "Ensemble" INT
) AS $$
BEGIN
    RETURN QUERY
    	SELECT cts."Month", cts."Total", cts."Individual", cts."Group", cts."Ensemble"
        FROM "olap_course_type_summary" as cts
        WHERE cts."Year" = courseYear
        ORDER BY (EXTRACT(MONTH FROM TO_DATE(cts."Month", 'Mon')));
END;
$$ LANGUAGE plpgsql;

-- # Q2 
-- ## VIEW
--    View how many students there are with no sibling, with one sibling, etc...
CREATE OR REPLACE VIEW view_sibling_counts AS
WITH unified_siblings AS (
    SELECT "sibling_1" AS student_id FROM "sibling"
    UNION ALL
    SELECT "sibling_2" FROM "sibling"
),
sibling_counts AS (
    SELECT s."id", COUNT(us.student_id) AS "No. of Siblings"
    FROM "student" s
    LEFT JOIN unified_siblings AS us ON s."id" = us.student_id
    GROUP BY s."id"
)
SELECT "No. of Siblings", COUNT(*) AS "No. of Students"
FROM sibling_counts
GROUP BY "No. of Siblings"
ORDER BY "No. of Siblings";

-- ## Nested VIEW
-- View how many students there are with no sibling, with one sibling, etc...
CREATE VIEW view_number_of_siblings AS
(SELECT nr_siblings, COUNT(*) AS students
 FROM (
      SELECT sibling_id, COUNT(*) AS nr_siblings
      FROM (
           (SELECT sibling_1 AS sibling_id
           FROM sibling)
           UNION ALL
           (SELECT sibling_2 AS sibling_id
           FROM sibling)) AS all_siblings
      GROUP BY sibling_id
      ) AS sibling_counts
 GROUP BY nr_siblings)

UNION

(SELECT 0 AS nr_siblings, COUNT(*) AS students
 FROM student
     LEFT JOIN sibling ON (student.id = sibling.sibling_1 OR student.id = sibling.sibling_2)
 WHERE sibling.sibling_1 IS NULL OR sibling.sibling_2 IS NULL)

ORDER BY nr_siblings;

-- # Q3
-- ## FUNCTION - QUERY
--    List instructor ids and names who has given more than a specific number of
--    lessons during the current month
--    Indepented of type, sum all the lessons and sort the result by the nbr of
--    given lessons
CREATE OR REPLACE FUNCTION fn_get_instructor_lesson_counts_above_threshold(
    threshold INT
    ) RETURNS TABLE("Instructor Id" INT, "First name" VARCHAR(100), 
    "Last name" VARCHAR(100), "No. of Lessons" BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.instructor_id AS "Instructor Id",
           p."first_name" AS "First name",
           p."last_name" AS "Last name",
           COUNT(s.id) AS "No. of Lessons"
    FROM "session" AS s
        INNER JOIN "instructor" i ON s."instructor_id" = i.id
        INNER JOIN "person" p ON i."person_id" = p."id"
    WHERE 
        DATE_TRUNC('month', s."start_time") = DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY s.instructor_id, p."first_name", p."last_name"
    HAVING COUNT(s.id) > threshold
    ORDER BY "No. of Lessons" DESC;
END;
$$ LANGUAGE plpgsql;

-- # Q4
-- ## FUNCTION - QUERY
--    List all ensembles held during the week ahead
CREATE OR REPLACE FUNCTION get_ensemble_seats_availability()
RETURNS TABLE(
    "Day" TEXT,
    "Genre" VARCHAR(100),
    "No. of Free Seats" TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT to_char(s.start_time, 'Dy') AS "Day",
           g."name" AS "Genre",
           CASE
               WHEN e."max_nr_of_students" - COUNT(sb."student_id") = 0 THEN 'No Seats'
               WHEN e."max_nr_of_students" - COUNT(sb."student_id") BETWEEN 1 AND 2 THEN '1 or 2 Seats'
               ELSE 'Many Seats'
           END AS "No. of Free Seats"
    FROM "ensemble" AS e
    JOIN session AS s ON e."session_id" = s."id"
    JOIN "genre" AS g ON e."genre_id" = g."id"
    LEFT JOIN student_booking AS sb ON e."session_id" = sb."session_id"
    WHERE s."start_time" >= CURRENT_DATE
      AND s."start_time" < CURRENT_DATE + INTERVAL '1 week'
    GROUP BY s."start_time", g."name", e."max_nr_of_students"
    ORDER BY g."name", s."start_time";
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_ensemble_seats_availability();

-- HG
-- ## Denormalized data layer for OLAP
--    Data layer
CREATE TABLE "historical_stored_prices_of_lessons" (
    "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "lesson_type" VARCHAR(100) NOT NULL,
    "genre" VARCHAR(100),
    "instrument" VARCHAR(100),
    "skill" VARCHAR(100),
    "lesson_price" FLOAT4 NOT NULL,
    "student_first_name" VARCHAR(100) NOT NULL,
    "student_last_name" VARCHAR(100) NOT NULL,
    "Student_email" VARCHAR(100) NOT NULL
)

--    Populate table
INSER INTO "historical_stored_prices_of_lessons" (
    "lesson_type",
    "genre",
    "instrument",
    "skill",
    "lesson_price",
    "student_first_name",
    "student_last_name",
    "student_email"
)

-- Expermienting
-- Should it be stored exactly as they want it outputed or "star schema"
 SELECT
    ct.name AS "lesson",
    gen.name AS "genre",
	inst.name AS "instrument",
	sl.name AS "skill",
-- CALL FUNCTION THAT WILL SET CORRECT PRICE!!!
	-- calculate_lesson_price(
    --         s.course_type_id, 
    --         COALESCE(il.instrument_id, gl.instrument_id), 
    --         COALESCE(il.skill_level_id, gl.skill_level_id),
    --         s.start_time, -- to check validity
    --         sb.student_id -- to check discount
    --         ) AS "lesson_price",
	p.first_name,
	p.last_name,
	p.email,
    -- -- DEBUGG section of select
	-- sb.*,
    -- s.id,
    -- s.start_time,
    -- s.course_type_id,
    -- COALESCE(sb.session_id, il.session_id, gl.session_id, e.session_id) AS session_id,
    -- COALESCE(il.instrument_id, gl.instrument_id) AS instrument_id,
    -- COALESCE(il.skill_level_id, gl.skill_level_id) AS skill_level_id
FROM 
    "student_booking" AS sb
LEFT JOIN 
    "session" AS s ON sb.session_id = s.id
LEFT JOIN 
    "individual_lesson" AS il ON sb.session_id = il.session_id
LEFT JOIN 
    "group_lesson" AS gl ON sb.session_id = gl.session_id
LEFT JOIN 
    "ensemble" AS e ON sb.session_id = e.session_id
LEFT JOIN
	"course_type" AS ct ON s.course_type_id = ct.id
LEFT JOIN 
    "instrument" AS inst ON inst.id = COALESCE(il.instrument_id, gl.instrument_id)
LEFT JOIN 
    "genre" AS gen ON gen.id = e.genre_id
LEFT JOIN 
    "skill_level" AS sl ON sl.id = COALESCE(il.skill_level_id, gl.skill_level_id)
LEFT JOIN
    "student" AS student ON student.id = sb.student_id
LEFT JOIN
	"person" AS p ON p.id = student.person_id
WHERE 
    s.start_time < CURRENT_TIMESTAMP;

CREATE OR REPLACE FUNCTION calculate_lesson_price(
    courseTypeID INT, 
    instrumentID INT, 
    skillLevelID INT,
    startTime    TIMESTAMP
    studentID    INT
    ) RETURNS FLOAT4 AS $$
DECLARE  
    computed_price;
BEGIN
    -- Your calculation logic here
    RETURN computed_price;
END;
$$ LANGUAGE plpgsql;