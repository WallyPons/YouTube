-- Tune PostgreSQL for efficient Bulk Load imports

-- 1. Temporary adjustment, they only last 
-- for the current session
SET maintenance_work_mem = '1GB'; -- Default is 64MB
-- Controls memory available to maintenance operations

SET synchronous_commit = OFF; -- Default is ON
-- Controls whether COMMIT waits for the WAL (transaction log)
-- to be physically flushed to disk before telling you it 
-- succeeded.

SET work_mem = '256MB';  -- Default is 64MB
-- Controls the memory each operation node in a query can use 
-- before spilling to disk.

SELECT pg_reload_conf();
-- Apply the changes live, no need to restart the server

SHOW work_mem;
-- verify changes

-- 2. For large imports, also consider increasing:
ALTER SYSTEM SET wal_buffers = '64MB'; -- Default is -1 (auto)
-- Shared memory used to hold WAL records before they are 
-- written to disk.

ALTER SYSTEM SET checkpoint_timeout = '15min'; -- Default is 5min
-- The maximum time between automatic checkpoints.

ALTER SYSTEM SET max_wal_size = '8GB'; -- Default is 1GB
-- A soft limit on how much WAL can accumulate between 
-- checkpoints.

/*
Don't forget to download a copy of this and other 
scripts FROM my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/
