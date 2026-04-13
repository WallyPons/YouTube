/*
Configure email profile in SQL
*/
-- 1. Configure your SQL instance
USE [master];
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE;
-- 2. Create a Database Mail account
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'Accountname',
    @email_address = 'someone@example1.com',
    @display_name = 'SQL email account',
    @mailserver_name = ':https://fakeserver.com',
    @port = 587, -- Commonly used port
    @enable_ssl = 1, -- Recommended
    @username = 'someone@example1.com',
    @password = '░▒▓░▒▓─░▒▓░▒▓';
-- 3. Create a Database Mail profile
EXECUTE msdb.dbo.sysmail_add_profile_sp
    @profile_name = 'SomeFakeMailProfile';
-- 4. Add the account to the profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'SomeFakeMailProfile',
    @account_name = 'Accountname',
    @sequence_number = 1; -- Sort order
-- 5. Grant public access to the profile
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'SomeFakeMailProfile',
    @principal_name = 'public',
    @is_default = 1;
/*
 Don't forget to download a copy of this and other 
 scripts from my GitHub repo, please check the link and 
 name of the file on the video description. This and 
 other solutions are given "AS IS" under no  warranty 
 or claim.
*/