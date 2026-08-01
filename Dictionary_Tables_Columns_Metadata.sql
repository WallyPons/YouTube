/*
A very useful script to generate a dictionary to get
table, column details and their related metadata from
most MS SQL Database types.
*/

SELECT ROW_NUMBER() OVER (ORDER BY t.name ASC) AS ID,
       CAST(CURRENT_TIMESTAMP AS DATE) AS ProcessDate,
       @@SERVERNAME AS ServerName,
       t.create_date,
       t.modify_date,
       t.object_id,
       '[' + DB_NAME() + '].
        [' + SCHEMA_NAME(t.schema_id) + '].
        [' + t.name + ']' 
       AS [FQON: Database + Schema + Table],
       c.name AS ColumnName,
       ty.name AS DataTypeName,
       c.max_length,
       c.precision,
       c.scale,
       c.is_nullable,
       se.value AS ExtendedPropertyValue
FROM sys.tables t
    INNER JOIN sys.columns c
        ON t.object_id = c.object_id
    INNER JOIN sys.types ty
        ON ty.user_type_id = c.user_type_id
    LEFT JOIN sys.extended_properties se
        ON se.major_id = t.object_id
           AND se.minor_id = c.column_id
ORDER BY t.name,
         c.column_id;


/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/