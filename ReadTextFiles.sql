-- 1. OPENROWSET: Reads the entire file into one column (no storing on SQL)
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/openrowset-bulk-transact-sql?view=sql-server-ver17
-- Required permissions: ADMINISTER DATABASE BULK OPERATIONS or ADMINISTER BULK OPERATIONS

-- a. Without format file
-- Text file
SELECT *
FROM OPENROWSET(
    BULK 'Z:\MSSQL\BACKUP\TXTCSV\MyText.txt',
    SINGLE_CLOB -- Options: SINGLE_CLOB, SINGLE_BLOB, or SINGLE_NCLOB
) AS FileData;

-- CSV
SELECT *
FROM OPENROWSET(
    BULK 'Z:\MSSQL\BACKUP\TXTCSV\SQLExport.csv',
    SINGLE_CLOB -- Options: SINGLE_CLOB, SINGLE_BLOB, or SINGLE_NCLOB
) AS FileData;

/*
    Output: One column, One row, Whole file as text
    Pros: Very simple, No schema required
    Cons: You must parse it yourself
    Observation: Not good for large files
*/

-- b. With format file
/*
c. Create a table, no data needed, all we need is to extracy the format file with BCP:
-- Text file
DROP TABLE IF EXISTS [CorporateData_East1].[dbo].[MyText];
CREATE TABLE [CorporateData_East1].[dbo].[MyText]
(
    id int,
    first_name varchar(25),
    last_name varchar(25),
    age int,
    country varchar(30)
);

d. Execute the BCP command from CMD:
bcp [CorporateData_East1].[dbo].[MyText] format nul -f "Z:\MSSQL\BACKUP\TXTCSV\MyText.fmt" -N -S"." -T

-- CSV
DROP TABLE IF EXISTS [CorporateData_East1].[dbo].[SQLExport];
CREATE TABLE [CorporateData_East1].[dbo].[SQLExport]
(
    id int,
    first_name varchar(25),
    last_name varchar(25),
    email varchar(50),
    gender varchar(11),
    race_group varchar(50),
    hospital_code varchar(20),
    car_make varchar(20) 
);

e. Execute the BCP command from CMD:
bcp [CorporateData_East1].[dbo].[SQLExport] format nul -f "Z:\MSSQL\BACKUP\TXTCSV\SQLExport.fmt" -N -S"." -T

*************************************************************************************************
*    Notes: If your file is UTF-8 or ANSI, you need to change these values on the format file:  *
*    1. SQLNCHAR/SQLINT → SQLCHAR                                                                      *
*    2. prefix length 2 → 0                                                                     *
*    3. Also, you need to add the "," for each column and add "\r\n" for the last column.       *
*************************************************************************************************
*/

-- Text file
SELECT *
FROM OPENROWSET(
    BULK 'Z:\MSSQL\BACKUP\TXTCSV\MyText.txt',
    FORMATFILE = 'Z:\MSSQL\BACKUP\TXTCSV\MyText.fmt',
    FIRSTROW = 2
) AS FileData;

-- CSV
SELECT *
FROM OPENROWSET(
    BULK 'Z:\MSSQL\BACKUP\TXTCSV\SQLExport.csv',
    FORMATFILE = 'Z:\MSSQL\BACKUP\TXTCSV\SQLExport.fmt',
    FIRSTROW = 2
)AS FileData ;





-- 2. Bulk insert
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/bulk-insert-transact-sql?view=sql-server-ver17
-- Required permissions: ADMINISTER DATABASE BULK OPERATIONS or ADMINISTER BULK OPERATIONS
-- a. DROP/CREATE table
DROP TABLE IF EXISTS #SQLExport
CREATE TABLE #SQLExport
(
    id int,
    first_name varchar(25),
    last_name varchar(25),
    email varchar(50),
    gender varchar(11),
    race_group varchar(50),
    hospital_code varchar(20),
    car_make varchar(20) 
);

-- b. Execute BULK INSERT
BULK INSERT #SQLExport
FROM 'Z:\MSSQL\BACKUP\TXTCSV\SQLExport.csv'   -- File exported from SQL Server, original source: Mockaroo.com
WITH
(
    FIRSTROW = 2,              -- Skips the header row if your CSV file has one
    FIELDTERMINATOR = ',',     -- Field delimiter, in this case a comma
    ROWTERMINATOR = '\n',      -- Use '\r\n' for Windows-style line endings if '\n' doesn't work :: '0x0a' is required for LF-only files
    BATCHSIZE = 250,           -- Specifies the number of rows in a batch.
    MAXERRORS = 2,             -- Specifies the maximum number of syntax errors allowed in the data before the bulk-import operation is canceled.
    TABLOCK                    -- Specifies that a table-level lock is acquired for the duration of the bulk-import operation
);

-- c. Select all table data
Select * 
From #SQLExport

-- d. Optionally, verify data length (not needed, just fun!)
Select MAX(LEN(id)) id,
       MAX(LEN(first_name)) first_name,
       MAX(LEN(last_name)) last_name,
       MAX(LEN(email)) email,
       MAX(LEN(gender)) gender,
       MAX(LEN(race_group)) race_group,
       MAX(LEN(hospital_code)) hospital_code,
       MAX(LEN(car_make)) car_make
From #SQLExport

-- 3. Insert text file info into table (ordinary or temp)
-- a. Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO

-- b. Drop/Create/insert table
DROP TABLE IF EXISTS #CMDRun
CREATE TABLE #CMDRun (output varchar(max))
INSERT INTO #CMDRun

-- c. Execute CMD
EXECUTE xp_cmdshell 'Type Z:\MSSQL\BACKUP\TXTCSV\CMDTest5Columns.txt';
--EXECUTE xp_cmdshell 'Type Z:\MSSQL\BACKUP\TXTCSV\CMDTest4Columns.txt';
--EXECUTE xp_cmdshell 'Type Z:\MSSQL\BACKUP\TXTCSV\MyList.txt';
GO

-- d. Disable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO

-- e. Select on table
Select * From #CMDRun

-- With 4 columns (PARSENAME() only supports 4 columns.)
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/parsename-transact-sql?view=sql-server-ver17
-- 4 Columns
SELECT
    PARSENAME(REPLACE(c.output, ',', '.'), 4) AS FirstName,
    PARSENAME(REPLACE(c.output, ',', '.'), 3) AS LastName,
    PARSENAME(REPLACE(c.output, ',', '.'), 2) AS Age,
    PARSENAME(REPLACE(c.output, ',', '.'), 1) AS Country
FROM #CMDRun c
WHERE c.output IS NOT NULL;

-- 5 Columns (will not work)
SELECT
    PARSENAME(REPLACE(c.output, ',', '.'), 5) AS Id,
    PARSENAME(REPLACE(c.output, ',', '.'), 4) AS FirstName,
    PARSENAME(REPLACE(c.output, ',', '.'), 3) AS LastName,
    PARSENAME(REPLACE(c.output, ',', '.'), 2) AS Age,
    PARSENAME(REPLACE(c.output, ',', '.'), 1) AS Country
FROM #CMDRun c
WHERE c.output IS NOT NULL;



-- 4. Read and parse from table with more than 4 columns using STRING_SPLIT
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/string-split-transact-sql?view=sql-server-ver17
-- 4 Columns
SELECT
    MAX(CASE WHEN s.ordinal = 1 THEN TRIM(s.value) END) AS FirstName,
    MAX(CASE WHEN s.ordinal = 2 THEN TRIM(s.value) END) AS LastName,
    MAX(CASE WHEN s.ordinal = 3 THEN TRIM(s.value) END) AS Age,
    MAX(CASE WHEN s.ordinal = 4 THEN TRIM(s.value) END) AS Country
FROM #CMDRun d
CROSS APPLY STRING_SPLIT(d.output, ',', 1) s
WHERE d.output IS NOT NULL
  AND LTRIM(RTRIM(d.output)) <> ''
GROUP BY d.output;


-- 5 Columns
SELECT
    MAX(CASE WHEN s.ordinal = 1 THEN TRIM(s.value) END) AS Id,
    MAX(CASE WHEN s.ordinal = 2 THEN TRIM(s.value) END) AS FirstName,
    MAX(CASE WHEN s.ordinal = 3 THEN TRIM(s.value) END) AS LastName,
    MAX(CASE WHEN s.ordinal = 4 THEN TRIM(s.value) END) AS Age,
    MAX(CASE WHEN s.ordinal = 5 THEN TRIM(s.value) END) AS Country
FROM #CMDRun d
CROSS APPLY STRING_SPLIT(d.output, ',', 1) s
WHERE d.output IS NOT NULL
  AND LTRIM(RTRIM(d.output)) <> ''
GROUP BY d.output;

-- 5. With PIVOT Table function
SELECT [1] AS Id,
       [2] AS FirstName,
       [3] AS LastName,
       [4] AS Age,
       [5] AS Country
FROM
(
    SELECT d.output,
           s.ordinal,
           TRIM(s.value) AS value
    FROM #CMDRun d
        CROSS APPLY STRING_SPLIT(d.output, ',', 1)s
    WHERE TRIM(d.output) <> ''
) src
PIVOT
(
    MAX(value)
    FOR ordinal IN ([1], [2], [3], [4], [5])
) p;