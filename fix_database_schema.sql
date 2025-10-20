-- Fix Database Schema for Real-time System
-- Add missing brand_id columns to enable proper agent functionality

-- Add brand_id to stimuli_feedback table
ALTER TABLE stimuli_feedback 
ADD COLUMN IF NOT EXISTS brand_id UUID;

-- Add brand_id to instagram_posts table  
ALTER TABLE instagram_posts
ADD COLUMN IF NOT EXISTS brand_id UUID;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_stimuli_feedback_brand_id ON stimuli_feedback(brand_id);
CREATE INDEX IF NOT EXISTS idx_instagram_posts_brand_id ON instagram_posts(brand_id);

-- Update existing records with default brand_id (replace with your actual brand_id)
-- UPDATE stimuli_feedback SET brand_id = 'a1b2c3d4-e5f6-7890-1234-567890abcdef' WHERE brand_id IS NULL;
-- UPDATE instagram_posts SET brand_id = 'a1b2c3d4-e5f6-7890-1234-567890abcdef' WHERE brand_id IS NULL;

-- Add constraints (optional - uncomment if you want to enforce brand_id)
-- ALTER TABLE stimuli_feedback ALTER COLUMN brand_id SET NOT NULL;
-- ALTER TABLE instagram_posts ALTER COLUMN brand_id SET NOT NULL;

-- Verify the changes
SELECT 'stimuli_feedback columns:' as table_name;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'stimuli_feedback' 
ORDER BY ordinal_position;

SELECT 'instagram_posts columns:' as table_name;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'instagram_posts' 
ORDER BY ordinal_position;
