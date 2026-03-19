-- 1. Get Min and Max dates
Select 
MIN(CommunityOwnedDate) AS MinDate,
MAX(CommunityOwnedDate) AS MaxDate
FROM [StackOverflow2010New].[dbo].[Posts_Archive];


-- a. Count
Select COUNT(*) AS Count 
FROM [StackOverflow2010New].[dbo].[Posts_Archive];
-- 3,729,195

-- 2. This will cause database degradation:
DELETE FROM [StackOverflow2010New].[dbo].[Posts_Archive]
WHERE CommunityOwnedDate >= '2008-08-12 04:59:35.017'
      AND CommunityOwnedDate <= '2018-08-17 18:17:11.620';

-- 3. Better for transaction log: 
-- a. Variable declaration
DECLARE @BatchSize BIGINT = 100000; -- Batch Size
DECLARE @DateFrom DATE = '2008-08-12 04:59:35.017';
DECLARE @DateTo DATE = '2018-08-17 18:17:11.620';
DECLARE @RowsAffected BIGINT = 1;

-- 4. Process
WHILE @RowsAffected > 0
BEGIN
    BEGIN TRANSACTION;
    Print 'Current Date : ' + Convert(varchar, getdate(), 9)
    DELETE TOP (@BatchSize)
    FROM [StackOverflow2010New].[dbo].[Posts_Archive]
    WHERE CommunityOwnedDate >= @DateFrom 
    AND CommunityOwnedDate <= @DateTo 

    SET @RowsAffected = @@ROWCOUNT;

    COMMIT TRANSACTION;
    Print 'Current Date : ' + Convert(varchar, getdate(), 9)

-- 5. Delay
    WAITFOR DELAY '00:00:01'; -- 1 second delay
END
GO