/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see some
examples to release system resources:
*/

-- 1. Clears the entire plan cache, forcing all 
-- subsequent queries to recompile.
DBCC FREEPROCCACHE;

-- 2. Flushes the distributed query connection cache, 
-- clearing cached connections to linked servers and 
-- clearing associated memory on SQL Server
DBCC FREESESSIONCACHE WITH NO_INFOMSGS;

-- 3. Clears all entries from all system caches, 
-- including plan caches, security tokens, and memory 
-- clerks, reducing memory pressure.
DBCC FREESYSTEMCACHE ('ALL');

-- 4. Removes all clean (unmodified) data pages from 
-- the buffer pool (memory).
DBCC DROPCLEANBUFFERS;

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/