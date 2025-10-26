-- Add belief_alignment_tag column to copy_generator table
-- Run this in Supabase SQL Editor

-- Add column to the actual table in content_generation schema
ALTER TABLE IF EXISTS content_generation.copy_generator
ADD COLUMN IF NOT EXISTS belief_alignment_tag TEXT;

-- Update the public view to include this column
DROP VIEW IF EXISTS public.copy_generator;
CREATE VIEW public.copy_generator AS SELECT * FROM content_generation.copy_generator;

-- Grant permissions
GRANT ALL ON public.copy_generator TO anon, authenticated, service_role;

-- Verify
SELECT 
  column_name, 
  data_type
FROM information_schema.columns
WHERE table_schema IN ('content_generation', 'public')
  AND table_name = 'copy_generator'
  AND column_name = 'belief_alignment_tag';
