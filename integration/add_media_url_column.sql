-- Add media_url column to creative_assets
-- Run this in Supabase SQL Editor

ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS media_url TEXT;

-- Add copy_id column if missing
ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS copy_id UUID;

-- Update the public view
DROP VIEW IF EXISTS public.creative_assets;
CREATE VIEW public.creative_assets AS SELECT * FROM content_generation.creative_assets;

-- Grant permissions
GRANT ALL ON public.creative_assets TO anon, authenticated, service_role;

-- Verify
SELECT 
  column_name, 
  data_type
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'creative_assets'
  AND column_name IN ('media_url', 'copy_id', 'brand_id')
ORDER BY column_name;
