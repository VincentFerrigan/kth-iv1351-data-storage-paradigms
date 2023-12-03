-- Query 1: Number of lessons per month
CREATE VIEW number_of_lessons AS
SELECT EXTRACT(MONTH FROM s.start_time) AS "Month",
       COUNT(s.id) AS "Total",
       COUNT(i_l.id) AS "Individual Lessons",
       COUNT(g_l.id) AS "Group Lessons",
       COUNT(e.id) AS "Ensembles"

FROM session AS s

LEFT JOIN individual_lesson AS i_l
    ON i_l.session_id = s.id

LEFT JOIN group_lesson AS g_l
    ON g_l.session_id = s.id

LEFT JOIN ensemble AS e
    ON e.session_id = s.id

WHERE EXTRACT(YEAR FROM s.start_time) = '2023'

GROUP BY EXTRACT(MONTH FROM s.start_time)
ORDER BY EXTRACT(MONTH FROM s.start_time);


-- Query 2: Number of students with siblings
CREATE VIEW number_of_siblings AS
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


-- Query 3: Number of given lessons per instructor the current month
CREATE VIEW monthly_given_lessons AS
SELECT i.id AS "ID",
       p.first_name AS "First name",
       p.last_name AS "Last name",
       COUNT(*) AS "Given lessons"
FROM instructor_booking i_b
    INNER JOIN instructor i ON i_b.instructor_id = i.id
    INNER JOIN person p ON i.person_id = p.id
    INNER JOIN session s ON i_b.session_id = s.id
WHERE s.start_time >= date_trunc('month', '2023-11-28 20:00:00'::timestamp) --date_trunc('month', CURRENT_DATE) --0 in december

GROUP BY i.id, p.first_name, p.last_name
ORDER BY "Given lessons" DESC;


--Query 4: View of a ensembles next week
CREATE VIEW ensembles_next_week AS
SELECT to_char(s.start_time, 'Day') AS day_of_week,
       g.name AS genre,
    CASE
        WHEN e.max_nr_of_students - COUNT(sb.student_id) = 0 THEN 'No seats'
        WHEN e.max_nr_of_students - COUNT(sb.student_id) BETWEEN 1 AND 2 THEN '1-2 Seats Left'
        ELSE 'Many seats'
        END AS availability
FROM ensemble AS e
JOIN session AS s ON e.session_id = s.id
JOIN genre AS g ON e.genre_id = g.id
LEFT JOIN student_booking AS sb ON e.session_id = sb.session_id

WHERE s.start_time >= CURRENT_DATE
  AND s.start_time < CURRENT_DATE + INTERVAL '1 week'

GROUP BY s.start_time, g.name, e.max_nr_of_students
ORDER BY g.name, s.start_time;

-- ALTERNATIVE
-- Q1 
-- Show the number of lessons given per month during a specified year. 
-- OI should A make an OLAP out of it?
-- OI Should I create a function instead? Like in Q3???
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
GROUP BY to_char(s."start_time", 'Mon'), EXTRACT(YEAR FROM s."start_time");
-- ORDER BY EXTRACT(YEAR FROM s."start_time"), MIN(EXTRACT(MONTH FROM s."start_time"));

-- Q1 view in use were both select and order is used. Should I make this one into a function? 
SELECT "Month", "Total", "Individual", "Group", "Ensemble"
FROM view_course_type_summary
WHERE "Year" = 2023
ORDER BY (EXTRACT(MONTH FROM TO_DATE("Month", 'Mon')));

-- Q1 as function
-- Show the number of lessons given per month during a given year. 
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

-- Q2 
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

-- Q3
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

-- Q4
SELECT to_char(s.start_time, 'Dy') AS "Day",
       g.name AS "Genre",
    CASE
        WHEN e.max_nr_of_students - COUNT(sb.student_id) = 0 THEN 'No Seats'
        WHEN e.max_nr_of_students - COUNT(sb.student_id) BETWEEN 1 AND 2 THEN '1 or 2 Seats'
        ELSE 'Many Seats'
        END AS "No. of Free Seats"
FROM ensemble AS e
JOIN session AS s ON e.session_id = s.id
JOIN genre AS g ON e.genre_id = g.id
LEFT JOIN student_booking AS sb ON e.session_id = sb.session_id

WHERE s.start_time >= CURRENT_DATE
  AND s.start_time < CURRENT_DATE + INTERVAL '1 week'

GROUP BY s.start_time, g.name, e.max_nr_of_students
ORDER BY g.name, s.start_time;