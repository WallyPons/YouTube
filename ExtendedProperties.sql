/*
How to add/update/delete extended properties for any
SQL database.
*/

-- 1. Add a Database Extended property
EXEC [DB_DEMO]. -- Database
[sys]. -- Schema
[sp_addextendedproperty] -- Catallog
@name = N'MS_Description', -- The name of the property
@value = N'DB_DEMO DB'; -- The value to be associated
GO

-- 2. Update a Database Extended property
EXEC [DB_DEMO]. -- Database
[sys]. -- Schema
[sp_updateextendedproperty] -- Catallog
@name = N'MS_Description', -- The name of the property
@value = N'DB_DEMO DB Updated'; -- The value to be associated
GO

-- 3. Drop a Database Extended property
EXEC [DB_DEMO]. -- Database
[sys]. -- Schema
[sp_dropextendedproperty] -- Catallog
@name = N'MS_Description' -- The name of the property
GO

-- 4. View extended properties for a database
SELECT * FROM [DB_DEMO].  -- Database name
[sys]. -- Schema
[extended_properties] -- Returns a row for each extended property
GO

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/
