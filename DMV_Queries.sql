-- 1. DMV Category: Security & Permissions

-- a. What It Audits / Tracks: All logins on the server (SQL, Windows, groups, certificates)
-- b. Typical Use Case: Baseline security review; compare current vs. previous logins
Select * From sys.server_principals

-- a. What It Audits / Tracks: SQL logins with hashes, policy, expiration, etc.
-- b. Typical Use Case: Password policies, disabled accounts, and login audit exports
Select * From sys.sql_logins

-- a. What It Audits / Tracks: Database-level users, roles, and schemas
-- b. Typical Use Case: Identify who has access at the database level
Select * From sys.database_principals

-- a. What It Audits / Tracks: Memberships in database roles
-- b. Typical Use Case: Detect unauthorized role membership changes
Select * From sys.database_role_members

-- a. What It Audits / Tracks: Memberships in server roles
-- b. Typical Use Case: Detect server-level role escalations
Select * From sys.server_role_members

-- a. What It Audits / Tracks: Explicit GRANT/DENY/REVOKE at the server level
-- b. Typical Use Case: Track who has CONTROL SERVER or ALTER ANY LOGIN
Select * From sys.server_permissions

-- a. What It Audits / Tracks: Explicit GRANT/DENY/REVOKE at the database level
-- b. Typical Use Case: Track excessive or changed database permissions
Select * From sys.database_permissions

-- a. What It Audits / Tracks: Current connected sessions
-- b. Typical Use Case: Detect suspicious logins or orphaned sessions
Select * From sys.dm_exec_sessions --where host_name != 'null'

-- a. What It Audits / Tracks: Active connections with client info
-- b. Typical Use Case: Identify IPs, apps, and protocols used
Select * From sys.dm_exec_connections

-- a. What It Audits / Tracks: Current running queries
-- b. Typical Use Case: Detect long-running or unauthorized actions
Select * From sys.dm_exec_requests

-- a. What It Audits / Tracks: Aggregated query execution statistics
-- b. Typical Use Case: Identify changes in workload or unusual queries
Select * From sys.dm_exec_query_stats

-- a. What It Audits / Tracks: Object creation and modification timestamps
-- b. Typical Use Case: Track newly created or altered objects
Select * From sys.objects

-- a. What It Audits / Tracks: Active transactions
-- b. Typical Use Case: Find open or long-running transactions after DDLs
Select * From sys.dm_tran_active_transactions

-- a. What It Audits / Tracks: Database-level transaction info
-- b. Typical Use Case: Check who/what modified data recently
Select * From sys.dm_tran_database_transactions

-- a. What It Audits / Tracks: List of all possible audit actions
-- b. Typical Use Case: Map which actions are supported by the audit engine
Select * From sys.dm_audit_actions

-- a. What It Audits / Tracks: All server-level configuration settings
-- b. Typical Use Case: Detect when options like xp_cmdshell or CLR are toggled
Select * From sys.configurations

-- a. What It Audits / Tracks: DLLs loaded by SQL Server
-- b. Typical Use Case: Check for unauthorized DLLs or components
Select * From sys.dm_os_loaded_modules

-- a. What It Audits / Tracks: Internal event buffers (login failures, errors)
-- b. Typical Use Case: Retrieve security or memory errors historically
Select * From sys.dm_os_ring_buffers

-- a. What It Audits / Tracks: Active audits and their states
-- b. Typical Use Case: Confirm that auditing is running properly
Select * From sys.dm_server_audit_status

-- List all users and their database permissions

SELECT 
    dp.name AS UserName,
    dp.type_desc AS UserType,
    dp.authentication_type_desc,
    pe.class_desc,
    pe.permission_name,
    pe.state_desc AS PermissionState,
    OBJECT_NAME(pe.major_id) AS ObjectName
FROM sys.database_principals AS dp
LEFT JOIN sys.database_permissions AS pe 
    ON dp.principal_id = pe.grantee_principal_id
WHERE dp.name NOT IN ('guest','dbo','INFORMATION_SCHEMA','sys')
ORDER BY dp.name;
