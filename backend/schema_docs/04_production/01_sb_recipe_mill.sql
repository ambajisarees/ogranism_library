-- SQL Schema for Mill Printing Job Work Recipes & Extension Masters
-- Target Schema: IMMBE2627

-- 1. Sidecar Table: Party Master Extension (for Mill capabilities & metadata)
CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_master_ext" (
  party_code VARCHAR PRIMARY KEY, -- Maps to sq_MASTER.code
  short_alias VARCHAR,
  is_active_mill BOOLEAN DEFAULT TRUE,
  mill_type VARCHAR DEFAULT 'PRINTING', -- PRINTING, DYEING, PROCESSING
  print_capabilities TEXT[],           -- Supported print types
  remarks TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Sidecar Table: Quality/Fabric Master Extension
CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_qual_ext" (
  qual_code VARCHAR PRIMARY KEY, -- Maps to sq_QUAL.qcode
  fabric_category VARCHAR,       -- Saree, Dupatta, Dress Material, etc.
  gsm NUMERIC(6, 2),
  standard_width_inch NUMERIC(5, 2),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Core Table: Mill Printing Recipes (sb_recipe_mill)
CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_recipe_mill" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mill_code VARCHAR NOT NULL,
  mill_name VARCHAR NOT NULL,
  fabric_code VARCHAR NOT NULL,
  fabric_name VARCHAR NOT NULL,
  print_type VARCHAR NOT NULL,   -- e.g. Overprint, Padding, Discharge, Pigment, Reactive, Direct, Digital
  value_type VARCHAR NOT NULL,   -- e.g. Ink, Smoke, Zari, Foil, Table Print, Machine Print, Brass, Duster
  rate NUMERIC(10, 2) NOT NULL CHECK (rate >= 0),
  effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
  is_active BOOLEAN DEFAULT TRUE,
  remarks TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by VARCHAR DEFAULT 'system'
);

-- 4. Indexes for Rapid Search & Filtering
CREATE INDEX IF NOT EXISTS idx_sb_recipe_mill_lookup 
  ON "IMMBE2627"."sb_recipe_mill" (mill_code, fabric_code, effective_date DESC);

CREATE INDEX IF NOT EXISTS idx_sb_recipe_mill_types 
  ON "IMMBE2627"."sb_recipe_mill" (print_type, value_type);

CREATE INDEX IF NOT EXISTS idx_sb_recipe_mill_active 
  ON "IMMBE2627"."sb_recipe_mill" (is_active, effective_date DESC);

-- 5. RLS Policies
ALTER TABLE "IMMBE2627"."sb_recipe_mill" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "IMMBE2627"."sb_master_ext" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "IMMBE2627"."sb_qual_ext" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable full access for authenticated users" 
  ON "IMMBE2627"."sb_recipe_mill" FOR ALL USING (true);

CREATE POLICY "Enable full access for authenticated users" 
  ON "IMMBE2627"."sb_master_ext" FOR ALL USING (true);

CREATE POLICY "Enable full access for authenticated users" 
  ON "IMMBE2627"."sb_qual_ext" FOR ALL USING (true);

-- 6. Aggregate View: Latest Effective Rates per Mill & Fabric
CREATE OR REPLACE VIEW "IMMBE2627"."vw_recipe_mill_latest" AS
SELECT DISTINCT ON (mill_code, fabric_code, print_type, value_type)
  id,
  mill_code,
  mill_name,
  fabric_code,
  fabric_name,
  print_type,
  value_type,
  rate,
  effective_date,
  is_active,
  remarks,
  created_at,
  updated_at
FROM "IMMBE2627"."sb_recipe_mill"
WHERE is_active = TRUE
ORDER BY mill_code, fabric_code, print_type, value_type, effective_date DESC;
