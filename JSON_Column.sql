/*
JSON data type: Applies to SQL 2025 (17.x)

The json data type stores JSON documents in a 
native binary format. The json type provides 
a high-fidelity storage of JSON documents 
optimized for easy querying and manipulation.
*/ 
-- 1. Sample table with JSON column
CREATE TABLE [DB_DEMO].[dbo].[ProductData]
(Id INT IDENTITY(1, 1) PRIMARY KEY,
 ProcessDate DATE DEFAULT GETDATE(),
 ProductJson JSON NOT NULL);
-- 2. Insert JSON data
INSERT INTO [DB_DEMO].[dbo].[ProductData] (ProductJson)
VALUES ('{
    "ProdCode": "8B1E78F8-6252-435B-A801-2CC3C2E45F77",
    "ProdName": "Natural Material",
    "RequiresAuth": true,
    "MainComposition": "Wood",
    "Lab": {
        "Name": "Forest Corp",
        "Location": "Wilderness"
    },
    "Composition": ["Item 1", "Item 2"]
}');
-- 3. Read the JSON data
SELECT TOP 1 * FROM [DB_DEMO].[dbo].[ProductData];
/*
 Don't forget to download a copy of this and other 
 scripts from my GitHub repo, please check the link and 
 name of the file on the video description. This and 
 other solutions are given "AS IS" under no  warranty 
 or claim.
*/