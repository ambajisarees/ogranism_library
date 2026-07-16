// @ts-nocheck
import postgres from 'npm:postgres'

const SCHEMA = 'IMMBE2627'

interface GreyOrderRequest {
  date?: string;
  gcode: string;
  bcode?: string;
  qual: string;
  unit: string;
  pcs?: number | string;
  mts?: number | string;
  lots?: number | string;
  rate?: number | string;
  disc?: number | string;
  gracedays?: number | string;
  rmk?: string;
  creator?: string;
}

Deno.serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  const databaseUrl = Deno.env.get('SUPABASE_DB_URL');
  if (!databaseUrl) {
    return new Response(JSON.stringify({ error: 'SUPABASE_DB_URL is not set' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  const sql = postgres(databaseUrl, { prepare: false })

  try {
    const rawBody = await req.json()
    const body = rawBody as GreyOrderRequest
    
    const {
      date,
      gcode,
      bcode,
      qual,
      unit,
      pcs,
      mts,
      lots,
      rate,
      disc,
      gracedays,
      rmk,
      creator
    } = body

    if (!gcode) throw new Error('Weaver (gcode) is required.')
    if (!qual) throw new Error('Quality (qual) is required.')
    if (!unit) throw new Error('Unit (PCS/MTS) is required.')

    // ── DATABASE TRANSACTION ───────────────────────────────────────────────
    const result = await sql.begin(async (tx) => {
      // 1. Resolve next ORDERNO < 100000
      const rowsSb = await tx`
        SELECT COALESCE(max("ORDERNO"), 0)::int AS max_ord_sb 
        FROM "${tx.unsafe(SCHEMA)}"."sb_pur_ord"
        WHERE "ORDERNO" < 100000
      `
      
      const maxSb = Number(rowsSb[0]?.max_ord_sb || 0)
      const nextOrderNo = Math.max(maxSb, 0) + 1

      // 2. Insert into sb_pur_ord
      const orderInsert = {
        ORDERNO: nextOrderNo,
        DATE: date || new Date().toISOString(),
        gcode: gcode,
        BCODE: bcode || null,
        QUAL: qual,
        UNIT: unit,
        PCS: pcs ? Number(pcs) : null,
        MTS: mts ? Number(mts) : null,
        LOTS: lots ? Number(lots) : null,
        RATE: rate ? Number(rate) : null,
        DISC: disc ? Number(disc) : null,
        GRACEDAYS: gracedays ? Number(gracedays) : null,
        RMK: rmk || null,
        cancelled: false,
        CREATETIME: new Date().toISOString(),
        UPDATETIME: new Date().toISOString(),
        CREATOR: creator || null
      }

      await tx`
        INSERT INTO "${tx.unsafe(SCHEMA)}"."sb_pur_ord" ${tx(orderInsert)}
      `

      return {
        success: true,
        orderno: nextOrderNo,
      }
    })

    await sql.end()

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      }
    })
  } catch (err) {
    console.error('Error in create-grey-order:', err)
    try { await sql.end() } catch (_) {}

    const errorMsg = err instanceof Error ? err.message : String(err)
    return new Response(JSON.stringify({ error: errorMsg }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      }
    })
  }
})
