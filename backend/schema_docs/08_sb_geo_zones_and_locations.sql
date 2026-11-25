-- ============================================================================
-- Ambaji Sarees ERP: Stage 11.1 — All-India Geo Locations, Villages & Zone Map
-- Target Schema: IMMBE2627
-- Applied Migrations:
--   1. create_sb_geo_zones_and_locations
--   2. seed_sb_geo_zones_and_legacy_locations
-- ============================================================================

CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_geo_zones" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "zone_code" TEXT UNIQUE NOT NULL,
    "zone_name" TEXT NOT NULL,
    "parent_region" TEXT NOT NULL DEFAULT 'WEST'
        CHECK ("parent_region" IN ('WEST', 'CENTRAL', 'SOUTH', 'EAST', 'NORTH', 'LOCAL')),
    "state_name" TEXT,
    "gst_state_code" CHAR(2),
    "color_token" TEXT NOT NULL DEFAULT 'cyan'
        CHECK ("color_token" IN ('primary', 'emerald', 'cyan', 'indigo', 'orange', 'red', 'pink')),
    "center_lat" NUMERIC(9,6) NOT NULL DEFAULT 21.170200,
    "center_lng" NUMERIC(9,6) NOT NULL DEFAULT 72.831100,
    "boundary_points" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "default_transport_hub" TEXT,
    "default_transport" TEXT,
    "assigned_adatiya_codes" TEXT[] NOT NULL DEFAULT '{}'::text[],
    "active_locations_count" INT NOT NULL DEFAULT 0,
    "active_masters_count" INT NOT NULL DEFAULT 0,
    "active_haste_count" INT NOT NULL DEFAULT 0,
    "notes" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_geo_locations" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "location_key" TEXT UNIQUE NOT NULL,
    "pincode" VARCHAR(6),
    "place_name" TEXT NOT NULL,
    "clean_place_name" TEXT NOT NULL,
    "office_type" TEXT NOT NULL DEFAULT 'SO'
        CHECK ("office_type" IN ('HO', 'SO', 'BO', 'HUB', 'CITY')),
    "delivery_status" TEXT DEFAULT 'Delivery',
    "taluka" TEXT,
    "district" TEXT,
    "division_name" TEXT,
    "region_name" TEXT,
    "circle_name" TEXT,
    "state_name" TEXT NOT NULL DEFAULT 'MAHARASHTRA',
    "gst_state_code" CHAR(2) NOT NULL DEFAULT '27',
    "latitude" NUMERIC(9,6),
    "longitude" NUMERIC(9,6),
    "distance_from_surat_km" INT,
    "nearest_station" TEXT,
    "default_transport" TEXT,
    "zone_id" UUID REFERENCES "IMMBE2627"."sb_geo_zones"("id") ON DELETE SET NULL,
    "zone_code" TEXT,
    "legacy_city_aliases" TEXT[] NOT NULL DEFAULT '{}'::text[],
    "master_party_count" INT NOT NULL DEFAULT 0,
    "haste_party_count" INT NOT NULL DEFAULT 0,
    "top_adatiya_codes" TEXT[] NOT NULL DEFAULT '{}'::text[],
    "source_type" TEXT NOT NULL DEFAULT 'ERP_LEGACY_RECONCILED'
        CHECK ("source_type" IN ('INDIA_POST_OGD', 'INDIA_POST_API', 'ERP_LEGACY_RECONCILED', 'ERP_CUSTOM')),
    "is_verified_erp_market" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_pincode"
    ON "IMMBE2627"."sb_geo_locations" ("pincode");

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_clean_place"
    ON "IMMBE2627"."sb_geo_locations" (LOWER("clean_place_name") text_pattern_ops);

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_place"
    ON "IMMBE2627"."sb_geo_locations" (LOWER("place_name") text_pattern_ops);

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_district"
    ON "IMMBE2627"."sb_geo_locations" (LOWER("district"));

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_taluka"
    ON "IMMBE2627"."sb_geo_locations" (LOWER("taluka"));

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_zone_code"
    ON "IMMBE2627"."sb_geo_locations" ("zone_code");

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_erp_rank"
    ON "IMMBE2627"."sb_geo_locations" (("master_party_count" + "haste_party_count") DESC, "clean_place_name");

CREATE INDEX IF NOT EXISTS "idx_sb_geo_locations_aliases_gin"
    ON "IMMBE2627"."sb_geo_locations" USING GIN ("legacy_city_aliases");

-- RLS & RPCs (`fn_refresh_geo_zone_stats`, `fn_upsert_geo_locations_batch`)
-- live inside IMMBE2627 via migrations `create_sb_geo_zones_and_locations` and
-- `seed_sb_geo_zones_and_legacy_locations`.
