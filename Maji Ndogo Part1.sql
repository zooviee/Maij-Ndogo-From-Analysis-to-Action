-- Beginning our data driven journey in Maji Ndogo


-- This query returns the list of tables in the md_water_services database
-- There are 8 tables in the database
SHOW TABLES;


-- 	Getting to know our data
-- Exploring each table in the database


/* The data_dictionary table contains information about the 
table names, columns, description, datatype and entity relationship*/
SELECT *
FROM data_dictionary
LIMIT 5;


-- Exploring the employee table
/* We can see that this table has information about the employees and their personal information like 
phone number, email, address, province name, town, and their respective job position/type.*/
SELECT *
FROM employee
LIMIT 5;


-- Exploring the global_water_access table
/* This table contains information about the country name, region, population size, year,
global access to basic, limited, unimproved, and surface water on the national, rural, and urban level.*/
SELECT *
FROM global_water_access
LIMIT 5;


-- Exploring the location table
/* So we can see that this table has information on a specific location, with an address, 
the province and town the location is in, and if it's in a city (Urban) or not. 
We can't really see what location this is but we can see some sort of identifying number of that location.*/
SELECT *
FROM location
LIMIT 5;


-- Exploring the visits table
/* The visits table holds information on each employee's visits, source and location, time of record,
visit count, time in queue.*/
SELECT *
FROM visits
LIMIT 5;


-- Exploring the water_quality table
/* The water_quality table contains information about the subjective quality score and visit count.*/
SELECT *
FROM water_quality
LIMIT 5;


-- Exploring the water_source table
/* The water_source table logs information about each source like where it is, what type of source,
it is and number of people served.*/
SELECT *
FROM water_source
LIMIT 5;


-- Exploring the well_pollution table
/* The well_pollution table contains information about the type of pollution, source id 
and date recorded,pollutant concentration, biological contamination and results.*/
SELECT *
FROM well_pollution
LIMIT 5;


-- Diving into water sources
/* This query returns the unique water sources in the water_source table.
There are 5 unique types of water source listed.*/ 
SELECT DISTINCT type_of_water_source
FROM water_source;


-- Unpacking the visits to water sources
/* This query returns the information about the visits table where the 
estimated time to get water takes approximately 8 hours.*/
SELECT * 
FROM visits
WHERE time_in_queue > 500
LIMIT 10;


/* Investigating the type of water sources with approximately 8 hours for people to get water.
It appears that only shared taps fall into this category.*/ 
SELECT 
	ws.source_id,
    type_of_water_source,
    number_of_people_served,
    time_in_queue
FROM water_source AS ws
INNER JOIN visits AS vs
ON ws.source_id = vs.source_id
WHERE vs.time_in_queue > 500;


-- Further investigation of the types of water sources
SELECT 
	source_id,
    type_of_water_source,
    number_of_people_served
FROM water_source 
WHERE source_id IN ('AkKi00881224', 'AkLu01628224', 'AkRu05234224',
					'HaRu19601224', 'HaZa21742224', 'SoRu36096224',
                    'SoRu37635224', 'SoRu38776224');


-- Assessing the quality of water sources
SELECT *
FROM water_quality
WHERE visit_count >= 2 AND subjective_quality_score = 10;


-- Investigating pollution sources
SELECT *
FROM well_pollution
WHERE results = "Clean" AND biological > 0.01
LIMIT 5;


-- Dealing with inconsistences in the description column
SELECT description
FROM well_pollution
WHERE description LIKE 'Clean_%';


-- Updating the description column with the correct input for Bacteria: E. coli
UPDATE 
	well_pollution
SET 
	description = 'Bacteria: E. coli'
WHERE 
	description = 'Clean Bacteria: E. coli';


-- Updating the description column with the correct input for Bacteria: Giardia Lamblia
UPDATE 
	well_pollution
SET 
	description = 'Bacteria: Giardia Lamblia'
WHERE 
	description = 'Clean Bacteria: Giardia Lamblia';
    
 
 -- Validating the results column with the correct input
UPDATE 
	well_pollution
SET
	results =  'Contaminated: Biological'   
WHERE 
	biological > 0.01 AND results = 'Clean';