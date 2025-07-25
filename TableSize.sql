-- Table and index size
;with cte
as (SELECT SCHEMA_NAME(t.schema_id) as SchemaName,
           t.name as TableName,
           SUM(s.used_page_count) as used_pages_count,
           SUM(   CASE
                      WHEN (i.index_id < 2) THEN
                  (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
                      ELSE
                          lob_used_page_count + row_overflow_used_page_count
                  END
              ) as pages
    FROM sys.dm_db_partition_stats AS s
        JOIN sys.tables AS t
            ON s.object_id = t.object_id
        JOIN sys.indexes AS i
            ON i.[object_id] = t.[object_id]
               AND s.index_id = i.index_id
    GROUP BY t.schema_id,
             t.name
   )
Select cte.SchemaName,
       cte.TableName,
       cast((cte.pages * 8.) / 1024 as decimal(10, 3)) as TableSizeInMB,
       cast(((CASE
                  WHEN cte.used_pages_count > cte.pages THEN
                      cte.used_pages_count - cte.pages
                  ELSE
                      0
              END
             ) * 8. / 1024
            ) as decimal(10, 3)) as PKSizeInMB --IndexSizeInMB
From cte
Order by 3 desc
GO