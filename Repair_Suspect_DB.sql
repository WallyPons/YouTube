/*

*********************************
**** Repair Suspect Database ****
****   usign only 6 steps    ****
*********************************
*/

-- Instructions: Replace [YourDatabase] with 
-- the name of the database to repair, then 
-- execute the whole script.

-- 1. Resets the status of a suspect database.
EXEC sp_resetstatus [YourDatabase];

-- 2. Used for troubleshooting purposes
ALTER DATABASE [YourDatabase] SET EMERGENCY;

-- 3. Checks the physical and logical integrity
-- of the database
DBCC CHECKDB([YourDatabase])

-- 4. This option restricts access to the database 
-- to only one user at a time
ALTER DATABASE [YourDatabase] SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;

-- 5. Tries to repair all reported errors. These repairs
-- can cause some data loss. 
DBCC CHECKDB ([YourDatabase], REPAIR_ALLOW_DATA_LOSS);

-- 6. This option removes the single-user restriction 
-- to access the database and sets it to MULTI-USER.
ALTER DATABASE [YourDatabase] SET MULTI_USER;

-- Warning: There might be data loss during this process,
-- use only as a last resort or if you don't have
-- a database backup on hand. You can download this 
-- code from my Github repository. This solution
-- is given "AS IS" under no warranty or claim.
