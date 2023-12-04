-- Query 1: Number of lessons per month
CREATE VIEW number_of_lessons AS
SELECT EXTRACT(MONTH FROM s.start_time) AS "Month",
       COUNT(s.id) AS "Total",
       COUNT(i_l.id) AS "Individual Lessons",
       COUNT(g_l.id) AS "Group Lessons",
       COUNT(e.id) AS "Ensembles"

FROM session AS s
    LEFT JOIN individual_lesson AS i_l ON i_l.session_id = s.id
    LEFT JOIN group_lesson AS g_l ON g_l.session_id = s.id
    LEFT JOIN ensemble AS e ON e.session_id = s.id

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
WHERE s.start_time >= date_trunc('month', CURRENT_DATE)

GROUP BY i.id, p.first_name, p.last_name
ORDER BY "Given lessons" DESC;


--Query 4: View of a ensembles next week
CREATE MATERIALIZED VIEW ensembles_next_week AS
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
