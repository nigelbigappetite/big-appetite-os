-- Simple clustering tables for public schema
-- Run this in Supabase SQL Editor

-- Create cohorts table
CREATE TABLE IF NOT EXISTS cohorts (
    cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_name TEXT NOT NULL,
    cohort_description TEXT,
    driver_profile JSONB NOT NULL,
    characteristics JSONB NOT NULL,
    messaging_strategy JSONB,
    size INT NOT NULL,
    percentage FLOAT,
    cluster_algorithm TEXT,
    silhouette_score FLOAT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- Create clustering runs table
CREATE TABLE IF NOT EXISTS clustering_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    algorithm TEXT NOT NULL,
    parameters JSONB NOT NULL,
    n_actors INT NOT NULL,
    n_clusters INT NOT NULL,
    silhouette_score FLOAT,
    calinski_harabasz_score FLOAT,
    davies_bouldin_score FLOAT,
    feature_config JSONB NOT NULL,
    validation_metrics JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by TEXT DEFAULT 'system',
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- Create actor cohort assignments table
CREATE TABLE IF NOT EXISTS actor_cohort_assignments (
    actor_id UUID REFERENCES actor_profiles(actor_id) ON DELETE CASCADE,
    cohort_id UUID REFERENCES cohorts(cohort_id) ON DELETE CASCADE,
    assignment_confidence FLOAT,
    distance_to_center FLOAT,
    alternative_cohorts JSONB DEFAULT '[]'::jsonb,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assignment_method TEXT DEFAULT 'clustering',
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid,
    PRIMARY KEY (actor_id, cohort_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_cohorts_size ON cohorts(size DESC);
CREATE INDEX IF NOT EXISTS idx_actor_cohort_actor ON actor_cohort_assignments(actor_id);
CREATE INDEX IF NOT EXISTS idx_actor_cohort_cohort ON actor_cohort_assignments(cohort_id);
CREATE INDEX IF NOT EXISTS idx_clustering_runs_date ON clustering_runs(created_at DESC);

-- Grant permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Simple clustering tables created successfully in public schema!';
    RAISE NOTICE 'Tables: cohorts, clustering_runs, actor_cohort_assignments';
END $$;
