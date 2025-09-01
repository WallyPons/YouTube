-- Drop the table for a fresh start
drop table if exists control;

-- Control table
create table control (
user_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
created_by bigint not null default 0,
user_email VARCHAR(50) not null default 'fakeuser1@email.com',
user_email_pass VARCHAR(50) not null,
user_is_admin boolean not null default false,
user_is_reporting boolean not null default false,
user_is_loggedin boolean not null default false,
user_last_login TIMESTAMP,
user_locked boolean not null default false
);


-- Index
create index idx_control_user_mail on control (user_email);

-- Initial user: Admin rights by default
insert into control 
(created_by, user_email, user_email_pass, user_is_admin, user_is_reporting)
values 
(1, 'GRANDMA@WHATEVERMAIL.com', 'C0mpl3xP@$$w0rd!#', true, true);

-- Select limit 1
select * from control limit 1;

-- Select with WHERE using lower case
select * from control where user_email = 'grandma@whatevermail.com' LIMIT 1;

-- Select with WHERE using correct value in format
select * from control where user_email = 'GRANDMA@WHATEVERMAIL.com' LIMIT 1;

-- Create citext extension, this works at the database level
CREATE EXTENSION IF NOT EXISTS citext;

-- Assign citext to the control table: email
ALTER TABLE control ALTER COLUMN user_email TYPE citext;

-- Select with WHERE using lower case again,it should return the values
select * from control where user_email = 'grandma@whatevermail.com' LIMIT 1;

-- Verify, this can be done before the process:
-- Table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'control' -- lowercase unless you quoted it
    AND table_schema = 'public';   -- adjust schema if needed

-- Although they were not affected, please do verify them    
-- Constraints
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(c.oid) AS definition
FROM 
    pg_constraint c
JOIN 
    pg_class t ON c.conrelid = t.oid
JOIN 
    pg_namespace n ON n.oid = t.relnamespace
WHERE 
    t.relname = 'control'
    AND n.nspname = 'public';  -- schema

-- Really important to check
-- Indexes
SELECT 
    indexname, indexdef
FROM 
    pg_indexes
WHERE 
    tablename = 'control'
    AND schemaname = 'public';


-- Cause...why not!
-- List all tables
SELECT * --tablename 
FROM pg_catalog.pg_tables
WHERE schemaname = 'public';