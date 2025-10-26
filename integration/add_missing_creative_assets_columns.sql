-- Add all missing columns to creative_assets table
-- Run this in Supabase SQL Editor

-- Add creative_type column
ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS creative_type TEXT DEFAULT 'instagram_post';

-- Add generation_prompt column
ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS generation_prompt TEXT;

-- Add created_at column if missing
ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update the public view
DROP VIEW IF EXISTS public.creative_assets;
CREATE VIEW public.creative_assets AS SELECT * FROM content_generation.creative_assets;

-- Grant permissions
GRANT ALL ON public.creative_assets TO anon, authenticated, service_role;

-- Verify all columns exist
SELECT 
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'creative_assets'
ORDER BY ordinal_position;
