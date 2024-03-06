-- Type conversion with a CASE clause

SELECT
  CASE WHEN
          -- Use true when column value is 'F'
          violation_in_front_of_or_opposite = 'F' THEN TRUE
       WHEN
          -- Use false when column value is 'O'
         violation_in_front_of_or_opposite = 'O' THEN FALSE
       ELSE
          NULL
  END AS is_violation_in_front
FROM
  parking_violation;

  -- Applying aggregate functions to converted values

  SELECT
  -- Define the range_size from the max and min summons number
  MAX(CAST(summons_number AS BIGINT)) - MIN(CAST(summons_number AS BIGINT)) AS range_size
FROM
  parking_violation;

 -- Cleaning invalid dates

 SELECT
  -- Replace '0' with NULL
  NULLIF(date_first_observed,'0') AS date_first_observed
FROM
  parking_violation;

  SELECT
  -- Convert date_first_observed into DATE
    DATE(NULLIF(date_first_observed, '0')) AS date_first_observed
FROM
  parking_violation;

--Converting and displaying dates

SELECT
  summons_number,
  -- Convert issue_date to a DATE
  DATE(issue_date) AS issue_date,
  -- Convert date_first_observed to a DATE
  DATE(date_first_observed) AS date_first_observed
FROM
  parking_violation;

SELECT
  summons_number,
  -- Display issue_date using the YYYYMMDD format
  TO_CHAR(issue_date, 'YYYYMMDD') AS issue_date,
  -- Display date_first_observed using the YYYYMMDD format
  TO_CHAR(date_first_observed, 'YYYYMMDD') AS date_first_observed
FROM (
  SELECT
    summons_number,
    DATE(issue_date) AS issue_date,
    DATE(date_first_observed) AS date_first_observed
  FROM
    parking_violation
) sub

-- Extracting hours from a time value

SELECT
  -- Convert violation_time to a TIMESTAMP
  TO_TIMESTAMP(violation_time,'HH12MI:PM')::TIME AS violation_time
FROM
  parking_violation
WHERE
  -- Exclude NULL violation_time
  violation_time IS NOT NULL;

  SELECT
  -- Populate column with violation_time hours
  EXTRACT('hour' FROM violation_time) AS hour,
  COUNT(*)
FROM (
    SELECT
      TO_TIMESTAMP(violation_time, 'HH12MIPM')::TIME as violation_time
    FROM
      parking_violation
    WHERE
      violation_time IS NOT NULL
) sub
GROUP BY
  hour
ORDER BY
  hour

-- A parking violation report by day of the month

SELECT
  -- Convert issue_date to a DATE value
  DATE(issue_date) AS issue_date
FROM
  parking_violation;

  SELECT
  -- Create issue_day from the day value of issue_date
  EXTRACT('day' FROM issue_date) AS issue_day,
  -- Include the count of violations for each day
  COUNT(*)
FROM (
  SELECT
    -- Convert issue_date to a `DATE` value
    DATE(issue_date) AS issue_date
  FROM
    parking_violation
) sub
GROUP BY
  issue_day
ORDER BY
  issue_day;

-- Risky parking behavior

SELECT
  summons_number,
  -- Convert violation_time to a TIMESTAMP
  TO_TIMESTAMP(violation_time, 'HH12MIPM')::TIME as violation_time,
  -- Convert to_hours_in_effect to a TIMESTAMP
  TO_TIMESTAMP(to_hours_in_effect, 'HH12MIPM')::TIME as to_hours_in_effect
FROM
  parking_violation
WHERE
  -- Exclude all day parking restrictions
  NOT (from_hours_in_effect = '1200AM' AND to_hours_in_effect = '1159PM');

  SELECT
  summons_number,
  -- Create column for hours between to_hours_in_effect and violation_time
  EXTRACT('hour' FROM to_hours_in_effect - violation_time) AS hours,
  -- Create column for minutes between to_hours_in_effect and violation_time
  EXTRACT('minutes' FROM to_hours_in_effect - violation_time) AS minutes
FROM (
  SELECT
    summons_number,
    TO_TIMESTAMP(violation_time, 'HH12MIPM')::time as violation_time,
    TO_TIMESTAMP(to_hours_in_effect, 'HH12MIPM')::time as to_hours_in_effect
  FROM
    parking_violation
  WHERE
    NOT (from_hours_in_effect = '1200AM' AND to_hours_in_effect = '1159PM')
) sub

SELECT
  -- Return the count of records
  COUNT(*)
FROM
  time_differences
WHERE
  -- Include records with a hours value of 0
  hours = 0 AND
  -- Include records with a minutes value of at most 59
  minutes <= 59;