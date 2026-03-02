CREATE OR ALTER PROCEDURE dbo.sp_BcpExportTableCSV
(
    @DatabaseName SYSNAME,
    @SchemaName   SYSNAME,
    @TableName    SYSNAME,
    @OutputFolder NVARCHAR(4000),
    @FileName     NVARCHAR(255) = NULL,      -- optional
    @BcpOptions   NVARCHAR(2000) = '-c -T'   -- default options
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FullTableName NVARCHAR(1000);
    DECLARE @FullPath      NVARCHAR(4000);
    DECLARE @BCPCommand    NVARCHAR(4000);
    DECLARE @ServerName    NVARCHAR(255);

    BEGIN TRY

        -- 1. Validate table exists
        IF NOT EXISTS
        (
            SELECT 1
            FROM sys.databases
            WHERE name = @DatabaseName
        )
        BEGIN
            RAISERROR('Database does not exist.', 16, 1);
            RETURN;
        END

        SET @FullTableName =
            QUOTENAME(@DatabaseName) + '.' +
            QUOTENAME(@SchemaName)   + '.' +
            QUOTENAME(@TableName);

        -- 2. Default file name if not supplied
        IF @FileName IS NULL
            SET @FileName = @TableName + '.csv';

        -- 3. Ensure trailing slash
        IF RIGHT(@OutputFolder,1) NOT IN ('\','/')
            SET @OutputFolder = @OutputFolder + '\';

        SET @FullPath = @OutputFolder + @FileName;

        SET @ServerName = @@SERVERNAME;

        -- 4. Build BCP command
        SET @BCPCommand =
            'bcp "' + @FullTableName + '" out "' + @FullPath + '" '
            + @BcpOptions
            + ' -S "' + @ServerName + '"';

        PRINT 'Executing:';
        PRINT @BCPCommand;
        
        -- 5. Enable xp_cmdshell
        EXEC sp_configure 'show advanced options', 1;
        RECONFIGURE;

        EXEC sp_configure 'xp_cmdshell', 1;
        RECONFIGURE;
                
        -- 6. Execute BCP
        EXEC xp_cmdshell @BCPCommand;

        -- 7. Disable xp_cmdshell
        EXEC sp_configure 'xp_cmdshell', 0;
        RECONFIGURE;

        EXEC sp_configure 'show advanced options', 0;
        RECONFIGURE;

    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Error: ' + @ErrorMessage;

        -- 8. Attempt to disable xp_cmdshell in case of failure
        EXEC sp_configure 'xp_cmdshell', 0;
        RECONFIGURE;

        EXEC sp_configure 'show advanced options', 0;
        RECONFIGURE;

        RAISERROR(@ErrorMessage,16,1);
    END CATCH
END
GO

-- 9. Test Run
EXEC dbo.sp_BcpExportTableCSV 
    @DatabaseName = 'CorporateData_East1', 
    @SchemaName   = 'dbo', 
    @TableName    = 'SamplePeople', 
    @OutputFolder = 'Z:\ExportCSV', 
    @FileName     = 'Export6.csv', 
    @BcpOptions   = '-c -t"," -T';