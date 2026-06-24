/*
Using spaces for object names: While SQL Server 
technically allows spaces in object names, DBA's 
and developers consider them a bad practice.
Avoiding them, is highly recommended.
*/
-- 1. Database (One Space)
CREATE DATABASE [ ];
GO

-- 2. Create schema (One Space)
USE [ ];
GO
CREATE SCHEMA [ ]; 
GO

-- 3. Create table (One Space)
CREATE TABLE 
[ ].[ ].[ ] (Val1 INT); 
GO

-- 4. Insert five values
INSERT INTO [ ].[ ].[ ]
(
    Val1
)
VALUES (1),(2),(3),(4),(5);
GO

-- 5. Select the values
SELECT *
FROM [ ].[ ].[ ];
GO

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/