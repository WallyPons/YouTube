-- Create database folders
/*
MD F:\MSSQL\StackOverflow2010\PRIMARY
MD G:\MSSQL\StackOverflow2010\TRANSLOG
MD F:\MSSQL\StackOverflow2010\TBL
MD F:\MSSQL\StackOverflow2010\LOB
MD F:\MSSQL\StackOverflow2010\IDX
*/

/*
USE [master]
GO

DROP DATABASE IF EXISTS [StackOverflow2010]
GO 
*/


USE [master]
GO

CREATE DATABASE [StackOverflow2010]
 CONTAINMENT = NONE
 ON PRIMARY 
(NAME = N'[PRIMARY]_[StackOverflow2010]', FILENAME = N'F:\MSSQL\StackOverflow2010\PRIMARY\[PRIMARY]_[StackOverflow2010].mdf' , SIZE = 512MB , FILEGROWTH = 0 )
 LOG ON 
(NAME = N'[TRANSLOG]_[StackOverflow2010]', FILENAME = N'G:\MSSQL\StackOverflow2010\TRANSLOG\[TRANSLOG]_[StackOverflow2010].ldf' , SIZE = 512MB , FILEGROWTH = 64MB)
COLLATE SQL_Latin1_General_CP1_CI_AS
GO
ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 160 -- SQL Server 2022
ALTER DATABASE [StackOverflow2010] SET ANSI_NULL_DEFAULT OFF 
ALTER DATABASE [StackOverflow2010] SET ANSI_NULLS OFF 
ALTER DATABASE [StackOverflow2010] SET ANSI_PADDING OFF 
ALTER DATABASE [StackOverflow2010] SET ANSI_WARNINGS OFF 
ALTER DATABASE [StackOverflow2010] SET ARITHABORT OFF 
ALTER DATABASE [StackOverflow2010] SET AUTO_CLOSE OFF 
ALTER DATABASE [StackOverflow2010] SET AUTO_SHRINK OFF 
ALTER DATABASE [StackOverflow2010] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
ALTER DATABASE [StackOverflow2010] SET AUTO_UPDATE_STATISTICS ON 
ALTER DATABASE [StackOverflow2010] SET CURSOR_CLOSE_ON_COMMIT OFF 
ALTER DATABASE [StackOverflow2010] SET CURSOR_DEFAULT GLOBAL 
ALTER DATABASE [StackOverflow2010] SET CONCAT_NULL_YIELDS_NULL OFF 
ALTER DATABASE [StackOverflow2010] SET NUMERIC_ROUNDABORT OFF 
ALTER DATABASE [StackOverflow2010] SET QUOTED_IDENTIFIER OFF 
ALTER DATABASE [StackOverflow2010] SET RECURSIVE_TRIGGERS OFF 
ALTER DATABASE [StackOverflow2010] SET DISABLE_BROKER 
ALTER DATABASE [StackOverflow2010] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
ALTER DATABASE [StackOverflow2010] SET DATE_CORRELATION_OPTIMIZATION OFF 
ALTER DATABASE [StackOverflow2010] SET PARAMETERIZATION SIMPLE 
ALTER DATABASE [StackOverflow2010] SET READ_COMMITTED_SNAPSHOT ON -- When it is turned to ON, row versioning is used instead of locking
ALTER DATABASE [StackOverflow2010] SET READ_WRITE 
ALTER DATABASE [StackOverflow2010] SET RECOVERY SIMPLE -- Chage to Full when migration is completed (see lines 67 ~ 70)
ALTER DATABASE [StackOverflow2010] SET MULTI_USER 
ALTER DATABASE [StackOverflow2010] SET PAGE_VERIFY CHECKSUM 
ALTER DATABASE [StackOverflow2010] SET TARGET_RECOVERY_TIME = 60 SECONDS -- Recommended value
GO

ALTER DATABASE [StackOverflow2010] SET DELAYED_DURABILITY = DISABLED 
GO
USE [StackOverflow2010]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [StackOverflow2010] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO

/* -- Run after data migration
USE [master]
GO
ALTER DATABASE [StackOverflow2010] SET RECOVERY FULL WITH NO_WAIT
GO
*/

USE [master]
-- FileGroups
-- Tables (3,729,195 records)
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_TBL_dbo_ROW_Posts]    -- Used for ROW compression
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_TBL_dbo_PAGE_Posts]   -- Used for PAGE compression (no indexes here, only PK)
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_TBL_dbo_Size]         -- Used to store size informations
-- IDX
-- ROW
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_ROW_Posts_LastEditorDisplayName]
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_ROW_Posts_Tags]
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_ROW_Posts_Title]
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_ROW_Posts_AnswerCount]
-- PAGE
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_PAGE_Posts_LastEditorDisplayName]
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_PAGE_Posts_Tags]
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_PAGE_Posts_Title]
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_IDX_dbo_PAGE_Posts_AnswerCount]
-- LOBs
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_LOB_dbo_ROW_Posts]
ALTER DATABASE [StackOverflow2010] ADD FILEGROUP [FG_LOB_dbo_PAGE_Posts]

-- Files
-- Tables
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[TBL]_[dbo_ROW_Posts]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\TBL\[TBL]_[dbo_ROW_Posts]_[1].ndf', SIZE = 2048MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_TBL_dbo_ROW_Posts]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[TBL]_[dbo_PAGE_Posts]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\TBL\[TBL]_[dbo_PAGE_Posts]_[1].ndf', SIZE = 2048MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_TBL_dbo_PAGE_Posts]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[TBL]_[dbo_Size]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\TBL\[TBL]_[dbo_Size]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_TBL_dbo_Size]
-- IDX
-- ROW
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_ROW_Posts_LastEditorDisplayName]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_ROW_Posts_LastEditorDisplayName]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_ROW_Posts_LastEditorDisplayName]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_ROW_Posts_Tags]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_ROW_Posts_Tags]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_ROW_Posts_Tags]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_ROW_Posts_Title]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_ROW_Posts_Title]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_ROW_Posts_Title]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_ROW_Posts_AnswerCount]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_ROW_Posts_AnswerCount]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_ROW_Posts_AnswerCount]
-- PAGE
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_PAGE_Posts_LastEditorDisplayName]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_PAGE_Posts_LastEditorDisplayName]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_PAGE_Posts_LastEditorDisplayName]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_PAGE_Posts_Tags]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_PAGE_Posts_Tags]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_PAGE_Posts_Tags]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_PAGE_Posts_Title]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_PAGE_Posts_Title]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_PAGE_Posts_Title]
ALTER DATABASE [StackOverflow2010] ADD FILE ( NAME = N'[IDX]_[dbo_PAGE_Posts_AnswerCount]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\IDX\[IDX]_[dbo_PAGE_Posts_AnswerCount]_[1].ndf', SIZE = 1MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_IDX_dbo_PAGE_Posts_AnswerCount]
-- Lobs
ALTER DATABASE [StackOverflow2010] ADD FILE (NAME = N'[LOB]_[dbo_ROW_Posts]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\LOB\[LOB]_[dbo_ROW_Posts]_[1].ndf', SIZE = 550MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_LOB_dbo_ROW_Posts]
ALTER DATABASE [StackOverflow2010] ADD FILE (NAME = N'[LOB]_[dbo_PAGE_Posts]_[1]', FILENAME = N'F:\MSSQL\StackOverflow2010\LOB\[LOB]_[dbo_PAGE_Posts]_[1].ndf', SIZE = 550MB , MAXSIZE = UNLIMITED ,FILEGROWTH = 10% ) TO FILEGROUP [FG_LOB_dbo_PAGE_Posts]


USE [StackOverflow2010]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ROW_Posts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AcceptedAnswerId] [int] NULL,
	[AnswerCount] [int] NULL,
	[Body] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ClosedDate] [datetime] NULL,
	[CommentCount] [int] NULL,
	[CommunityOwnedDate] [datetime] NULL,
	[CreationDate] [datetime] NOT NULL,
	[FavoriteCount] [int] NULL,
	[LastActivityDate] [datetime] NOT NULL,
	[LastEditDate] [datetime] NULL,
	[LastEditorDisplayName] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastEditorUserId] [int] NULL,
	[OwnerUserId] [int] NULL,
	[ParentId] [int] NULL,
	[PostTypeId] [int] NOT NULL,
	[Score] [int] NOT NULL,
	[Tags] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Title] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ViewCount] [int] NOT NULL,
 CONSTRAINT [PK_ROW_Posts_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_TBL_dbo_ROW_Posts]
) ON [FG_TBL_dbo_ROW_Posts] TEXTIMAGE_ON [FG_LOB_dbo_ROW_Posts]
GO

-- Page
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PAGE_Posts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AcceptedAnswerId] [int] NULL,
	[AnswerCount] [int] NULL,
	[Body] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ClosedDate] [datetime] NULL,
	[CommentCount] [int] NULL,
	[CommunityOwnedDate] [datetime] NULL,
	[CreationDate] [datetime] NOT NULL,
	[FavoriteCount] [int] NULL,
	[LastActivityDate] [datetime] NOT NULL,
	[LastEditDate] [datetime] NULL,
	[LastEditorDisplayName] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastEditorUserId] [int] NULL,
	[OwnerUserId] [int] NULL,
	[ParentId] [int] NULL,
	[PostTypeId] [int] NOT NULL,
	[Score] [int] NOT NULL,
	[Tags] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Title] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ViewCount] [int] NOT NULL,
 CONSTRAINT [PK_PAGE_Posts_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_TBL_dbo_PAGE_Posts]
) ON [FG_TBL_dbo_PAGE_Posts] TEXTIMAGE_ON [FG_LOB_dbo_PAGE_Posts]
GO


-- Size

USE [StackOverflow2010]
GO

CREATE TABLE [dbo].[Size](
	[Id] [bigint] NULL,
	[ServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabaseName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TimeStamp] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Logical Name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[File Name] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Curr. Alloc. Space (MB)] [decimal](18, 2) NULL,
	[Space Used (MB)] [decimal](18, 2) NULL,
	[Avail. Space (MB)] [decimal](18, 2) NULL,
	[Max Size(MB)] [decimal](18, 2) NULL,
	[AutoG Perc.] [int] NOT NULL,
	[Perc. Used] [decimal](38, 16) NULL,
	[Perc. Avail.] [decimal](38, 16) NULL
) ON [FG_TBL_dbo_Size]
GO




-- Idx
-- ROW
USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_ROW_Posts_LastEditorDisplayName] ON [dbo].[ROW_Posts]
(
	[LastEditorDisplayName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_ROW_Posts_LastEditorDisplayName]
GO


USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_ROW_Posts_Tags] ON [dbo].[ROW_Posts]
(
	[Tags] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_ROW_Posts_Tags]
GO

USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_ROW_Posts_Title] ON [dbo].[ROW_Posts]
(
	[Title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_ROW_Posts_Title]
GO

USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_ROW_Posts_AnswerCount] ON [dbo].[ROW_Posts]
(
	[AnswerCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_ROW_Posts_AnswerCount]
GO

-- Page
USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_PAGE_Posts_LastEditorDisplayName] ON [dbo].[PAGE_Posts]
(
	[LastEditorDisplayName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_PAGE_Posts_LastEditorDisplayName]
GO


USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_PAGE_Posts_Tags] ON [dbo].[PAGE_Posts]
(
	[Tags] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_PAGE_Posts_Tags]
GO

USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_PAGE_Posts_Title] ON [dbo].[PAGE_Posts]
(
	[Title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_PAGE_Posts_Title]
GO

USE [StackOverflow2010]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_dbo_PAGE_Posts_AnswerCount] ON [dbo].[PAGE_Posts]
(
	[AnswerCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_IDX_dbo_PAGE_Posts_AnswerCount]
GO

-- Function
CREATE OR ALTER FUNCTION dbo.fn_CompressionSavings
(
    @OriginalSize DECIMAL(18, 2),
    @CompressedSize DECIMAL(18, 2)
)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @Savings DECIMAL(12, 2);

    IF @OriginalSize = 0 OR @OriginalSize IS NULL OR @CompressedSize IS NULL
        RETURN NULL;

    SET @Savings = ABS((@CompressedSize - @OriginalSize) / @OriginalSize * 100);

    RETURN CONVERT(VARCHAR(10), @Savings) + '%';
END;
GO