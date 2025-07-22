-- 1. Table to store execution auditing
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [DB_DEMO].[dbo].[AuditProcs](
	[Audit_Id] [int] IDENTITY(1,1) NOT NULL,
	[proc_obj_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_name] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[spid] [int] NULL,
	[serv_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_date] [datetime2](7) NULL,
CONSTRAINT [PK_NC_UNQ_Audit_Id_AuditProcs] PRIMARY KEY CLUSTERED 
(
	[Audit_Id] ASC
)

WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
	  ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF ) ON [PRIMARY]

) ON [PRIMARY]
GO

-- 2. Create a simple stored procedure
CREATE OR ALTER PROCEDURE usp_SampleProcMemInfo
AS
BEGIN
    SET NOCOUNT ON

    -- a. Stored Proc code:
    -- b. Begin transacion
	BEGIN TRAN
	-- c. Actual code (Requires VIEW SERVER STATE permission on the server)
    SELECT total_physical_memory_kb / 1024 AS [Physical Memory (MB)],
           available_physical_memory_kb / 1024 AS [Available Memory (MB)],
           total_page_file_kb / 1024 AS [Total Page File (MB)],
           available_page_file_kb / 1024 AS [Available Page File (MB)],
           system_cache_kb / 1024 AS [System Cache (MB)],
           system_memory_state_desc AS [System Memory State]
    FROM sys.dm_os_sys_memory WITH (NOLOCK)
    OPTION (RECOMPILE); -- This option re-evaluates the optimal execution plan
    -- d. Commit transaction
	COMMIT

    -- e. Insert values into a table:
    BEGIN TRAN
    INSERT INTO [DB_DEMO].[dbo].[AuditProcs] (proc_obj_id, proc_name, spid, serv_name, proc_user, proc_date)
    VALUES
    (@@PROCID, OBJECT_NAME(@@PROCID), @@SPID, @@SERVERNAME, suser_sname(), GETDATE())
    COMMIT

END;

-- 3. Execute Stored Procedure
Exec [DB_DEMO].[dbo].[usp_SampleProcMemInfo];

-- 4. Select values from the table
Select Top 50 * From [DB_DEMO].[dbo].[AuditProcs];
