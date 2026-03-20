USE [DB_DEMO]
GO

/*
sp_rename is a SQL Server system stored procedure used 
to rename user-created objects (tables, columns, indexes)
WARNING: It may potentially affect existing user stored
procedures, triggers and views.
*/

-- 1. Drop Table if exists
-- DROP TABLE IF EXISTS [DB_DEMO].[dbo].[RenameThis]
-- DROP TABLE IF EXISTS [DB_DEMO].[dbo].[RenameThat]

-- 2. Create table
CREATE TABLE [DB_DEMO].[dbo].[RenameThis]
(
    Id [int] IDENTITY(1, 1) NOT NULL,
    SomeData [varchar](15),
    CONSTRAINT [PK_NC_UNQ_RenameThis_Id]
        PRIMARY KEY NONCLUSTERED ([Id] ASC)
        WITH (PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
) ON [PRIMARY]
GO

-- 3. Verify existence
SELECT name
From sys.tables
Where name = 'RenameThis'

-- 4. Rename table
EXEC sp_rename 
    'RenameThis', -- Old name
    'RenameThat'; -- New name

-- 5. Verify existence
SELECT name
From sys.tables
Where name = 'RenameThat'

-- 6. Rename a column from the table
EXEC sp_rename 
    'RenameThat.SomeData', -- Old name
    'NewData',             -- New name
    'COLUMN';              -- Type

-- 7. View table properties
Exec sp_help [RenameThat]

-- 8. Add an index (IdxRename)
CREATE NONCLUSTERED INDEX [IdxRename]
ON [dbo].[RenameThat] ([NewData] ASC)
WITH (PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        SORT_IN_TEMPDB = ON, 
        ONLINE = OFF, 
        ALLOW_ROW_LOCKS = ON,
        ALLOW_PAGE_LOCKS = ON
     ) ON [PRIMARY]
GO

-- 9. Rename the index
EXEC sp_rename 
    'dbo.RenameThat.IdxRename', -- Old name
    'IdxRenameNew',             -- New name
    'INDEX';                    -- Type

-- 10. View table properties
Exec sp_help [RenameThat]