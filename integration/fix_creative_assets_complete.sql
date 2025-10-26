-- Complete fix for creative_assets table - Add ALL required columns
-- Run this in Supabase SQL Editor

-- Check current structure
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'creative_assets'
ORDER BY ordinal_position;

-- Add all missing columns
-- Don't add id - table already has a primary key (asset_id)

ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS brand_id UUID REFERENCES core.brands(brand_id);

ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS copy_id UUID;

ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS media_url TEXT;

ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS creative_type TEXT DEFAULT 'instagram_post';

ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS generation_prompt TEXT;

ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update the public view
DROP VIEW IF EXISTS public.creative_assets;
CREATE VIEW public.creative_assets AS SELECT * FROM content_generation.creative_assets;

-- Grant permissions
GRANT ALL ON public.creative_assets TO anon, authenticated, service_role;

-- Verify all required columns exist
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'creative_assets'
  AND column_name IN ('id', 'brand_id', 'copy_id', 'media_url', 'creative_type', 'generation_prompt', 'created_at')
ORDER BY column_name;

-- Final structure check
SELECT 
  column_name, 
  data_type,
  column_default
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'creative_assets'
ORDER BY ordinal_position;
