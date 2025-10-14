-- =====================================================
-- CREATE CLUSTERING TABLES FOR BIG APPETITE OS
-- =====================================================
-- Run this in Supabase SQL Editor to create clustering tables

-- Create clustering schema
CREATE SCHEMA IF NOT EXISTS clusters;

-- =====================================================
-- COHORTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS clusters.cohorts (
    cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_name TEXT NOT NULL,
    cohort_description TEXT,
    
    -- Driver profile (6 psychological drivers)
    driver_profile JSONB NOT NULL,
    
    -- Cohort characteristics
    characteristics JSONB NOT NULL,
    
    -- Messaging strategy recommendations
    messaging_strategy JSONB,
    
    -- Size and composition
    size INT NOT NULL CHECK (size > 0),
    percentage FLOAT CHECK (percentage >= 0 AND percentage <= 100),
    
    -- Clustering metadata
    cluster_algorithm TEXT,
    cluster_parameters JSONB,
    silhouette_score FLOAT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    
    -- Brand isolation (for future multi-brand support)
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- =====================================================
-- ACTOR COHORT ASSIGNMENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS clusters.actor_cohort_assignments (
    actor_id UUID REFERENCES actors.actor_profiles(actor_id) ON DELETE CASCADE,
    cohort_id UUID REFERENCES clusters.cohorts(cohort_id) ON DELETE CASCADE,
    
    -- Assignment confidence and quality
    assignment_confidence FLOAT CHECK (assignment_confidence >= 0 AND assignment_confidence <= 1),
    distance_to_center FLOAT CHECK (distance_to_center >= 0),
    
    -- Alternative assignments (top 3 alternatives)
    alternative_cohorts JSONB DEFAULT '[]'::jsonb,
    
    -- Assignment metadata
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assignment_method TEXT DEFAULT 'clustering',
    
    -- Brand isolation
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid,
    
    PRIMARY KEY (actor_id, cohort_id)
);

-- =====================================================
-- CLUSTERING RUNS
-- =====================================================
CREATE TABLE IF NOT EXISTS clusters.clustering_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Algorithm details
    algorithm TEXT NOT NULL,
    parameters JSONB NOT NULL,
    
    -- Dataset info
    n_actors INT NOT NULL CHECK (n_actors > 0),
    n_clusters INT NOT NULL CHECK (n_clusters > 0),
    
    -- Quality metrics
    silhouette_score FLOAT,
    calinski_harabasz_score FLOAT,
    davies_bouldin_score FLOAT,
    
    -- Feature configuration
    feature_config JSONB NOT NULL,
    
    -- Validation results
    validation_metrics JSONB,
    
    -- Run metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by TEXT DEFAULT 'system',
    
    -- Brand isolation
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- =====================================================
-- COHORT EVOLUTION TRACKING
-- =====================================================
CREATE TABLE IF NOT EXISTS clusters.cohort_history (
    cohort_id UUID REFERENCES clusters.cohorts(cohort_id) ON DELETE CASCADE,
    snapshot_date TIMESTAMPTZ DEFAULT NOW(),
    
    -- Snapshot data
    size INT NOT NULL,
    driver_profile JSONB NOT NULL,
    characteristics JSONB NOT NULL,
    
    -- Change tracking
    size_change INT DEFAULT 0,
    driver_profile_change JSONB,
    
    -- Brand isolation
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid,
    
    PRIMARY KEY (cohort_id, snapshot_date)
);

-- =====================================================
-- PATTERN ANALYSIS RESULTS
-- =====================================================
CREATE TABLE IF NOT EXISTS clusters.pattern_analysis (
    analysis_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Analysis metadata
    analysis_type TEXT NOT NULL,
    analysis_date TIMESTAMPTZ DEFAULT NOW(),
    
    -- Results
    results JSONB NOT NULL,
    visualizations JSONB DEFAULT '[]'::jsonb,
    
    -- Dataset info
    n_actors INT NOT NULL,
    data_quality_score FLOAT,
    
    -- Brand isolation
    brand_id UUID DEFAULT 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Actor assignments
CREATE INDEX IF NOT EXISTS idx_actor_cohort_actor ON clusters.actor_cohort_assignments(actor_id);
CREATE INDEX IF NOT EXISTS idx_actor_cohort_cohort ON clusters.actor_cohort_assignments(cohort_id);
CREATE INDEX IF NOT EXISTS idx_actor_cohort_confidence ON clusters.actor_cohort_assignments(assignment_confidence DESC);

-- Cohorts
CREATE INDEX IF NOT EXISTS idx_cohorts_size ON clusters.cohorts(size DESC);
CREATE INDEX IF NOT EXISTS idx_cohorts_algorithm ON clusters.cohorts(cluster_algorithm);
CREATE INDEX IF NOT EXISTS idx_cohorts_silhouette ON clusters.cohorts(silhouette_score DESC);

-- Clustering runs
CREATE INDEX IF NOT EXISTS idx_clustering_runs_date ON clusters.clustering_runs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_clustering_runs_algorithm ON clusters.clustering_runs(algorithm);
CREATE INDEX IF NOT EXISTS idx_clustering_runs_silhouette ON clusters.clustering_runs(silhouette_score DESC);

-- Pattern analysis
CREATE INDEX IF NOT EXISTS idx_pattern_analysis_type ON clusters.pattern_analysis(analysis_type);
CREATE INDEX IF NOT EXISTS idx_pattern_analysis_date ON clusters.pattern_analysis(analysis_date DESC);

-- Cohort history
CREATE INDEX IF NOT EXISTS idx_cohort_history_cohort ON clusters.cohort_history(cohort_id);
CREATE INDEX IF NOT EXISTS idx_cohort_history_date ON clusters.cohort_history(snapshot_date DESC);

-- =====================================================
-- FUNCTIONS FOR COHORT MANAGEMENT
-- =====================================================

-- Function to get actor's current cohort
CREATE OR REPLACE FUNCTION clusters.get_actor_cohort(actor_uuid UUID)
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
    FROM clusters.actor_cohort_assignments aca
    JOIN clusters.cohorts c ON aca.cohort_id = c.cohort_id
    WHERE aca.actor_id = actor_uuid
    ORDER BY aca.assignment_confidence DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get cohort summary
CREATE OR REPLACE FUNCTION clusters.get_cohort_summary()
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
    FROM clusters.cohorts c
    ORDER BY c.size DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PERMISSIONS
-- =====================================================

-- Grant permissions to service_role
GRANT ALL ON SCHEMA clusters TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA clusters TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA clusters TO service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA clusters TO service_role;

-- Grant permissions to authenticated users (for future web app)
GRANT USAGE ON SCHEMA clusters TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA clusters TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA clusters TO authenticated;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE 'Clustering schema created successfully!';
    RAISE NOTICE 'Tables created: cohorts, actor_cohort_assignments, clustering_runs, cohort_history, pattern_analysis';
    RAISE NOTICE 'Functions created: get_actor_cohort, get_cohort_summary';
    RAISE NOTICE 'Ready for clustering data!';
END $$;
