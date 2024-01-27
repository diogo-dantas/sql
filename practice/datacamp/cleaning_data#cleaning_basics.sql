-- Introduction to data cleaning

--Applying functions for string cleaning

SELECT
  -- Add 0s to ensure violation_location is 4 characters in length
  LPAD(violation_location,4,'0') AS violation_location,
  -- Replace 'P-U' with 'TRK' in vehicle_body_type column
  REPLACE(vehicle_body_type,'P-U','TRK') AS vehicle_body_type,
  -- Ensure only first letter capitalized in street_name
  INITCAP(street_name) AS street_name
FROM parking_violation;

-- Patterning matching

--Classifying parking violations by time of day

SELECT 
	summons_number, 
    CASE WHEN 
    	summons_number IN (
          SELECT 
  			summons_number 
  		  FROM 
  			parking_violation 
  		  WHERE 
            -- Match violation_time for morning values
  			violation_time SIMILAR TO '\d\d\d\dA'
    	)
        -- Value when pattern matched
        THEN 1
        -- Value when pattern not matched
        ELSE 0 
    END AS morning 
FROM 
	parking_violation;

--Masking identifying information with regular expressions

SELECT 
	summons_number,
	-- Replace uppercase letters in plate_id with dash
	REGEXP_REPLACE(plate_id, '\D', '-', 'g') 
FROM 
	parking_violation;

--Matching similar strings

--Matching inconsistent color names

SELECT
  summons_number,
  vehicle_color
FROM
  parking_violation
WHERE
  -- Match SOUNDEX codes of vehicle_color and 'GRAY'
  DIFFERENCE(vehicle_color, 'GRAY') 

 SELECT 
	summons_number,
    vehicle_color,
	DIFFERENCE(vehicle_color, 'RED') AS "red",
	DIFFERENCE(vehicle_color, 'BLUE') AS "blue",
	DIFFERENCE(vehicle_color, 'YELLOW') AS "yellow"
FROM
	parking_violation
WHERE
	(
		DIFFERENCE(vehicle_color, 'RED') = 4 OR
		DIFFERENCE(vehicle_color, 'BLUE') = 4 OR
		DIFFERENCE(vehicle_color, 'YELLOW') = 4
    -- Exclude records with 'BL' and 'BLA' vehicle colors
	) AND vehicle_color NOT SIMILAR TO 'BLA?' ;

UPDATE 
	parking_violation pv
SET 
	vehicle_color = CASE
      -- Complete conditions and results
      WHEN red = 4 THEN 'RED'
      WHEN blue = 4 THEN 'BLUE'
      WHEN yellow = 4 THEN 'YELLOW'
	END
FROM 
	red_blue_yellow rby
WHERE 
	rby.summons_number = pv.summons_number;

SELECT * FROM parking_violation LIMIT 10;

--Formatting text for colleagues

SELECT 
	-- Add 0s to ensure each event_id is 10 digits in length
	LPAD(event_id,10,'0') as event_id, 
    parking_held 
FROM 
    film_permit;

SELECT 
	LPAD(event_id, 10, '0') as event_id, 
    -- Fix capitalization in parking_held column
    INITCAP(parking_held) as parking_held
FROM 
    film_permit;

SELECT 
	LPAD(event_id, 10, '0') as event_id, 
    -- Replace consecutive spaces with a single space
    REGEXP_REPLACE(INITCAP(parking_held), ' +',' ', 'g')  as parking_held
FROM 
    film_permit;
        summons_number
      FROM
        parking_violation
      WHERE
        DIFFERENCE(vehicle_color, 'GRAY') = 4 AND
        -- Filter out records that have GR as vehicle_color
        vehicle_color != 'GR'
);

--Standardizing multiple colors

SELECT 
	summons_number,
	vehicle_color,
    -- Include the DIFFERENCE() value for each color
	DIFFERENCE(vehicle_color, 'RED') AS "red",
	DIFFERENCE(vehicle_color, 'BLUE') AS "blue",
	DIFFERENCE(vehicle_color, 'YELLOW') AS "yellow"
FROM
	parking_violation
WHERE 
	(
      	-- Condition records on DIFFERENCE() value of 4
		DIFFERENCE(vehicle_color, 'RED') = 4 OR
		DIFFERENCE(vehicle_color,'BLUE') = 4 OR
		DIFFERENCE(vehicle_color, 'YELLOW') = 4
	)

SELECT 
	summons_number,
    vehicle_color,
	DIFFERENCE(vehicle_color, 'RED') AS "red",
	DIFFERENCE(vehicle_color, 'BLUE') AS "blue",
	DIFFERENCE(vehicle_color, 'YELLOW') AS "yellow"
FROM
	parking_violation
WHERE
	(
		DIFFERENCE(vehicle_color, 'RED') = 4 OR
		DIFFERENCE(vehicle_color, 'BLUE') = 4 OR
		DIFFERENCE(vehicle_color, 'YELLOW') = 4
    -- Exclude records with 'BL' and 'BLA' vehicle colors
	) AND vehicle_color NOT SIMILAR TO 'BLA?' ;

UPDATE 
	parking_violation pv
SET 
	vehicle_color = CASE
      -- Complete conditions and results
      WHEN red = 4 THEN 'RED'
      WHEN blue = 4 THEN 'BLUE'
      WHEN yellow = 4 THEN 'YELLOW'
	END
FROM 
	red_blue_yellow rby
WHERE 
	rby.summons_number = pv.summons_number;

SELECT * FROM parking_violation LIMIT 10;

--Formatting text for colleagues

SELECT 
	-- Add 0s to ensure each event_id is 10 digits in length
	LPAD(event_id,10,'0') as event_id, 
    parking_held 
FROM 
    film_permit;

SELECT 
	LPAD(event_id, 10, '0') as event_id, 
    -- Fix capitalization in parking_held column
    INITCAP(parking_held) as parking_held
FROM 
    film_permit;

SELECT 
	LPAD(event_id, 10, '0') as event_id, 
    -- Replace consecutive spaces with a single space
    REGEXP_REPLACE(INITCAP(parking_held), ' +',' ', 'g')  as parking_held
FROM 
    film_permit;