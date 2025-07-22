/*
-------------------------------------------------------
Calculate age by years, months and days using MS SQL Server
-------------------------------------------------------
This tutorial has been created by Wally Pons - April 2025
SQL Server DBA with over 25 years of experience in the field
-------------------------------------------------------
IT Engineer, Writer, Instructor, Consultant and founding
partner for Datagrupo, PBSoft.
-------------------------------------------------------
For a quick contact:
Web: https://datagrupo.com
Email: wpons@datagrupo.com
-------------------------------------------------------
*/

Declare @DOB datetime,
		@TotalDays int,
		@Year int,      
		@RemainingDay int,
		@Month int,
		@Day int		  

Set @DOB = '1990-04-21'  -- YYYY-MM-DD <-- Main variable

Set @TotalDays = DATEDIFF(DAY, @DOB, GETDATE())
Set @Year = @TotalDays / 365.25
Set @RemainingDay = @TotalDays % 365.25 -- Returns the remainder of one number divided by another.
Set @Month = @RemainingDay / 30.4375
Set @Day = @RemainingDay % 30.4375 -- Returns the remainder of one number divided by another.

PRINT 'You are: ' 
		+ CAST(@Year as varchar(3)) 
		+ ' Years, ' 
		+ CAST(@Month as varchar(2)) 
		+ ' Month(s) and '
		+ CAST(@Day as varchar(2)) 
		+ ' Days old' 