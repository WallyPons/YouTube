/*
MS SQL Collation: defines the rules for how data is sorted, 
compared, and stored in text (character) data types only.
Colations provide the following rules: Case Sensitivity,
Accent Sensitivity, Kana Sensitivity (Japanese kana 
characters), Width Sensitivity and Sorting Rules.

Naming convention: 
CI = Case Insensitive
CS = Case Sensitive
AI = Accent Insensitive
AS = Accent Sensitive
*/

-- 1. Identifying collation:
-- a. Instance Level
SELECT SERVERPROPERTY('Collation') 
    AS Current_Server_Collation;
-- b. Database level (specific database)
SELECT DATABASEPROPERTYEX('master', 'Collation') 
    AS DB_Collation;
-- c. By table columns (specific table)
SELECT name, collation_name
FROM sys.columns
WHERE object_id = OBJECT_ID('DDL_AuditLog_Server');

-- 2. List all SQL collations by name and description
SELECT *
FROM fn_helpcollations()

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/
