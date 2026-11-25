-- ============================================================================
-- Schema Doc 09: Stage 11.2 Hybrid GSTIN Cache, Prospect Leads & Staged Parties
-- Target Schema: IMMBE2627 (Supabase PostgreSQL 17)
-- Migration Applied: create_and_seed_gstin_cache_prospects_and_parties
-- ============================================================================

-- 1. Hybrid GSTIN Lookup Cache (`sb_gstin_cache`)
-- Stores raw GSTN Taxpayer (TP) JSON payloads keyed by 15-digit GSTIN.
-- Hydrated upfront from sq_MASTER.GSTIN + sq_HASTE.EXCISEREG and extended
-- lazily as users verify new customers during onboarding.

CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_gstin_cache" (
  gstin VARCHAR(15) PRIMARY KEY,
  pan_number VARCHAR(10),
  gst_state_code CHAR(2),
  legal_name TEXT NOT NULL,
  trade_name TEXT NOT NULL,
  gst_status TEXT NOT NULL DEFAULT 'Active',
  taxpayer_type TEXT NOT NULL DEFAULT 'Regular',
  constitution_of_business TEXT NOT NULL DEFAULT 'Proprietorship',
  registration_date TEXT,
  principal_address TEXT,
  pincode VARCHAR(10),
  district_name TEXT,
  state_name TEXT,
  hsn_codes TEXT[] NOT NULL DEFAULT ARRAY['5407','5208','6204']::TEXT[],
  filing_regularity TEXT NOT NULL DEFAULT 'REGULAR_MONTHLY',
  raw_json JSONB NOT NULL DEFAULT '{}'::JSONB,
  source_provider TEXT NOT NULL DEFAULT 'ERP_LEGACY_SEED',
  fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Staged Human-Verified ERP Parties (`sb_parties`)
-- Normalized target party master replacing legacy sq_MASTER + sq_HASTE once
-- confirmed by internal staff via the GSTIN Lookup & Onboard dialog.

CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_parties" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  party_code TEXT UNIQUE NOT NULL,
  legacy_master_code TEXT,
  legacy_haste_name TEXT,
  party_role TEXT NOT NULL DEFAULT 'CUSTOMER',
  trade_name TEXT NOT NULL,
  legal_name TEXT,
  gstin VARCHAR(15),
  pan_number VARCHAR(10),
  gst_status TEXT NOT NULL DEFAULT 'Active',
  taxpayer_type TEXT NOT NULL DEFAULT 'Regular',
  constitution_of_business TEXT,
  contact_person TEXT,
  mobile TEXT,
  phone TEXT,
  email TEXT,
  address_line1 TEXT,
  address_line2 TEXT,
  city_name TEXT,
  pincode VARCHAR(10),
  district_name TEXT,
  state_name TEXT,
  gst_state_code CHAR(2),
  location_id UUID REFERENCES "IMMBE2627"."sb_geo_locations"(id) ON DELETE SET NULL,
  zone_code TEXT,
  adatiya_name TEXT,
  preferred_transport TEXT,
  nearest_station TEXT,
  distance_from_surat_km INTEGER,
  credit_days INTEGER NOT NULL DEFAULT 30,
  credit_limit NUMERIC(14,2) NOT NULL DEFAULT 0,
  msme_number TEXT,
  verification_status TEXT NOT NULL DEFAULT 'HUMAN_VERIFIED',
  verified_by TEXT NOT NULL DEFAULT 'ERP_TEAM',
  gstin_snapshot_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Textile Expansion Prospect Leads (`sb_prospect_leads`)
-- Keeps unconverted sq_HASTE shops, regional Kapda Mandi directories, MSME
-- Udyam NIC-46411/47510 entries, and Google Places leads cleanly isolated from
-- sb_parties until converted via 1-click GST verification.

CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_prospect_leads" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_key TEXT UNIQUE NOT NULL,
  shop_name TEXT NOT NULL,
  legal_name TEXT,
  source_channel TEXT NOT NULL DEFAULT 'HASTE_MINED',
  lead_status TEXT NOT NULL DEFAULT 'UNCONVERTED_HASTE',
  gstin VARCHAR(15),
  pan_number VARCHAR(10),
  mobile TEXT,
  whatsapp TEXT,
  contact_person TEXT,
  address TEXT,
  place_name TEXT NOT NULL,
  pincode VARCHAR(10),
  district_name TEXT,
  state_name TEXT,
  gst_state_code CHAR(2),
  location_id UUID REFERENCES "IMMBE2627"."sb_geo_locations"(id) ON DELETE SET NULL,
  zone_code TEXT,
  adatiya_name TEXT,
  preferred_transport TEXT,
  distance_from_surat_km INTEGER,
  specialization_tags TEXT[] NOT NULL DEFAULT ARRAY['Sarees','Dress Material']::TEXT[],
  priority_score INTEGER NOT NULL DEFAULT 50,
  promoted_party_id UUID REFERENCES "IMMBE2627"."sb_parties"(id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
