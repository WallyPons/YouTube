SELECT Property,
       Value
FROM
(
    SELECT CONVERT(NVARCHAR(128), SERVERPROPERTY('SERVERNAME')) AS [ServerName],
           LOCAL_NET_ADDRESS AS [IPAddressOfSQLServer],
           CLIENT_NET_ADDRESS AS [ClientIPAddress],
           CONVERT(NVARCHAR(128), SERVERPROPERTY('COMPUTERNAMEPHYSICALNETBIOS')) AS [NetBIOS],
           (
               SELECT create_date
               FROM sys.server_principals
               WHERE sid = 0x010100000000000512000000
           ) AS [SQL_Installation_Date],
           (
               SELECT VALUE_IN_USE
               FROM SYS.CONFIGURATIONS
               WHERE NAME = 'MAX DEGREE OF PARALLELISM'
           ) AS [MAXDOP],
           (
               SELECT VALUE_IN_USE
               FROM SYS.CONFIGURATIONS
               WHERE NAME = 'MAX SERVER MEMORY (MB)'
           ) AS [SQLMemory],
           CONVERT(NVARCHAR(128), SERVERPROPERTY('EDITION')) AS [Edition],
           CONVERT(NVARCHAR(128), SERVERPROPERTY('COLLATION')) AS [Collation],
           CONVERT(BIT, SERVERPROPERTY('ISCLUSTERED')) AS [IsClustered],
           CONVERT(BIT, SERVERPROPERTY('ISFULLTEXTINSTALLED')) AS [IsFullTextInstalled],
           CONVERT(BIT, SERVERPROPERTY('ISINTEGRATEDSECURITYONLY')) AS [IsIntegratedSecurityOnly],
           CONVERT(TINYINT, SERVERPROPERTY('FILESTREAMCONFIGUREDLEVEL')) AS [FileStreamConfiguredLevel],
           CONVERT(TINYINT, SERVERPROPERTY('FILESTREAMEFFECTIVELEVEL')) AS [FileStreamEffectiveLevel],
           CONVERT(NVARCHAR(128), SERVERPROPERTY('PRODUCTVERSION')) AS [ProductVersion],
           CONVERT(NVARCHAR(128), SERVERPROPERTY('SQLCHARSETNAME')) AS [SQLCharsetName],
           CONVERT(NVARCHAR(128), SERVERPROPERTY('SQLSORTORDERNAME')) AS [SQLSortOrderName]
    FROM SYS.DM_EXEC_CONNECTIONS
    WHERE SESSION_ID = @@SPID
) AS src
    CROSS APPLY
(
    VALUES
        ('ServerName', CONVERT(NVARCHAR(4000), [ServerName])),
        ('IPAddressOfSQLServer', CONVERT(NVARCHAR(4000), [IPAddressOfSQLServer])),
        ('ClientIPAddress', CONVERT(NVARCHAR(4000), [ClientIPAddress])),
        ('NetBIOS', CONVERT(NVARCHAR(4000), [NetBIOS])),
        ('SQL_Installation_Date', CONVERT(NVARCHAR(4000), [SQL_Installation_Date])),
        ('MAXDOP', CONVERT(NVARCHAR(4000), [MAXDOP])),
        ('SQLMemory', CONVERT(NVARCHAR(4000), [SQLMemory])),
        ('Edition', CONVERT(NVARCHAR(4000), [Edition])),
        ('Collation', CONVERT(NVARCHAR(4000), [Collation])),
        ('IsClustered', CONVERT(NVARCHAR(4000), [IsClustered])),
        ('IsFullTextInstalled', CONVERT(NVARCHAR(4000), [IsFullTextInstalled])),
        ('IsIntegratedSecurityOnly', CONVERT(NVARCHAR(4000), [IsIntegratedSecurityOnly])),
        ('FileStreamConfiguredLevel', CONVERT(NVARCHAR(4000), [FileStreamConfiguredLevel])),
        ('FileStreamEffectiveLevel', CONVERT(NVARCHAR(4000), [FileStreamEffectiveLevel])),
        ('ProductVersion', CONVERT(NVARCHAR(4000), [ProductVersion])),
        ('SQLCharsetName', CONVERT(NVARCHAR(4000), [SQLCharsetName])),
        ('SQLSortOrderName', CONVERT(NVARCHAR(4000), [SQLSortOrderName]))
) AS ca (Property, Value);
