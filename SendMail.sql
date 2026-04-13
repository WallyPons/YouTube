/*
If you already have the database mail feature configured
in your SQL server instance, you can send an email by
using the T-SQL script below:
*/

-- 1. Send email from SSMS
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'SomeFakeMailProfile',
    @recipients = 'somerecipient@example1.com',
    @copy_recipients = 'copied@example1.com',
    @blind_copy_recipients = 'emailnotshown@example1.com',
    @body = 'here you type the text content of the email',
    @subject = 'Here you type the subject';

-- a. For variables @recipients, @copy_recipients and 
-- @blind_copy_recipients, use semicolon to include 
-- multiple destination emails.
-- b. @body can store up to 1,073,741,823 characters.
-- c. @subject is limited to 255 characters.

-- 2. If you're not sure about your database mail settings,
-- you can run the following stored procedures and inquiry
-- your SQL instance:

-- a. View global system settings
EXEC msdb.dbo.sysmail_help_configure_sp;
-- b. View all mail accounts (SMTP details)
EXEC msdb.dbo.sysmail_help_account_sp;
-- c. View all profiles
EXEC msdb.dbo.sysmail_help_profile_sp;
-- d. View account-to-profile mappings
EXEC msdb.dbo.sysmail_help_profileaccount_sp;


/*
 Don't forget to download a copy of this and other 
 scripts from my GitHub repo, please check the link and 
 name of the file on the video description. This and 
 other solutions are given "AS IS" under no  warranty 
 or claim.
*/