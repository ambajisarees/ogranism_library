// @ts-nocheck
import postgres from 'npm:postgres'

const SCHEMA = 'IMMBE2627'

interface GoogleSyncRequest {
  action: 'save_auth' | 'get_auth' | 'pull_contacts' | 'push_contacts';
  email?: string;
  refreshToken?: string;
  accessToken?: string;
  expiresIn?: number;
  contacts?: any[];
}

Deno.serve(async (req: Request) => {
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
    const body = (await req.json()) as GoogleSyncRequest;
    const { action, email, refreshToken, accessToken, expiresIn, contacts } = body;

    // ── 1. SAVE OAUTH GOOGLE AUTHENTICATION ─────────────────────────────
    if (action === 'save_auth') {
      if (!email || !refreshToken) {
        throw new Error('Email and refreshToken are required for save_auth');
      }

      const expiresAt = expiresIn ? new Date(Date.now() + expiresIn * 1000).toISOString() : null;

      await sql`
        INSERT INTO "${sql.unsafe(SCHEMA)}"."sb_google_auth" (
          "email", "refresh_token", "access_token", "expires_at", "updated_at"
        ) VALUES (
          ${email}, ${refreshToken}, ${accessToken || null}, ${expiresAt}, NOW()
        )
        ON CONFLICT ("email") DO UPDATE SET
          "refresh_token" = EXCLUDED."refresh_token",
          "access_token" = EXCLUDED."access_token",
          "expires_at" = EXCLUDED."expires_at",
          "updated_at" = NOW()
      `;

      await sql.end();
      return new Response(JSON.stringify({ success: true, email }), {
        status: 200,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    // ── 2. GET CURRENT AUTH STATUS ──────────────────────────────────────
    if (action === 'get_auth') {
      const rows = await sql`
        SELECT "id", "email", "access_token", "expires_at", "created_at"
        FROM "${sql.unsafe(SCHEMA)}"."sb_google_auth"
        ORDER BY "created_at" DESC
        LIMIT 1
      `;

      await sql.end();
      const auth = rows[0] || null;

      return new Response(JSON.stringify({
        connected: auth !== null,
        email: auth?.email || null,
        expiresAt: auth?.expires_at || null,
      }), {
        status: 200,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    // ── 3. UPSERT PULLED GOOGLE CONTACTS ────────────────────────────────
    if (action === 'pull_contacts') {
      if (!Array.isArray(contacts)) {
        throw new Error('contacts array is required for pull_contacts');
      }

      let upsertedCount = 0;

      for (const item of contacts) {
        const resourceName = item.resourceName || item.google_resource_name;
        if (!resourceName) continue;

        const displayName = item.names?.[0]?.displayName || item.display_name || 'Unnamed Google Contact';
        const givenName = item.names?.[0]?.givenName || item.given_name || null;
        const familyName = item.names?.[0]?.familyName || item.family_name || null;
        const companyName = item.organizations?.[0]?.name || item.company_name || null;
        const jobTitle = item.organizations?.[0]?.title || item.job_title || null;
        const photoUrl = item.photos?.[0]?.url || item.photo_url || null;

        const phones = item.phoneNumbers || item.phone_numbers || [];
        const emailsList = item.emailAddresses || item.emails || [];
        const addressesList = item.addresses || [];
        const userDefined = item.userDefined || item.user_defined_fields || [];
        const memberships = item.memberships || item.group_memberships || [];
        const notes = item.biographies?.[0]?.value || item.notes || null;

        // Primary phone extraction
        let primaryPhone = item.primary_phone || null;
        if (!primaryPhone && phones.length > 0) {
          primaryPhone = phones[0].canonicalForm || phones[0].value || phones[0].number || null;
        }

        await sql`
          INSERT INTO "${sql.unsafe(SCHEMA)}"."sb_google_contacts" (
            "google_resource_name",
            "etag",
            "display_name",
            "given_name",
            "family_name",
            "company_name",
            "job_title",
            "photo_url",
            "phone_numbers",
            "primary_phone",
            "emails",
            "addresses",
            "user_defined_fields",
            "group_memberships",
            "notes",
            "raw_data",
            "sync_status",
            "last_synced_at",
            "updated_at"
          ) VALUES (
            ${resourceName},
            ${item.etag || null},
            ${displayName},
            ${givenName},
            ${familyName},
            ${companyName},
            ${jobTitle},
            ${photoUrl},
            ${JSON.stringify(phones)},
            ${primaryPhone},
            ${JSON.stringify(emailsList)},
            ${JSON.stringify(addressesList)},
            ${JSON.stringify(userDefined)},
            ${JSON.stringify(memberships)},
            ${notes},
            ${JSON.stringify(item)},
            'synced',
            NOW(),
            NOW()
          )
          ON CONFLICT ("google_resource_name") DO UPDATE SET
            "etag" = EXCLUDED."etag",
            "display_name" = EXCLUDED."display_name",
            "given_name" = EXCLUDED."given_name",
            "family_name" = EXCLUDED."family_name",
            "company_name" = EXCLUDED."company_name",
            "job_title" = EXCLUDED."job_title",
            "photo_url" = EXCLUDED."photo_url",
            "phone_numbers" = EXCLUDED."phone_numbers",
            "primary_phone" = COALESCE(EXCLUDED."primary_phone", "sb_google_contacts"."primary_phone"),
            "emails" = EXCLUDED."emails",
            "addresses" = EXCLUDED."addresses",
            "user_defined_fields" = EXCLUDED."user_defined_fields",
            "group_memberships" = EXCLUDED."group_memberships",
            "notes" = EXCLUDED."notes",
            "raw_data" = EXCLUDED."raw_data",
            "sync_status" = 'synced',
            "last_synced_at" = NOW(),
            "updated_at" = NOW()
        `;

        upsertedCount++;
      }

      await sql.end();
      return new Response(JSON.stringify({ success: true, count: upsertedCount }), {
        status: 200,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    await sql.end();
    return new Response(JSON.stringify({ error: `Unknown action: ${action}` }), {
      status: 400,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });
  } catch (err) {
    console.error('Error in google-contacts-sync:', err);
    try { await sql.end() } catch (_) {}
    const errorMsg = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: errorMsg }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });
  }
});
