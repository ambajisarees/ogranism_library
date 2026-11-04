# ==============================================================================
# ZERO-TRUNCATION 1-CLICK EMPIRE SQL EXPORTER (Run on MAIN-PC PowerShell)
# ==============================================================================
# Connects locally via Windows Auth to MAIN-PC\SQLEXPRESS (IMMBE2627) and saves
# untruncated CSV files into Desktop\empire_sql_dump\ in ~3 seconds!
# ==============================================================================

$Server = ".\SQLEXPRESS"
$Database = "IMMBE2627"
$OutDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "empire_sql_dump"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$ConnStr = "Server=$Server;Database=$Database;Integrated Security=True;TrustServerCertificate=True;"

function Export-QueryToCsv($Name, $Sql) {
    try {
        $Conn = New-Object System.Data.SqlClient.SqlConnection($ConnStr)
        $Conn.Open()
        $Cmd = $Conn.CreateCommand()
        $Cmd.CommandTimeout = 120
        $Cmd.CommandText = $Sql
        $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter($Cmd)
        $Table = New-Object System.Data.DataTable
        [void]$Adapter.Fill($Table)
        $Conn.Close()
        $OutFile = Join-Path $OutDir "$Name.csv"
        $Table | Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8
        Write-Host "[OK] Saved $Name.csv ($($Table.Rows.Count) rows)" -ForegroundColor Green
    } catch {
        Write-Host "[WARN] Skipped $Name : $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 1. Multi-Year Row Counts across IMMBE2425, IMMBE2526, IMMBE2627
Export-QueryToCsv "01_multiyear_row_counts" @"
WITH R26 AS (SELECT t.name, SUM(p.rows) cnt FROM [IMMBE2627].sys.tables t JOIN [IMMBE2627].sys.partitions p ON t.object_id=p.object_id WHERE p.index_id IN (0,1) AND t.is_ms_shipped=0 GROUP BY t.name),
     R25 AS (SELECT t.name, SUM(p.rows) cnt FROM [IMMBE2526].sys.tables t JOIN [IMMBE2526].sys.partitions p ON t.object_id=p.object_id WHERE p.index_id IN (0,1) AND t.is_ms_shipped=0 GROUP BY t.name),
     R24 AS (SELECT t.name, SUM(p.rows) cnt FROM [IMMBE2425].sys.tables t JOIN [IMMBE2425].sys.partitions p ON t.object_id=p.object_id WHERE p.index_id IN (0,1) AND t.is_ms_shipped=0 GROUP BY t.name)
SELECT R26.name AS Table_Name, ISNULL(R24.cnt,0) AS Rows_2425, ISNULL(R25.cnt,0) AS Rows_2526, ISNULL(R26.cnt,0) AS Rows_2627
FROM R26 LEFT JOIN R25 ON R26.name=R25.name LEFT JOIN R24 ON R26.name=R24.name
ORDER BY ISNULL(R26.cnt,0) DESC, ISNULL(R25.cnt,0) DESC, R26.name;
"@

# 2. All Columns Blueprint
Export-QueryToCsv "02_all_columns_schema" @"
SELECT c.TABLE_NAME, c.ORDINAL_POSITION, c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, c.NUMERIC_SCALE, c.IS_NULLABLE, c.COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN INFORMATION_SCHEMA.TABLES t ON c.TABLE_SCHEMA=t.TABLE_SCHEMA AND c.TABLE_NAME=t.TABLE_NAME
WHERE t.TABLE_TYPE='BASE TABLE'
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;
"@

# 3. Export Empire's UI, Screen, Form, Config & Report Brain Tables Directly!
$BrainTables = @(
    "SCREENLIST", "SCREENCOMP", "SCREEN_EXPOSE", "formsettings", "CUSTOMFORMS",
    "FORMPERM", "CONFIG", "settings", "uniq_config", "REPORTQUERIES",
    "QUICKREPORTS", "Reportoptions", "REPORTGROUPING", "UDRS", "RMKLIST", "logins"
)
foreach ($Tbl in $BrainTables) {
    Export-QueryToCsv "brain_$Tbl" "SELECT * FROM dbo.[$Tbl];"
}

# 4. Export Views / Stored Procs
Export-QueryToCsv "04_sql_views_and_procs" @"
SELECT o.type_desc, o.name, m.definition
FROM sys.sql_modules m JOIN sys.objects o ON m.object_id=o.object_id
ORDER BY o.type_desc, o.name;
"@

Write-Host "`nDONE! Copy the folder '$OutDir' into docs/empire_intake/ !" -ForegroundColor Cyan

