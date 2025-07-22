/*
						========== DISCLAIMER ==========

Certain Social Security Number (SSN) ranges are reserved for specific purposes, 
including use in advertisements and promotional materials. For example, 
the range 987-65-4320 through 987-65-4329 is specifically reserved for this purpose. 

*/

-- 1. Temp table (local)
	-- a. Drop the table (if exists)
DROP TABLE IF EXISTS #SSNTemp

	-- b. Create the temp table
CREATE TABLE #SSNTemp 
(
    FullName VARCHAR(15),
    SSN CHAR(9) -- fixed-length data type, 9 bytes per row
);

-- 2. Insert the fake records for demonstration purposes (no hyphens will be needed)
INSERT INTO #SSNTemp (FullName, SSN)
VALUES
('Ralph Smith', '987654320'),
('Hank Jones',  '987654324'),
('Jim Peters',  '987654322');

-- 3. Read the table
Select Top 3
    *
From #SSNTemp;
GO

-- 4. Get column length per SSN stored
Select Top 3
    LEN(SSN) AS [Column length]
From #SSNTemp;
GO

-- 5. Record extraction: 3 values to the left
Select Top 3
    LEFT(SSN, 3) AS [3 values to the left]
From #SSNTemp;
GO

-- 6. Record extraction: 2 values on the center
Select Top 3
    SUBSTRING(SSN, 4, 2) AS [2 values on the center]
From #SSNTemp;
GO

-- 7. Record extraction: 4 values at the end
Select Top 3
    RIGHT(SSN, 4) AS [4 values at the end]
From #SSNTemp;
GO

-- 8. Record extraction: Using hyphens
Select FullName,			-- Full name
	LEFT(SSN, 3)			-- First three
	+ '-'					-- First hyphen
	+ SUBSTRING(SSN, 4, 2)	-- Middle two
	+ '-'					-- Second hyphen
	+ RIGHT(SSN, 4)			-- Last four
	AS [Full SSN]			-- Full SSN with hyphens
From #SSNTemp;
GO


-- 9. Example using variables
Declare @ssn CHAR(9);

	Set @ssn = '219099999';
	Select @ssn AS [SSN];
	Select LEN(@ssn) AS [Length];
	Select LEFT(@ssn, 3) AS [3 values to the left];
	Select SUBSTRING(@ssn, 4, 2) AS [2 values on the center];
	Select RIGHT(@ssn, 4) AS [4 values at the end];

-- 10. Full SSN
	Select LEFT(@ssn, 3) 
		+ '-' -- First hyphen 
		+ SUBSTRING(@ssn, 4, 2) 
		+ '-' -- Second hyphen
		+ RIGHT(@ssn, 4) 
	AS [Full SSN];
GO