// @ts-nocheck
import postgres from 'npm:postgres'

const SCHEMA = 'IMMBE2627'

Deno.serve(async (req) => {
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

  const authHeader = req.headers.get('Authorization')
  let userId: string | null = null
  let userEmail: string | null = null

  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1]
    try {
      const payloadBase64 = token.split('.')[1]
      const decodedPayload = JSON.parse(atob(payloadBase64.replace(/-/g, '+').replace(/_/g, '/')))
      userId = decodedPayload.sub || null
      userEmail = decodedPayload.email || null
    } catch (e) {
      console.error('Error decoding JWT:', e)
    }
  }

  const sql = postgres(Deno.env.get('SUPABASE_DB_URL')!, { prepare: false })

  try {
    const body = await req.json()
    const {
      mill,
      greyqual,
      cut_date,
      cut_length,
      avg_wt,
      total_fresh_pcs,
      total_second_pcs,
      total_fent_wt,
      job_type,
      value_addition,
      screen,
      selected_cards, // Array of objects with CARDNO, RMTS, RPCS, lot, RATE, WEAVER, WCHAL, WCHDAT, DESPNO, DDATE
      start_cut_card_no, // Starting CUTCARDNO override
      sb_cardpic,
      start_multi_vno,
      edit_multi_vno,
    } = body

    if (!selected_cards || selected_cards.length === 0) {
      throw new Error('No Taka cards selected for cutting.')
    }

    const totalFreshPcs = Number(total_fresh_pcs || 0)
    const totalSecondPcs = Number(total_second_pcs || 0)
    const totalFentWt = Number(total_fent_wt || 0)
    const cutLength = Number(cut_length || 0)
    const avgWt = Number(avg_wt || 0)

    if (cutLength <= 0) throw new Error('Cut length must be greater than zero.')
    if (avgWt <= 0) throw new Error('Saree weight must be greater than zero.')

    // ── MATH LAYER: Calculate summary-level totals ─────────────────────────
    const selectedCards = selected_cards as Array<any>
    const totalRmts = selectedCards.reduce((sum, c) => sum + Number(c.PMTS || c.WMTS || c.RMTS || 0), 0)
    const totalRpcs = selectedCards.reduce((sum, c) => sum + Number(c.RPCS || 0), 0)

    if (totalRmts <= 0) throw new Error('Total received meters (RMTS) of selected cards must be greater than zero.')

    const weightPerMeter = avgWt / cutLength
    const fentMtsTot = Number(((totalFentWt * cutLength) / avgWt).toFixed(2))
    const freshMtsTot = Number((totalFreshPcs * cutLength).toFixed(2))
    const sareeWtTot = Number((totalFreshPcs * avgWt).toFixed(2))
    const secondMtsTot = Number((totalSecondPcs * 5.0).toFixed(2))

    const freshPct = Number(((freshMtsTot / totalRmts) * 100).toFixed(2))
    const secondPct = Number(((secondMtsTot / totalRmts) * 100).toFixed(2))
    const fentPct = Number(((fentMtsTot / totalRmts) * 100).toFixed(2))

    // ── DATABASE TRANSACTION ───────────────────────────────────────────────
    const result = await sql.begin(async (tx) => {
      // Lock summary table to prevent race conditions on max("MULTI_VNO") and max("CUTCARDNO")
      await tx`
        LOCK TABLE "${tx.unsafe(SCHEMA)}"."sb_cutdet_summary" IN EXCLUSIVE MODE
      `

      // Resolve username from sb_APP_PROFILES if available, otherwise fall back to email prefix
      let username = userEmail ? userEmail.split('@')[0] : null
      if (userId) {
        const profileRows = await tx`
          SELECT username 
          FROM "${tx.unsafe(SCHEMA)}"."sb_APP_PROFILES"
          WHERE id = ${userId}
        `
        if (profileRows && profileRows.length > 0 && profileRows[0].username) {
          username = profileRows[0].username
        }
      }

      const editMultiVnoNum = Number(edit_multi_vno || 0)
      const startMultiVnoNum = Number(start_multi_vno || 0)

      let nextMultiVno = 0
      let nextCutCardNo = 0

      if (editMultiVnoNum > 0) {
        // Resolve original min CUTCARDNO for this batch before deleting
        const [{ min_cc }] = await tx`
          SELECT MIN("CUTCARDNO")::int AS min_cc 
          FROM "${tx.unsafe(SCHEMA)}"."sb_cutdet"
          WHERE "MULTI_VNO" = ${editMultiVnoNum}
        `
        nextCutCardNo = min_cc || 1

        // Delete existing entries for the old batch number
        await tx`
          DELETE FROM "${tx.unsafe(SCHEMA)}"."sb_cutdet"
          WHERE "MULTI_VNO" = ${editMultiVnoNum}
        `
        await tx`
          DELETE FROM "${tx.unsafe(SCHEMA)}"."sb_cutdet_summary"
          WHERE "MULTI_VNO" = ${editMultiVnoNum}
        `

        // Use start_multi_vno if user modified it, otherwise keep old
        nextMultiVno = startMultiVnoNum > 0 ? startMultiVnoNum : editMultiVnoNum
      } else {
        // Resolve next MULTI_VNO starting with 1 (Fiscal Context: VNO < 100000)
        if (startMultiVnoNum > 0) {
          nextMultiVno = startMultiVnoNum
        } else {
          const [{ max_vno_sb }] = await tx`
            SELECT COALESCE(max("MULTI_VNO"), 0)::int AS max_vno_sb 
            FROM "${tx.unsafe(SCHEMA)}"."sb_cutdet"
            WHERE "MULTI_VNO" < 100000
          `
          nextMultiVno = max_vno_sb + 1
        }

        // Resolve starting CUTCARDNO starting with 1
        const [{ max_cc_sb }] = await tx`
          SELECT COALESCE(max("CUTCARDNO"), 0)::int AS max_cc_sb 
          FROM "${tx.unsafe(SCHEMA)}"."sb_cutdet"
          WHERE "CUTCARDNO" < 100000
        `
        nextCutCardNo = max_cc_sb + 1
      }

      if (Number(start_cut_card_no) > 0) {
        nextCutCardNo = Number(start_cut_card_no)
      }

      // Always clear any existing records for the TARGET nextMultiVno to prevent duplicates or clean unused blank entries
      await tx`
        DELETE FROM "${tx.unsafe(SCHEMA)}"."sb_cutdet"
        WHERE "MULTI_VNO" = ${nextMultiVno}
      `
      await tx`
        DELETE FROM "${tx.unsafe(SCHEMA)}"."sb_cutdet_summary"
        WHERE "MULTI_VNO" = ${nextMultiVno}
      `

      const cutCardNos: number[] = []
      const reccardNos: number[] = []

      // 3. Formulate individual rows with pro-rata distribution and rounding absorption
      let distributedFreshPcs = 0
      let distributedSecondPcs = 0

      const detailInserts = selectedCards.map((card, idx) => {
        const cardRmts = Number(card.PMTS || card.WMTS || card.RMTS || 0)
        const share = cardRmts / totalRmts
        const isLast = idx === selectedCards.length - 1

        let freshPcs = 0
        let secondPcs = 0

        if (isLast) {
          freshPcs = totalFreshPcs - distributedFreshPcs;
          secondPcs = totalSecondPcs - distributedSecondPcs;
        } else {
          freshPcs = Math.round(totalFreshPcs * share);
          secondPcs = Math.round(totalSecondPcs * share);
          distributedFreshPcs += freshPcs;
          distributedSecondPcs += secondPcs;
        }

        const fentWt = Number((totalFentWt * share).toFixed(3))
        const fentMts = Number((fentMtsTot * share).toFixed(2))
        const secondMts = Number((secondMtsTot * share).toFixed(2))

        const currentCCNo = nextCutCardNo++
        cutCardNos.push(currentCCNo)
        
        const recCardNo = Number(card.CARDNO || 0)
        reccardNos.push(recCardNo)

        return {
          CNO: 4,
          MULTI_CNO: 4,
          TYPE: 'J1', // Checklist says J1
          MULTI_TYPE: '03', // Checklist says 03
          MULTI_VNO: nextMultiVno,
          CUTCARDNO: currentCCNo,
          reccardno: recCardNo,
          CARDNO: recCardNo,
          PVNO: null, // Checklist says NULL
          lot: card.LOT || card.lot || '',
          GREYQUAL: card.QUAL || card.qual || greyqual,
          MILL: card.MILL || card.mill || mill,
          WEAVER: card.WEAVER || card.weaver || '',
          WCHAL: card.WCHAL || card.wchal || '',
          WCHDAT: card.WCHDAT || card.wchdat || null,
          DESPNO: card.DESPNO ? Number(card.DESPNO) : null,
          DDATE: card.DDATE || card.ddate || null,
          SCREEN: screen || null,
          RMTS: cardRmts,
          RPCS: Number(card.RPCS || 0),
          CPCS: freshPcs,
          SECONDS: secondPcs,
          FENT: fentMts,
          FENT_WT: fentWt,
          AVG_WT: avgWt,
          RATE: Number(card.RATE || 0),
          CCUT: cutLength,
          CMTS: Number((freshPcs * cutLength).toFixed(2)),
          closed: 'Y', // Checklist says Y
          sb_status: 'COMPLETED',
          CUTDATE: cut_date || new Date().toISOString(),
          GODOWN_TRANSFER: false,
          sb_cardpic: sb_cardpic || null,
          sb_created_by: userId,
          CREATOR: username,
          CREATETIME: new Date().toISOString(),
          UPDATER: editMultiVnoNum > 0 ? username : null,
          UPDATETIME: editMultiVnoNum > 0 ? new Date().toISOString() : null,
        }
      })

      // 4. Insert detailed rows
      await tx`
        INSERT INTO "${tx.unsafe(SCHEMA)}"."sb_cutdet" ${tx(detailInserts)}
      `

      // 5. Insert summary row
      const summaryInsert = {
        MULTI_VNO: nextMultiVno,
        MILL: mill,
        GREYQUAL: greyqual,
        CUTDATE: cut_date || new Date().toISOString(),
        CUT_LENGTH: cutLength,
        AVG_WT: avgWt,
        TOTAL_RMTS: totalRmts,
        TOTAL_RPCS: totalRpcs,
        TOTAL_FRESH_PCS: totalFreshPcs,
        TOTAL_SECOND_PCS: totalSecondPcs,
        TOTAL_FENT_WT: totalFentWt,
        TOTAL_SAREE_WT: sareeWtTot,
        TOTAL_FENT_MTS: fentMtsTot,
        TOTAL_SECOND_MTS: secondMtsTot,
        FRESH_PCT: freshPct,
        SECOND_PCT: secondPct,
        FENT_PCT: fentPct,
        JOB_TYPE: job_type,
        VALUE_ADDITION: value_addition,
        SCREEN: screen || null,
        sb_cardpic: sb_cardpic || null,
        CUTCARDNOS: cutCardNos,
        RECCARDNOS: reccardNos,
        sb_status: 'COMPLETED',
        sb_created_by: userId,
      }

      await tx`
        INSERT INTO "${tx.unsafe(SCHEMA)}"."sb_cutdet_summary" ${tx(summaryInsert)}
      `

      return {
        success: true,
        multi_vno: nextMultiVno,
        inserted_rows: detailInserts.length,
        cut_card_nos: cutCardNos,
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
    console.error('Error in create-cutting-batch:', err)
    try { await sql.end() } catch (_) {}

    let errorMessage = err.message || String(err)
    if (errorMessage.includes('sb_cutdet_unique_reccardno')) {
      errorMessage = 'One or more of the selected rolls (Takas) have already been cut by another user in a separate batch. Please refresh and select different rolls.'
    } else if (errorMessage.includes('sb_cutdet_summary_MULTI_VNO_key')) {
      errorMessage = 'The voucher number (MULTI_VNO) is already in use. Please select a different voucher number.'
    }

    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      }
    })
  }
})
