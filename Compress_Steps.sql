-- Size table
CREATE TABLE [dbo].[Size](
	[Id] [bigint] NULL,
	[ServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabaseName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TimeStamp] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Logical Name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[File Name] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Curr. Alloc. Space (MB)] [decimal](18, 2) NULL,
	[Space Used (MB)] [decimal](18, 2) NULL,
	[Avail. Space (MB)] [decimal](18, 2) NULL,
	[Max Size(MB)] [decimal](18, 2) NULL,
	[AutoG Perc.] [int] NOT NULL,
	[Perc. Used] [decimal](38, 16) NULL,
	[Perc. Avail.] [decimal](38, 16) NULL
) ON [PRIMARY]
GO

-- Populate table
-- TRUNCATE TABLE [StackOverflow2010].[dbo].[Size]
INSERT INTO [StackOverflow2010].[dbo].[Size]
SELECT ROW_NUMBER() OVER (ORDER BY db_name()) AS Id,
       @@servername as ServerName,
       db_name() as DatabaseName,
       --Cast(CURRENT_TIMESTAMP AS [DATE]) as ProcessDate,
       --Cast(CURRENT_TIMESTAMP AS [TIME]) as ProcessTime,
	   Convert(varchar, getdate(), 9) as TimeStamp,
       Name as 'Logical Name',
       filename as 'File Name',
       CONVERT(Decimal(18, 2), ROUND(Size / 128.000, 2)) AS [Curr. Alloc. Space (MB)],
       CONVERT(Decimal(18, 2), ROUND(FILEPROPERTY(Name, 'SpaceUsed') / 128.000, 2)) AS [Space Used (MB)],
       CONVERT(Decimal(18, 2), ROUND((Size - FILEPROPERTY(Name, 'SpaceUsed')) / 128.000, 2)) AS [Avail. Space (MB)],
       [Max Size(MB)] = Case
                            When CONVERT(Decimal(18, 2), ROUND((maxsize) / 128.000, 2)) != -0.01 Then
                                CONVERT(Decimal(18, 2), ROUND((maxsize) / 128.000, 2))
                            Else
                                -1
                        End,
       Growth as [AutoG Perc.],
       (CONVERT(Decimal(18, 2), ROUND(FILEPROPERTY(Name, 'SpaceUsed') / 128.000, 2))
        / CONVERT(Decimal(18, 2), ROUND(Size / 128.000, 2)) * 100
       ) as [Perc. Used],
       (CONVERT(Decimal(18, 2), ROUND((Size - FILEPROPERTY(Name, 'SpaceUsed')) / 128.000, 2))
        / CONVERT(Decimal(18, 2), ROUND(Size / 128.000, 2)) * 100
       ) as [Perc. Avail.]
FROM dbo.sysfiles
GO

-- Files
Select * From [StackOverflow2010].[dbo].[Size]

-- Data structure
-- Tables information
Exec sp_help '[dbo].[ROW_Posts]';
Exec sp_help '[dbo].[PAGE_Posts]';

-- Unique table object id
SELECT OBJECT_ID('[dbo].[ROW_Posts]') AS UniqueOBJECT_ID;    
SELECT OBJECT_ID('[dbo].[PAGE_Posts]') AS UniqueOBJECT_ID;

-- Logical names and files path
Select name AS [Logical Name], filename AS [File Name]  From sysfiles

-- Index information
EXEC sp_helpindex '[dbo].[ROW_Posts]';
EXEC sp_helpindex '[dbo].[PAGE_Posts]';

-- Unique index id information
SELECT 
    CONCAT(i.object_id, '-', i.index_id) AS UniqueIndexKey,
    OBJECT_NAME(i.object_id) AS TableOrView,
    i.name AS IndexName
FROM sys.indexes AS i
WHERE
    i.name IN  ( 'IDX_dbo_PAGE_Posts_AnswerCount', 'IDX_dbo_PAGE_Posts_LastEditorDisplayName', 'IDX_dbo_PAGE_Posts_Tags', 
                 'IDX_dbo_ROW_Posts_AnswerCount', 'IDX_dbo_PAGE_Posts_Title', 'IDX_dbo_ROW_Posts_LastEditorDisplayName',
                 'IDX_dbo_ROW_Posts_Tags','IDX_dbo_ROW_Posts_Title'
              );

-- Provides metadata about all indexes in the current database.
Select *
From sys.indexes
Where name IN  ( 'IDX_dbo_PAGE_Posts_AnswerCount', 'IDX_dbo_PAGE_Posts_LastEditorDisplayName', 'IDX_dbo_PAGE_Posts_Tags', 
                 'IDX_dbo_ROW_Posts_AnswerCount', 'IDX_dbo_PAGE_Posts_Title', 'IDX_dbo_ROW_Posts_LastEditorDisplayName',
                 'IDX_dbo_ROW_Posts_Tags','IDX_dbo_ROW_Posts_Title'
              );

-- Offers information about index fragmentation and size.
SELECT
    s.object_id,
    s.index_id,
    i.name AS index_name,
    s.avg_fragmentation_in_percent
FROM
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') AS s
INNER JOIN
    sys.indexes AS i ON i.object_id = s.object_id AND i.index_id = s.index_id
Where name IN  ( 'IDX_dbo_PAGE_Posts_AnswerCount', 'IDX_dbo_PAGE_Posts_LastEditorDisplayName', 'IDX_dbo_PAGE_Posts_Tags', 
                 'IDX_dbo_ROW_Posts_AnswerCount', 'IDX_dbo_PAGE_Posts_Title', 'IDX_dbo_ROW_Posts_LastEditorDisplayName',
                 'IDX_dbo_ROW_Posts_Tags','IDX_dbo_ROW_Posts_Title'
              );

-- Querying the tables
-- Sample
Select Top 10 
	LastEditorDisplayName,	-- nvarchar(80)
	Tags,					-- nvarchar(300)
	Title,					-- nvarchar(500)
	AnswerCount				-- int(4)
From [StackOverflow2010].[dbo].[ROW_Posts];

-- Sample
Select Top 10 
	LastEditorDisplayName,	-- nvarchar(80)
	Tags,					-- nvarchar(300)
	Title,					-- nvarchar(500)
	AnswerCount				-- int(4)
From [StackOverflow2010].[dbo].[Page_Posts];

-- Count
Select FORMAT(COUNT(Id), 'N0') AS Total_Records
From [StackOverflow2010].[dbo].[ROW_Posts] WITH (NOLOCK);
GO

Select FORMAT(COUNT(Id), 'N0') AS Total_Records
From [StackOverflow2010].[dbo].[PAGE_Posts] WITH (NOLOCK);
GO


-- 1. Table compression:
USE [StackOverflow2010]
ALTER TABLE [dbo].[ROW_Posts] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = ROW
) -- 28 Secs...


USE [StackOverflow2010]
ALTER TABLE [dbo].[PAGE_Posts] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = PAGE
) -- 29 Secs...

-- 2. Index compression:
-- a. ROW -- 9 Secs...
ALTER INDEX [IDX_dbo_ROW_Posts_AnswerCount] On [StackOverflow2010].[dbo].[ROW_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON);
ALTER INDEX [IDX_dbo_ROW_Posts_LastEditorDisplayName] On [StackOverflow2010].[dbo].[ROW_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON);
ALTER INDEX [IDX_dbo_ROW_Posts_Tags] On [StackOverflow2010].[dbo].[ROW_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON);
ALTER INDEX [IDX_dbo_ROW_Posts_Title] On [StackOverflow2010].[dbo].[ROW_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON);

-- b. PAGE -- 13 Secs...
ALTER INDEX [IDX_dbo_PAGE_Posts_AnswerCount] On [StackOverflow2010].[dbo].[PAGE_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE, SORT_IN_TEMPDB = ON);
ALTER INDEX [IDX_dbo_PAGE_Posts_LastEditorDisplayName] On [StackOverflow2010].[dbo].[PAGE_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE, SORT_IN_TEMPDB = ON);
ALTER INDEX [IDX_dbo_PAGE_Posts_Tags] On [StackOverflow2010].[dbo].[PAGE_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE, SORT_IN_TEMPDB = ON);
ALTER INDEX [IDX_dbo_PAGE_Posts_Title] On [StackOverflow2010].[dbo].[PAGE_Posts] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE, SORT_IN_TEMPDB = ON);

-- c. PK Compression
ALTER INDEX PK_ROW_Posts_Id On dbo.ROW_Posts REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON); -- 20 Secs...
ALTER INDEX PK_PAGE_Posts_Id On dbo.PAGE_Posts REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE, SORT_IN_TEMPDB = ON); -- 27 Secs...



-- 1st query
-- List all logical names
Select [Logical Name],
       [File Name],
       [Curr. Alloc. Space (MB)],
       [Space Used (MB)],
       [Avail. Space (MB)]
From [StackOverflow2010].[dbo].[Size]
Where [Logical Name] = '[TBL]_[dbo_ROW_Posts]_[1]'
Order by Id, [Logical Name], [TimeStamp] ASC;


-- 2nd query
-- Variables
DECLARE @LEADVal INT
SET @LEADVal = 1

-- Query
SELECT  TOP 1 [Logical Name],
       [File Name],
       [Curr. Alloc. Space (MB)] AS [Old Curr. Alloc. Space (MB)],
       LEAD([Curr. Alloc. Space (MB)], @LEADVal) OVER (ORDER BY [Logical Name]) AS [New Curr. Alloc. Space (MB)],
       (LEAD([Curr. Alloc. Space (MB)], @LEADVal) OVER (ORDER BY [Logical Name]) - [Curr. Alloc. Space (MB)]) AS [Increased Curr. Alloc. Space (MB)],
       FORMAT(
           ABS(([Curr. Alloc. Space (MB)] - LEAD([Curr. Alloc. Space (MB)], @LEADVal) OVER (ORDER BY [Logical Name]))
               / [Curr. Alloc. Space (MB)]),
           'P2') AS [% Increased Alloc. (MB)],
       [Space Used (MB)] AS [Old Space Used (MB)],
       LEAD([Space Used (MB)], @LEADVal) OVER (ORDER BY [Logical Name]) AS [New Space Used (MB)],
       [Space Used (MB)] - LEAD([Space Used (MB)], @LEADVal) OVER (ORDER BY [Logical Name]) AS [Reduced Space (MB)],
       FORMAT(
           ABS(([Space Used (MB)] - LEAD([Space Used (MB)], @LEADVal) OVER (ORDER BY [Logical Name]))
               / [Space Used (MB)]),
           'P2') AS [% Savings Compr.],
       'DBCC SHRINKFILE (N''' + [Logical Name] + ''', '+'1)' AS [ShrinkCommand]
  FROM [StackOverflow2010].[dbo].[Size]
  Where [Logical Name] IN ('[TBL]_[dbo_ROW_Posts]_[1]')
GO





-- Using a cursor

-- 1. Drop Temp Tables
DROP TABLE IF EXISTS #LogicalNames;
DROP TABLE IF EXISTS #Results;

-- 2. Create and Insert values into temp table
SELECT DISTINCT [Logical Name]
INTO #LogicalNames
FROM [StackOverflow2010].[dbo].[Size];

-- 3. Create the results temporary table
CREATE TABLE #Results (
    [Logical Name] NVARCHAR(255),
    [File Name] NVARCHAR(255),
    [Old Curr. Alloc. Space (MB)] DECIMAL(18,2),
    [New Curr. Alloc. Space (MB)] DECIMAL(18,2),
    [Increased Curr. Alloc. Space (MB)] DECIMAL(18,2),
    [% Increased Alloc. (MB)] NVARCHAR(20),
    [Old Space Used (MB)] DECIMAL(18,2),
    [New Space Used (MB)] DECIMAL(18,2),
    [Reduced Space (MB)] DECIMAL(18,2),
    [% Savings Compr.] NVARCHAR(20),
    [ShrinkCommand] NVARCHAR(MAX)
);

-- 4. Declare all cursor variables
DECLARE @LogicalName NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @LEADVal INT = 1;

-- 5. Cursor's definition
DECLARE LogicalNameCursor CURSOR FAST_FORWARD FOR
    SELECT [Logical Name] FROM #LogicalNames;

-- 6. Open your cursor
OPEN LogicalNameCursor;
FETCH NEXT FROM LogicalNameCursor INTO @LogicalName;

-- 7. Loop through the process
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
        INSERT INTO #Results
        SELECT TOP 1
               [Logical Name],
               [File Name],
               [Curr. Alloc. Space (MB)] AS [Old Curr. Alloc. Space (MB)],
               LEAD([Curr. Alloc. Space (MB)], ' + CAST(@LEADVal AS NVARCHAR(10)) + ') OVER (ORDER BY [Logical Name]) AS [New Curr. Alloc. Space (MB)],
               (LEAD([Curr. Alloc. Space (MB)], ' + CAST(@LEADVal AS NVARCHAR(10)) + ') OVER (ORDER BY [Logical Name]) - [Curr. Alloc. Space (MB)]) AS [Increased Curr. Alloc. Space (MB)],
               FORMAT(
                   ABS(([Curr. Alloc. Space (MB)] - LEAD([Curr. Alloc. Space (MB)], ' + CAST(@LEADVal AS NVARCHAR(10)) + ') OVER (ORDER BY [Logical Name]))
                       / [Curr. Alloc. Space (MB)]),
                   ''P2'') AS [% Increased Alloc. (MB)],
               [Space Used (MB)] AS [Old Space Used (MB)],
               LEAD([Space Used (MB)], ' + CAST(@LEADVal AS NVARCHAR(10)) + ') OVER (ORDER BY [Logical Name]) AS [New Space Used (MB)],
               [Space Used (MB)] - LEAD([Space Used (MB)], ' + CAST(@LEADVal AS NVARCHAR(10)) + ') OVER (ORDER BY [Logical Name]) AS [Reduced Space (MB)],
               FORMAT(
                   ABS(([Space Used (MB)] - LEAD([Space Used (MB)], ' + CAST(@LEADVal AS NVARCHAR(10)) + ') OVER (ORDER BY [Logical Name]))
                       / [Space Used (MB)]),
                   ''P2'') AS [% Savings Compr.],
               ''DBCC SHRINKFILE (N''''' + @LogicalName + ''''', 1)'' AS [ShrinkCommand]
          FROM [StackOverflow2010].[dbo].[Size]
         WHERE [Logical Name] = N''' + @LogicalName + ''';';

    -- Debug (optional):
    -- PRINT @SQL;

    EXEC sp_executesql @SQL;

    FETCH NEXT FROM LogicalNameCursor INTO @LogicalName;
END;

-- 8. Close and deallocate
CLOSE LogicalNameCursor;
DEALLOCATE LogicalNameCursor;

-- 9. Show results
SELECT * FROM #Results ORDER BY [Logical Name];


-- Other tools, might not be on the video....

-- Calculate savings % manually
DECLARE @V1 DECIMAL(12, 2) -- Original Size
DECLARE @V2 DECIMAL(12, 2) -- After Compression
DECLARE @R1 DECIMAL(12, 2) -- Result
SET @V1 = 98.88
SET @V2 = 30.69
SET @R1 =
(
    Select ABS((@V2 - @V1) / @V1 * 100)
)
Select CONVERT(VARCHAR(7),@R1)+'%'

-- Count with format function
Select FORMAT(COUNT(Id), 'N0') AS Total_Records
From [StackOverflow2010].[dbo].[ROW_Posts] WITH (NOLOCK);
GO

Select FORMAT(COUNT(Id), 'N0') AS Total_Records
From [StackOverflow2010].[dbo].[PAGE_Posts] WITH (NOLOCK);
GO

-- Longest value
Select MAX(LEN(LastEditorDisplayName)) AS LastEditorDisplayName
From [StackOverflow2010].[dbo].[Posts];

Select MAX(LEN(Tags)) AS Tags
From [StackOverflow2010].[dbo].[Posts];

Select MAX(LEN(Title)) AS Title
From [StackOverflow2010].[dbo].[Posts];

-- Count Null Values
-- Real records:
With CTE_LastEditorDisplayName AS (
Select COUNT(CASE WHEN LastEditorDisplayName IS NULL THEN 1 END) AS [NULL LastEditorDisplayName]
From [StackOverflow2010].[dbo].[Posts])
Select FORMAT([NULL LastEditorDisplayName], 'N0') AS [NULL LastEditorDisplayName] From CTE_LastEditorDisplayName
GO

-- Real records:
With [CTE_NULL Tags] AS (
Select COUNT(CASE WHEN Tags IS NULL THEN 1 END) AS [NULL Tags]
From [StackOverflow2010].[dbo].[Posts])
Select FORMAT([NULL Tags], 'N0') AS [NULL Tags] From [CTE_NULL Tags]
GO

-- Real records:
With [CTE_Null Title] AS (
Select COUNT(CASE WHEN Title IS NULL THEN 1 END) AS [NULL Title]
From [StackOverflow2010].[dbo].[Posts])
Select FORMAT([NULL Title], 'N0') AS [NULL Title] From [CTE_Null Title]
GO

