-- Comparing LEN and DATALENGTH functions
-- 1. Declare two variables
DECLARE @MyVarchar30 VARCHAR(30) = 'Something';
DECLARE @MyNVarchar30 NVARCHAR(30) = 'Something';

-- 2. String function: LEN
SELECT LEN(@MyVarchar30) AS [LEN and VARCHAR],
LEN(@MyNVarchar30) AS [LEN and NVARCHAR];

-- 3. System Scalar function: DATALENGTH
SELECT DATALENGTH(@MyVarchar30) AS [DATALENGTH and VARCHAR], 
DATALENGTH(@MyNVarchar30) AS [DATALENGTH and NVARCHAR];

/*
Key differences:
----------------------------------
1. LEN() will always: 
	a. Measures in characters
	b. Exclude trailing spaces

2. DATALENGTH() will always:
	a. Measure in bytes
	b. Will consider spaces
*/
