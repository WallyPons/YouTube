-- 1. List contents from a DataTable
-- a. Select
Select *
	From [DB_DATA_DEMO].[dbo].[DataTable];
-- b. Count
Select COUNT(*) TotalRecords
	From [DB_DATA_DEMO].[dbo].[DataTable];


-- 2. Backup table unsing INTO statement:
-- a. To the same database (You can specify all the columns with * or some of the columns, it's your choice)
Select * 
INTO 
[DB_DATA_DEMO].[dbo].[DataTable_BK] -- New table will be created with same structure and current data
From 
[DB_DATA_DEMO].[dbo].[DataTable]; -- Source table
-- b. Verify
Select * 
	From [DB_DATA_DEMO].[dbo].[DataTable_BK];

-- c. To another database
Select * 
INTO 
[DB_DATA_DEMO2].[dbo].[DataTable_BK] -- New table will be created with same structure and current data
From 
[DB_DATA_DEMO].[dbo].[DataTable]; -- Source table
-- d. Verify
Select * 
	From [DB_DATA_DEMO2].[dbo].[DataTable_BK];

-- Advantages:
	-- Creates a copy of the table either on the existing DB or another DB
	-- Supports filtering ("Where" conditions and "Top n")
-- Disadvantages:
	-- It's a one time operation 
	-- if you want to update the created table you need to run INSERT INTO statements
	

-- 2. Compare contents on data changes
Select COUNT(*) TotalRecords_Source From [DB_DATA_DEMO].[dbo].[DataTable]
--union all
Select COUNT(*) TotalRecords_BK From [DB_DATA_DEMO].[dbo].[DataTable_BK]
--union all
Select COUNT(*) TotalRecords_BK From [DB_DATA_DEMO2].[dbo].[DataTable_BK]

-- a. Add new record on source:
INSERT INTO [DB_DATA_DEMO].[dbo].[DataTable] (Data1, Data2, Data3, Data4)
VALUES (NEWID(), NEWID(), NEWID(), NEWID())

-- b. Compare physical records using the Except function
Select PK_Id
From [DB_DATA_DEMO].[dbo].[DataTable]
	Except -- Operator to compare differences
Select PK_Id
From [DB_DATA_DEMO].[dbo].[DataTable_BK]

Select PK_Id
From [DB_DATA_DEMO].[dbo].[DataTable]
	Except -- Operator to compare differences
Select PK_Id
From [DB_DATA_DEMO2].[dbo].[DataTable_BK]

-- 3. Update the new record (To an already existing table)
-- a. Enable Identity Insert
SET IDENTITY_INSERT [DB_DATA_DEMO].[dbo].[DataTable_BK] ON -- Enable
-- b. Insert process
INSERT INTO [DB_DATA_DEMO].[dbo].[DataTable_BK]
(
    PK_Id, -- Primary Key
    Data1,
    Data2,
    Data3,
    Data4
)
Select PK_Id,
       Data1,
       Data2,
       Data3,
       Data4
From [DB_DATA_DEMO].[dbo].[DataTable]
Where PK_Id IN (
                   Select PK_Id
                   From [DB_DATA_DEMO].[dbo].[DataTable]
                   Except -- Operator to compare differences
                   Select PK_Id
                   From [DB_DATA_DEMO].[dbo].[DataTable_BK]
               )
-- c. Disable identity insert
SET IDENTITY_INSERT [DB_DATA_DEMO].[dbo].[DataTable_BK] OFF -- Disable

-------

-- d. Update the second table
-- e. Enable Identity Insert
SET IDENTITY_INSERT [DB_DATA_DEMO2].[dbo].[DataTable_BK] ON -- Enable
-- f. Insert process
INSERT INTO [DB_DATA_DEMO2].[dbo].[DataTable_BK]
(
    PK_Id, -- Primary Key
    Data1,
    Data2,
    Data3,
    Data4
)
Select PK_Id,
       Data1,
       Data2,
       Data3,
       Data4
From [DB_DATA_DEMO].[dbo].[DataTable]
Where PK_Id IN (
                   Select PK_Id
                   From [DB_DATA_DEMO].[dbo].[DataTable]
                   Except -- Operator to compare differences
                   Select PK_Id
                   From [DB_DATA_DEMO2].[dbo].[DataTable_BK]
               )
-- g. Disable identity insert
SET IDENTITY_INSERT [DB_DATA_DEMO2].[dbo].[DataTable_BK] OFF -- Disable



/*
Create database (if needed):
CREATE DATABASE [DB_DATA_DEMO]
GO
CREATE DATABASE [DB_DATA_DEMO2]
GO

Drop tables (if needed):
DROP TABLE IF EXISTS [DB_DATA_DEMO].[dbo].[DataTable]
DROP TABLE IF EXISTS [DB_DATA_DEMO].[dbo].[DataTable_BK]
DROP TABLE IF EXISTS [DB_DATA_DEMO2].[dbo].[DataTable_BK]

Create Table:
CREATE TABLE [DB_DATA_DEMO].[dbo].[DataTable]
(
    [PK_Id] [int] IDENTITY(1, 1) NOT FOR REPLICATION NOT NULL,
    [Data1] [uniqueidentifier] NULL,
    [Data2] [uniqueidentifier] NULL,
    [Data3] [uniqueidentifier] NULL,
    [Data4] [uniqueidentifier] NULL,
    CONSTRAINT [PK_DataTable_PK_Id]
        PRIMARY KEY CLUSTERED ([PK_Id] ASC)
        WITH (PAD_INDEX = OFF, 
			  STATISTICS_NORECOMPUTE = OFF, 
			  IGNORE_DUP_KEY = OFF, 
			  ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
) ON [PRIMARY]
GO

Select ('[' + db_name() +
		'].[' + schema_name(schema_id) + 
		'].[' + name + ']') AS FQON
From sys.tables
Where name like '%table%';

-- Old Table
Select COUNT(*) AS TTL  From [DB_DEMO].[dbo].[DataTable] WITH (NOLOCK);
-- New table
Select COUNT(*) AS TTL  From [DB_DEMO].[dbo].[DataTable2] WITH (NOLOCK);

Insert values:
INSERT INTO [DB_DATA_DEMO].[dbo].[DataTable] (Data1, Data2, Data3, Data4)
VALUES (NEWID(), NEWID(), NEWID(), NEWID())
GO 100

Truncate (if needed):
TRUNCATE TABLE [DB_DATA_DEMO].[dbo].[DataTable]
*/