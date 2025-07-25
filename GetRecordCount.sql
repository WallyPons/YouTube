-- Create a temporary table with the same structure as the dynamic query result
DROP TABLE IF EXISTS ##RowCounts
CREATE TABLE ##RowCounts (
    TableName NVARCHAR(255),
    [RowCount] BIGINT
);

-- Declare the dynamic query variable
DECLARE @QueryString NVARCHAR(MAX);

-- Construct the dynamic query
SELECT @QueryString = COALESCE(@QueryString + ' UNION ALL ', '')
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

-- Insert the dynamic query results into the temporary table
INSERT INTO ##RowCounts (TableName, [RowCount])
EXEC sp_executesql @QueryString;

-- Check the inserted results
SELECT * FROM ##RowCounts Order by [RowCount] DESC;