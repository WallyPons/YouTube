CREATE OR ALTER PROCEDURE dbo.sp_BcpExportQueryCSV
(
    @Query        NVARCHAR(MAX),
    @OutputFolder NVARCHAR(4000),
    @FileName     NVARCHAR(255) = 'Export.csv',
    @BcpOptions   NVARCHAR(2000) = '-c -T'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ServerName NVARCHAR(255);
    DECLARE @FullPath   NVARCHAR(4000);
    DECLARE @BCPCommand NVARCHAR(MAX);
    DECLARE @BCPCommand_VARCHAR VARCHAR(8000); 

    BEGIN TRY

        IF RIGHT(@OutputFolder,1) NOT IN ('\','/')
            SET @OutputFolder = @OutputFolder + '\';

        SET @FullPath = @OutputFolder + @FileName;
        SET @ServerName = @@SERVERNAME;

        -- 1. Escape double quotes
        SET @Query = REPLACE(@Query, '"', '""');

        -- 2. Build BCP command
        SET @BCPCommand =
            'bcp "' + @Query + '" queryout "' + @FullPath + '" '
            + @BcpOptions
            + ' -S "' + @ServerName + '"';

        PRINT 'Executing:';
        PRINT @BCPCommand;

        -- 3. Enable xp_cmdshell
        EXEC sp_configure 'show advanced options', 1;
        RECONFIGURE;

        EXEC sp_configure 'xp_cmdshell', 1;
        RECONFIGURE;

        -- 4. Convert to VARCHAR(8000)
        SET @BCPCommand_VARCHAR = CAST(@BCPCommand AS VARCHAR(8000));
        EXEC xp_cmdshell @BCPCommand_VARCHAR;

        -- 5. Disable xp_cmdshell
        EXEC sp_configure 'xp_cmdshell', 0;
        RECONFIGURE;

        EXEC sp_configure 'show advanced options', 0;
        RECONFIGURE;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Error: ' + @ErrorMessage;

        EXEC sp_configure 'xp_cmdshell', 0;
        RECONFIGURE;

        EXEC sp_configure 'show advanced options', 0;
        RECONFIGURE;

        RAISERROR(@ErrorMessage,16,1);
    END CATCH
END
GO

-- 6. Test run
EXEC dbo.sp_BcpExportQueryCSV
    @Query = 'SELECT * FROM [CorporateData_East1].[dbo].[SamplePeople] WHERE Job_Title = ''Software Consultant''',
    @OutputFolder = 'Z:\ExportCSV',
    @FileName = 'Export7.csv',
    @BcpOptions = '-c -t"," -T';