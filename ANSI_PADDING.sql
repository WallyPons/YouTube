/*
ANSI_PADDING: controls how trailing spaces (for 
character data) and trailing zeros (for binary 
data) are handled during storage in columns.
*/
-- 1. Drop temp tables if they exists
DROP TABLE IF EXISTS #ANSI_PADDING_OFF;
DROP TABLE IF EXISTS #ANSI_PADDING_ON;

-- 2. Create two temp tables
-- a. First table has ANSI_PADDING OFF
SET ANSI_PADDING OFF
CREATE TABLE #ANSI_PADDING_OFF
(
    NameChar CHAR(10),
    NameVarChar VARCHAR(10)
);
-- b. Second table has ANSI_PADDING ON
SET ANSI_PADDING ON
CREATE TABLE #ANSI_PADDING_ON
(
    NameChar CHAR(10),
    NameVarChar VARCHAR(10)
);

-- 3.Insert values into the tables
-- a. First table
INSERT INTO #ANSI_PADDING_OFF
(
    NameChar,
    NameVarChar
)
VALUES
('Wally   ', 'Wally   '); -- 5 chars + 3 spaces
-- b. Second table
INSERT INTO #ANSI_PADDING_ON
(
    NameChar,
    NameVarChar
)
VALUES
('Wally   ', 'Wally   '); -- 5 chars + 3 spaces

-- 4. Select values from both tables, compare results
-- a. First table
Select 'ANSI_PADDING_OFF' [Type],
       MAX(DATALENGTH(NameChar)) LenghtChar,
       MAX(DATALENGTH(NameVarChar)) LenghtVarChar
From #ANSI_PADDING_OFF;
-- b. Second table
Select 'ANSI_PADDING_ON' [Type],
       MAX(DATALENGTH(NameChar)) LenghtChar,
       MAX(DATALENGTH(NameVarChar)) LenghtVarChar
From #ANSI_PADDING_ON;

/*
Don't forget to download a copy of this and other 
scripts FROM my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/