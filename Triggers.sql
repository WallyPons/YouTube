USE [DB_DEMO]
GO

-- 1. Drop tables and triggers (clean environment)
-- a. Tables
DROP TABLE IF EXISTS [DB_DEMO].[dbo].[TblTriggerWatch];
DROP TABLE IF EXISTS [DB_DEMO].[dbo].[Person];
-- b. Triggers ('DROP TRIGGER' does not allow specifying the database name as a prefix)
DROP TRIGGER IF EXISTS [dbo].[trg_Insert_dbo_Person];
DROP TRIGGER IF EXISTS [dbo].[trg_Update_dbo_Person];
DROP TRIGGER IF EXISTS [dbo].[trg_Delete_dbo_Person];

-- 2. Create tables
-- a. Person
CREATE TABLE [DB_DEMO].[dbo].[Person]
(
    [Person_Id] [bigint] IDENTITY(1, 1) NOT NULL,
    [PersonName] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DateOfBirth] [date] NULL,
    CONSTRAINT [PK_NC_UNQ_Person_Id_Person]
        PRIMARY KEY NONCLUSTERED ([Person_Id] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
) ON [PRIMARY]
GO

-- b. TblTriggerWatch
CREATE TABLE [DB_DEMO].[dbo].[TblTriggerWatch]
(
    [Action_Id] [bigint] IDENTITY(1, 1) NOT NULL,
    [Record_Id] [bigint] NULL,
    [Table_Schema] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Table_Name] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Trigger_name] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Host_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[App_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DB] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Action_Taken] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Action_Time] [datetime],
    [User_Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [spid] [int] NULL,
    [Server_Name] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_NC_UNQ_TblTriggerWatch_Action_Id]
        PRIMARY KEY NONCLUSTERED ([Action_Id] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
) ON [PRIMARY]
GO
-- 3. Triggers
-- a. Insert
CREATE OR ALTER TRIGGER [dbo].[trg_Insert_dbo_Person]
ON [DB_DEMO].[dbo].[person]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables
    DECLARE @Record_Id BIGINT;
    DECLARE @TableObjectId INT = OBJECT_ID('DB_DEMO.dbo.Person');
    DECLARE @Schema_Name SYSNAME = SCHEMA_NAME(OBJECTPROPERTY(@TableObjectId, 'SchemaId'));
	DECLARE @Table_Name SYSNAME = OBJECT_NAME(@TableObjectId);
    DECLARE @Trigger_Name SYSNAME = OBJECT_NAME(@@PROCID);
	DECLARE @Host_Name NVARCHAR(128) = HOST_NAME();
	DECLARE @App_Name NVARCHAR(128) = APP_NAME();
	

    -- Main record ID
    SELECT @Record_Id = Person_Id
    FROM INSERTED;

    -- Insert process
    INSERT INTO [dbo].[TblTriggerWatch]
    (
        Record_Id,
        Table_Schema,
        Table_Name,
        Trigger_Name,
		[Host_name],
		[App_name],
        DB,
        Action_Taken,
        Action_Time,
        [User_Name],
        spid,
        Server_Name
    )
    VALUES
    (@Record_Id,
     @Schema_Name,
     @Table_Name,
     @Trigger_Name,
	 @Host_Name,
	 @App_Name,
     DB_NAME(),
     'Insert',
     CAST(CURRENT_TIMESTAMP AS DATETIME),
     SUSER_SNAME(),
     @@SPID,
     @@SERVERNAME
    );
END
GO

-- b. UPDATE
CREATE OR ALTER TRIGGER [dbo].[trg_Update_dbo_Person]
ON [DB_DEMO].[dbo].[person]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables
    DECLARE @Record_Id BIGINT;
    DECLARE @TableObjectId INT = OBJECT_ID('DB_DEMO.dbo.Person');
    DECLARE @Schema_Name SYSNAME = SCHEMA_NAME(OBJECTPROPERTY(@TableObjectId, 'SchemaId'));
    DECLARE @Table_Name SYSNAME = OBJECT_NAME(@TableObjectId);
    DECLARE @Trigger_Name SYSNAME = OBJECT_NAME(@@PROCID);
	DECLARE @Host_Name NVARCHAR(128) = HOST_NAME();
	DECLARE @App_Name NVARCHAR(128) = APP_NAME();


    -- Main record ID
    SELECT @Record_Id = Person_Id
    FROM INSERTED;

    -- Insert process
    INSERT INTO [dbo].[TblTriggerWatch]
    (
        Record_Id,
        Table_Schema,
        Table_Name,
        Trigger_name,
		[Host_name],
		[App_name],
        DB,
        Action_Taken,
        Action_Time,
        [User_Name],
        spid,
        Server_Name
    )
    VALUES
    (@Record_Id,
     @Schema_Name,
     @Table_Name,
     @Trigger_Name,
	 @Host_Name,
	 @App_Name,
     DB_NAME(),
     'Update',
     CAST(CURRENT_TIMESTAMP AS DATETIME),
     SUSER_SNAME(),
     @@SPID,
     @@SERVERNAME
    );
END
GO

-- c. DELETE
CREATE OR ALTER TRIGGER [dbo].[trg_Delete_dbo_Person]
ON [DB_DEMO].[dbo].[person]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables
    DECLARE @Record_Id BIGINT;
    DECLARE @TableObjectId INT = OBJECT_ID('DB_DEMO.dbo.Person');
    DECLARE @Schema_Name SYSNAME = SCHEMA_NAME(OBJECTPROPERTY(@TableObjectId, 'SchemaId'));
	DECLARE @Table_Name SYSNAME = OBJECT_NAME(@TableObjectId);
    DECLARE @Trigger_Name SYSNAME = OBJECT_NAME(@@PROCID);
	DECLARE @Host_Name NVARCHAR(128) = HOST_NAME();
	DECLARE @App_Name NVARCHAR(128) = APP_NAME();
    

    -- Main record ID
    SELECT @Record_Id = Person_Id
    FROM DELETED;

    -- Insert process
    INSERT INTO [dbo].[TblTriggerWatch]
    (
        Record_Id,
        Table_Schema,
        Table_Name,
        Trigger_name,
		[Host_name],
		[App_name],
        DB,
        Action_Taken,
        Action_Time,
        [User_Name],
        spid,
        Server_Name
    )
    VALUES
    (@Record_Id,
     @Schema_Name,
     @Table_Name,
     @Trigger_Name,
	 @Host_Name,
	 @App_Name,
     DB_NAME(),
     'Delete',
     CAST(CURRENT_TIMESTAMP AS DATETIME),
     SUSER_SNAME(),
     @@SPID,
     @@SERVERNAME
    );
END

-- 4. List all triggers
SELECT OBJECT_NAME(parent_id) AS tablename, *
FROM [db_demo].sys.triggers

-- 5. Test the triggers
-- a. Select from tables
Select * From [DB_DEMO].[dbo].[Person];
Select * From [DB_DEMO].[dbo].[TblTriggerWatch];


-- b. Insert (DateOfBirth has wrong date)
INSERT INTO [DB_DEMO].[dbo].[Person]
(
    PersonName,
    DateOfBirth
)
Values
('Steven', '1982-06-02');

-- c. Update the DateOfBirth to a correct date
UPDATE [DB_DEMO].[dbo].[Person]
SET DateOfBirth = '1985-12-29'
Where Person_Id = 1;

-- d. Delete Person_Id 1
DELETE From [DB_DEMO].[dbo].[Person]
Where Person_Id = 1;