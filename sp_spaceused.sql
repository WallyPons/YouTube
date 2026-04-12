/*
The sp_spaceused system stored procedure displays either:

1. The number of rows, disk space reserved, and disk space 
   used by a table, indexed view, or Service Broker queue 
   in the current database.

2. The disk space reserved and used by the whole database.
*/

USE [AdventureWorksLT2025];
GO

-- 1. The following example reports disk space information 
-- for the Customer table and its indexes.
EXECUTE sp_spaceused N'[SalesLT].[Customer]';
GO
-- 2. Space used in the current database in two rows.
EXECUTE sp_spaceused;
GO

/*
 Don't forget to download a copy of this and other 
 scripts from my GitHub repo, please check the link and 
 name of the file on the video description. This and 
 other solutions are given "AS IS" under no  warranty 
 or claim.
 */
