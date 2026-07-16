-- Create table sb_media inside schema IMMBE2627
CREATE TABLE IF NOT EXISTS "IMMBE2627"."sb_media" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- File Identity
    file_path TEXT NOT NULL,
    file_name TEXT NOT NULL,
    display_name TEXT,
    file_size BIGINT NOT NULL DEFAULT 0,
    mime_type TEXT NOT NULL,
    width INT,
    height INT,
    
    -- Categorization
    bucket TEXT NOT NULL DEFAULT 'general',
    media_type TEXT,
    tags TEXT[] DEFAULT '{}',
    
    -- Entity Linkage
    entity_type TEXT,
    entity_id TEXT,
    entity_label TEXT,
    is_linked BOOLEAN DEFAULT FALSE,
    
    -- Thumbnails & Optimization
    thumb_path TEXT,
    compressed_path TEXT,
    
    -- Audit (References to auth schema)
    uploaded_by UUID REFERENCES auth.users(id),
    uploader_name TEXT,
    linked_by UUID REFERENCES auth.users(id),
    linked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Soft delete
    is_archived BOOLEAN DEFAULT FALSE,
    archived_at TIMESTAMPTZ
);

-- Create indexes for performant lookups
CREATE INDEX IF NOT EXISTS idx_sb_media_bucket ON "IMMBE2627".sb_media(bucket);
CREATE INDEX IF NOT EXISTS idx_sb_media_entity ON "IMMBE2627".sb_media(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_sb_media_linked ON "IMMBE2627".sb_media(is_linked);
CREATE INDEX IF NOT EXISTS idx_sb_media_type ON "IMMBE2627".sb_media(media_type);
CREATE INDEX IF NOT EXISTS idx_sb_media_tags ON "IMMBE2627".sb_media USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_sb_media_created ON "IMMBE2627".sb_media(created_at DESC);

-- Enable Row-Level Security
ALTER TABLE "IMMBE2627"."sb_media" ENABLE ROW LEVEL SECURITY;

-- Select policy: All authenticated users can read metadata
CREATE POLICY "Team can read all media" ON "IMMBE2627"."sb_media"
    FOR SELECT USING (auth.role() = 'authenticated');

-- Insert policy: All authenticated users can insert records
CREATE POLICY "Team can insert media" ON "IMMBE2627"."sb_media"
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Update policy: All authenticated users can update records
CREATE POLICY "Team can update media" ON "IMMBE2627"."sb_media"
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Delete policy: Only the uploader can delete their own metadata
CREATE POLICY "Uploader can delete own media" ON "IMMBE2627"."sb_media"
    FOR DELETE USING (uploaded_by = auth.uid());
