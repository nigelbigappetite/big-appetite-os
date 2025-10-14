-- =====================================================
-- CLUSTERING SCHEMA FOR PATTERN ANALYSIS & SEGMENTATION
-- =====================================================
-- This migration creates the database schema for customer segmentation
-- and pattern analysis based on psychological driver distributions

-- Create clustering schema
CREATE SCHEMA IF NOT EXISTS clusters;

-- =====================================================
-- COHORTS TABLE
-- =====================================================
-- Stores discovered customer segments/cohorts
CREATE TABLE IF NOT EXISTS clusters.cohorts (
    cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_name TEXT NOT NULL,
    cohort_description TEXT,
    
    -- Driver profile (6 psychological drivers)
    driver_profile JSONB NOT NULL CHECK (
        jsonb_typeof(driver_profile) = 'object' AND
        driver_profile ? 'Safety' AND
        driver_profile ? 'Connection' AND
        driver_profile ? 'Status' AND
        driver_profile ? 'Growth' AND
        driver_profile ? 'Freedom' AND
        driver_profile ? 'Purpose'
    ),
    
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
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE CASCADE
);

-- =====================================================
-- ACTOR COHORT ASSIGNMENTS
-- =====================================================
-- Maps actors to their assigned cohorts
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
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    PRIMARY KEY (actor_id, cohort_id)
);

-- =====================================================
-- CLUSTERING RUNS
-- =====================================================
-- Tracks each clustering attempt for audit and comparison
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
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE CASCADE
);

-- =====================================================
-- COHORT EVOLUTION TRACKING
-- =====================================================
-- Tracks how cohorts change over time
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
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    PRIMARY KEY (cohort_id, snapshot_date)
);

-- =====================================================
-- PATTERN ANALYSIS RESULTS
-- =====================================================
-- Stores pattern analysis results and insights
CREATE TABLE IF NOT EXISTS clusters.pattern_analysis (
    analysis_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Analysis metadata
    analysis_type TEXT NOT NULL, -- 'driver_distribution', 'correlation', 'contradiction', 'quantum'
    analysis_date TIMESTAMPTZ DEFAULT NOW(),
    
    -- Results
    results JSONB NOT NULL,
    visualizations JSONB DEFAULT '[]'::jsonb,
    
    -- Dataset info
    n_actors INT NOT NULL,
    data_quality_score FLOAT,
    
    -- Brand isolation
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE CASCADE
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

-- Function to update cohort history
CREATE OR REPLACE FUNCTION clusters.update_cohort_history()
RETURNS void AS $$
BEGIN
    INSERT INTO clusters.cohort_history (cohort_id, size, driver_profile, characteristics, brand_id)
    SELECT 
        cohort_id,
        size,
        driver_profile,
        characteristics,
        brand_id
    FROM clusters.cohorts
    WHERE last_updated > COALESCE(
        (SELECT MAX(snapshot_date) FROM clusters.cohort_history WHERE cohort_id = clusters.cohorts.cohort_id),
        '1900-01-01'::timestamptz
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Trigger to update cohort last_updated timestamp
CREATE OR REPLACE FUNCTION clusters.update_cohort_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_cohort_timestamp
    BEFORE UPDATE ON clusters.cohorts
    FOR EACH ROW
    EXECUTE FUNCTION clusters.update_cohort_timestamp();

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
-- SAMPLE DATA VALIDATION
-- =====================================================

-- Validate that we can insert sample data
DO $$
BEGIN
    -- Test insert a sample cohort
    INSERT INTO clusters.cohorts (
        cohort_name,
        driver_profile,
        characteristics,
        size,
        percentage,
        cluster_algorithm,
        silhouette_score,
        brand_id
    ) VALUES (
        'Test Cohort',
        '{"Safety": 0.4, "Connection": 0.3, "Status": 0.1, "Growth": 0.1, "Freedom": 0.05, "Purpose": 0.05}'::jsonb,
        '{"dominant_driver": "Safety", "avg_contradiction": 0.2, "superposition_prevalence": 0.1}'::jsonb,
        50,
        16.7,
        'kmeans',
        0.45,
        (SELECT brand_id FROM core.brands LIMIT 1)
    );
    
    -- Clean up test data
    DELETE FROM clusters.cohorts WHERE cohort_name = 'Test Cohort';
    
    RAISE NOTICE 'Clustering schema created successfully!';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating clustering schema: %', SQLERRM;
END $$;
