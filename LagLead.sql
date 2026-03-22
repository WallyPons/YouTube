-- 1. Verify temp table existence, if it exists then drop
DROP TABLE IF EXISTS #SalesTest

-- a. Create temp table
CREATE TABLE #SalesTest
(
    Sales_Id [int] IDENTITY(1, 1) NOT NULL,
    SC_Id [int] NOT NULL, -- Sales Customer Id
    Sales_Date datetime2 NOT NULL,
    Sales_Amount decimal(16, 2) NOT NULL,
    CONSTRAINT [PK_NC_UNQ_SalesTest_Sales_Id]
        PRIMARY KEY NONCLUSTERED ([Sales_Id] ASC)
        WITH (PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON,
        ALLOW_PAGE_LOCKS = ON)
);
GO

-- 2. Insert dummy values (add more if you wish)
INSERT INTO #SalesTest
(
    SC_Id, -- Sales Customer Id
    Sales_Date,
    Sales_Amount
)
VALUES
-- Sales Customer Id 1
(1, '20260101', 54.99),
(1, '20260102', 75.97),
(1, '20260103', 24.89),
(1, '20260104', 104.95),
(1, '20260105', 63.16),
(1, '20260106', 63.16),
-- Sales Customer Id 2
(2, '20260101', 62.36),
(2, '20260102', 92.86),
(2, '20260103', 77.23),
(2, '20260104', 114.48),
(2, '20260105', 45.90),
(2, '20260106', 45.90);

-- 3. Select dummy values
Select Sales_Id,
       SC_Id,
       CONVERT(VARCHAR, Sales_Date, 107) AS [Sales Date],
       Sales_Amount AS [Sales Amount]
From #SalesTest;

-- 4. Using Lag (Show previous value)
Select SC_Id,
       CONVERT(VARCHAR, Sales_Date, 107) AS [Sales Date],
       Sales_Amount AS [Sales Amount],

       LAG(Sales_Amount, 1, 0) 
       OVER (PARTITION BY SC_Id -- Sales Customer Id
       ORDER BY Sales_Date) AS [Previous Value]
From #SalesTest WHERE SC_Id = 2;

-- 5. Using Lead (Show next value)
Select SC_Id,
       CONVERT(VARCHAR, Sales_Date, 107) AS [Sales Date],
       Sales_Amount AS [Sales Amount],
       
       LEAD(Sales_Amount, 1, 0) 
       OVER (PARTITION BY SC_Id -- Sales Customer Id
       ORDER BY Sales_Date) AS [Next Value]
From #SalesTest WHERE SC_Id = 2;


-- 5. Using Lead (Evaluate for a higher value)
Select SC_Id,
       CONVERT(VARCHAR, Sales_Date, 107) AS [Sales Date],
       Sales_Amount AS [Sales Amount],
       
       LEAD(Sales_Amount, 1, 0) 
       OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
       AS [Next Value],
       
       CASE
           
           WHEN LEAD(Sales_Amount, 1, 0) 
           OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
           > Sales_Amount Then 'Yes'
           
           WHEN LEAD(Sales_Amount, 1, 0) 
           OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
           < Sales_Amount Then 'No'
           
           WHEN LEAD(Sales_Amount, 1, 0) 
           OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
           = Sales_Amount Then 'Same Value'
       
        End as [Was it higher?]
From #SalesTest 
        WHERE SC_Id = 1;

-- 6. Using Lag and Lead
Select SC_Id,
       CONVERT(VARCHAR, Sales_Date, 107) AS [Sales Date],
       
       LAG(Sales_Amount, 2, 0) 
       OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
       AS Prev_2_Value,
       
       LAG(Sales_Amount, 1, 0) 
       OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
       AS Prev_1_Value,
       
       Sales_Amount AS [Sales Amount],
       
       LEAD(Sales_Amount, 1, 0) 
       OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
       AS Next_1_Value,
       
       LEAD(Sales_Amount, 2, 0) 
       OVER (PARTITION BY SC_Id ORDER BY Sales_Date) 
       AS Next_2_Value
From #SalesTest 
       WHERE SC_Id = 1;