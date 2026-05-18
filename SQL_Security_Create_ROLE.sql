/*
SQL Security: Create a SQL SERVER ROLE
WARNING: Server-level roles are server-wide in 
their permissions scope.
*/
USE [master];
GO
-- 1. Check for existing SERVER ROLES
SELECT name AS Server_Role_Name,
create_date, is_fixed_role
FROM sys.server_principals 
WHERE type_desc = 'SERVER_ROLE'
ORDER BY name;
GO
-- 2. Create the Server Role (if it does not exists)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals 
WHERE name = 'ConsultantAlterAnyLogin' 
AND type_desc = 'SERVER_ROLE')
	BEGIN
CREATE SERVER ROLE [ConsultantAlterAnyLogin];
PRINT 'Server Role created successfully.';
	END
	ELSE
PRINT 'Server Role already exists.';
GO
-- 3. Add Member (Consultant1) to the Role
ALTER SERVER ROLE [ConsultantAlterAnyLogin] 
ADD MEMBER [Consultant1]; -- LOGIN
GO
-- 4. Grant the permission to the Role
GRANT ALTER ANY LOGIN -- Can alter any login
TO [ConsultantAlterAnyLogin]; -- ROLE
GO
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/