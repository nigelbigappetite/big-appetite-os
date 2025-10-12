-- Create separate social media tables for better organization
-- This approach allows platform-specific fields and cleaner schema

-- TikTok Comments Table
CREATE TABLE IF NOT EXISTS signals.tiktok_comments (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id),
    video_id TEXT NOT NULL,
    comment_id TEXT NOT NULL,
    comment_text TEXT NOT NULL,
    author_username TEXT,
    author_display_name TEXT,
    author_followers_count INTEGER,
    author_verified BOOLEAN DEFAULT FALSE,
    comment_timestamp TIMESTAMP WITH TIME ZONE,
    like_count INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0,
    is_reply BOOLEAN DEFAULT FALSE,
    parent_comment_id TEXT,
    video_url TEXT,
    video_caption TEXT,
    video_like_count INTEGER,
    video_comment_count INTEGER,
    video_view_count INTEGER,
    video_timestamp TIMESTAMP WITH TIME ZONE,
    hashtags TEXT[],
    mentions TEXT[],
    language_code TEXT,
    raw_content JSONB DEFAULT '{}'::jsonb,
    raw_metadata JSONB DEFAULT '{}'::jsonb,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    intake_method TEXT,
    intake_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Instagram Comments Table
CREATE TABLE IF NOT EXISTS signals.instagram_comments (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id),
    post_id TEXT NOT NULL,
    comment_id TEXT NOT NULL,
    comment_text TEXT NOT NULL,
    author_username TEXT,
    author_display_name TEXT,
    author_followers_count INTEGER,
    author_verified BOOLEAN DEFAULT FALSE,
    comment_timestamp TIMESTAMP WITH TIME ZONE,
    like_count INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0,
    is_reply BOOLEAN DEFAULT FALSE,
    parent_comment_id TEXT,
    post_url TEXT,
    post_caption TEXT,
    post_like_count INTEGER,
    post_comment_count INTEGER,
    post_view_count INTEGER,
    post_timestamp TIMESTAMP WITH TIME ZONE,
    hashtags TEXT[],
    mentions TEXT[],
    language_code TEXT,
    raw_content JSONB DEFAULT '{}'::jsonb,
    raw_metadata JSONB DEFAULT '{}'::jsonb,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    intake_method TEXT,
    intake_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_tiktok_comments_brand_id ON signals.tiktok_comments(brand_id);
CREATE INDEX IF NOT EXISTS idx_tiktok_comments_video_id ON signals.tiktok_comments(video_id);
CREATE INDEX IF NOT EXISTS idx_tiktok_comments_author_username ON signals.tiktok_comments(author_username);
CREATE INDEX IF NOT EXISTS idx_tiktok_comments_comment_timestamp ON signals.tiktok_comments(comment_timestamp);

CREATE INDEX IF NOT EXISTS idx_instagram_comments_brand_id ON signals.instagram_comments(brand_id);
CREATE INDEX IF NOT EXISTS idx_instagram_comments_post_id ON signals.instagram_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_instagram_comments_author_username ON signals.instagram_comments(author_username);
CREATE INDEX IF NOT EXISTS idx_instagram_comments_comment_timestamp ON signals.instagram_comments(comment_timestamp);

-- Add comments for documentation
COMMENT ON TABLE signals.tiktok_comments IS 'TikTok comments from Wing Shack videos';
COMMENT ON TABLE signals.instagram_comments IS 'Instagram comments from Wing Shack posts';
