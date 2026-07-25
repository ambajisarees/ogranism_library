-- Schema Definition for Google Contacts & Master Party Linker Engine
-- Target Schema: IMMBE2627

CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_google_contacts" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "google_resource_name" TEXT UNIQUE NOT NULL,
    "etag" TEXT,
    "master_code" TEXT, -- Logical link to sq_MASTER.code (Strictly Read-Only Mirror)
    "display_name" TEXT NOT NULL,
    "given_name" TEXT,
    "family_name" TEXT,
    "company_name" TEXT,
    "job_title" TEXT,
    "photo_url" TEXT, -- Contact avatar picture from Google
    "phone_numbers" JSONB DEFAULT '[]'::jsonb, -- Array of [{ "number": "+91...", "type": "mobile", "canonical": "+9198251..." }]
    "primary_phone" TEXT,
    "emails" JSONB DEFAULT '[]'::jsonb,
    "addresses" JSONB DEFAULT '[]'::jsonb, -- Postal addresses from Google
    "user_defined_fields" JSONB DEFAULT '[]'::jsonb, -- Google custom key-value pairs
    "group_memberships" JSONB DEFAULT '[]'::jsonb, -- Google Contact groups / label tags
    "notes" TEXT, -- Google Biographies / Notes
    "raw_data" JSONB, -- 100% COMPLETE UNALTERED RAW GOOGLE PEOPLE API JSON PAYLOAD
    "sync_status" TEXT DEFAULT 'synced', -- 'synced', 'pending_push', 'pending_pull', 'unlinked'
    "last_synced_at" TIMESTAMPTZ DEFAULT NOW(),
    "created_at" TIMESTAMPTZ DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ DEFAULT NOW()
);

-- Index primary phone for fast phone lookup in CRM & WhatsApp flow
CREATE INDEX IF NOT EXISTS "idx_sb_google_contacts_primary_phone" 
ON "IMMBE2627"."sb_google_contacts" ("primary_phone");

-- Index master_code for 1-to-N lookup (Master Org -> N Contacts)
CREATE INDEX IF NOT EXISTS "idx_sb_google_contacts_master_code" 
ON "IMMBE2627"."sb_google_contacts" ("master_code");

-- Lookup View: vw_sb_people_linker
-- Joins Google Contacts with sq_MASTER for party intelligence
CREATE OR REPLACE VIEW "IMMBE2627"."vw_sb_people_linker" AS
SELECT 
    c."id",
    c."google_resource_name",
    c."etag",
    c."master_code",
    c."display_name",
    c."given_name",
    c."family_name",
    c."company_name",
    c."job_title",
    c."photo_url",
    c."phone_numbers",
    c."primary_phone",
    c."emails",
    c."addresses",
    c."user_defined_fields",
    c."group_memberships",
    c."notes",
    c."raw_data",
    c."sync_status",
    c."last_synced_at",
    c."created_at",
    c."updated_at",
    m."NAME" AS "master_name",
    m."CITY1" AS "master_city",
    m."STATION" AS "master_station",
    m."MOBILE" AS "master_mobile",
    m."GCODE" AS "master_gcode",
    m."ADATIYA" AS "master_adatiya",
    m."crdays" AS "master_crdays",
    m."FLASH_RMK" AS "master_flash_rmk"
FROM "IMMBE2627"."sb_google_contacts" c
LEFT JOIN "IMMBE2627"."sq_MASTER" m ON c."master_code" = m."code";

-- Authentication Storage Table for Google OAuth Refresh Tokens
CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_google_auth" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "email" TEXT UNIQUE NOT NULL,
    "refresh_token" TEXT NOT NULL,
    "access_token" TEXT,
    "expires_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ DEFAULT NOW()
);
