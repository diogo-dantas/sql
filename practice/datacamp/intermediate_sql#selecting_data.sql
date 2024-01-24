--Practice with COUNT()

-- Count the number of records in the people table
SELECT COUNT(*) AS count_records
FROM people;

-- Count the number of birthdates in the people table
SELECT COUNT(birthdate) AS count_birthdate
FROM people; 

-- Count the records for languages and countries represented in the films table
SELECT COUNT(country) AS count_countries, COUNT(language) AS count_languages
FROM films;



