/*
https://learn.microsoft.com/en-us/sql/t-sql/functions/format-transact-sql?view=sql-server-ver17

The FORMAT function in SQL is used to format a value (number, date, or time) 
into a specific string format. It allows for culture-specific formatting and 
is particularly useful for presenting data in a more user-friendly and 
readable way, especially in reports or displays.

Ex: Select FORMAT( value , format [ , culture ] )

Value: It is the value to do formatting. It should be in support of the data type format. 
For reference, here's a list of supported data types and their equivalent data type:

a. Numeric Data Types:
INT, BIGINT, DECIMAL, NUMERIC, FLOAT, REAL, MONEY, SMALLMONEY

b. Date and Time Data Types:
DATE, TIME, DATETIME, DATETIME2, SMALLDATETIME, DATETIMEOFFSET.

Format: It is the required format in which we require the output. This parameter should contain 
a valid format string in the NVARCHAR data type.

Culture: It is an optional parameter. By default, SQL Server uses the current session language 
for a default culture. We can provide a specific culture here.

Numeric formats:
	C or c: Currency format.
	D or d: Decimal format.
	E or e: Exponential (scientific) format.
	F or f: Fixed-point format.
	G or g: General format.
	N or n: Number format.
	P or p: Percentage format.
	X or x: Hexadecimal format.

Some of the most common English cultures for currency are:
	en-US (English - United States)
	en-GB (English - United Kingdom)
	en-CA (English - Canada)
	en-AU (English - Australia)
	en-IN (English - India)

European Languages:
	fr-FR (French - France)
	de-DE (German - Germany)
	es-ES (Spanish - Spain)
	it-IT (Italian - Italy)
	pt-PT (Portuguese - Portugal)
	nl-NL (Dutch - Netherlands)

Asian Languages:
	ja-JP (Japanese - Japan)
	ko-KR (Korean - Korea)
	zh-CN (Chinese - Simplified, PRC)
	zh-TW (Chinese - Traditional, Taiwan)

Other Examples:
	ar-SA (Arabic - Saudi Arabia)
	ru-RU (Russian - Russia)
	hi-IN (Hindi - India)
*/

-- 1. Drop temp table (if exists)
DROP TABLE IF EXISTS #Salaries

-- 2. Create temp table
CREATE TABLE #Salaries
(
    Salary_Id BIGINT IDENTITY(1, 1) PRIMARY KEY,
    Position_Id BIGINT NOT NULL,
    SalaryValue DECIMAL(18, 2) NOT NULL,
	PercentageValue DECIMAL(18, 2) NOT NULL,
	RandomNumbers INT,
	RandomDates DATE
);

-- 3. Insert values into the temp table
INSERT INTO #Salaries
(
    Position_Id,
    SalaryValue,
	PercentageValue,
	RandomNumbers,
	RandomDates
)
VALUES
(1, 4500, 0.75, 12345, '10-21-2021'),
(2, 5000, 0.35, 56789, '06-15-2010'),
(3, 5500.99, 0.20, 258963, '02-18-2019'),
(4, 6800.33, 0.15, 123654, '12-12-2022' ),
(5, 10101.01, 0.89, 789654, '04-19-1980');

-- 4. Select values from the temp table
Select Salary_Id,
       Position_Id,
       SalaryValue,
	   PercentageValue,
       RandomNumbers,
	   RandomDates
From #Salaries;

-- 5. Format the monetary values with commas: N = Numeric Format and P = Percentage Format
Select Salary_Id,
       Position_Id,
       FORMAT(SalaryValue, 'N', 'en-us') AS SalaryValue,
	   FORMAT(PercentageValue, 'P', 'en-us') AS PercentageValue
From #Salaries

-- 6. Format the monetary values with commas and decimals: C = Currency Format
Select Salary_Id,
       Position_Id,
       FORMAT(SalaryValue, 'C4', 'en-us') AS SalaryValue,
	   FORMAT(PercentageValue, 'P4', 'en-us') AS PercentageValue
From #Salaries;

-- 7. Format the monetary values with different currency symbols:
	-- a. Great British Pounds (£)
	-- b. Hindi Rupee (₹)
	-- c. Italy (Most Europe €)
	-- d. Japan's Yen (¥)
	-- e. Russian Ruble (₽)
Select 
	   SalaryValue,
       FORMAT(SalaryValue, 'C', 'en-gb') AS [SalaryValue-en-gb],
	   FORMAT(SalaryValue, 'C', 'en-IN') AS [SalaryValue-en-IN],
	   FORMAT(SalaryValue, 'C', 'it-IT') AS [SalaryValue-it-IT],
	   FORMAT(SalaryValue, 'C', 'ja-JP') AS [SalaryValue-ja-JP],
	   FORMAT(SalaryValue, 'C', 'ru-RU') AS [SalaryValue-ru-RU]
From #Salaries;


-- 8. Other Formats
-- a. Format Exponential (scientific) and Hexadecimal format
Select 
	   RandomNumbers,
       FORMAT(RandomNumbers, 'E') AS ExponentialValue,
       FORMAT(RandomNumbers, 'X') AS HexadecimalValue
From #Salaries;

-- 9. Dates

SELECT 
	   RandomDates,
	   FORMAT(RandomDates, 'd', 'en-US') AS 'US English',
       FORMAT(RandomDates, 'd', 'en-gb') AS 'British English',
       FORMAT(RandomDates, 'd', 'de-de') AS 'German',
       FORMAT(RandomDates, 'd', 'zh-cn') AS 'Chinese Simplified (PRC)',
	   FORMAT(RandomDates, 'D', 'en-US') AS 'US English',
       FORMAT(RandomDates, 'D', 'en-gb') AS 'British English',
       FORMAT(RandomDates, 'D', 'de-de') AS 'German',
       FORMAT(RandomDates, 'D', 'zh-cn') AS 'Chinese Simplified (PRC)',
	   FORMAT(RandomDates, 'D', 'hi-IN') AS 'Hindi - India',
	   FORMAT(RandomDates, 'D', 'ru-RU') AS 'Russian - Russia',
	   FORMAT(RandomDates, 'D', 'ar-SA') AS 'Arabic - Saudi Arabia'
From #Salaries;