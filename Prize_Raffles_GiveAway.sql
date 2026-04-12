-- 1. Let's pick 50 random customers into a 
-- new table created automatically
DROP TABLE IF EXISTS [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]

SELECT TOP 50
    CustomerID AS [Customer ID],
    CONCAT_WS(' ', FirstName, MiddleName, LastName, Suffix) AS [Full Customer Name],
    CompanyName AS [Company Name],
    EmailAddress AS [Email Address],
    Phone
INTO [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01] -- New table
FROM [AdventureWorksLT2025].[SalesLT].[Customer] -- Source table
ORDER BY NEWID() ASC; -- For randomness
                      
-- 2. Alter the table and create three columns
ALTER TABLE [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]
ADD -- This will add three columns
    [Winner] [bit] NOT NULL
        DEFAULT 0,
    [Winning_Date] [DATETIME2],
    [SQL_User] nvarchar(128);

-- 3. View table
SELECT *
FROM [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01];

-- 4. Get a radom winner
USE [AdventureWorksLT2025];
GO

SET NOCOUNT ON;
DECLARE @GetWinner INT = NULL
SET @GetWinner =
(
    SELECT Top 1
        [Customer ID]
    FROM [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]
    WHERE [Winner] = 0
    ORDER BY NEWID() ASC
);
-- a. Print Winner
DECLARE @FullName VARCHAR(100)
SET @FullName =
(
    Select [Full Customer Name]
    FROM [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]
    WHERE [Customer ID] = @GetWinner
)
--PRINT 'Your winner code is: ' + @GetWinner
--+ ', congratulations!'
PRINT 'Your winner name is: ' + @FullName + ', congratulations!'
PRINT '' -- b. White space
-- c. Update until everyone Winner
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]
    SET [Winner] = 1,
        [Winning_Date] = GETDATE(),
        [SQL_User] = (SUSER_NAME())
    Where [Customer ID] = @GetWinner;
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';
END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Error detected; transaction rolled back.';
    END

    -- Capture and display error details
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage,
           ERROR_SEVERITY() AS ErrorSeverity,
           ERROR_STATE() AS ErrorState;
END CATCH;

-- d. Count remaining
--WaitFor Delay '00:00:01' -- Delay 1 sec
DECLARE @Remaining INT
SET @Remaining =
(
    Select COUNT_BIG(*)
    FROM [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]
    WHERE [Winner] = 0
)
IF @Remaining = ''
    PRINT 'No more winners!'
IF @Remaining = 1
    PRINT '1 winner left!'
IF @Remaining > 1
    PRINT 'There are ' + CAST(@Remaining AS VARCHAR) + ' remaining winners!'

-- e. View current winners
SELECT [Customer ID],
       [Full Customer Name],
       Winner,
       Winning_Date,
       SQL_User
FROM [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]
WHERE Winner = 1

-- e. View pending winners
SELECT [Customer ID],
       [Full Customer Name],
       Winner,
       Winning_Date,
       SQL_User
FROM [AdventureWorksLT2025].[SalesLT].[Customer_Giveaway01]
WHERE Winner = 0