-- Add missing columns to clustering_runs table
-- Run this in Supabase SQL Editor

ALTER TABLE clustering_runs 
ADD COLUMN IF NOT EXISTS calinski_harabasz_score FLOAT;

ALTER TABLE clustering_runs 
ADD COLUMN IF NOT EXISTS davies_bouldin_score FLOAT;

ALTER TABLE clustering_runs 
ADD COLUMN IF NOT EXISTS validation_metrics JSONB;

ALTER TABLE clustering_runs 
ADD COLUMN IF NOT EXISTS created_by TEXT DEFAULT 'system';

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Missing columns added to clustering_runs table successfully!';
END $$;
