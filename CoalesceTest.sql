-- 1. Drop table IF EXISTS
DROP TABLE IF EXISTS #COALESCE_TEST

-- 2. Create local temp table
CREATE TABLE #COALESCE_TEST
(
    ProdCode VARCHAR(21)
        DEFAULT (CONVERT(VARCHAR(4), YEAR(GETDATE())) 
                    + '-' + LEFT(NEWID(), 8) 
                    + RIGHT(NEWID(), 8)),
    ProdName VARCHAR(20),
    ProdPrice DECIMAL(12, 2)
);

-- 3. Insert values
INSERT INTO #COALESCE_TEST
(
    ProdName,
    ProdPrice
)
VALUES
('TUNNER1', 22.99),
('TUNNER2', NULL),
('TUNNER3', 20.99),
('TUNNER4', 27.99),
('TUNNER5', NULL);

-- 4. Query without COALESCE
Select ProdCode,
       ProdName,
       ProdPrice
From #COALESCE_TEST;

-- 5. Query with COALESCE
Select ProdCode,
       ProdName,
       COALESCE(ProdPrice, 0) AS ProdPrice
From #COALESCE_TEST;
