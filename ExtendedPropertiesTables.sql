/*
Add/update/delete extended properties for any SQL table.
*/
-- 1. Add description for a table
EXEC [DB_DEMO]. -- Database
[sys].  -- Schema
[sp_addextendedproperty]  -- Catallog
@name = N'MS_Description', -- The name of the property
@value = N'Badges Table',  -- The value
@level0type = N'SCHEMA',   -- The type (SCHEMA, Trigger, etc)
@level0name = N'dbo',  -- The name of the level 0 object type
@level1type = N'TABLE',  -- The type of level 1 object
@level1name = N'Badges';  -- The name of the level 1 object
GO

-- 2. Update Description for a table
EXEC [DB_DEMO]. -- Database
[sys].  -- Schema
[sp_updateextendedproperty]  -- Catallog
@name = N'MS_Description', -- The name of the property
@value = N'Badges Table',  -- The value
@level0type = N'SCHEMA',   -- The type (SCHEMA, Trigger, etc)
@level0name = N'dbo',  -- The name of the level 0 object type
@level1type = N'TABLE',  -- The type of level 1 object
@level1name = N'Badges';  -- The name of the level 1 object
GO

-- 3. Drop description for a table
EXEC [DB_DEMO]. -- Database
[sys].  -- Schema
[sp_dropextendedproperty]  -- Catallog
@name = N'MS_Description', -- The name of the property
@level0type = N'SCHEMA',   -- The type (SCHEMA, Trigger, etc)
@level0name = N'dbo',  -- The name of the level 0 object type
@level1type = N'TABLE',  -- The type of level 1 object
@level1name = N'Badges';  -- The name of the level 1 object
GO

-- 4. View extended properties for a database and objects
SELECT * FROM [DB_DEMO].[sys].[extended_properties]
GO
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/