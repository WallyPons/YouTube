/*
Calculate distance between two coordinates 
(latitude and longitude) using ACOS(), SIN() 
and RAD() functions.
*/

-- 1. Declare variables and assign values
DECLARE @Lat1 FLOAT = 41.9028;  -- Rome, Italy
DECLARE @Lon1 FLOAT = 12.4964;
DECLARE @Lat2 FLOAT = 44.94;    -- Bologna, Italy
DECLARE @Lon2 FLOAT = 11.33;

-- 2. Drop/Create temp table
DROP TABLE IF EXISTS #Distances;
CREATE TABLE #Distances(Distance_KM FLOAT);

-- 3. Insert values to temp table
INSERT INTO #Distances
SELECT 6371 * ACOS(SIN(RADIANS(@Lat1)) * 
SIN(RADIANS(@Lat2)) + COS(RADIANS(@Lat1)) 
* COS(RADIANS(@Lat2)) * COS(RADIANS
(@Lon2 - @Lon1))); 

-- 4. Run a SELECT using the FORMAT function
SELECT FORMAT(Distance_KM, 'N2') AS Distance_KM, 
(SELECT FORMAT(Distance_KM  / 1.609, 'N2')) 
AS Distance_MI FROM #Distances;
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/