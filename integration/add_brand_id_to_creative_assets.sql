-- Add brand_id column to creative_assets table
-- Run this in Supabase SQL Editor

-- Check current structure first
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'creative_assets'
ORDER BY ordinal_position;

-- Add column to the actual table in content_generation schema
ALTER TABLE IF EXISTS content_generation.creative_assets
ADD COLUMN IF NOT EXISTS brand_id UUID REFERENCES core.brands(brand_id);

-- Update the public view to include this column
DROP VIEW IF EXISTS public.creative_assets;
CREATE VIEW public.creative_assets AS SELECT * FROM content_generation.creative_assets;

-- Grant permissions
GRANT ALL ON public.creative_assets TO anon, authenticated, service_role;

-- Create index for brand_id lookups
CREATE INDEX IF NOT EXISTS idx_creative_assets_brand_id 
ON content_generation.creative_assets(brand_id);

-- Verify the column was added
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'creative_assets'
  AND column_name = 'brand_id';
