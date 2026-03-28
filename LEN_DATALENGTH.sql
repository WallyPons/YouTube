-- Comparing LEN and DATALENGTH functions
-- 1. Declare two variables
DECLARE @MyVarchar30 VARCHAR(30) 
	SET @MyVarchar30 = 'Something' 
DECLARE @MyNVarchar30 NVARCHAR(30) 
	SET @MyNVarchar30 = 'Something' 

-- 2. String function: LEN
SELECT LEN(@MyVarchar30) 
	AS [LEN and VARCHAR];

SELECT LEN(@MyNVarchar30) 
	AS [LEN and NVARCHAR];

-- 3. System Scalar function: DATALENGTH
SELECT DATALENGTH(@MyVarchar30) 
	AS [DATALENGTH and VARCHAR];

SELECT DATALENGTH(@MyNVarchar30) 
	AS [DATALENGTH and NVARCHAR];

/*
Differences between both functions
----------------------------------
1. LEN() will always: 
	a. Measures in characters
	b. Excludes trailing spaces

2. DATALENGTH() will always:
	a. Measures in bytes
	b. Will consider spaces
*/