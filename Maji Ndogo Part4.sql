-- Charting the course of Maji Ndogo's water future

-- Joining the visits table to the location table
-- The query below returns the province, town, visit count and location id.
SELECT 
	l.province_name,
    l.town_name,
    v.visit_count,
    l.location_id
FROM
	visits AS v
JOIN
	location AS l 
ON
	v.location_id = l.location_id;


-- Joining the visits table to the location table and water source table 
/* The query below returns the province, town, type of water source, people served, 
number of time spent on queue(mins) for locations visited once.*/
SELECT 
	l.province_name,
    l.town_name,
    l.location_type,
    ws.type_of_water_source,
    ws.number_of_people_served,
    v.time_in_queue
FROM
	visits AS v
JOIN
	location AS l 
ON
	v.location_id = l.location_id
JOIN
	water_source AS ws
ON
	ws.source_id = v.source_id
WHERE v.visit_count = 1;
    

-- Joining the visits table to the well pollution, location, and water sources tables
/* The query below returns the province, town, type of water source, people served, time spent on queue(mins) 
and the pollution results status for each type of water source for locations visited once.*/
SELECT 
	l.province_name,
    l.town_name,
    l.location_type,
    ws.type_of_water_source,
    ws.number_of_people_served,
    v.time_in_queue,
    wp.results
FROM
	visits AS v
-- The well_pollution table contains information about the well sources only, so we use a left join to retrieve
-- the information about the wells and return null for the remaining water sources
LEFT JOIN
	well_pollution AS wp
ON 
	wp.source_id = v.source_id
JOIN
	location AS l 
ON
	v.location_id = l.location_id
JOIN
	water_source AS ws
ON
	ws.source_id = v.source_id
WHERE v.visit_count = 1;


-- Creating a view of the query above named combined_analysis_table for easy reference and analysis
CREATE VIEW combined_analysis_table AS (
-- This view assembles data from different tables into one to simplify analysis
	SELECT 
		l.province_name,
		l.town_name,
		l.location_type,
		ws.type_of_water_source AS source_type,
		ws.number_of_people_served AS people_served,
		v.time_in_queue,
		wp.results
	FROM
		visits AS v
	LEFT JOIN
		well_pollution AS wp
	ON 
		wp.source_id = v.source_id
	JOIN
		location AS l 
	ON
		v.location_id = l.location_id
	JOIN
		water_source AS ws
	ON
		ws.source_id = v.source_id
	WHERE v.visit_count = 1);
    
    
-- Building a pivot table for province and their types of water sources! 
-- This time, we want to break down our data into provinces or towns and source types.
WITH province_totals AS (-- This CTE calculates the population of each province
	SELECT
		province_name,
		SUM(people_served) AS total_ppl_serv
	FROM
		combined_analysis_table
	GROUP BY
		province_name
)
SELECT
	ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
	ROUND((SUM(CASE 
					WHEN source_type = 'river'
					THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE 
					WHEN source_type = 'shared_tap'
					THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE
					WHEN source_type = 'tap_in_home'
					THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE
					WHEN source_type = 'tap_in_home_broken'
					THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE
					WHEN source_type = 'well' 
					THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN
	province_totals pt
ON 
	ct.province_name = pt.province_name
GROUP BY
	ct.province_name
ORDER BY
	ct.province_name;
    

-- Let's aggregate the data per town now.
DROP TABLE IF EXISTS town_aggregated_water_access;
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
--  This CTE calculates the population of each town.
-- Since there are two Harare towns in two provinces (Akatsi and Kilimani), we have to group by province_name and town_name
-- This ensures that we retrieve the distinct town names in each province.
SELECT 
	province_name, 
    town_name, 
    SUM(people_served) AS total_ppl_serv
FROM 
	combined_analysis_table
GROUP BY 
	province_name,
    town_name
)
SELECT
	ct.province_name,
	ct.town_name,
	ROUND((SUM(CASE 
					WHEN source_type = 'river'
					THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE 
					WHEN source_type = 'shared_tap'
					THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE
					WHEN source_type = 'tap_in_home'
					THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE
					WHEN source_type = 'tap_in_home_broken'
					THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE 
					WHEN source_type = 'well'
					THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
-- Since the town names are not unique, we have to join on a composite key
JOIN
	town_totals tt 
ON 
	ct.province_name = tt.province_name 
    AND 
    ct.town_name = tt.town_name
-- group by province first, then by town.
GROUP BY
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;
    

-- The query below returns the town that has the highest ratio of people who have taps, but have no running water
SELECT
	province_name,
	town_name,
	ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_broken_taps
FROM
	town_aggregated_water_access;
    
 
 -- Our final task, create a table where our teams have the information they need to fix, upgrade and repair water sources.
 
-- Creating our progress report table
CREATE TABLE Project_progress (
	Project_id SERIAL PRIMARY KEY,
	source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
	Address VARCHAR(50),
	Town VARCHAR(30),
	Province VARCHAR(30),
	Source_type VARCHAR(50),
	Improvement VARCHAR(50),
	Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
	Date_of_completion DATE,
	Comments TEXT
);


-- The description of each project_progress table atrribute is given below.

-- Project_id - 		Unique key for sources in case we visit the same source more than once in the future.
-- source_id − 			Each of the sources we want to improve should exist, and should refer to the source table. This ensures data integrity.
-- Address − 			Street address where the location of the water source is situated
-- Town - 				Name of the town where the location of the water source is situated
-- Province - 			Name of the province where the location of the water source is situated
-- Source_type - 		Type of category of the water source. Can be: tap_in_home, tap_in_home_broken, well, shared_type, river
-- Improvement − 		What the engineers should do at that place
-- Source_status − 		We want to limit the type of information engineers can give us, so we limit Source_status.
--                  	By DEFAULT all projects are in the "Backlog" which is like a TODO list.
--                  	CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
-- Date_of_completion − Engineers will add this the day the source has been upgraded.
-- Comments − 			Engineers can leave comments.


-- Inserting values in the progress report table
INSERT INTO Project_progress (`Source_id`, `Address`, `Town`, `Province`, `Source_type`, `Improvement`)
SELECT
	ws.source_id,
	l.address,
	l.town_name,
	l.province_name,
	ws.type_of_water_source,
    CASE 
		WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN wp.results = 'Contaminated: Biological' THEN  'Install UV and RO filter'
        WHEN ws.type_of_water_source = 'river' THEN 'Drill wells'
        WHEN ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 THEN CONCAT("Install ", FLOOR(v.time_in_queue/30), " taps nearby")
        WHEN ws.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
	END AS Improvements
FROM
	water_source AS ws
LEFT JOIN
	well_pollution AS wp
ON 
	ws.source_id = wp.source_id
INNER JOIN
	visits AS v
ON 
	ws.source_id = v.source_id
INNER JOIN
	location AS l
ON 
	l.location_id = v.location_id
WHERE 
	v.visit_count = 1
    AND (
		wp.results != 'Clean'
		OR ws.type_of_water_source IN ('tap_in_home_broken','river')
		OR (ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30)
);


-- verify the project_progress table data
SELECT
	*
FROM
	project_progress;