-- 1. We'll run this against the StackOverflow database
-- a. A temp table will be used to store the results
DROP TABLE IF EXISTS ##RowCounts
CREATE TABLE ##RowCounts (
    TableName NVARCHAR(255),
    [RowCount] BIGINT
);
-- 2. Declare the dynamic query variable
DECLARE @QueryString NVARCHAR(MAX);
-- 3. Construct the dynamic query
SELECT 
@QueryString = COALESCE(@QueryString + ' UNION ALL ', '')
+ 'SELECT '
+ '''' + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
+ '.' + QUOTENAME(sOBJ.name) + '''' + ' AS [TableName], '
+ 'COUNT_BIG(*) AS [RowCount] '
+ 'FROM ' + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
+ '.' + QUOTENAME(sOBJ.name) + ' WITH (NOLOCK) '
FROM sys.objects AS sOBJ
WHERE
      sOBJ.type = 'U'
      AND sOBJ.is_ms_shipped = 0x0
ORDER BY SCHEMA_NAME(sOBJ.schema_id), sOBJ.name;
-- 4. Insert the dynamic query results on temp table
INSERT INTO ##RowCounts (TableName, [RowCount])
EXEC sp_executesql @QueryString;
-- 5. Run a select on the inserted results from ##RowCounts
SELECT * FROM ##RowCounts Order by [RowCount] DESC;

-- Don't forget to download a copy of this and other 
-- scripts from my Github repo, please check the link and 
-- name of the file on the video description. 
-- This and other solutions are given "AS IS" under no
-- warranty or claim.
