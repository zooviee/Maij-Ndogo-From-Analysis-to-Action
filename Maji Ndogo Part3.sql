-- Weaving The Data Threads of Maji Ndogo's Narrative


-- Creating the auditor report table and importing the auditor report csv file in the table.


DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);


-- Comparing the quality scores in the water_quality table to the auditor's scores.
SELECT 
	ar.location_id,
	v.record_id,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
	auditor_report AS ar
INNER JOIN
	visits AS v
ON 
	ar.location_id = v.location_id
INNER JOIN
	water_quality AS w
ON
	v.record_id = w.record_id;
    

-- Investigating the auditor and employees' scores.
-- This query checks if the auditor's scores are equal to the surveyor's scores for each visit made to a location.
SELECT 
	ar.location_id,
     v.record_id,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
	auditor_report AS ar
INNER JOIN
	visits AS v
ON 
	ar.location_id = v.location_id
INNER JOIN
	water_quality AS w
ON
	v.record_id = w.record_id
WHERE
	ar.true_water_source_score = w.subjective_quality_score
	AND
	v.visit_count = 1;


-- Checking for incorrect records
-- This query checks if the auditor's scores are not equal to the surveyor's scores for each visit made to a location..
SELECT 
	ar.location_id,
	v.record_id,
    ar.type_of_water_source AS auditor_source,
    ws.type_of_water_source AS survey_source,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
	auditor_report AS ar
INNER JOIN
	visits AS v
ON 
	ar.location_id = v.location_id
INNER JOIN
	water_quality AS w
ON
	v.record_id = w.record_id
INNER JOIN
	water_source AS ws
ON
	v.source_id = ws.source_id
WHERE
	ar.true_water_source_score != w.subjective_quality_score
    AND
    v.visit_count = 1;
    

-- Joining the employee information
-- This query returns the names of the employees who made errors in their quality score observations
SELECT 
	ar.location_id,
	v.record_id,
    e.employee_name,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
	auditor_report AS ar
INNER JOIN
	visits AS v
ON 
	ar.location_id = v.location_id
INNER JOIN
	water_quality AS w
ON
	v.record_id = w.record_id
INNER JOIN
	employee AS e
ON
	v.assigned_employee_id = e.assigned_employee_id
WHERE
	ar.true_water_source_score != w.subjective_quality_score
    AND
    v.visit_count = 1;
    

-- Converting the above information as a common table expression (CTE)
WITH Incorrect_records AS (
	SELECT 
		ar.location_id,
		v.record_id,
		e.employee_name,
		ar.true_water_source_score AS auditor_score,
		w.subjective_quality_score AS employee_score
	FROM
		auditor_report AS ar
	INNER JOIN
		visits AS v
	ON 
		ar.location_id = v.location_id
	INNER JOIN
		water_quality AS w
	ON
		v.record_id = w.record_id
	INNER JOIN
		employee AS e
	ON
		v.assigned_employee_id = e.assigned_employee_id
	WHERE
		ar.true_water_source_score != w.subjective_quality_score
		AND
		v.visit_count = 1),
error_count AS (
	SELECT 
		employee_name,
		COUNT(*) AS number_of_mistakes
	FROM
		Incorrect_records
	GROUP BY
		employee_name)
    
    
-- Investigating employees with number of mistakes greater than the average number of mistakes
-- This query returns the employees who made mistakes more than the average (6) number of mistakes.
SELECT
	employee_name,
	ROUND(AVG(number_of_mistakes), 2) AS avg_number_of_mistakes
FROM
	error_count
WHERE
	number_of_mistakes > (SELECT ROUND(AVG(number_of_mistakes), 2) FROM error_count)
GROUP BY
	employee_name;
    

-- Creating a view of Incorrect records
CREATE VIEW Incorrect_records AS (
	SELECT
		ar.location_id,
		v.record_id,
		e.employee_name,
		ar.true_water_source_score AS auditor_score,
		wq.subjective_quality_score AS employee_score,
		ar.statements AS statements
	FROM
		auditor_report AS ar
	JOIN
		visits AS v
	ON 
		ar.location_id = v.location_id
	JOIN
		water_quality AS wq
	ON 
		v.record_id = wq.record_id
	JOIN
		employee AS e
	ON 
		e.assigned_employee_id = v.assigned_employee_id
	WHERE
		v.visit_count = 1
	AND 
		ar.true_water_source_score != wq.subjective_quality_score);
	

-- Creating the error count and suspect list CTEs
-- The query below creates a temporary table for error count of each employee and a suspect list containing "corrupt" employees.
WITH error_count AS (
	SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and employees scores are different*/
	GROUP BY
		employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes)
	SELECT
		employee_name,
		number_of_mistakes
	FROM
		error_count
	WHERE
		number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
        
        
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
	employee_name,
	location_id,
	statements
FROM
	Incorrect_records
WHERE
	employee_name IN (SELECT employee_name FROM suspect_list);
    

