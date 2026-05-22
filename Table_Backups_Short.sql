/*
Table Backups: Testing code is on line 45
*/
-- 1. The whole table (one time only)
SELECT * INTO -- This creates a new table
[AdventureWorks2025].[dbo].[ErrorLogNew]
FROM [AdventureWorks2025].[dbo].[ErrorLog]; 

-- 2. To another database (one time only)
SELECT * INTO -- This creates a new table
[AdventureWorksDW2025].[dbo].[ErrorLogNew]
FROM [AdventureWorks2025].[dbo].[ErrorLog]; 

-- 3. Update differences on the destination table
-- a. This can be done continuously or as needed
-- b. Enable Identity Insert
SET IDENTITY_INSERT 
[AdventureWorks2025].[dbo].[ErrorLogNew] ON
-- c. Table to be updated (Created on step 1)
INSERT INTO [AdventureWorks2025].[dbo].[ErrorLogNEW](
ErrorLogID,ErrorTime,UserName,ErrorNumber,ErrorSeverity,
ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
-- d. Source table to be compared against
SELECT ErrorLogID,ErrorTime,UserName,ErrorNumber,
ErrorSeverity, ErrorState,ErrorProcedure,ErrorLine,
ErrorMessage 
FROM [AdventureWorks2025].[dbo].[ErrorLog]
-- e. EXCEPT condition (Add missing rows on ErrorLogNEW)
WHERE ErrorLogID IN (SELECT ErrorLogID FROM 
[AdventureWorks2025].[dbo].[ErrorLog] EXCEPT
SELECT ErrorLogID FROM 
[AdventureWorks2025].[dbo].[ErrorLogNEW])
-- f. Disable identity insert
SET IDENTITY_INSERT 
[AdventureWorks2025].[dbo].[ErrorLogNEW] OFF
/*
Don't forget to download a copy of this and other 
scripts FROM my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/


/*
Testing area:
-- a. If empty, add a record to the ErrorLog table
INSERT INTO [AdventureWorks2025].[dbo].[ErrorLog]
(
    UserName,
    ErrorNumber,
    ErrorSeverity,
    ErrorState,
    ErrorProcedure,
    ErrorLine,
    ErrorMessage
)
VALUES
(SUSER_NAME(), 1, 1, 1, 'dbo.Test', 1, 'Test');

-- b. SELECT statements
-- Source table
SELECT * FROM [AdventureWorks2025].[dbo].[ErrorLog];
-- Created on step 1 and 2
SELECT * FROM [AdventureWorks2025].[dbo].[ErrorLogNEW];
SELECT * FROM [AdventureWorksDW2025].[dbo].[ErrorLogNew];

-- c. Truncate all tables (if needed)
-- Source table (optional)
TRUNCATE TABLE [AdventureWorks2025].[dbo].[ErrorLog];
-- Created on step 1 and 2
TRUNCATE TABLE [AdventureWorks2025].[dbo].[ErrorLogNEW];
TRUNCATE TABLE [AdventureWorksDW2025].[dbo].[ErrorLogNew];

-- d. Drop new tables only, do not drop source
-- Created on step 1 and 2
DROP TABLE IF EXISTS [AdventureWorks2025].[dbo].[ErrorLogNEW];
DROP TABLE IF EXISTS [AdventureWorksDW2025].[dbo].[ErrorLogNew];
*/