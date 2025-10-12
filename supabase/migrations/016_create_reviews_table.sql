-- Create reviews table in signals schema
-- This table stores customer reviews from various platforms

CREATE TABLE IF NOT EXISTS signals.reviews (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id),
    review_text TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_source TEXT NOT NULL,
    reviewer_name TEXT,
    review_timestamp TIMESTAMP WITH TIME ZONE,
    raw_content TEXT NOT NULL,
    raw_metadata JSONB DEFAULT '{}'::jsonb,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    intake_method TEXT,
    intake_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_reviews_brand_id ON signals.reviews(brand_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON signals.reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_review_source ON signals.reviews(review_source);
CREATE INDEX IF NOT EXISTS idx_reviews_review_timestamp ON signals.reviews(review_timestamp);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_name ON signals.reviews(reviewer_name);

-- Add comments for documentation
COMMENT ON TABLE signals.reviews IS 'Customer reviews from various platforms (Google, Trustpilot, etc.)';
COMMENT ON COLUMN signals.reviews.signal_id IS 'Unique identifier for each review';
COMMENT ON COLUMN signals.reviews.brand_id IS 'Reference to the brand this review belongs to';
COMMENT ON COLUMN signals.reviews.review_text IS 'The full text of the customer review';
COMMENT ON COLUMN signals.reviews.rating IS 'Star rating (1-5 scale)';
COMMENT ON COLUMN signals.reviews.review_source IS 'Platform where review was posted (google, trustpilot, etc.)';
COMMENT ON COLUMN signals.reviews.reviewer_name IS 'Name of the reviewer (if available)';
COMMENT ON COLUMN signals.reviews.review_timestamp IS 'When the review was posted';
COMMENT ON COLUMN signals.reviews.raw_content IS 'Complete review data as JSON';
COMMENT ON COLUMN signals.reviews.raw_metadata IS 'Additional metadata about the review';
COMMENT ON COLUMN signals.reviews.intake_method IS 'How this data was ingested (api, csv, scraping, etc.)';
COMMENT ON COLUMN signals.reviews.intake_metadata IS 'Metadata about the data ingestion process';
