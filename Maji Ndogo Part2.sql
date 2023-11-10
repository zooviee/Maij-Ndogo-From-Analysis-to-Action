-- Clustering data to unveil Maji Ndogo's water crisis.

-- Updating the employee's table with their respective email addresses.
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');


-- Removing trailing whitespaces from the phone numbers
UPDATE employee
SET phone_number = TRIM(phone_number);


-- Honouring the workers
SELECT
	town_name,
    COUNT(*) AS num_employees
FROM 
	employee
GROUP BY town_name
ORDER BY num_employees DESC;


-- Top 3 employees based on the visit count
SELECT 
	assigned_employee_id,
    COUNT(*) AS number_of_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY number_of_visits DESC
LIMIT 3;


-- Top 3 employee information
SELECT 
	employee_name,
    email,
    phone_number
FROM employee
WHERE assigned_employee_id IN (1, 30, 34);


-- Analysing Locations
-- Number of records per town  
SELECT 
	town_name,
    COUNT(*) AS number_of_records
FROM location
GROUP BY town_name
ORDER BY number_of_records DESC
LIMIT 5;


-- Number of records per province
SELECT 
	province_name,
    COUNT(*) AS number_of_records
FROM location
GROUP BY province_name
ORDER BY number_of_records DESC
LIMIT 5;


-- Number of records per province per town
SELECT 
	province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM 
	location
GROUP BY province_name, town_name
ORDER BY province_name ASC, records_per_town DESC
LIMIT 5;
    
    
-- Number of records per location type
SELECT 
	location_type,
    COUNT(*) AS num_sources
FROM
	location
GROUP BY location_type;


-- Expressing the number of records per location in percentages
-- Approximately 60% of ou water sources are in Rural communities across Maji Ndogo.
SELECT 
	(23740 / (15910 + 23740) * 100) AS pct_urban,
    (15910 / (15910 + 23740) * 100) AS pct_rural;
    

-- Diving into water sources


-- Number of people surveyed 
SELECT 
    SUM(number_of_people_served) AS total_num_of_people
FROM water_source;


-- Count of each water source
SELECT
	type_of_water_source,
    COUNT(*) AS num_of_records
FROM
	water_source
GROUP BY type_of_water_source
ORDER BY num_of_records DESC;


-- Average number of people per water source
SELECT 
	type_of_water_source,
    ROUND(AVG(number_of_people_served), 0) AS average_num_of_people
FROM water_source
GROUP BY type_of_water_source
ORDER BY average_num_of_people DESC;


-- Number of people getting water from each water source
SELECT 
	type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    ROUND(SUM((number_of_people_served) / 27628140 * 100), 0) AS percentage_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY total_num_of_people DESC;


-- Ranking water sources in order of priority
SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    RANK() OVER(ORDER BY SUM(number_of_people_served) DESC) AS rank_population
FROM water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC;


-- Ranking water sources with RANK()
SELECT
	source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER(PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('well', 'shared_tap', 'river')
ORDER BY type_of_water_source, priority_rank DESC;


-- Ranking water sources with DENSE_RANK()
SELECT
	source_id,
    type_of_water_source,
    number_of_people_served,
    DENSE_RANK() OVER(PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('well', 'shared_tap', 'river')
ORDER BY type_of_water_source, priority_rank DESC;


-- Ranking water sources with ROW_NUMBER()
SELECT
	source_id,
    type_of_water_source,
    number_of_people_served,
    ROW_NUMBER() OVER(PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('well', 'shared_tap', 'river')
ORDER BY type_of_water_source, priority_rank DESC;


-- Analysing queues


-- How long did the survey take?
SELECT 
	MIN(time_of_record) AS first_date,
    MAX(time_of_record) AS last_date,
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS Survey_length
FROM
	visits;
    

-- What is the average total queue time for water?
SELECT
	AVG(NULLIF(time_in_queue, 0))AS Avg_time_in_queue
FROM 
	visits;
    
    
-- What is the average queue time on different days?
SELECT 
	DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue,0)),0) AS avg_queue_time
FROM visits
GROUP BY DAYNAME(time_of_record);


-- How can we communicate this information efficiently?
SELECT 
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue,0)),0) AS avg_queue_time
FROM visits
GROUP BY TIME_FORMAT(TIME(time_of_record), '%H:00')
ORDER BY avg_queue_time DESC;


-- Drilling down for each time and day of the week
SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
	ROUND(AVG(
		CASE
		WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
		ELSE NULL
	END
		),0) AS Sunday,
	ROUND(AVG(
		CASE
		WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
		ELSE NULL
	END
		),0) AS Monday,
	ROUND(AVG(
		CASE
		WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
		ELSE NULL
	END
		),0) AS Tuesday,
	ROUND(AVG(
		CASE
		WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
		ELSE NULL
	END
		),0) AS Wednesday,
	ROUND(AVG(
		CASE
		WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
		ELSE NULL
	END
		),0) AS Thursday,
	ROUND(AVG(
		CASE
		WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
		ELSE NULL
	END
		),0) AS Friday,
	ROUND(AVG(
		CASE
		WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
		ELSE NULL
	END
		),0) AS Saturday
FROM
	visits
WHERE
	time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
	hour_of_day
ORDER BY
	hour_of_day;
  