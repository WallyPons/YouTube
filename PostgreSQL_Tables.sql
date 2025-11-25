-- PostgreSQL version, database and schema
SELECT version(), current_database(), current_schema();

-- List all tables
SELECT * --tablename 
FROM pg_catalog.pg_tables
WHERE schemaname not in  ('pg_catalog', 'information_schema');

-- List temporary tables
SELECT
    table_catalog,
    table_schema,
    table_name,
    table_type
FROM
    information_schema.tables
WHERE
    table_schema LIKE 'pg_temp_%' AND table_type = 'LOCAL TEMPORARY';

/*
3 million inserts for each table
----------------------------------------------------------
1. ordinarytable  : ordinarydata  : 
2. unloggedtable  : unloggeddata  : 
3. temporarytable : temporarydata : 
*/



-- 1. Create ordinary table
-- drop table if exists ordinarytable;
create table ordinarytable (
row_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
ordinarydata TEXT);

-- 2. Runtime: 
DO $$
BEGIN
    FOR i IN 1..3000000 LOOP  -- 3 million inserts
        INSERT INTO ordinarytable (ordinarydata)
        VALUES ('3 million inserts');
    END LOOP;
END $$; 

-- 3. Count
select count(row_id) from ordinarytable;


-- 4. Create unlogged tabe
-- drop table if exists unloggedtable;
create unlogged table unloggedtable (
row_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
unloggeddata TEXT);


-- 5. Runtime: 
DO $$
BEGIN
    FOR i IN 1..3000000 LOOP -- 3 million inserts
        INSERT INTO unloggedtable (unloggeddata)
        VALUES ('3 million inserts');
    END LOOP;
END $$; 

-- 6. Count 
select count(row_id) from unloggedtable;

-- 7. Create temporary table
-- drop table temporarytable;
CREATE TEMPORARY TABLE temporarytable ( 
    row_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    temporarydata TEXT 
);

-- 8. Runtime: 
DO $$
BEGIN
    FOR i IN 1..3000000 LOOP -- 3 million inserts
        INSERT INTO temporarytable (temporarydata)
        VALUES ('3 million inserts');
    END LOOP;
END $$;

-- 9. Count
select count(row_id) from temporarytable;

