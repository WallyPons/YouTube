/*
Extended Event Session: Capture all Deadlocks
*/
-- 1. Before executing, make sure "C:\XE" exists.
CREATE EVENT SESSION [Deadlocks]
ON SERVER ADD EVENT sqlserver.xml_deadlock_report
(ACTION
    (   package0.collect_cpu_cycle_time,
        package0.collect_system_time,
        sqlos.scheduler_address,
        sqlos.task_time,
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.context_info,
        sqlserver.database_name,
        sqlserver.nt_username,
        sqlserver.sql_text,
        sqlserver.username)
)ADD TARGET package0.event_file -- Event target pkg
(SET filename = N'C:\XE\Deadlocks.xel', -- Path\File
max_file_size = (1024), max_rollover_files = (3))
WITH
(   MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0KB, MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF, STARTUP_STATE = ON
) 
GO
-- 2. Start the Extended Event session:
ALTER EVENT SESSION [Deadlocks] 
ON SERVER STATE = START; -- Use STOP to halt the session
GO
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/