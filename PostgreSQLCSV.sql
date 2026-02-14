-- https://www.postgresql.org/docs/current/sql-copy.html
-- Show server encoding
SHOW SERVER_ENCODING;

-- DROP DATABASE IF EXISTS
DROP DATABASE IF EXISTS importcsv WITH (FORCE);

-- Create database
CREATE DATABASE importcsv;

-- List databases
SELECT datname
FROM pg_database
WHERE datistemplate = false;

-- Create table
CREATE TABLE MyList (List text);
-- TRUNCATE TABLE myList;

-- Select
Select * From MyList;

COPY MyList
FROM 'Z:/MSSQL/BACKUP/TXTCSV/MyList.txt'
WITH (
    FORMAT text,
    ENCODING 'UTF8',
    ON_ERROR ignore,
    HEADER false
);

-- Create table Mytext
CREATE TABLE MyText
(
    id int,
    first_name text,
    last_name text,
    age int,
    country text
);

-- Copy data into MyText
COPY MyText
FROM 'Z:/MSSQL/BACKUP/TXTCSV/Mytext.txt'
WITH (
    FORMAT csv,
    ENCODING 'UTF8',
    ON_ERROR ignore,
    HEADER true
);

-- Select MyText
Select * From MyText;

-- Create table SQLExport (1,000 rows)
CREATE TABLE SQLExport
(
    id int,
    first_name text,
    last_name text,
    email text,
    gender text,
    race_group text,
    hospital_code text,
    car_make text 
);

-- Copy data into SQLExport
COPY SQLExport
FROM 'Z:/MSSQL/BACKUP/TXTCSV/SQLExport.csv'
WITH (
    FORMAT csv,
    ENCODING 'UTF8',
    ON_ERROR ignore,
    HEADER true
);

-- Select SQLExport
Select * From SQLExport LIMIT 10;

-- Another way of copying data
COPY SQLExport2 FROM 'Z:/MSSQL/BACKUP/TXTCSV/SQLExport.csv' DELIMITER ',' CSV HEADER;

-- Select SQLExport
Select * From SQLExport2 LIMIT 10;

-- List all tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE';
