/* 
1. SQL Aggregate functions:
    a. COUNT
    b. MAX
    c. MIN
    d. AVG
2. System Scalar function
    a. DATALENGTH
3. Scalar function (with example):
    a. ISNUMERIC
*/

-- 1. Count rows on the table
SELECT COUNT(*)  AS TotalRows
FROM [DB_DEMO].[dbo].[MaxMinAvgIsNum]
WITH (NOLOCK); -- 1,000 rows

-- 2. Read Top 10 rows FROM the table
SELECT TOP 10 *
FROM [DB_DEMO].[dbo].[MaxMinAvgIsNum]
WITH (NOLOCK);

-- 3. Look for maximum length on each column 
SELECT MAX(DATALENGTH(id)) id,
       MAX(DATALENGTH(first_name)) first_name,
       MAX(DATALENGTH(last_name)) last_name,
       MAX(DATALENGTH(email)) email,
       MAX(DATALENGTH(gender)) gender,
       MAX(DATALENGTH(race_group)) race_group,
       MAX(DATALENGTH(hospital_code)) hospital_code,
       MAX(DATALENGTH(car_make)) car_make
FROM [DB_DEMO].[dbo].[MaxMinAvgIsNum]
WITH (NOLOCK);

-- 4. Look for minimum length for each column
SELECT MIN(DATALENGTH(id)) id,
       MIN(DATALENGTH(first_name)) first_name,
       MIN(DATALENGTH(last_name)) last_name,
       MIN(DATALENGTH(email)) email,
       MIN(DATALENGTH(gender)) gender,
       MIN(DATALENGTH(race_group)) race_group,
       MIN(DATALENGTH(hospital_code)) hospital_code,
       MIN(DATALENGTH(car_make)) car_make
FROM [DB_DEMO].[dbo].[MaxMinAvgIsNum]
WITH (NOLOCK);

-- 5. Look for average length for each column
SELECT AVG(DATALENGTH(id)) id,
       AVG(DATALENGTH(first_name)) first_name,
       AVG(DATALENGTH(last_name)) last_name,
       AVG(DATALENGTH(email)) email,
       AVG(DATALENGTH(gender)) gender,
       AVG(DATALENGTH(race_group)) race_group,
       AVG(DATALENGTH(hospital_code)) hospital_code,
       AVG(DATALENGTH(car_make)) car_make
FROM [DB_DEMO].[dbo].[MaxMinAvgIsNum]
WITH (NOLOCK);

-- 6. Look for columns with numeric attributes
SELECT ISNUMERIC(id) id,
       ISNUMERIC(first_name) first_name,
       ISNUMERIC(last_name) last_name,
       ISNUMERIC(email) email,
       ISNUMERIC(gender) gender,
       ISNUMERIC(race_group) race_group,
       ISNUMERIC(hospital_code) hospital_code,
       ISNUMERIC(car_make) car_make
FROM [DB_DEMO].[dbo].[MaxMinAvgIsNum]
WITH (NOLOCK);

-- a. Update to numeric
UPDATE [DB_DEMO].[dbo].[MaxMinAvgIsNum]
SET first_name = 1
WHERE id = 1

-- b. Revert update
UPDATE [DB_DEMO].[dbo].[MaxMinAvgIsNum]
SET first_name = 'Beck'
WHERE id = 1