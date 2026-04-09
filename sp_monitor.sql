-- Displays statistics about SQL Server.
USE [master];
GO
EXECUTE sp_monitor;
GO
/*
Column name			Description
---------------------------------------------------------------------
last_run			Time sp_monitor was last run.
current_run			Time sp_monitor is being run.
seconds				Number of elapsed seconds since 
					sp_monitor was run.
cpu_busy			Number of seconds that the server 
					computer's CPU has done SQL Server work.
io_busy				Number of seconds that SQL Server spent 
					doing input and output operations.
idle				Number of seconds that SQL Server was idle.
packets_received	Number of input packets read by SQL Server.
packets_sent		Number of output packets written by SQL Server.
packet_errors		Number of errors encountered by SQL Server while 
					reading and writing packets.
total_read			Number of reads by SQL Server.
total_write			Number of writes by SQL Server.
total_errors		Number of errors encountered by SQL Server while 
					reading and writing.
connections			Number of logins or attempted logins to SQL Server.
*/

/*
Don't forget to download a copy of this and other 
scripts from my Github repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/