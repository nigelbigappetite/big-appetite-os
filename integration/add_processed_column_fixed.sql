-- Add column to BOTH the actual table AND the public view

-- Add to actual table in social_media schema
ALTER TABLE IF EXISTS social_media.social_posts
ADD COLUMN IF NOT EXISTS processed_by_agents BOOLEAN DEFAULT FALSE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_social_posts_processed 
ON social_media.social_posts(processed_by_agents);

-- Create index for filtering unprocessed posts
CREATE INDEX IF NOT EXISTS idx_social_posts_unprocessed 
ON social_media.social_posts(created_at) 
WHERE processed_by_agents IS NULL OR processed_by_agents = FALSE;

-- Add comment
COMMENT ON COLUMN social_media.social_posts.processed_by_agents IS 
'Flag indicating whether this post has been processed by the quantum agent system.';

-- IMPORTANT: Also update the public view to include this column
DROP VIEW IF EXISTS public.social_posts;
CREATE VIEW public.social_posts AS SELECT * FROM social_media.social_posts;
GRANT ALL ON public.social_posts TO anon, authenticated, service_role;

-- Verify
SELECT 
  column_name, 
  data_type, 
  column_default
FROM information_schema.columns
WHERE table_schema IN ('social_media', 'public')
  AND table_name = 'social_posts'
  AND column_name = 'processed_by_agents';
