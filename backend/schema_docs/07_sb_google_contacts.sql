-- ============================================================================
-- Ambaji Sarees ERP: Stage 9.1 — Lossless 2-Table Google Contacts Schema
-- Target Schema: IMMBE2627
-- Default Google Account: design.ambaji@gmail.com
--
-- Architecture Decision:
--   Strictly 2 tables (NO separate phone_numbers or junction link tables):
--     1. "IMMBE2627"."sb_google_sync_state" -> OAuth credentials, delta nextSyncToken,
--        contactGroups ID->label map, sync counters & health status.
--     2. "IMMBE2627"."sb_contacts" -> 1:1 lossless Google People API v1 Person
--        mirror + GIN-indexed normalized phones (phone_norms[]) and inline ERP
--        Group/Party links (linked_group_codes[], linked_master_codes[], erp_links).
-- ============================================================================

-- 1. Table 1: Sync State, OAuth Credentials & Contact Groups Label Map
CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_google_sync_state" (
    "email" TEXT PRIMARY KEY,
    "oauth_client_id" TEXT DEFAULT '486012291961-nqqh431rt0sobmu8on4nsq3ipqjfral4.apps.googleusercontent.com',
    "oauth_client_secret" TEXT,
    "refresh_token" TEXT,
    "access_token" TEXT,
    "token_expires_at" TIMESTAMPTZ,
    "next_sync_token" TEXT,
    "contact_groups_map" JSONB NOT NULL DEFAULT '{}'::jsonb,
    "last_full_sync_at" TIMESTAMPTZ,
    "last_delta_sync_at" TIMESTAMPTZ,
    "last_push_at" TIMESTAMPTZ,
    "total_google_contacts" INT NOT NULL DEFAULT 0,
    "is_continuous_sync_enabled" BOOLEAN NOT NULL DEFAULT true,
    "sync_health" TEXT NOT NULL DEFAULT 'DISCONNECTED'
        CHECK ("sync_health" IN ('HEALTHY', 'SYNCING', 'TOKEN_EXPIRED', 'DISCONNECTED', 'ERROR')),
    "last_error" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO "IMMBE2627"."sb_google_sync_state" ("email", "sync_health")
VALUES ('design.ambaji@gmail.com', 'DISCONNECTED')
ON CONFLICT ("email") DO NOTHING;

-- 2. Table 2: Lossless 1:1 Google People API v1 Mirror + Fast ERP Lookup
CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_contacts" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "google_account_email" TEXT NOT NULL DEFAULT 'design.ambaji@gmail.com',

    -- 1:1 Google People API v1 Person resource fields
    "resource_name" TEXT UNIQUE NOT NULL,
    "etag" TEXT,
    "google_metadata" JSONB NOT NULL DEFAULT '{}'::jsonb,
    "names" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "nicknames" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "photos" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "phone_numbers" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "email_addresses" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "addresses" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "organizations" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "biographies" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "relations" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "events" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "birthdays" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "urls" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "memberships" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "user_defined" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "client_data" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "raw_person" JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Fast Indexed Display & Normalized Phone Lookup Columns
    "display_name" TEXT NOT NULL DEFAULT 'Unnamed Contact',
    "given_name" TEXT,
    "family_name" TEXT,
    "company_name" TEXT,
    "job_title" TEXT,
    "primary_phone" TEXT,
    "primary_email" TEXT,
    "photo_url" TEXT,
    "notes_text" TEXT,
    "group_labels" TEXT[] NOT NULL DEFAULT '{}'::text[],
    "phone_norms" TEXT[] NOT NULL DEFAULT '{}'::text[],

    -- ERP M:N Group & Party Links (stored inline to avoid extra junction tables)
    "linked_group_codes" TEXT[] NOT NULL DEFAULT '{}'::text[],
    "linked_master_codes" TEXT[] NOT NULL DEFAULT '{}'::text[],
    "erp_links" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "is_starred" BOOLEAN NOT NULL DEFAULT false,
    "is_archived" BOOLEAN NOT NULL DEFAULT false,

    -- Two-Way Sync Lifecycle Columns
    "sync_status" TEXT NOT NULL DEFAULT 'SYNCED'
        CHECK ("sync_status" IN ('SYNCED', 'PENDING_PUSH', 'CONFLICT', 'LOCAL_ONLY', 'DELETED_ON_GOOGLE')),
    "dirty_fields" TEXT[] NOT NULL DEFAULT '{}'::text[],
    "import_source" TEXT NOT NULL DEFAULT 'GOOGLE_API'
        CHECK ("import_source" IN ('GOOGLE_API', 'GOOGLE_CSV', 'ERP_MANUAL')),
    "last_synced_at" TIMESTAMPTZ DEFAULT NOW(),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. B-Tree & GIN Indexes for 7,000+ Contact Queries & <0.5ms Phone Lookups
CREATE INDEX IF NOT EXISTS "idx_sb_contacts_display_name"
    ON "IMMBE2627"."sb_contacts" ("display_name");

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_display_name_lower"
    ON "IMMBE2627"."sb_contacts" (LOWER("display_name"));

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_company_name"
    ON "IMMBE2627"."sb_contacts" ("company_name");

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_primary_phone"
    ON "IMMBE2627"."sb_contacts" ("primary_phone");

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_sync_status"
    ON "IMMBE2627"."sb_contacts" ("sync_status");

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_phone_norms_gin"
    ON "IMMBE2627"."sb_contacts" USING GIN ("phone_norms");

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_linked_groups_gin"
    ON "IMMBE2627"."sb_contacts" USING GIN ("linked_group_codes");

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_linked_masters_gin"
    ON "IMMBE2627"."sb_contacts" USING GIN ("linked_master_codes");

CREATE INDEX IF NOT EXISTS "idx_sb_contacts_group_labels_gin"
    ON "IMMBE2627"."sb_contacts" USING GIN ("group_labels");

-- 4. High-Throughput Atomic Batch Upsert RPC (60s statement_timeout)
CREATE OR REPLACE FUNCTION "IMMBE2627"."fn_upsert_google_contacts_batch"(
    p_rows JSONB,
    p_account_email TEXT DEFAULT 'design.ambaji@gmail.com',
    p_import_source TEXT DEFAULT 'GOOGLE_API'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = "IMMBE2627", public
SET statement_timeout = '60s'
AS $$
DECLARE
    v_account_email TEXT := COALESCE(NULLIF(TRIM(p_account_email), ''), 'design.ambaji@gmail.com');
    v_source TEXT := CASE
        WHEN p_import_source IN ('GOOGLE_API', 'GOOGLE_CSV', 'ERP_MANUAL') THEN p_import_source
        ELSE 'GOOGLE_API'
    END;
    v_deleted INT := 0;
    v_upserted INT := 0;
    v_total INT := 0;
BEGIN
    IF p_rows IS NULL OR jsonb_typeof(p_rows) <> 'array' OR jsonb_array_length(p_rows) = 0 THEN
        SELECT COUNT(*)::int INTO v_total
        FROM "IMMBE2627"."sb_contacts"
        WHERE "google_account_email" = v_account_email
          AND "sync_status" <> 'DELETED_ON_GOOGLE';

        RETURN jsonb_build_object('upserted', 0, 'deleted', 0, 'total_active', v_total);
    END IF;

    INSERT INTO "IMMBE2627"."sb_google_sync_state" ("email")
    VALUES (v_account_email)
    ON CONFLICT ("email") DO NOTHING;

    WITH deleted_keys AS (
        SELECT DISTINCT (elem->>'resource_name') AS resource_name
        FROM jsonb_array_elements(p_rows) AS elem
        WHERE COALESCE(elem->>'resource_name', '') <> ''
          AND COALESCE(
              (elem->'google_metadata'->>'deleted')::boolean,
              (elem->'raw_person'->'metadata'->>'deleted')::boolean,
              false
          ) = true
    ),
    updated_deleted AS (
        UPDATE "IMMBE2627"."sb_contacts" c
        SET
            "sync_status" = 'DELETED_ON_GOOGLE',
            "is_archived" = true,
            "last_synced_at" = NOW(),
            "updated_at" = NOW()
        FROM deleted_keys d
        WHERE c."resource_name" = d.resource_name
        RETURNING 1
    )
    SELECT COUNT(*)::int INTO v_deleted FROM updated_deleted;

    WITH deduped AS (
        SELECT DISTINCT ON (elem->>'resource_name')
            elem
        FROM jsonb_array_elements(p_rows) AS elem
        WHERE COALESCE(elem->>'resource_name', '') <> ''
          AND COALESCE(
              (elem->'google_metadata'->>'deleted')::boolean,
              (elem->'raw_person'->'metadata'->>'deleted')::boolean,
              false
          ) = false
        ORDER BY (elem->>'resource_name'), COALESCE(elem->>'etag', '') DESC
    ),
    upserted_rows AS (
        INSERT INTO "IMMBE2627"."sb_contacts" (
            "google_account_email",
            "resource_name",
            "etag",
            "google_metadata",
            "names",
            "nicknames",
            "photos",
            "phone_numbers",
            "email_addresses",
            "addresses",
            "organizations",
            "biographies",
            "relations",
            "events",
            "birthdays",
            "urls",
            "memberships",
            "user_defined",
            "client_data",
            "raw_person",
            "display_name",
            "given_name",
            "family_name",
            "company_name",
            "job_title",
            "primary_phone",
            "primary_email",
            "photo_url",
            "notes_text",
            "group_labels",
            "phone_norms",
            "linked_group_codes",
            "linked_master_codes",
            "erp_links",
            "is_starred",
            "is_archived",
            "sync_status",
            "import_source",
            "last_synced_at",
            "updated_at"
        )
        SELECT
            v_account_email,
            elem->>'resource_name',
            NULLIF(elem->>'etag', ''),
            COALESCE(CASE WHEN jsonb_typeof(elem->'google_metadata') = 'object' THEN elem->'google_metadata' END, '{}'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'names') = 'array' THEN elem->'names' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'nicknames') = 'array' THEN elem->'nicknames' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'photos') = 'array' THEN elem->'photos' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'phone_numbers') = 'array' THEN elem->'phone_numbers' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'email_addresses') = 'array' THEN elem->'email_addresses' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'addresses') = 'array' THEN elem->'addresses' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'organizations') = 'array' THEN elem->'organizations' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'biographies') = 'array' THEN elem->'biographies' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'relations') = 'array' THEN elem->'relations' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'events') = 'array' THEN elem->'events' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'birthdays') = 'array' THEN elem->'birthdays' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'urls') = 'array' THEN elem->'urls' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'memberships') = 'array' THEN elem->'memberships' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'user_defined') = 'array' THEN elem->'user_defined' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'client_data') = 'array' THEN elem->'client_data' END, '[]'::jsonb),
            COALESCE(CASE WHEN jsonb_typeof(elem->'raw_person') = 'object' THEN elem->'raw_person' END, '{}'::jsonb),
            COALESCE(NULLIF(TRIM(elem->>'display_name'), ''), 'Unnamed Contact'),
            NULLIF(TRIM(elem->>'given_name'), ''),
            NULLIF(TRIM(elem->>'family_name'), ''),
            NULLIF(TRIM(elem->>'company_name'), ''),
            NULLIF(TRIM(elem->>'job_title'), ''),
            NULLIF(TRIM(elem->>'primary_phone'), ''),
            NULLIF(TRIM(elem->>'primary_email'), ''),
            NULLIF(TRIM(elem->>'photo_url'), ''),
            NULLIF(elem->>'notes_text', ''),
            CASE
                WHEN jsonb_typeof(elem->'group_labels') = 'array'
                THEN ARRAY(SELECT DISTINCT v FROM jsonb_array_elements_text(elem->'group_labels') AS t(v) WHERE v IS NOT NULL AND v <> '')
                ELSE '{}'::text[]
            END,
            CASE
                WHEN jsonb_typeof(elem->'phone_norms') = 'array'
                THEN ARRAY(SELECT DISTINCT v FROM jsonb_array_elements_text(elem->'phone_norms') AS t(v) WHERE v IS NOT NULL AND v <> '')
                ELSE '{}'::text[]
            END,
            CASE
                WHEN jsonb_typeof(elem->'linked_group_codes') = 'array'
                THEN ARRAY(SELECT DISTINCT v FROM jsonb_array_elements_text(elem->'linked_group_codes') AS t(v) WHERE v IS NOT NULL AND v <> '')
                ELSE '{}'::text[]
            END,
            CASE
                WHEN jsonb_typeof(elem->'linked_master_codes') = 'array'
                THEN ARRAY(SELECT DISTINCT v FROM jsonb_array_elements_text(elem->'linked_master_codes') AS t(v) WHERE v IS NOT NULL AND v <> '')
                ELSE '{}'::text[]
            END,
            COALESCE(CASE WHEN jsonb_typeof(elem->'erp_links') = 'array' THEN elem->'erp_links' END, '[]'::jsonb),
            COALESCE((elem->>'is_starred')::boolean, false),
            COALESCE((elem->>'is_archived')::boolean, false),
            'SYNCED',
            v_source,
            NOW(),
            NOW()
        FROM deduped
        ON CONFLICT ("resource_name") DO UPDATE SET
            "google_account_email" = EXCLUDED."google_account_email",
            "etag" = COALESCE(EXCLUDED."etag", "sb_contacts"."etag"),
            "google_metadata" = CASE WHEN EXCLUDED."google_metadata" <> '{}'::jsonb THEN EXCLUDED."google_metadata" ELSE "sb_contacts"."google_metadata" END,
            "names" = CASE WHEN EXCLUDED."names" <> '[]'::jsonb THEN EXCLUDED."names" ELSE "sb_contacts"."names" END,
            "nicknames" = CASE WHEN EXCLUDED."nicknames" <> '[]'::jsonb THEN EXCLUDED."nicknames" ELSE "sb_contacts"."nicknames" END,
            "photos" = CASE WHEN EXCLUDED."photos" <> '[]'::jsonb THEN EXCLUDED."photos" ELSE "sb_contacts"."photos" END,
            "phone_numbers" = EXCLUDED."phone_numbers",
            "email_addresses" = EXCLUDED."email_addresses",
            "addresses" = EXCLUDED."addresses",
            "organizations" = EXCLUDED."organizations",
            "biographies" = EXCLUDED."biographies",
            "relations" = EXCLUDED."relations",
            "events" = EXCLUDED."events",
            "birthdays" = EXCLUDED."birthdays",
            "urls" = EXCLUDED."urls",
            "memberships" = EXCLUDED."memberships",
            "user_defined" = EXCLUDED."user_defined",
            "client_data" = EXCLUDED."client_data",
            "raw_person" = CASE WHEN EXCLUDED."raw_person" <> '{}'::jsonb THEN EXCLUDED."raw_person" ELSE "sb_contacts"."raw_person" END,
            "display_name" = EXCLUDED."display_name",
            "given_name" = EXCLUDED."given_name",
            "family_name" = EXCLUDED."family_name",
            "company_name" = EXCLUDED."company_name",
            "job_title" = EXCLUDED."job_title",
            "primary_phone" = COALESCE(EXCLUDED."primary_phone", "sb_contacts"."primary_phone"),
            "primary_email" = COALESCE(EXCLUDED."primary_email", "sb_contacts"."primary_email"),
            "photo_url" = COALESCE(EXCLUDED."photo_url", "sb_contacts"."photo_url"),
            "notes_text" = COALESCE(EXCLUDED."notes_text", "sb_contacts"."notes_text"),
            "group_labels" = EXCLUDED."group_labels",
            "phone_norms" = EXCLUDED."phone_norms",
            "linked_group_codes" = CASE
                WHEN COALESCE(array_length("sb_contacts"."linked_group_codes", 1), 0) > 0
                THEN "sb_contacts"."linked_group_codes"
                ELSE EXCLUDED."linked_group_codes"
            END,
            "linked_master_codes" = CASE
                WHEN COALESCE(array_length("sb_contacts"."linked_master_codes", 1), 0) > 0
                THEN "sb_contacts"."linked_master_codes"
                ELSE EXCLUDED."linked_master_codes"
            END,
            "erp_links" = CASE
                WHEN jsonb_array_length("sb_contacts"."erp_links") > 0
                THEN "sb_contacts"."erp_links"
                ELSE EXCLUDED."erp_links"
            END,
            "is_starred" = ("sb_contacts"."is_starred" OR EXCLUDED."is_starred"),
            "is_archived" = false,
            "sync_status" = CASE
                WHEN "sb_contacts"."sync_status" = 'PENDING_PUSH' THEN 'PENDING_PUSH'
                ELSE 'SYNCED'
            END,
            "import_source" = CASE
                WHEN "sb_contacts"."import_source" = 'GOOGLE_API' AND EXCLUDED."import_source" = 'GOOGLE_CSV'
                THEN 'GOOGLE_API'
                ELSE EXCLUDED."import_source"
            END,
            "last_synced_at" = NOW(),
            "updated_at" = NOW()
        RETURNING 1
    )
    SELECT COUNT(*)::int INTO v_upserted FROM upserted_rows;

    SELECT COUNT(*)::int INTO v_total
    FROM "IMMBE2627"."sb_contacts"
    WHERE "google_account_email" = v_account_email
      AND "sync_status" <> 'DELETED_ON_GOOGLE';

    UPDATE "IMMBE2627"."sb_google_sync_state"
    SET
        "total_google_contacts" = v_total,
        "updated_at" = NOW()
    WHERE "email" = v_account_email;

    RETURN jsonb_build_object(
        'upserted', v_upserted,
        'deleted', v_deleted,
        'total_active', v_total
    );
END;
$$;

-- 5. Row Level Security, Grants & PostgREST Schema Reload
ALTER TABLE "IMMBE2627"."sb_google_sync_state" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "IMMBE2627"."sb_contacts" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "sb_google_sync_state_all_authenticated" ON "IMMBE2627"."sb_google_sync_state";
CREATE POLICY "sb_google_sync_state_all_authenticated"
    ON "IMMBE2627"."sb_google_sync_state"
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "sb_contacts_all_authenticated" ON "IMMBE2627"."sb_contacts";
CREATE POLICY "sb_contacts_all_authenticated"
    ON "IMMBE2627"."sb_contacts"
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON "IMMBE2627"."sb_google_sync_state" TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON "IMMBE2627"."sb_contacts" TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION "IMMBE2627"."fn_upsert_google_contacts_batch"(JSONB, TEXT, TEXT) TO authenticated, service_role;

NOTIFY pgrst, 'reload schema';
