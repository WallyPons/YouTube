-- Use the database from where you want run the BCP Export
-- Variable declarations
DECLARE @FPath as varchar(256)
DECLARE @FExtension as char(3)
DECLARE @SQLcred as varchar(255)
DECLARE @QOSelect as varchar(25)
DECLARE @BCPpath as varchar(256)
DECLARE @BCPExtension as char(3)
DECLARE @BCPLogOut as varchar(256)
DECLARE @BCPLogIn as varchar(256)
DECLARE @BCPLogOutextension as char(3)
DECLARE @BCPLogInextension as char(3)
DECLARE @DestinationDB as varchar(128)
DECLARE @BCPOptions as varchar(128)

-- Variable values
SET @FPath = 'C:\BCP\DB_SOPORTE_IT\FormatFile'              -- Format file path
SET @FExtension = 'fmt'                                     -- Format file extension
SET @SQLcred = '-S"." -T'                                   -- SQL Server credentials (-S server name, -T trusted connection)
SET @QOSelect = 'Select'                                    -- Select statement portion can use TOP n if needed
SET @BCPpath = 'C:\BCP\DB_SOPORTE_IT\QueryOut'              -- BCP files path
SET @BCPExtension = 'dat'                                   -- BCP file extension
SET @BCPLogOut = 'C:\BCP\DB_SOPORTE_IT\Log\Out'             -- Export log files
SET @BCPLogIn = 'C:\BCP\DB_SOPORTE_IT\Log\In'               -- Import log files
SET @BCPLogOutextension = 'log'                             -- File extension for the OUT log
SET @BCPLogInextension = 'log'                              -- File extension for the IN log
SET @DestinationDB = 'DB_SOPORTE_ITNew'                     -- Target database
SET @BCPOptions = '-N -E -b 100000'                         -- Aside from the options (-N keep non-text native, -E keep identity values), you can set the batch size (-b)

-- If you need to create the folders from SQL
/*
EXEC master.dbo.xp_create_subdir @FPath
EXEC master.dbo.xp_create_subdir @BCPpath
EXEC master.dbo.xp_create_subdir @BCPLogOut
EXEC master.dbo.xp_create_subdir @BCPLogIn
*/

-- Remove trailing backslash for paths, if they exist
SET @FPath = CASE 
                WHEN RIGHT(@FPath, 1) = '\' THEN LEFT(@FPath, LEN(@FPath) - 1) 
                ELSE @FPath 
             END;

SET @BCPpath = CASE 
                WHEN RIGHT(@BCPpath, 1) = '\' THEN LEFT(@FPath, LEN(@BCPpath) - 1) 
                ELSE @BCPpath 
             END;


SET @BCPLogOut = CASE 
                WHEN RIGHT(@BCPLogOut, 1) = '\' THEN LEFT(@BCPLogOut, LEN(@BCPLogOut) - 1) 
                ELSE @BCPLogOut 
             END;

SET @BCPLogIn = CASE 
                WHEN RIGHT(@BCPLogIn, 1) = '\' THEN LEFT(@BCPLogIn, LEN(@BCPLogIn) - 1) 
                ELSE @BCPLogIn 
             END;

/* 
Query to generate format files, export and import scripts. 
Theses must be put in a batch file for later execution.
*/

;
With CTE_Cols
AS (SELECT db_name() AS Dbname,
       schema_name(t.schema_id) AS schema_name,
       t.name AS TABLE_NAME,
       STUFF(
           (SELECT ',[' + c.name + ']' AS [text()]  
            FROM sys.columns c
            WHERE c.object_id = t.object_id
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),  
           1, 1, '') AS COLUMN_NAME
FROM sys.tables t
   )
Select Dbname,
       [schema_name],
       TABLE_NAME,
       COLUMN_NAME,
       'bcp [' + Dbname + '].[' + schema_name + '].[' + TABLE_NAME + '] format nul -f "' + @FPath + '\' + schema_name
       + '_' + TABLE_NAME + '.' + @FExtension + '"' + ' -N ' + @SQLcred AS FormatFileBCP,
       'bcp "' + @QOSelect + ' ' + COLUMN_NAME + ' From [' + Dbname + '].[' + schema_name + '].[' + TABLE_NAME
       + '] WITH (NOLOCK)" queryout "' + @BCPpath + '\' + schema_name + '_' + TABLE_NAME + '.' + @BCPExtension
       + '" -f "' + @FPath + '\' + schema_name + '_' + TABLE_NAME + '.' + @FExtension + '" -o "' + @BCPLogOut + '\'
       + schema_name + '_' + TABLE_NAME + '.' + @BCPLogOutextension + '" -N ' + @SQLcred AS ExportBCP,
       'bcp [' + @DestinationDB + '].[' + schema_name + '].[' + TABLE_NAME + '] in "' + @BCPpath + '\' + schema_name
       + '_' + TABLE_NAME + '.' + @BCPExtension + '" -f "' + @FPath + '\' + schema_name + '_' + TABLE_NAME + '.'
       + @FExtension + '" -o "' + @BCPLogIn + '\' + schema_name + '_' + TABLE_NAME + '.' + @BCPLogInextension + '" '
       + @BCPOptions + ' ' + @SQLcred AS ImportBCP
From CTE_Cols
-- Where TABLE_NAME = '?' -- You can filter by one table, if needed.
Order By TABLE_NAME ASC;
