-- Handling missing data

--Using a fill-in value

UPDATE
  parking_violation
SET
  -- Replace NULL vehicle_body_type values with `Unknown`
  vehicle_body_type= COALESCE(vehicle_body_type, 'Unknown');

SELECT COUNT(*) FROM parking_violation WHERE vehicle_body_type = 'Unknown';

--Analyzing incomplete records

SELECT
  -- Define the SELECT list: issuing_agency and num_missing
  issuing_agency,
  COUNT(*) AS num_missing
FROM
  parking_violation
WHERE
  -- Restrict the results to NULL vehicle_body_type values
  vehicle_body_type IS NULL
  -- Group results by issuing_agency
  GROUP BY issuing_agency
  -- Order results by num_missing in descending order
  ORDER BY num_missing DESC;

-- Handling duplicated data

--Duplicate parking violations

SELECT
  	summons_number,
    -- Use ROW_NUMBER() to define duplicate window
  	ROW_NUMBER() OVER(
         PARTITION BY
         plate_id, 
         issue_date, 
         violation_time, 
         house_number, 
         street_name 
    -- Modify ROW_NUMBER() value to define duplicate column
      )-1 AS duplicate, 
    plate_id, 
    issue_date, 
    violation_time, 
    house_number, 
    street_name
FROM 
	parking_violation;

SELECT 
	-- Include all columns 
	*
FROM (
	SELECT
  		summons_number,
  		ROW_NUMBER() OVER(
        	PARTITION BY 
            	plate_id, 
          		issue_date, 
          		violation_time, 
          		house_number, 
          		street_name
      	) - 1 AS duplicate, 
      	plate_id, 
      	issue_date, 
      	violation_time, 
      	house_number, 
      	street_name 
	FROM 
		parking_violation
) sub
WHERE
	-- Only return records where duplicate is 1 or more
	duplicate > 0;

--Resolving impartial duplicates

SELECT 
	-- Include SELECT list columns
	summons_number, 
    MIN(fee) AS fee
FROM 
	parking_violation 
GROUP BY
	-- Define column for GROUP BY
	summons_number 
HAVING 
	-- Restrict to summons numbers with count greater than 1
	COUNT(summons_number) > 1;

--Detecting invalid values

--Detecting invalid values with regular expressions

SELECT
  summons_number,
  plate_id,
  registration_state
FROM
  parking_violation
WHERE
  -- Define the pattern to use for matching
  registration_state = '\D+';

 SELECT
  summons_number,
  plate_id,
  plate_type
FROM
  parking_violation
WHERE
  -- Define the pattern to use for matching
  plate_type != '\D\D\D';

  SELECT
  summons_number,
  plate_id,
  vehicle_make
FROM
  parking_violation
WHERE
  -- Define the pattern to use for matching
   vehicle_make != '\D{/}{\s}'

--Identifying out-of-range vehicle model years

SELECT
  -- Define the columns to return from the query
  summons_number,
  plate_id,
  vehicle_year
FROM
  parking_violation
WHERE
  -- Define the range constraint for invalid vehicle years
  vehicle_year NOT BETWEEN 1970 AND 2021;

-- Detecting inconsistent data

--Identifying invalid parking violations

SELECT 
  -- Specify return columns
  summons_number, 
  violation_time, 
  from_hours_in_effect, 
  to_hours_in_effect
FROM 
  parking_violation 
WHERE 
  -- Condition on values outside of the restricted range
  violation_time NOT BETWEEN from_hours_in_effect AND to_hours_in_effect;

SELECT 
  summons_number, 
  violation_time, 
  from_hours_in_effect, 
  to_hours_in_effect 
FROM 
  parking_violation 
WHERE 
  -- Exclude results with overnight restrictions 
  from_hours_in_effect < to_hours_in_effect AND 
  violation_time NOT BETWEEN from_hours_in_effect AND to_hours_in_effect;

--Invalid violations with overnight parking restrictions

SELECT
  summons_number,
  violation_time,
  from_hours_in_effect,
  to_hours_in_effect
FROM
  parking_violation
WHERE
  -- Ensure from hours greater than to hours
  from_hours_in_effect > to_hours_in_effect AND
  -- Ensure violation_time less than from hours
  violation_time < from_hours_in_effect AND
  -- Ensure violation_time greater than to hours
  violation_time > to_hours_in_effect;

--Recovering deleted data

-- Select all zip codes from the borough of Manhattan
SELECT zip_code FROM nyc_zip_codes WHERE borough = 'Manhattan';

SELECT 
	event_id,
	CASE 
      WHEN zip_code IN (SELECT zip_code FROM nyc_zip_codes WHERE borough = 'Manhattan') THEN 'Manhattan' 
      -- Match Brooklyn zip codes
      WHEN zip_code IN (SELECT zip_code FROM nyc_zip_codes WHERE borough = 'Brooklyn') THEN 'Brooklyn'
      -- Match Bronx zip codes
      WHEN zip_code IN (SELECT zip_code FROM nyc_zip_codes WHERE borough = 'Bronx') THEN 'Bronx'
      -- Match Queens zip codes
      WHEN zip_code IN (SELECT zip_code FROM nyc_zip_codes WHERE borough = 'Queens') THEN 'Queens'
      -- Match Staten Island zip codes
      WHEN zip_code IN (SELECT zip_code FROM nyc_zip_codes WHERE borough = 'Staten Island') THEN 'Staten Island'
      -- Use default for non-matching zip_code
      ELSE NULL 
    END as borough
FROM
	film_permit;