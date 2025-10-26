-- ============================================================================
-- ADD processed_by_agents COLUMN
-- ============================================================================
-- This migration adds tracking for posts processed by the quantum agent system
-- ============================================================================

-- Add column to track processed posts
ALTER TABLE social_media.social_posts
ADD COLUMN IF NOT EXISTS processed_by_agents BOOLEAN DEFAULT FALSE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_social_posts_processed 
ON social_media.social_posts(processed_by_agents);

-- Create index for filtering unprocessed posts
CREATE INDEX IF NOT EXISTS idx_social_posts_unprocessed 
ON social_media.social_posts(created_at) 
WHERE processed_by_agents IS NULL OR processed_by_agents = FALSE;

-- Add comment explaining the column
COMMENT ON COLUMN social_media.social_posts.processed_by_agents IS 
'Flag indicating whether this post has been processed by the quantum agent system. Set to true after running through observation, adjustment, and content generation agents.';

-- Verify the column was added
SELECT 
  column_name, 
  data_type, 
  column_default
FROM information_schema.columns
WHERE table_schema = 'social_media'
  AND table_name = 'social_posts'
  AND column_name = 'processed_by_agents';
