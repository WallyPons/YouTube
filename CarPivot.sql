-- 1. Drop temp table (if exists)
-- a. Verify existence, if it exists then drop
DROP TABLE IF EXISTS #VehicleData;

-- 2. Create global temp table
-- a. Will be accesible to any SQL session
CREATE TABLE #VehicleData
(
    Id BIGINT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    Manufacturer VARCHAR(50),
    [Model] VARCHAR(50),
    Series VARCHAR(50),
    ProductionYear INT,
    PurchaseDate DATE
);

-- 3. Insert data into global temp table
-- a. Identity values will be created automatically
INSERT INTO #VehicleData
(
    Manufacturer,
    [Model],
    Series,
    ProductionYear,
    PurchaseDate
)
VALUES
('Ford', 'Taurus', 'SEL', 2011, '2020-12-10'),
('Ford', 'Taurus', 'SEL', 2012, '2019-06-15'),
('Ford', 'Taurus', 'SEL', 2013, '2021-01-23'),
('Ford', 'Taurus', 'SEL', 2014, '2017-09-21'),
('Ford', 'Taurus', 'SE', 2011, '2022-09-01'),
('Ford', 'Taurus', 'SE', 2016, '2021-11-29'),
('Ford', 'Taurus', 'SE', 2015, '2020-03-17'),
('Ford', 'Taurus', 'SE', 2015, '2017-08-22'),
('Ford', 'Focus', 'SE', 2010, '2014-02-10'),
('Ford', 'Focus', 'SE', 2010, '2019-04-12'),
('Ford', 'Focus', 'SE', 2008, '2012-03-26'),
('Ford', 'Focus', 'SES', 2015, '2020-01-09'),
('Ford', 'Focus', 'SES', 2015, '2018-07-20'),
('Ford', 'Focus', 'S', 2014, '2014-02-10'),
('Ford', 'Focus', 'S', 2014, '2019-08-24'),
('Ford', 'Escape', 'SE', 2013, '2014-12-29'),
('Ford', 'Escape', 'SE', 2013, '2014-11-15'),
('Ford', 'Escape', 'SE Ecoboost', 2014, '2016-05-17'),
('Ford', 'Escape', 'SE Ecoboost', 2015, '2017-06-23'),
('Ford', 'Escape', 'SE Ecoboost', 2017, '2020-01-09'),
('Ford', 'Escape', 'Titanium Ecoboost', 2018, '2020-11-23'),
('Ford', 'Escape', 'SE Ecoboost', 2017, '2022-09-30'),
('Ford', 'Mustang', 'Ecoboost', 2015, '2015-03-21'),
('Ford', 'Mustang', 'Ecoboost', 2016, '2016-04-29'),
('Ford', 'Mustang', 'Ecoboost', 2017, '2017-10-11'),
('Ford', 'Mustang', 'Ecoboost', 2018, '2024-08-15'),
('Ford', 'Mustang', 'GT', 2015, '2024-08-15'),
('Ford', 'Mustang', 'GT', 2019, '2025-04-26'),
('Ford', 'Mustang', '3.7 V6', 2011, '2020-09-13'),
('Ford', 'Mustang', 'GT 500', 2009, '2014-01-23'),
('Ford', 'Mustang', 'Cobra Terminator', 2002, '2018-07-29'),
('Ford', 'Expedition', ' 3.5 V6 Ecoboost', 2018, '2020-06-25'),
('Ford', 'Edge', 'SEL', 2013, '2016-09-10'),
('Ford', 'Edge', 'SE', 2013, '2019-06-03'),
('Ford', 'Edge', 'SE', 2016, '2021-05-01'),
('Ford', 'Flex', 'Limited', 2014, '2017-08-19'),
('Ford', 'Edge', 'SE', 2014, '2015-03-19');

-- 4. View inserted rows
-- a. Select all
Select id,
       Manufacturer,
       [Model],
       Series,
       ProductionYear,
       PurchaseDate
From #VehicleData;

-- b. Select group by Manufacturer
Select Manufacturer,
       Count(Manufacturer) AS ManufCount
From #VehicleData
Group By Manufacturer
Order By Manufacturer;

-- c. Select group by Manufacturer and [Model]
Select Manufacturer,
       [Model],
       Count([Model]) AS [ModelCount]
From #VehicleData
Group By Manufacturer,
         [Model]
Order By Manufacturer,
         [Model];

-- d. Select group by Manufacturer and ProductionYear
Select Manufacturer,
       ProductionYear,
       Count(ProductionYear) AS ProductionYearCount
From #VehicleData
Group By Manufacturer,
         ProductionYear
Order By ProductionYear, ProductionYearCount ASC;

-- 5. First Pivot table
/*
A pivot table in SQL is a data transformation technique that converts 
unique values from rows in a table into columns, while simultaneously 
performing aggregations on other columns.
*/
SELECT *
FROM
-- Subquery begins here (classic Pivot table)
(
    SELECT id,
           Manufacturer,
           [Model],
           Series,
           ProductionYear,
           PurchaseDate
    FROM #VehicleData
) AS [DataSource] -- Subquery ends here, also uses [DataSource] as an alias
PIVOT -- Pivot begins here
(
    COUNT(ProductionYear)
    FOR [ProductionYear] IN ([2008], [2010], [2011], [2012], [2013], [2014], [2015], [2016], [2017], [2018], [2019]) -- Years
) as [PivotData] -- Pivot aliasing

/*
STRING_AGG: https://learn.microsoft.com/en-us/sql/t-sql/functions/string-agg-transact-sql?view=sql-server-ver17
Concatenates the values of string expressions and places separator values between them. 
The separator isn't added at the end of string. (2017 and up)

QUOTENAME: https://learn.microsoft.com/en-us/sql/t-sql/functions/quotename-transact-sql?view=sql-server-ver17
Returns a Unicode string with the delimiters added to make the input string a valid 
SQL Server delimited identifier. (2008 and up)
*/

-- 6. Second Pivot, has the "STRING_AGG" function for SQL 2017 and up
-- a. Declare variables
DECLARE @cols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);

-- b. Build the column list dynamically with STRING_AGG
SELECT @cols = STRING_AGG(QUOTENAME(ProductionYear), ',')
FROM
(SELECT DISTINCT ProductionYear FROM #VehicleData) AS Years;

-- c. Build the dynamic SQL
SET @sql = '
SELECT *
FROM #VehicleData
PIVOT (
    COUNT(ProductionYear)
    FOR ProductionYear IN (' + @cols + ')
) AS VehiclePivot;
';

-- d. Execute the dynamic SQL
EXEC sp_executesql @sql;
GO

-- 7. Third Pivot, total by year
-- a. Declare variables
DECLARE @cols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);

-- b. Build the column list dynamically
SELECT @cols = STRING_AGG(QUOTENAME(ProductionYear), ',')
FROM
(SELECT DISTINCT ProductionYear FROM #VehicleData) AS Years;

-- c. Build the dynamic SQL with grouping
SET @sql
    = '
SELECT Manufacturer, [Model], ' + @cols
      + '
FROM (
    SELECT Manufacturer, [Model], ProductionYear
    FROM #VehicleData
) AS Source
PIVOT (
    COUNT(ProductionYear)
    FOR ProductionYear IN (' + @cols + ')
) AS VehiclePivot;
';

-- d. Execute the dynamic SQL
EXEC sp_executesql @sql;
GO


-- 8. Using a Grand Total
-- a. Declare variables
DECLARE @cols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);

-- b. Build the column list dynamically
SELECT @cols = STRING_AGG(QUOTENAME(ProductionYear), ',')
FROM (SELECT DISTINCT ProductionYear FROM #VehicleData) AS Years;

-- c. Build the dynamic SQL
SET @sql = '
SELECT Manufacturer, [Model], Series,
       ' + @cols + ', 
       (' + REPLACE(@cols, ',', ' + ') + ') AS [GrandTotal]
FROM (
    SELECT Manufacturer, [Model], Series, ProductionYear
    FROM #VehicleData
) AS Source
PIVOT (
    COUNT(ProductionYear)
    FOR ProductionYear IN (' + @cols + ')
) AS VehiclePivot;
';

-- d. Execute the dynamic SQL
EXEC sp_executesql @sql;
GO



/*
Additional testing:
INSERT INTO #VehicleData
(
    Manufacturer,
    [Model],
    Series,
    ProductionYear,
    PurchaseDate
)
VALUES
('Toyota', 'Corolla', 'SE', 1999, '2001-10-25'),
('Toyota', 'Corolla', 'SE', 2000, '2003-11-15'),
('Toyota', 'Corolla', 'SE', 2001, '2003-12-03'),
('Toyota', 'Corolla', 'SE', 2002, '2005-04-09'),
('Toyota', 'Corolla', 'SE', 2002, '2005-04-29'),
('Toyota', 'Corolla', 'SE', 2004, '2006-01-11'),
('Honda', 'Accord', 'SE', 2011, '2013-05-22'),
('Subaru', 'Impreza', 'RS', 2016, '2021-05-02'),
('Honda', 'Accord', 'SE', 2010, '2013-06-05'),
('Honda', 'Accord', 'SE', 2016, '2016-03-12');
*/
