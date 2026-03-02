/*

usage: bcp {dbtable | query} {in | out | queryout | format} datafile
  [-m maxerrors]            [-f formatfile]          [-e errfile]
  [-F firstrow]             [-L lastrow]             [-b batchsize]
  [-n native type]          [-c character type]      [-w wide character type]
  [-N keep non-text native] [-V file format version] [-q quoted identifier]
  [-C code page specifier]  [-t field terminator]    [-r row terminator]
  [-i inputfile]            [-o outfile]             [-a packetsize]
  [-S server name]          [-U username]            [-P password]
  [-T trusted connection]   [-v version]             [-R regional enable]
  [-k keep null values]     [-E keep identity values][-G Azure Active Directory Authentication]
  [-h "load hints"]         [-x generate xml format file]
  [-d database name]        [-K application intent]  [-l login timeout]

Options:
----------------------------------
1. bcp: Invokes BCP
2. [database].[schema].[table]: FQON
3. out: Option to export to a file
4. Path and file name
5. -c character type
6. -t field terminator ","(delimiter)
7. -T trusted connection
8. -S server name

Script:
----------------------------------
With trusted connection:
bcp "[CorporateData_East1].[dbo].[SamplePeople]" out "Z:\ExportCSV\Export2.csv" -c -t"," -T -S "."

With Credentials:
bcp "[CorporateData_East1].[dbo].[SamplePeople]" out "Z:\ExportCSV\Export3.csv" -c -t"," -U DBA1 -P @!r97#Zo -S "CORPORATEDATA"

*/


/*
Export to CSV from SQL Server using BCP
Source: [CorporateData_East1].[dbo].[SamplePeople];
*/

-- 1. Use a combination of BCP + xp_cmdshell
-- a. Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO

-- b. Execute CMD
--EXECUTE xp_cmdshell 'bcp "[CorporateData_East1].[dbo].[SamplePeople]" out "Z:\ExportCSV\Export4.csv" -c -t"," -T -S "."';
--EXECUTE xp_cmdshell 'bcp "Select * From [CorporateData_East1].[dbo].[SamplePeople] Where Job_Title = ''Software Consultant''" queryout "Z:\ExportCSV\Export5.csv" -c -t"," -T -S "."';

GO

-- c. Disable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO