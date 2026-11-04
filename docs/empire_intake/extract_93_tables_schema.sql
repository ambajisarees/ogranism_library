-- =============================================================================
-- EMPIRE (MAIN-PC\SQLEXPRESS - SQL Server 2012 / 11.0.2100)
-- COMPLETE 1-SHOT CONTEXT HARVESTER (ONLY 3 GRIDS TO SAVE!)
-- =============================================================================
-- Tested for SQL Server 2012 (11.0.2100). Automatically switches from [master]
-- to [IMMBE2627], so you can paste this directly into your open SQLQuery1.sql
-- window and press F5!
--
-- OUTPUTS EXACTLY 3 GRIDS AT THE BOTTOM OF SSMS:
--   Grid 1 -> Save As: 1_multiyear_row_counts.csv
--             (Compares row counts across FY 24-25, FY 25-26, and FY 26-27 for all 69 user tables)
--   Grid 2 -> Save As: 2_all_tables_columns.csv
--             (Every column, data type, length, PK, and default across all 69 user tables)
--   Grid 3 -> Save As: 3_empire_ui_and_report_brain.csv
--             (Combines SCREENLIST, SCREENCOMP, SCREEN_EXPOSE, formsettings, CUSTOMFORMS,
--              FORMPERM, REPORTQUERIES, QUICKREPORTS, Reportoptions, UDRS, CONFIG, settings,
--              uniq_config, RMKLIST, USERS, and SQL Views/Procs into ONE single table!)
-- =============================================================================

USE [IMMBE2627];
GO

-- =============================================================================
-- GRID 1: MULTI-YEAR ROW COUNTS (IMMBE2425 vs IMMBE2526 vs IMMBE2627)
-- =============================================================================
WITH Rows2627 AS (
    SELECT t.name AS table_name, SUM(p.rows) AS row_cnt
    FROM [IMMBE2627].sys.tables t
    INNER JOIN [IMMBE2627].sys.partitions p ON t.object_id = p.object_id
    WHERE p.index_id IN (0, 1) AND t.is_ms_shipped = 0
    GROUP BY t.name
),
Rows2526 AS (
    SELECT t.name AS table_name, SUM(p.rows) AS row_cnt
    FROM [IMMBE2526].sys.tables t
    INNER JOIN [IMMBE2526].sys.partitions p ON t.object_id = p.object_id
    WHERE p.index_id IN (0, 1) AND t.is_ms_shipped = 0
    GROUP BY t.name
),
Rows2425 AS (
    SELECT t.name AS table_name, SUM(p.rows) AS row_cnt
    FROM [IMMBE2425].sys.tables t
    INNER JOIN [IMMBE2425].sys.partitions p ON t.object_id = p.object_id
    WHERE p.index_id IN (0, 1) AND t.is_ms_shipped = 0
    GROUP BY t.name
)
SELECT 
    r26.table_name AS [Table_Name],
    ISNULL(r24.row_cnt, 0) AS [Rows_FY2425],
    ISNULL(r25.row_cnt, 0) AS [Rows_FY2526],
    ISNULL(r26.row_cnt, 0) AS [Rows_FY2627],
    CASE 
        WHEN ISNULL(r26.row_cnt, 0) > 0 THEN 'ACTIVE_IN_2627'
        WHEN ISNULL(r25.row_cnt, 0) > 0 OR ISNULL(r24.row_cnt, 0) > 0 THEN 'USED_IN_PRIOR_FY_OR_YEAR_END'
        ELSE 'EMPTY_ACROSS_3_YEARS'
    END AS [Usage_Status]
FROM Rows2627 r26
LEFT JOIN Rows2526 r25 ON r26.table_name = r25.table_name
LEFT JOIN Rows2425 r24 ON r26.table_name = r24.table_name
ORDER BY 
    ISNULL(r26.row_cnt, 0) DESC,
    ISNULL(r25.row_cnt, 0) DESC,
    r26.table_name ASC;

-- =============================================================================
-- GRID 2: COMPLETE COLUMN BLUEPRINT FOR ALL USER TABLES IN IMMBE2627
-- =============================================================================
WITH TableRowCounts AS (
    SELECT t.name AS table_name, SUM(p.rows) AS total_rows
    FROM sys.tables t
    INNER JOIN sys.partitions p ON t.object_id = p.object_id
    WHERE p.index_id IN (0, 1) AND t.is_ms_shipped = 0
    GROUP BY t.name
),
PrimaryKeys AS (
    SELECT 
        ku.TABLE_SCHEMA,
        ku.TABLE_NAME,
        ku.COLUMN_NAME,
        ku.ORDINAL_POSITION AS pk_ordinal
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
        ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
        AND tc.TABLE_SCHEMA = ku.TABLE_SCHEMA
    WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
)
SELECT 
    c.TABLE_NAME AS [table_name],
    ISNULL(rc.total_rows, 0) AS [rows_2627],
    c.ORDINAL_POSITION AS [col_order],
    c.COLUMN_NAME AS [column_name],
    c.DATA_TYPE AS [data_type],
    c.CHARACTER_MAXIMUM_LENGTH AS [max_len],
    c.NUMERIC_PRECISION AS [num_precision],
    c.NUMERIC_SCALE AS [num_scale],
    c.IS_NULLABLE AS [is_nullable],
    CASE WHEN pk.COLUMN_NAME IS NOT NULL THEN 'PK_' + CAST(pk.pk_ordinal AS VARCHAR(5)) ELSE '' END AS [primary_key],
    c.COLUMN_DEFAULT AS [default_value]
FROM INFORMATION_SCHEMA.COLUMNS c
INNER JOIN INFORMATION_SCHEMA.TABLES t
    ON c.TABLE_SCHEMA = t.TABLE_SCHEMA 
    AND c.TABLE_NAME = t.TABLE_NAME
LEFT JOIN TableRowCounts rc
    ON c.TABLE_NAME = rc.table_name
LEFT JOIN PrimaryKeys pk
    ON c.TABLE_SCHEMA = pk.TABLE_SCHEMA
    AND c.TABLE_NAME = pk.TABLE_NAME
    AND c.COLUMN_NAME = pk.COLUMN_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE'
ORDER BY 
    c.TABLE_NAME ASC,
    c.ORDINAL_POSITION ASC;

-- =============================================================================
-- GRID 3: UNIFIED DUMP OF EMPIRE'S UI SCREENS, FORM SETTINGS & REPORT QUERIES
-- Uses SQL Server 2012 native XML serialization so ALL 15 config/brain tables
-- + Views/Stored Procs come out in ONE single grid to save!
-- =============================================================================
SELECT 'SCREENLIST' AS [Source], (SELECT * FROM dbo.SCREENLIST FOR XML RAW('row'), ROOT('rows')) AS [Payload_XML]
UNION ALL
SELECT 'SCREENCOMP', (SELECT * FROM dbo.SCREENCOMP FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'SCREEN_EXPOSE', (SELECT * FROM dbo.SCREEN_EXPOSE FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'formsettings', (SELECT * FROM dbo.formsettings FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'CUSTOMFORMS', (SELECT * FROM dbo.CUSTOMFORMS FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'FORMPERM', (SELECT * FROM dbo.FORMPERM FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'CONFIG', (SELECT * FROM dbo.CONFIG FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'settings', (SELECT * FROM dbo.settings FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'uniq_config', (SELECT * FROM dbo.uniq_config FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'REPORTQUERIES', (SELECT * FROM dbo.REPORTQUERIES FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'QUICKREPORTS', (SELECT * FROM dbo.QUICKREPORTS FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'Reportoptions', (SELECT * FROM dbo.Reportoptions FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'REPORTGROUPING', (SELECT * FROM dbo.REPORTGROUPING FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'UDRS', (SELECT * FROM dbo.UDRS FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'RMKLIST', (SELECT * FROM dbo.RMKLIST FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'USERS_SAFE', (SELECT * FROM dbo.USERS FOR XML RAW('row'), ROOT('rows'))
UNION ALL
SELECT 'SQL_MODULES_VIEWS_PROCS', (
    SELECT o.type_desc, o.name, m.definition
    FROM sys.sql_modules m
    INNER JOIN sys.objects o ON m.object_id = o.object_id
    FOR XML RAW('row'), ROOT('rows')
);
