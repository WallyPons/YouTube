SELECT ROW_NUMBER() OVER (ORDER BY db_name()) AS Id,
       @@servername as ServerName,
       db_name() as DatabaseName,
       --Cast(CURRENT_TIMESTAMP AS [DATE]) as ProcessDate,
       --Cast(CURRENT_TIMESTAMP AS [TIME]) as ProcessTime,
	   Convert(varchar, getdate(), 9) as TimeStamp,
       fg.groupname as 'Filegroup',
       Name as 'Logical Name',
       filename as 'File Name',
       CONVERT(Decimal(18, 2), ROUND(Size / 128.000, 2)) AS [Curr. Alloc. Space (MB)],
       CONVERT(Decimal(18, 2), ROUND(FILEPROPERTY(Name, 'SpaceUsed') / 128.000, 2)) AS [Space Used (MB)],
       CONVERT(Decimal(18, 2), ROUND((Size - FILEPROPERTY(Name, 'SpaceUsed')) / 128.000, 2)) AS [Avail. Space (MB)],
       [Max Size(MB)] = Case
                            When CONVERT(Decimal(18, 2), ROUND((maxsize) / 128.000, 2)) != -0.01 Then
                                CONVERT(Decimal(18, 2), ROUND((maxsize) / 128.000, 2))
                            Else
                                -1
                        End,
       Growth as [AutoG Perc.],
       (CONVERT(Decimal(18, 2), ROUND(FILEPROPERTY(Name, 'SpaceUsed') / 128.000, 2))
        / CONVERT(Decimal(18, 2), ROUND(Size / 128.000, 2)) * 100
       ) as [Perc. Used],
       (CONVERT(Decimal(18, 2), ROUND((Size - FILEPROPERTY(Name, 'SpaceUsed')) / 128.000, 2))
        / CONVERT(Decimal(18, 2), ROUND(Size / 128.000, 2)) * 100
       ) as [Perc. Avail.]

FROM 
    dbo.sysfiles AS sf
LEFT JOIN 
    dbo.sysfilegroups AS fg 
    ON sf.groupid = fg.groupid;

-- Filestreams only
SELECT ROW_NUMBER() OVER (ORDER BY db_name()) AS Id,
       @@servername as ServerName,
       db_name() as DatabaseName,
       Convert(varchar, getdate(), 9) as TimeStamp,

	name as [Device Name],
	physical_name as [Physical Name],
	CONVERT (Decimal(15,2) ,ROUND(size/1024.000,2))*8 as [Current Size (MB)] ,
	CONVERT (Decimal(15,2) ,ROUND(max_size/1024.000,2))*8 as [Max Size (MB)] 
	

From sys.database_files
Where type = 2;
