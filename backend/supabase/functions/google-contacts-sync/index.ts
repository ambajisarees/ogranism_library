// @ts-nocheck
import postgres from 'npm:postgres'

const SCHEMA = 'IMMBE2627'
const DEFAULT_EMAIL = 'design.ambaji@gmail.com'
const DEFAULT_CLIENT_ID = '486012291961-nqqh431rt0sobmu8on4nsq3ipqjfral4.apps.googleusercontent.com'

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface GoogleSyncRequest {
  action: 'get_sync_state' | 'save_auth' | 'exchange_oauth_code' | 'refresh_token' | 'upsert_batch'
  email?: string
  oauthClientId?: string
  oauthClientSecret?: string
  refreshToken?: string
  accessToken?: string
  expiresIn?: number
  code?: string
  codeVerifier?: string
  redirectUri?: string
  importSource?: string
  rows?: unknown[]
}

function jsonResponse(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  })
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS })
  }

  const databaseUrl = Deno.env.get('SUPABASE_DB_URL')
  if (!databaseUrl) {
    return jsonResponse({ error: 'SUPABASE_DB_URL is not set' }, 500)
  }

  const sql = postgres(databaseUrl, { prepare: false })

  try {
    const body = (await req.json()) as GoogleSyncRequest
    const action = body.action
    const email = (body.email || DEFAULT_EMAIL).trim().toLowerCase()

    // ── 1. GET SYNC STATE ────────────────────────────────────────────────
    if (action === 'get_sync_state') {
      await sql`
        INSERT INTO "${sql.unsafe(SCHEMA)}"."sb_google_sync_state" ("email")
        VALUES (${email})
        ON CONFLICT ("email") DO NOTHING
      `

      const rows = await sql`
        SELECT
          "email",
          "oauth_client_id",
          ("oauth_client_secret" IS NOT NULL AND "oauth_client_secret" <> '') AS "has_client_secret",
          ("refresh_token" IS NOT NULL AND "refresh_token" <> '') AS "has_refresh_token",
          ("access_token" IS NOT NULL AND "access_token" <> '') AS "has_access_token",
          "token_expires_at",
          "next_sync_token",
          "contact_groups_map",
          "last_full_sync_at",
          "last_delta_sync_at",
          "last_push_at",
          "total_google_contacts",
          "is_continuous_sync_enabled",
          "sync_health",
          "last_error",
          "updated_at"
        FROM "${sql.unsafe(SCHEMA)}"."sb_google_sync_state"
        WHERE "email" = ${email}
        LIMIT 1
      `

      await sql.end()
      return jsonResponse({ sync_state: rows[0] || null })
    }

    // ── 2. SAVE OAUTH TOKENS / CLIENT CREDENTIALS ────────────────────────
    if (action === 'save_auth') {
      const expiresAt =
        body.expiresIn && body.expiresIn > 0
          ? new Date(Date.now() + body.expiresIn * 1000).toISOString()
          : null

      const hasToken =
        Boolean(body.accessToken && body.accessToken.trim()) ||
        Boolean(body.refreshToken && body.refreshToken.trim())

      await sql`
        INSERT INTO "${sql.unsafe(SCHEMA)}"."sb_google_sync_state" (
          "email",
          "oauth_client_id",
          "oauth_client_secret",
          "refresh_token",
          "access_token",
          "token_expires_at",
          "sync_health",
          "last_error",
          "updated_at"
        ) VALUES (
          ${email},
          ${body.oauthClientId || DEFAULT_CLIENT_ID},
          ${body.oauthClientSecret || null},
          ${body.refreshToken || null},
          ${body.accessToken || null},
          ${expiresAt},
          ${hasToken ? 'HEALTHY' : 'DISCONNECTED'},
          NULL,
          NOW()
        )
        ON CONFLICT ("email") DO UPDATE SET
          "oauth_client_id" = COALESCE(NULLIF(EXCLUDED."oauth_client_id", ''), "sb_google_sync_state"."oauth_client_id"),
          "oauth_client_secret" = COALESCE(NULLIF(EXCLUDED."oauth_client_secret", ''), "sb_google_sync_state"."oauth_client_secret"),
          "refresh_token" = COALESCE(NULLIF(EXCLUDED."refresh_token", ''), "sb_google_sync_state"."refresh_token"),
          "access_token" = COALESCE(NULLIF(EXCLUDED."access_token", ''), "sb_google_sync_state"."access_token"),
          "token_expires_at" = COALESCE(EXCLUDED."token_expires_at", "sb_google_sync_state"."token_expires_at"),
          "sync_health" = CASE
            WHEN COALESCE(NULLIF(EXCLUDED."access_token", ''), "sb_google_sync_state"."access_token") IS NOT NULL
              OR COALESCE(NULLIF(EXCLUDED."refresh_token", ''), "sb_google_sync_state"."refresh_token") IS NOT NULL
            THEN 'HEALTHY'
            ELSE 'DISCONNECTED'
          END,
          "last_error" = NULL,
          "updated_at" = NOW()
      `

      await sql.end()
      return jsonResponse({ success: true, email })
    }

    // ── 3. EXCHANGE OAUTH AUTHORIZATION CODE ─────────────────────────────
    if (action === 'exchange_oauth_code') {
      if (!body.code || !body.redirectUri) {
        await sql.end()
        return jsonResponse({ error: 'code and redirectUri are required' }, 400)
      }

      const stateRows = await sql`
        SELECT "oauth_client_id", "oauth_client_secret"
        FROM "${sql.unsafe(SCHEMA)}"."sb_google_sync_state"
        WHERE "email" = ${email}
        LIMIT 1
      `

      const clientId =
        body.oauthClientId || stateRows[0]?.oauth_client_id || Deno.env.get('GOOGLE_OAUTH_CLIENT_ID') || DEFAULT_CLIENT_ID
      const clientSecret =
        body.oauthClientSecret || stateRows[0]?.oauth_client_secret || Deno.env.get('GOOGLE_OAUTH_CLIENT_SECRET') || ''

      const form = new URLSearchParams()
      form.set('code', body.code)
      form.set('client_id', clientId)
      if (clientSecret) form.set('client_secret', clientSecret)
      form.set('redirect_uri', body.redirectUri)
      form.set('grant_type', 'authorization_code')
      if (body.codeVerifier) form.set('code_verifier', body.codeVerifier)

      const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: form.toString(),
      })

      const tokenJson = await tokenRes.json()
      if (!tokenRes.ok || !tokenJson.access_token) {
        const errMsg = tokenJson.error_description || tokenJson.error || `HTTP ${tokenRes.status}`
        await sql`
          UPDATE "${sql.unsafe(SCHEMA)}"."sb_google_sync_state"
          SET "sync_health" = 'ERROR', "last_error" = ${errMsg}, "updated_at" = NOW()
          WHERE "email" = ${email}
        `
        await sql.end()
        return jsonResponse({ error: errMsg }, 400)
      }

      const expiresAt = new Date(Date.now() + Number(tokenJson.expires_in || 3600) * 1000).toISOString()

      await sql`
        INSERT INTO "${sql.unsafe(SCHEMA)}"."sb_google_sync_state" (
          "email", "oauth_client_id", "oauth_client_secret",
          "refresh_token", "access_token", "token_expires_at",
          "sync_health", "last_error", "updated_at"
        ) VALUES (
          ${email}, ${clientId}, ${clientSecret || null},
          ${tokenJson.refresh_token || null}, ${tokenJson.access_token}, ${expiresAt},
          'HEALTHY', NULL, NOW()
        )
        ON CONFLICT ("email") DO UPDATE SET
          "oauth_client_id" = EXCLUDED."oauth_client_id",
          "oauth_client_secret" = COALESCE(NULLIF(EXCLUDED."oauth_client_secret", ''), "sb_google_sync_state"."oauth_client_secret"),
          "refresh_token" = COALESCE(NULLIF(EXCLUDED."refresh_token", ''), "sb_google_sync_state"."refresh_token"),
          "access_token" = EXCLUDED."access_token",
          "token_expires_at" = EXCLUDED."token_expires_at",
          "sync_health" = 'HEALTHY',
          "last_error" = NULL,
          "updated_at" = NOW()
      `

      await sql.end()
      return jsonResponse({
        success: true,
        access_token: tokenJson.access_token,
        expires_at: expiresAt,
        has_refresh_token: Boolean(tokenJson.refresh_token),
      })
    }

    // ── 4. REFRESH GOOGLE ACCESS TOKEN ───────────────────────────────────
    if (action === 'refresh_token') {
      const stateRows = await sql`
        SELECT "oauth_client_id", "oauth_client_secret", "refresh_token"
        FROM "${sql.unsafe(SCHEMA)}"."sb_google_sync_state"
        WHERE "email" = ${email}
        LIMIT 1
      `
      const row = stateRows[0]
      const refreshToken = body.refreshToken || row?.refresh_token
      const clientId =
        body.oauthClientId || row?.oauth_client_id || Deno.env.get('GOOGLE_OAUTH_CLIENT_ID') || DEFAULT_CLIENT_ID
      const clientSecret =
        body.oauthClientSecret || row?.oauth_client_secret || Deno.env.get('GOOGLE_OAUTH_CLIENT_SECRET') || ''

      if (!refreshToken || !clientSecret) {
        await sql.end()
        return jsonResponse(
          { error: 'Missing refresh_token or oauth_client_secret for token refresh' },
          400,
        )
      }

      const form = new URLSearchParams()
      form.set('client_id', clientId)
      form.set('client_secret', clientSecret)
      form.set('refresh_token', refreshToken)
      form.set('grant_type', 'refresh_token')

      const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: form.toString(),
      })

      const tokenJson = await tokenRes.json()
      if (!tokenRes.ok || !tokenJson.access_token) {
        const errMsg = tokenJson.error_description || tokenJson.error || `HTTP ${tokenRes.status}`
        await sql`
          UPDATE "${sql.unsafe(SCHEMA)}"."sb_google_sync_state"
          SET "sync_health" = 'TOKEN_EXPIRED', "last_error" = ${errMsg}, "updated_at" = NOW()
          WHERE "email" = ${email}
        `
        await sql.end()
        return jsonResponse({ error: errMsg }, 401)
      }

      const expiresAt = new Date(Date.now() + Number(tokenJson.expires_in || 3600) * 1000).toISOString()

      await sql`
        UPDATE "${sql.unsafe(SCHEMA)}"."sb_google_sync_state"
        SET
          "access_token" = ${tokenJson.access_token},
          "token_expires_at" = ${expiresAt},
          "sync_health" = 'HEALTHY',
          "last_error" = NULL,
          "updated_at" = NOW()
        WHERE "email" = ${email}
      `

      await sql.end()
      return jsonResponse({
        success: true,
        access_token: tokenJson.access_token,
        expires_at: expiresAt,
      })
    }

    // ── 5. BATCH UPSERT CONTACTS VIA RPC ─────────────────────────────────
    if (action === 'upsert_batch') {
      if (!Array.isArray(body.rows)) {
        await sql.end()
        return jsonResponse({ error: 'rows array is required for upsert_batch' }, 400)
      }

      const importSource = body.importSource || 'GOOGLE_API'
      const rpcRows = await sql`
        SELECT "${sql.unsafe(SCHEMA)}"."fn_upsert_google_contacts_batch"(
          ${JSON.stringify(body.rows)}::jsonb,
          ${email},
          ${importSource}
        ) AS result
      `

      await sql.end()
      return jsonResponse({ success: true, ...(rpcRows[0]?.result || {}) })
    }

    await sql.end()
    return jsonResponse({ error: `Unknown action: ${action}` }, 400)
  } catch (err) {
    console.error('Error in google-contacts-sync:', err)
    try {
      await sql.end()
    } catch (_) {
      // ignore close errors
    }
    const errorMsg = err instanceof Error ? err.message : String(err)
    return jsonResponse({ error: errorMsg }, 500)
  }
})
