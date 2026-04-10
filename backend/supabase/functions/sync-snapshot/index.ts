import postgres from 'npm:postgres'

const SCHEMA = 'IMMBE2627'

const TABLE_CONFIG: Record<string, { group: string; mode: string }> = {
  sq_MASTER:         { group: 'masters',    mode: 'incremental' },
  sq_QUAL:           { group: 'masters',    mode: 'incremental' },
  sq_HASTE:          { group: 'masters',    mode: 'incremental' },
  sq_ACGROUP:        { group: 'masters',    mode: 'incremental' },
  sq_BILLS:          { group: 'billing',    mode: 'incremental' },
  sq_BILLDET:        { group: 'billing',    mode: 'incremental' },
  sq_FAS:            { group: 'billing',    mode: 'incremental' },
  sq_RECPAY:         { group: 'billing',    mode: 'incremental' },
  sq_BANKREC:        { group: 'billing',    mode: 'incremental' },
  sq_BILLS_einv:     { group: 'billing',    mode: 'incremental' },
  sq_MILLREC:        { group: 'production', mode: 'incremental' },
  sq_CHALTRN:        { group: 'production', mode: 'incremental' },
  sq_CUTDET:         { group: 'production', mode: 'incremental' },
  sq_PINVTRN:        { group: 'production', mode: 'incremental' },
  sq_PURORD:         { group: 'production', mode: 'incremental' },
  sq_SAREEDES:       { group: 'audit',      mode: 'incremental' },
  sq_DELETEDITEMS:   { group: 'audit',      mode: 'incremental' },
  sq_updates_billdet:{ group: 'audit',      mode: 'incremental' },
  sq_ATYPE:          { group: 'lookup',     mode: 'full_refresh' },
  sq_SERIES:         { group: 'lookup',     mode: 'full_refresh' },
  sq_CITIES:         { group: 'lookup',     mode: 'full_refresh' },
  sq_CLOTHTYPE:      { group: 'lookup',     mode: 'full_refresh' },
  sq_PACKING:        { group: 'lookup',     mode: 'full_refresh' },
  sq_TRANSPORTS:     { group: 'lookup',     mode: 'full_refresh' },
  sq_banks:          { group: 'lookup',     mode: 'full_refresh' },
  sq_COMPMST:        { group: 'lookup',     mode: 'full_refresh' },
}

const SNAPSHOT_CONFIG: Record<string, { keyCol: string; cols: string[] }> = {
  sq_ACGROUP:   { keyCol: 'gcode',     cols: ['gcode', 'NAME', 'SHORTGROUPNAME', '_airbyte_raw_id'] },
  sq_CLOTHTYPE: { keyCol: 'CLOTHTYPE', cols: ['CLOTHTYPE', 'UNIT', 'COST_PER'] },
  sq_PACKING:   { keyCol: 'PACKING',   cols: ['PACKING', 'BOXRATE'] },
  sq_TRANSPORTS:{ keyCol: 'TRANSPORT', cols: ['TRANSPORT', 'TRANSPORT_MODE', 'MOBILE'] },
  sq_MASTER:    { keyCol: 'code',      cols: ['code', 'NAME', 'ATYPE', 'UPDATETIME'] },
  sq_HASTE:     { keyCol: 'HASTE',     cols: ['HASTE', 'ADATIYA', 'PLACE', 'MOBILE'] },
  sq_QUAL:      { keyCol: 'qcode',     cols: ['qcode', 'NAME', 'CLOTHTYPE', 'ISBASEQUAL', 'SELL1'] },
}

function buildMergeSql(tableName: string, oldKey: string, newKey: string): string {
  const q = (s: string) => s.replace(/'/g, "''")
  const o = q(oldKey), n = q(newKey)
  switch (tableName) {
    case 'sq_ACGROUP':    return `UPDATE "${SCHEMA}"."sq_MASTER" SET "GCODE" = '${n}' WHERE "GCODE" = '${o}';\nDELETE FROM "${SCHEMA}"."sq_ACGROUP" WHERE gcode = '${o}';`
    case 'sq_CLOTHTYPE':  return `UPDATE "${SCHEMA}"."sq_QUAL" SET "CLOTHTYPE" = '${n}' WHERE "CLOTHTYPE" = '${o}';\nDELETE FROM "${SCHEMA}"."sq_CLOTHTYPE" WHERE "CLOTHTYPE" = '${o}';`
    case 'sq_PACKING':    return `UPDATE "${SCHEMA}"."sq_QUAL" SET "PACKING" = '${n}' WHERE "PACKING" = '${o}';\nDELETE FROM "${SCHEMA}"."sq_PACKING" WHERE "PACKING" = '${o}';`
    case 'sq_TRANSPORTS': return `UPDATE "${SCHEMA}"."sq_MASTER" SET "TRANSPORT" = '${n}' WHERE "TRANSPORT" = '${o}';\nUPDATE "${SCHEMA}"."sq_HASTE" SET "TRANSPORT" = '${n}' WHERE "TRANSPORT" = '${o}';\nDELETE FROM "${SCHEMA}"."sq_TRANSPORTS" WHERE "TRANSPORT" = '${o}';`
    case 'sq_MASTER':     return `UPDATE "${SCHEMA}"."sq_BILLS" SET code = '${n}' WHERE code = '${o}';\nUPDATE "${SCHEMA}"."sq_FAS" SET code = '${n}' WHERE code = '${o}';\nUPDATE "${SCHEMA}"."sq_HASTE" SET "ADATIYA" = '${n}' WHERE "ADATIYA" = '${o}';\nUPDATE "${SCHEMA}"."sq_MILLREC" SET "MILL_CODE" = '${n}' WHERE "MILL_CODE" = '${o}';\nDELETE FROM "${SCHEMA}"."sq_MASTER" WHERE code = '${o}';`
    case 'sq_HASTE':      return `UPDATE "${SCHEMA}"."sq_BILLS" SET haste = '${n}' WHERE haste = '${o}';\nDELETE FROM "${SCHEMA}"."sq_HASTE" WHERE "HASTE" = '${o}';`
    case 'sq_QUAL':       return `UPDATE "${SCHEMA}"."sq_BILLDET" SET qual = '${n}' WHERE qual = '${o}';\nUPDATE "${SCHEMA}"."sq_MILLREC" SET "GREYQUAL" = '${n}' WHERE "GREYQUAL" = '${o}';\nDELETE FROM "${SCHEMA}"."sq_QUAL" WHERE qcode = '${o}';`
    default:              return `-- Manual fix needed for ${tableName}: '${o}' → '${n}'`
  }
}

function buildDeleteSql(tableName: string, keyCol: string, oldKey: string): string {
  return `-- Verify manually before running:\nDELETE FROM "${SCHEMA}"."${tableName}" WHERE "${keyCol}" = '${oldKey.replace(/'/g, "''")}';`
}

function buildDeduplicateSql(tableName: string): string {
  return `DELETE FROM "${SCHEMA}"."${tableName}"\nWHERE "_airbyte_extracted_at" < (\n  SELECT MAX("_airbyte_extracted_at") FROM "${SCHEMA}"."${tableName}"\n);`
}

function isFuzzyMatch(a: string, b: string): boolean {
  const na = a.toUpperCase().trim(), nb = b.toUpperCase().trim()
  if (na === nb) return false
  if (na.split(' ')[0] === nb.split(' ')[0]) return true
  if (na.startsWith(nb) || nb.startsWith(na)) return true
  return levenshtein(na, nb) <= 3
}

function levenshtein(a: string, b: string): number {
  const m = a.length, n = b.length
  const dp: number[][] = Array.from({ length: m + 1 }, (_, i) =>
    Array.from({ length: n + 1 }, (_, j) => (i === 0 ? j : j === 0 ? i : 0))
  )
  for (let i = 1; i <= m; i++)
    for (let j = 1; j <= n; j++)
      dp[i][j] = a[i-1] === b[j-1] ? dp[i-1][j-1] : 1 + Math.min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1])
  return dp[m][n]
}

// Insert rows in chunks to avoid parameter limits
async function batchInsertSnapshots(
  sql: postgres.Sql,
  rows: Array<{ captured_at: string; table_name: string; record_key: string; record_json: unknown }>,
  chunkSize = 200
) {
  for (let i = 0; i < rows.length; i += chunkSize) {
    const chunk = rows.slice(i, i + chunkSize)
    await sql`INSERT INTO "IMMBE2627".sb_sync_snapshots ${sql(chunk, 'captured_at', 'table_name', 'record_key', 'record_json')}`
  }
}

Deno.serve(async (_req) => {
  const sql = postgres(Deno.env.get('SUPABASE_DB_URL')!, { prepare: false })
  const runTime = new Date().toISOString()

  try {
    // ── STEP 1: Count all 26 tables ──────────────────────────────────────────
    type CountRow = { table_name: string; row_count: number; prev_count: number | null; sync_group: string; sync_mode: string }
    const countResults: CountRow[] = []

    for (const [tableName, config] of Object.entries(TABLE_CONFIG)) {
      const [{ count }] = await sql.unsafe(`SELECT COUNT(*)::int AS count FROM "${SCHEMA}"."${tableName}"`)

      const prevRows = await sql`
        SELECT row_count FROM "IMMBE2627".sb_sync_log
        WHERE table_name = ${tableName}
        ORDER BY captured_at DESC LIMIT 1
      `
      countResults.push({
        table_name: tableName,
        row_count: count as number,
        prev_count: prevRows.length > 0 ? prevRows[0].row_count as number : null,
        sync_group: config.group,
        sync_mode: config.mode,
      })
    }

    // Batch insert all 26 rows into sb_sync_log
    const logRows = countResults.map(r => ({
      captured_at: runTime,
      table_name: r.table_name,
      row_count: r.row_count,
      prev_count: r.prev_count,
      sync_group: r.sync_group,
      sync_mode: r.sync_mode,
    }))
    await sql`INSERT INTO "IMMBE2627".sb_sync_log ${sql(logRows, 'captured_at', 'table_name', 'row_count', 'prev_count', 'sync_group', 'sync_mode')}`

    // ── STEP 2: Full-refresh anomaly detection ────────────────────────────────
    for (const r of countResults.filter(r => r.sync_mode === 'full_refresh')) {
      if (r.prev_count === null) continue
      const prev = r.prev_count, curr = r.row_count
      let anomalyType: string | null = null
      let description = '', suggestedSql = ''

      if (curr === 0) {
        anomalyType = 'zero'
        description = `${r.table_name} wiped to 0 rows (was ${prev}). Check Airbyte connector.`
        suggestedSql = `-- Do NOT auto-fix. Check Airbyte connector for ${r.table_name}.`
      } else if (prev > 0 && curr % prev === 0 && curr / prev >= 2) {
        anomalyType = 'multiplication'
        description = `${r.table_name} multiplied: ${prev} → ${curr} (×${curr / prev}). Ghost rows detected.`
        suggestedSql = buildDeduplicateSql(r.table_name)
      } else if (prev > 0 && curr > prev * 1.5) {
        anomalyType = 'spike'
        description = `${r.table_name} spiked: ${prev} → ${curr} (+${curr - prev} rows).`
        suggestedSql = buildDeduplicateSql(r.table_name)
      } else if (prev > 0 && curr < prev * 0.8) {
        anomalyType = 'drop'
        description = `${r.table_name} dropped: ${prev} → ${curr} (−${prev - curr} rows). Verify Airbyte.`
        suggestedSql = `-- Data loss detected. Do NOT auto-fix. Verify source in AMAZE.`
      }

      if (anomalyType) {
        const existing = await sql`
          SELECT id FROM "IMMBE2627".sb_sync_issues
          WHERE table_name = ${r.table_name} AND anomaly_type = ${anomalyType} AND status = 'open'
          LIMIT 1
        `
        if (!existing.length) {
          await sql`
            INSERT INTO "IMMBE2627".sb_sync_issues (table_name, anomaly_type, description, suggested_sql)
            VALUES (${r.table_name}, ${anomalyType}, ${description}, ${suggestedSql})
          `
        }
      }
    }

    // ── STEP 3: Record-level snapshots for 7 FK parent tables ────────────────
    for (const [tableName, snapConfig] of Object.entries(SNAPSHOT_CONFIG)) {
      const quotedCols = snapConfig.cols.map(c => `"${c}"`).join(', ')
      const currentRecords = await sql.unsafe(`SELECT ${quotedCols} FROM "${SCHEMA}"."${tableName}"`)

      const cutoff = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString()
      const prevSnaps = await sql`
        SELECT record_key, record_json, captured_at::text AS captured_at_str
        FROM "IMMBE2627".sb_sync_snapshots
        WHERE table_name = ${tableName} AND captured_at >= ${cutoff}
        ORDER BY captured_at DESC
      `

      // Build current key → record map
      const currentMap = new Map<string, Record<string, unknown>>()
      for (const rec of currentRecords) {
        const key = String(rec[snapConfig.keyCol] ?? '')
        if (key) currentMap.set(key, rec as Record<string, unknown>)
      }

      // Build previous snapshot map from most recent run only
      const prevRunKeys = new Set<string>()
      const prevMap = new Map<string, Record<string, unknown>>()
      if (prevSnaps.length) {
        const latestTs = prevSnaps[0].captured_at_str as string
        for (const snap of prevSnaps) {
          if ((snap.captured_at_str as string) !== latestTs) break
          prevRunKeys.add(snap.record_key as string)
          prevMap.set(snap.record_key as string, snap.record_json as Record<string, unknown>)
        }
      }

      // Write new snapshot rows
      if (currentMap.size > 0) {
        const snapshotRows = Array.from(currentMap.entries()).map(([key, rec]) => ({
          captured_at: runTime,
          table_name: tableName,
          record_key: key,
          record_json: rec,
        }))
        await batchInsertSnapshots(sql, snapshotRows)
      }

      // Purge snapshots older than 48 hours
      await sql`DELETE FROM "IMMBE2627".sb_sync_snapshots WHERE table_name = ${tableName} AND captured_at < ${cutoff}`

      if (!prevMap.size) continue

      const currentKeys = new Set(currentMap.keys())
      const disappeared = [...prevRunKeys].filter(k => !currentKeys.has(k))
      const appeared = [...currentKeys].filter(k => !prevRunKeys.has(k))

      const matchedAppeared = new Set<string>()
      for (const oldKey of disappeared) {
        const ghostRecord = prevMap.get(oldKey)!
        const ghostName = String(ghostRecord['NAME'] ?? ghostRecord['TRANSPORT'] ?? ghostRecord[snapConfig.keyCol] ?? oldKey)

        const renameMatch = appeared.find(newKey => {
          if (matchedAppeared.has(newKey)) return false
          const newRec = currentMap.get(newKey)!
          const newName = String(newRec['NAME'] ?? newRec['TRANSPORT'] ?? newRec[snapConfig.keyCol] ?? newKey)
          return isFuzzyMatch(ghostName, newName)
        })

        let anomalyType: string, description: string, suggestedSql: string
        let newRecord: Record<string, unknown> | null = null

        if (renameMatch) {
          matchedAppeared.add(renameMatch)
          newRecord = currentMap.get(renameMatch)!
          const newName = String(newRecord['NAME'] ?? newRecord['TRANSPORT'] ?? newRecord[snapConfig.keyCol] ?? renameMatch)
          anomalyType = 'ghost_rename'
          description = `${tableName}: '${ghostName}' → '${newName}'? Ghost entry detected. Merge?`
          suggestedSql = buildMergeSql(tableName, oldKey, renameMatch)
        } else {
          anomalyType = 'ghost_only'
          description = `${tableName}: '${ghostName}' (key: ${oldKey}) disappeared from source. Ghost row in Supabase.`
          suggestedSql = buildDeleteSql(tableName, snapConfig.keyCol, oldKey)
        }

        const existing = await sql`
          SELECT id FROM "IMMBE2627".sb_sync_issues
          WHERE table_name = ${tableName} AND anomaly_type = ${anomalyType}
            AND status = 'open' AND ghost_record->>'record_key' = ${oldKey}
          LIMIT 1
        `
        if (!existing.length) {
          await sql`
            INSERT INTO "IMMBE2627".sb_sync_issues
              (table_name, anomaly_type, description, ghost_record, new_record, suggested_sql)
            VALUES (
              ${tableName}, ${anomalyType}, ${description},
              ${sql.json({ record_key: oldKey, ...ghostRecord })},
              ${newRecord ? sql.json({ record_key: renameMatch, ...newRecord }) : null},
              ${suggestedSql}
            )
          `
        }
      }

      for (const newKey of appeared) {
        if (matchedAppeared.has(newKey)) continue
        const newRec = currentMap.get(newKey)!
        const newName = String(newRec['NAME'] ?? newRec['TRANSPORT'] ?? newRec[snapConfig.keyCol] ?? newKey)
        const existing = await sql`
          SELECT id FROM "IMMBE2627".sb_sync_issues
          WHERE table_name = ${tableName} AND anomaly_type = 'new_only'
            AND status = 'open' AND new_record->>'record_key' = ${newKey}
          LIMIT 1
        `
        if (!existing.length) {
          await sql`
            INSERT INTO "IMMBE2627".sb_sync_issues
              (table_name, anomaly_type, description, ghost_record, new_record, suggested_sql)
            VALUES (
              ${tableName}, 'new_only',
              ${`${tableName}: new entry '${newName}' (key: ${newKey}) appeared. No ghost match found.`},
              NULL,
              ${sql.json({ record_key: newKey, ...newRec })},
              '-- Informational only. No fix needed unless this is a duplicate.'
            )
          `
        }
      }
    }

    await sql.end()
    return new Response(
      JSON.stringify({ success: true, run_time: runTime, tables_counted: Object.keys(TABLE_CONFIG).length }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('sync-snapshot error:', err)
    try { await sql.end() } catch (_) { /* ignore */ }
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
