-- 1. Drop temp Table (if exists)
DROP TABLE IF EXISTS #ProductData

-- 2. Create temp Table
CREATE TABLE #ProductData
(
    Id INT IDENTITY(1, 1) PRIMARY KEY,
    ProcessDate DATE
        DEFAULT GETDATE(),
    ProductJson NVARCHAR(MAX)
);

-- a. Optional index (Only if 'ProductJson' is NVARCHAR(850) or less)
--CREATE INDEX Idx_NC_ProductData_ProductJson ON #ProductData ([ProductJson] ASC);

-- 3. Insert value into temp table
INSERT INTO #ProductData (ProductJson)
VALUES (N'{
    "ProdCode": "34409CFD-793B-4243-B4F5-C1D3608735B8",
    "ProdName": "Incredible Product",
    "RequiresAuth": true,
    "MainComposition": "Water",
    "Lab": {
        "Name": "Penn Riverstone",
        "Location": "Backyard",
        "Web": null,
        "Email": null
    },
    "Composition": ["2 hydrogen atoms", "1 oxygen atom", "Some mixing"]
}');

-- Another insert
INSERT INTO #ProductData (ProductJson)
VALUES (N'{
    "ProdCode": "8B1E78F8-6252-435B-A801-2CC3C2E45F77",
    "ProdName": "Natural Material",
    "RequiresAuth": true,
    "MainComposition": "Wood",
    "Lab": {
        "Name": "Forest Corp",
        "Location": "Wilderness",
        "Web": null,
        "Email": null
    },
    "Composition": ["Cellulose", "Hemicellulose", "Lignin", "Earth"]
}');

-- 4. Select the data and check if content in ProductJson is valid JSON
-- Note: The ISJSON function was introduced on MSSQL Server 2016
SELECT ProductJson
FROM #ProductData
WHERE ISJSON(ProductJson) = 1;

-- 5. Extract columns, including dictionary and list items
-- Note: The JSON_VALUE function was introduced on MSSQL Server 2016
SELECT Top 2 Id, ProcessDate, ProductJson,
    JSON_VALUE(ProductJson, '$.ProdCode') AS [Product Code],
	JSON_VALUE(ProductJson, '$.ProdName') AS [Product Name],
	JSON_VALUE(ProductJson, '$.RequiresAuth') AS [Requires Authorization],
	JSON_VALUE(ProductJson, '$.MainComposition') AS [Main Composition],
    -- This portion reads from the dictionary
	JSON_VALUE(ProductJson, '$.Lab.Name') AS [Lab Name],
	JSON_VALUE(ProductJson, '$.Lab.Location') AS [Lab Location],
	JSON_VALUE(ProductJson, '$.Lab.Web') AS [Lab Web],
	JSON_VALUE(ProductJson, '$.Lab.Email') AS [Lab Email],
	-- This portion reads from the JSON's list by position
	JSON_VALUE(ProductJson, '$.Composition[0]') AS Composition0,
	JSON_VALUE(ProductJson, '$.Composition[1]') AS Composition1,
	JSON_VALUE(ProductJson, '$.Composition[2]') AS Composition2,
	JSON_VALUE(ProductJson, '$.Composition[3]') AS Composition3
FROM #ProductData;

-- 6. For MongoDB Shell (add)
SELECT 'db.ProductData.insertOne('+ProductJson+')' AS [Mongo Script]
FROM #ProductData
