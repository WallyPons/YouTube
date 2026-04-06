/*
This function applies only to SQL Server 2025:
----------------------------------------------
- JARO_WINKLER_DISTANCE is in preview.
- JARO_WINKLER_DISTANCE is available in Azure SQL Managed 
  Instance with the SQL Server 2025 or Always-up-to-date
*/

/*
1. JARO_WINKLER_DISTANCE:
Calculates the edit distance between two strings giving 
preference to strings that match from the beginning for 
a set prefix length.
*/
-- a. Use a user database, no system databases allowed
USE [DB_DEMO]; -- Use one of your databases
GO
-- b. Enable database configuration settings and 
-- preview features
ALTER DATABASE SCOPED CONFIGURATION
SET PREVIEW_FEATURES = ON
GO
-- c. T-SQL Code
DECLARE @VAL1 VARCHAR(20) = 'Honor'
DECLARE @VAL2 VARCHAR(20) = 'Honorific'
SELECT JARO_WINKLER_DISTANCE(@VAL1, @VAL2) 
AS [JARO_WINKLER_DISTANCE];

/*
Don't forget to download a copy of this and other 
scripts from my Github repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/