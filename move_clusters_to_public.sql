-- Move clustering tables to public schema
-- Run this in Supabase SQL Editor

-- Drop existing clusters schema if it exists
DROP SCHEMA IF EXISTS clusters CASCADE;

-- Create cohorts table in public schema
CREATE TABLE IF NOT EXISTS cohorts (
    cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_name TEXT NOT NULL,
    cohort_description TEXT,
    driver_profile JSONB NOT NULL,
    characteristics JSONB NOT NULL,
    messaging_strategy JSONB,
    size INT NOT NULL CHECK (size > 0),
    percentage FLOAT CHECK (percentage >= 0 AND percentage <= 100),
    cluster_algorithm TEXT,
    cluster_parameters JSONB,
    silhouette_score FLOAT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- Create clustering runs table in public schema
CREATE TABLE IF NOT EXISTS clustering_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    algorithm TEXT NOT NULL,
    parameters JSONB NOT NULL,
    n_actors INT NOT NULL CHECK (n_actors > 0),
    n_clusters INT NOT NULL CHECK (n_clusters > 0),
    silhouette_score FLOAT,
    calinski_harabasz_score FLOAT,
    davies_bouldin_score FLOAT,
    feature_config JSONB NOT NULL,
    validation_metrics JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by TEXT DEFAULT 'system',
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- Create actor cohort assignments table in public schema
CREATE TABLE IF NOT EXISTS actor_cohort_assignments (
    actor_id UUID REFERENCES actor_profiles(actor_id) ON DELETE CASCADE,
    cohort_id UUID REFERENCES cohorts(cohort_id) ON DELETE CASCADE,
    assignment_confidence FLOAT CHECK (assignment_confidence >= 0 AND assignment_confidence <= 1),
    distance_to_center FLOAT CHECK (distance_to_center >= 0),
    alternative_cohorts JSONB DEFAULT '[]'::jsonb,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assignment_method TEXT DEFAULT 'clustering',
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid,
    PRIMARY KEY (actor_id, cohort_id)
);

-- Create cohort history table in public schema
CREATE TABLE IF NOT EXISTS cohort_history (
    cohort_id UUID REFERENCES cohorts(cohort_id) ON DELETE CASCADE,
    snapshot_date TIMESTAMPTZ DEFAULT NOW(),
    size INT NOT NULL,
    driver_profile JSONB NOT NULL,
    characteristics JSONB NOT NULL,
    size_change INT DEFAULT 0,
    driver_profile_change JSONB,
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid,
    PRIMARY KEY (cohort_id, snapshot_date)
);

-- Create pattern analysis table in public schema
CREATE TABLE IF NOT EXISTS pattern_analysis (
    analysis_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_type TEXT NOT NULL,
    analysis_date TIMESTAMPTZ DEFAULT NOW(),
    results JSONB NOT NULL,
    visualizations JSONB DEFAULT '[]'::jsonb,
    n_actors INT NOT NULL,
    data_quality_score FLOAT,
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_cohorts_size ON cohorts(size DESC);
CREATE INDEX IF NOT EXISTS idx_cohorts_algorithm ON cohorts(cluster_algorithm);
CREATE INDEX IF NOT EXISTS idx_cohorts_silhouette ON cohorts(silhouette_score DESC);

CREATE INDEX IF NOT EXISTS idx_actor_cohort_actor ON actor_cohort_assignments(actor_id);
CREATE INDEX IF NOT EXISTS idx_actor_cohort_cohort ON actor_cohort_assignments(cohort_id);
CREATE INDEX IF NOT EXISTS idx_actor_cohort_confidence ON actor_cohort_assignments(assignment_confidence DESC);

CREATE INDEX IF NOT EXISTS idx_clustering_runs_date ON clustering_runs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_clustering_runs_algorithm ON clustering_runs(algorithm);
CREATE INDEX IF NOT EXISTS idx_clustering_runs_silhouette ON clustering_runs(silhouette_score DESC);

CREATE INDEX IF NOT EXISTS idx_pattern_analysis_type ON pattern_analysis(analysis_type);
CREATE INDEX IF NOT EXISTS idx_pattern_analysis_date ON pattern_analysis(analysis_date DESC);

CREATE INDEX IF NOT EXISTS idx_cohort_history_cohort ON cohort_history(cohort_id);
CREATE INDEX IF NOT EXISTS idx_cohort_history_date ON cohort_history(snapshot_date DESC);

-- Create helper functions
CREATE OR REPLACE FUNCTION get_actor_cohort(actor_uuid UUID)
RETURNS TABLE (
    cohort_id UUID,
    cohort_name TEXT,
    assignment_confidence FLOAT,
    distance_to_center FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.cohort_id,
        c.cohort_name,
        aca.assignment_confidence,
        aca.distance_to_center
    FROM actor_cohort_assignments aca
    JOIN cohorts c ON aca.cohort_id = c.cohort_id
    WHERE aca.actor_id = actor_uuid
    ORDER BY aca.assignment_confidence DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cohort_summary()
RETURNS TABLE (
    cohort_id UUID,
    cohort_name TEXT,
    size INT,
    percentage FLOAT,
    dominant_driver TEXT,
    avg_contradiction FLOAT,
    silhouette_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.cohort_id,
        c.cohort_name,
        c.size,
        c.percentage,
        (c.characteristics->>'dominant_driver')::TEXT as dominant_driver,
        (c.characteristics->>'avg_contradiction')::FLOAT as avg_contradiction,
        c.silhouette_score
    FROM cohorts c
    ORDER BY c.size DESC;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- Grant permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Clustering tables moved to public schema successfully!';
    RAISE NOTICE 'Tables created: cohorts, clustering_runs, actor_cohort_assignments, cohort_history, pattern_analysis';
    RAISE NOTICE 'Functions created: get_actor_cohort, get_cohort_summary';
    RAISE NOTICE 'Ready for clustering data!';
END $$;
