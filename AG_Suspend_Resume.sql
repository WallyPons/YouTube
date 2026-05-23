-- Always ON/Availability Groups scripts for the DBA

/*
1. Returns a row for each database that is participating 
in an Always On availability group for which the local 
instance of SQL Server is hosting an availability replica.
*/
SELECT 
    @@SERVERNAME AS ServerName,
    DB_NAME(drs.database_id) AS DatabaseName,
    drs.is_primary_replica,
    CASE WHEN drs.is_primary_replica = 1 
    THEN 'PRIMARY' ELSE 'SECONDARY' END AS ReplicaRole,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc,
    drs.database_state_desc
FROM sys.dm_hadr_database_replica_states drs
WHERE drs.is_local = 1
ORDER BY DatabaseName, ReplicaRole;

/*
2. Suspends data movement between an Availability 
Group primary replica and a specific secondary database.
*/
ALTER DATABASE [DB1] SET HADR SUSPEND;

/*
3. Resumes suspended data movement between a 
primary and a secondary database.
*/
ALTER DATABASE [DB1] SET HADR RESUME;

/*
Don't forget to download a copy of this and other 
scripts FROM my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/