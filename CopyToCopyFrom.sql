/*
COPY moves data between PostgreSQL tables and standard 
file-system files. COPY TO copies the contents of a table 
to a file, while COPY FROM copies data from a file to a 
table (appending the data to whatever is in the table already). 

COPY TO can also copy the results of a SELECT query.
*/

-- 1. Create a sample table
-- DROP TABLE IF EXISTS public.SamplePeople;
CREATE TABLE public.SamplePeople
(Id integer, Name TEXT, LastName TEXT, DOB date);

-- 2. Import from a CSV file with same structure
COPY public.SamplePeople -- Schema and table name
FROM 'C:/Temp/SamplePeople.csv' -- Please note the "/"
WITH (FORMAT csv, HEADER false, DELIMITER ',',
NULL '', ENCODING 'UTF8')
WHERE DOB IS NOT NULL; -- Optional WHERE condition

-- 3. View data
Select * From public.SamplePeople;

-- 4. Export table to CSV (Excluding Id = 1)
COPY(Select Id, Name, Lastname FROM -- List of columns
public.SamplePeople WHERE Id != 1 -- Optional WHERE
ORDER BY Name DESC) -- You can change the export order
TO 'C:/Temp/SamplePeople2.csv' -- File to export to
WITH (FORMAT csv, HEADER true); -- CSV Will include headers

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, including the CSV used 
in this short video, please check the link and name of 
the files on the video description. This and other 
solutions are given "AS IS" under no warranty or claim.
*/
