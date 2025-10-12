-- Create social_comments table in signals schema
-- This table stores social media comments from various platforms

CREATE TABLE IF NOT EXISTS signals.social_comments (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id),
    platform TEXT NOT NULL,
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
    sentiment_score DECIMAL(3,2),
    sentiment_label TEXT,
    language_code TEXT,
    raw_content JSONB DEFAULT '{}'::jsonb,
    raw_metadata JSONB DEFAULT '{}'::jsonb,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    intake_method TEXT,
    intake_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_social_comments_brand_id ON signals.social_comments(brand_id);
CREATE INDEX IF NOT EXISTS idx_social_comments_platform ON signals.social_comments(platform);
CREATE INDEX IF NOT EXISTS idx_social_comments_post_id ON signals.social_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_social_comments_comment_timestamp ON signals.social_comments(comment_timestamp);
CREATE INDEX IF NOT EXISTS idx_social_comments_author_username ON signals.social_comments(author_username);
CREATE INDEX IF NOT EXISTS idx_social_comments_sentiment_score ON signals.social_comments(sentiment_score);
CREATE INDEX IF NOT EXISTS idx_social_comments_like_count ON signals.social_comments(like_count);

-- Add comments for documentation
COMMENT ON TABLE signals.social_comments IS 'Social media comments from various platforms (TikTok, Instagram, etc.)';
COMMENT ON COLUMN signals.social_comments.signal_id IS 'Unique identifier for each comment';
COMMENT ON COLUMN signals.social_comments.brand_id IS 'Reference to the brand this comment relates to';
COMMENT ON COLUMN signals.social_comments.platform IS 'Social media platform (tiktok, instagram, facebook, etc.)';
COMMENT ON COLUMN signals.social_comments.post_id IS 'ID of the post this comment is on';
COMMENT ON COLUMN signals.social_comments.comment_id IS 'Unique ID of the comment';
COMMENT ON COLUMN signals.social_comments.comment_text IS 'The actual comment text';
COMMENT ON COLUMN signals.social_comments.author_username IS 'Username of the comment author';
COMMENT ON COLUMN signals.social_comments.author_followers_count IS 'Number of followers the author has';
COMMENT ON COLUMN signals.social_comments.sentiment_score IS 'AI-generated sentiment score (-1 to 1)';
COMMENT ON COLUMN signals.social_comments.sentiment_label IS 'AI-generated sentiment label (positive, negative, neutral)';
