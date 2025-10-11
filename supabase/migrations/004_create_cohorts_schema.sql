-- =====================================================
-- COHORTS SCHEMA - Emergent Pattern Discovery
-- =====================================================
-- This schema implements emergent cohort discovery where clusters are found
-- from data rather than predefined. Cohorts evolve over time through splits,
-- merges, and dissolutions based on new data and changing patterns.

-- =====================================================
-- COHORTS TABLE
-- =====================================================
-- Discovered clusters with their characteristics and evolution
CREATE TABLE cohorts.cohorts (
    cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Cohort identification
    cohort_name TEXT, -- Human-readable name (may be null for unnamed clusters)
    cohort_type TEXT NOT NULL, -- 'behavioral', 'demographic', 'preference', 'mixed'
    cohort_status TEXT NOT NULL DEFAULT 'active', -- 'active', 'inactive', 'merged', 'split', 'dissolved'
    
    -- Discovery metadata
    discovered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    discovery_algorithm TEXT NOT NULL,
    discovery_parameters JSONB DEFAULT '{}',
    discovery_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in this cohort
    
    -- Cohort characteristics
    cohort_signature JSONB NOT NULL, -- Key characteristics that define this cohort
    centroid_vector TEXT, -- Vector representation as JSONB for now (adjust when pgvector is enabled)
    centroid_dimensions INTEGER, -- Number of dimensions in centroid
    
    -- Size and composition
    member_count INTEGER DEFAULT 0,
    max_member_count INTEGER, -- Peak membership count
    min_member_count INTEGER, -- Minimum membership count
    
    -- Stability metrics
    stability_score FLOAT DEFAULT 0.0, -- 0-1 how stable this cohort is
    coherence_score FLOAT DEFAULT 0.0, -- 0-1 how coherent the cohort is
    separation_score FLOAT DEFAULT 0.0, -- 0-1 how well separated from other cohorts
    
    -- Evolution tracking
    parent_cohort_id UUID REFERENCES cohorts.cohorts(cohort_id), -- If split from another cohort
    child_cohort_ids JSONB DEFAULT '[]', -- If this cohort was split into others
    merged_from_cohorts JSONB DEFAULT '[]', -- If this cohort resulted from merging
    
    -- Lifecycle
    first_formed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    dissolved_at TIMESTAMPTZ,
    dissolution_reason TEXT,
    
    -- Quality metrics
    data_quality_score FLOAT DEFAULT 0.0, -- 0-1 quality of underlying data
    representativeness_score FLOAT DEFAULT 0.0, -- 0-1 how representative of population
    
    -- Constraints
    CONSTRAINT valid_cohort_type CHECK (cohort_type IN ('behavioral', 'demographic', 'preference', 'mixed', 'custom')),
    CONSTRAINT valid_cohort_status CHECK (cohort_status IN ('active', 'inactive', 'merged', 'split', 'dissolved')),
    CONSTRAINT valid_confidence_scores CHECK (
        discovery_confidence >= 0 AND discovery_confidence <= 1 AND
        stability_score >= 0 AND stability_score <= 1 AND
        coherence_score >= 0 AND coherence_score <= 1 AND
        separation_score >= 0 AND separation_score <= 1 AND
        data_quality_score >= 0 AND data_quality_score <= 1 AND
        representativeness_score >= 0 AND representativeness_score <= 1
    ),
    CONSTRAINT valid_member_counts CHECK (
        member_count >= 0 AND
        (max_member_count IS NULL OR max_member_count >= member_count) AND
        (min_member_count IS NULL OR min_member_count <= member_count)
    )
);

-- =====================================================
-- ACTOR COHORT MEMBERSHIP TABLE
-- =====================================================
-- Many-to-many relationship between actors and cohorts
CREATE TABLE cohorts.actor_cohort_membership (
    membership_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    cohort_id UUID NOT NULL REFERENCES cohorts.cohorts(cohort_id) ON DELETE CASCADE,
    
    -- Membership details
    membership_type TEXT NOT NULL DEFAULT 'primary', -- 'primary', 'secondary', 'temporary'
    membership_confidence FLOAT NOT NULL, -- 0-1 confidence in this assignment
    distance_to_centroid FLOAT, -- Distance from actor to cohort centroid
    
    -- Assignment metadata
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_by_algorithm TEXT NOT NULL,
    assignment_parameters JSONB DEFAULT '{}',
    
    -- Membership status
    is_active BOOLEAN DEFAULT true,
    membership_strength FLOAT DEFAULT 0.0, -- 0-1 how strongly this actor belongs
    
    -- Evolution tracking
    previous_memberships JSONB DEFAULT '[]', -- Previous cohort assignments
    membership_history JSONB DEFAULT '[]', -- History of membership changes
    
    -- Quality metrics
    fit_score FLOAT DEFAULT 0.0, -- 0-1 how well this actor fits this cohort
    contribution_score FLOAT DEFAULT 0.0, -- 0-1 how much this actor contributes to cohort
    
    -- Temporal information
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMPTZ,
    removal_reason TEXT,
    
    -- Constraints
    CONSTRAINT valid_membership_type CHECK (membership_type IN ('primary', 'secondary', 'temporary', 'probationary')),
    CONSTRAINT valid_confidence CHECK (membership_confidence >= 0 AND membership_confidence <= 1),
    CONSTRAINT valid_strength CHECK (membership_strength >= 0 AND membership_strength <= 1),
    CONSTRAINT valid_fit_score CHECK (fit_score >= 0 AND fit_score <= 1),
    CONSTRAINT valid_contribution_score CHECK (contribution_score >= 0 AND contribution_score <= 1),
    CONSTRAINT unique_actor_cohort UNIQUE (actor_id, cohort_id)
);

-- =====================================================
-- COHORT EVOLUTION LOG TABLE
-- =====================================================
-- Track all changes to cohorts over time
CREATE TABLE cohorts.cohort_evolution_log (
    evolution_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_id UUID REFERENCES cohorts.cohorts(cohort_id) ON DELETE SET NULL,
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Evolution event details
    event_type TEXT NOT NULL, -- 'formed', 'split', 'merged', 'dissolved', 'updated', 'member_added', 'member_removed'
    event_description TEXT,
    event_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Event context
    trigger_reason TEXT, -- What caused this event
    trigger_algorithm TEXT, -- Which algorithm triggered this
    trigger_parameters JSONB DEFAULT '{}',
    
    -- State changes
    before_state JSONB, -- State before the event
    after_state JSONB, -- State after the event
    changed_attributes JSONB DEFAULT '[]', -- Which attributes changed
    
    -- Related cohorts
    related_cohort_ids JSONB DEFAULT '[]', -- Other cohorts involved in this event
    affected_actor_count INTEGER DEFAULT 0, -- Number of actors affected
    
    -- Event metadata
    event_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in this event
    event_importance FLOAT DEFAULT 0.0, -- 0-1 importance of this event
    requires_review BOOLEAN DEFAULT false, -- Whether this event needs human review
    
    -- Source tracking
    source_data JSONB DEFAULT '{}', -- Data that triggered this event
    source_signals JSONB DEFAULT '[]', -- Signals that contributed
    
    -- Constraints
    CONSTRAINT valid_event_type CHECK (event_type IN (
        'formed', 'split', 'merged', 'dissolved', 'updated', 'member_added', 
        'member_removed', 'characteristics_changed', 'stability_changed'
    )),
    CONSTRAINT valid_confidence CHECK (event_confidence >= 0 AND event_confidence <= 1),
    CONSTRAINT valid_importance CHECK (event_importance >= 0 AND event_importance <= 1)
);

-- =====================================================
-- CLUSTERING RUNS TABLE
-- =====================================================
-- Metadata about each clustering execution
CREATE TABLE cohorts.clustering_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Run details
    algorithm_name TEXT NOT NULL,
    algorithm_version TEXT,
    parameters JSONB NOT NULL,
    run_type TEXT NOT NULL DEFAULT 'full', -- 'full', 'incremental', 'targeted'
    
    -- Input data
    input_actor_count INTEGER NOT NULL,
    input_vector_type TEXT NOT NULL, -- 'demographic', 'behavioral', 'preference', 'combined'
    input_vector_dimensions INTEGER NOT NULL,
    input_data_quality FLOAT DEFAULT 0.0, -- 0-1 quality of input data
    
    -- Execution details
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    execution_time_ms INTEGER,
    status TEXT NOT NULL DEFAULT 'running', -- 'running', 'completed', 'failed', 'cancelled'
    
    -- Results
    discovered_cohort_count INTEGER DEFAULT 0,
    total_memberships INTEGER DEFAULT 0,
    average_cohort_size FLOAT,
    average_coherence FLOAT,
    average_separation FLOAT,
    
    -- Quality metrics
    overall_quality_score FLOAT DEFAULT 0.0, -- 0-1 overall clustering quality
    silhouette_score FLOAT, -- Standard clustering quality metric
    davies_bouldin_score FLOAT, -- Another clustering quality metric
    
    -- Error handling
    error_message TEXT,
    error_details JSONB DEFAULT '{}',
    
    -- Performance metrics
    memory_usage_mb INTEGER,
    cpu_usage_percent FLOAT,
    
    -- Constraints
    CONSTRAINT valid_run_type CHECK (run_type IN ('full', 'incremental', 'targeted', 'validation')),
    CONSTRAINT valid_status CHECK (status IN ('running', 'completed', 'failed', 'cancelled', 'paused')),
    CONSTRAINT valid_quality_scores CHECK (
        input_data_quality >= 0 AND input_data_quality <= 1 AND
        overall_quality_score >= 0 AND overall_quality_score <= 1
    ),
    CONSTRAINT valid_counts CHECK (
        input_actor_count >= 0 AND
        discovered_cohort_count >= 0 AND
        total_memberships >= 0
    )
);

-- =====================================================
-- COHORT CHARACTERISTICS TABLE
-- =====================================================
-- Detailed characteristics that define each cohort
CREATE TABLE cohorts.cohort_characteristics (
    characteristic_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_id UUID NOT NULL REFERENCES cohorts.cohorts(cohort_id) ON DELETE CASCADE,
    
    -- Characteristic details
    characteristic_type TEXT NOT NULL, -- 'demographic', 'behavioral', 'preference', 'psychographic'
    characteristic_name TEXT NOT NULL, -- 'age_range', 'purchase_frequency', 'spice_preference', etc.
    characteristic_value JSONB NOT NULL, -- The actual characteristic value
    
    -- Importance and strength
    importance_score FLOAT NOT NULL, -- 0-1 how important this characteristic is
    strength_score FLOAT NOT NULL, -- 0-1 how strong this characteristic is in the cohort
    distinctiveness_score FLOAT DEFAULT 0.0, -- 0-1 how distinctive this is vs. other cohorts
    
    -- Statistical measures
    mean_value FLOAT,
    median_value FLOAT,
    standard_deviation FLOAT,
    min_value FLOAT,
    max_value FLOAT,
    distribution_type TEXT, -- 'normal', 'skewed', 'bimodal', 'uniform', 'other'
    
    -- Confidence and evidence
    confidence_score FLOAT DEFAULT 0.0, -- 0-1 confidence in this characteristic
    evidence_count INTEGER DEFAULT 0, -- Number of data points supporting this
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Source tracking
    source_attributes JSONB DEFAULT '[]', -- Which actor attributes contributed
    source_weights JSONB DEFAULT '[]', -- Weights for each source attribute
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_characteristic_type CHECK (characteristic_type IN (
        'demographic', 'behavioral', 'preference', 'psychographic', 'temporal', 'spatial', 'other'
    )),
    CONSTRAINT valid_scores CHECK (
        importance_score >= 0 AND importance_score <= 1 AND
        strength_score >= 0 AND strength_score <= 1 AND
        distinctiveness_score >= 0 AND distinctiveness_score <= 1 AND
        confidence_score >= 0 AND confidence_score <= 1
    ),
    CONSTRAINT valid_evidence_count CHECK (evidence_count >= 0)
);

-- =====================================================
-- COHORT SIMILARITY MATRIX TABLE
-- =====================================================
-- Precomputed similarity scores between cohorts
CREATE TABLE cohorts.cohort_similarity_matrix (
    similarity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Similarity details
    cohort_a_id UUID NOT NULL REFERENCES cohorts.cohorts(cohort_id) ON DELETE CASCADE,
    cohort_b_id UUID NOT NULL REFERENCES cohorts.cohorts(cohort_id) ON DELETE CASCADE,
    
    -- Similarity metrics
    cosine_similarity FLOAT, -- Cosine similarity between centroids
    euclidean_distance FLOAT, -- Euclidean distance between centroids
    jaccard_similarity FLOAT, -- Jaccard similarity of characteristics
    overlap_score FLOAT, -- 0-1 how much the cohorts overlap
    
    -- Relationship type
    relationship_type TEXT, -- 'similar', 'complementary', 'opposite', 'independent'
    relationship_strength FLOAT, -- 0-1 strength of the relationship
    
    -- Computation metadata
    computed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    computation_method TEXT NOT NULL,
    computation_parameters JSONB DEFAULT '{}',
    
    -- Quality metrics
    similarity_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in similarity score
    stability_score FLOAT DEFAULT 0.0, -- 0-1 how stable this similarity is over time
    
    -- Constraints
    CONSTRAINT valid_similarity_scores CHECK (
        (cosine_similarity IS NULL OR (cosine_similarity >= -1 AND cosine_similarity <= 1)) AND
        (euclidean_distance IS NULL OR euclidean_distance >= 0) AND
        (jaccard_similarity IS NULL OR (jaccard_similarity >= 0 AND jaccard_similarity <= 1)) AND
        (overlap_score IS NULL OR (overlap_score >= 0 AND overlap_score <= 1))
    ),
    CONSTRAINT valid_relationship_type CHECK (relationship_type IN (
        'similar', 'complementary', 'opposite', 'independent', 'hierarchical', 'other'
    )),
    CONSTRAINT valid_strength CHECK (relationship_strength IS NULL OR (relationship_strength >= 0 AND relationship_strength <= 1)),
    CONSTRAINT valid_confidence CHECK (similarity_confidence >= 0 AND similarity_confidence <= 1),
    CONSTRAINT valid_stability CHECK (stability_score >= 0 AND stability_score <= 1),
    CONSTRAINT different_cohorts CHECK (cohort_a_id != cohort_b_id),
    CONSTRAINT unique_cohort_pair UNIQUE (cohort_a_id, cohort_b_id)
);

-- =====================================================
-- COHORT PERFORMANCE METRICS TABLE
-- =====================================================
-- Track how well cohorts perform over time
CREATE TABLE cohorts.cohort_performance_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_id UUID NOT NULL REFERENCES cohorts.cohorts(cohort_id) ON DELETE CASCADE,
    
    -- Metric details
    metric_name TEXT NOT NULL, -- 'response_rate', 'conversion_rate', 'engagement_score', etc.
    metric_value FLOAT NOT NULL,
    metric_unit TEXT, -- 'percentage', 'count', 'score', 'rate'
    
    -- Time period
    measurement_period_start TIMESTAMPTZ NOT NULL,
    measurement_period_end TIMESTAMPTZ NOT NULL,
    measurement_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Context
    context_type TEXT, -- 'stimulus_response', 'general_behavior', 'prediction_accuracy'
    context_id UUID, -- ID of the stimulus or other context
    
    -- Statistical measures
    sample_size INTEGER NOT NULL,
    confidence_interval_lower FLOAT,
    confidence_interval_upper FLOAT,
    p_value FLOAT,
    
    -- Comparison metrics
    baseline_value FLOAT, -- Comparison baseline
    improvement_over_baseline FLOAT, -- Improvement percentage
    percentile_rank FLOAT, -- Percentile rank among all cohorts
    
    -- Quality metrics
    data_quality_score FLOAT DEFAULT 0.0, -- 0-1 quality of underlying data
    measurement_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in measurement
    
    -- Constraints
    CONSTRAINT valid_metric_value CHECK (metric_value >= 0),
    CONSTRAINT valid_sample_size CHECK (sample_size > 0),
    CONSTRAINT valid_period CHECK (measurement_period_start < measurement_period_end),
    CONSTRAINT valid_quality_scores CHECK (
        data_quality_score >= 0 AND data_quality_score <= 1 AND
        measurement_confidence >= 0 AND measurement_confidence <= 1
    ),
    CONSTRAINT valid_percentile CHECK (percentile_rank IS NULL OR (percentile_rank >= 0 AND percentile_rank <= 100))
);

-- =====================================================
-- INDEXES FOR COHORTS SCHEMA
-- =====================================================

-- Cohorts indexes
CREATE INDEX idx_cohorts_brand_id ON cohorts.cohorts(brand_id);
CREATE INDEX idx_cohorts_type ON cohorts.cohorts(cohort_type);
CREATE INDEX idx_cohorts_status ON cohorts.cohorts(cohort_status);
CREATE INDEX idx_cohorts_discovered_at ON cohorts.cohorts(discovered_at);
CREATE INDEX idx_cohorts_stability_score ON cohorts.cohorts(stability_score);
CREATE INDEX idx_cohorts_parent_cohort_id ON cohorts.cohorts(parent_cohort_id) WHERE parent_cohort_id IS NOT NULL;

-- Actor cohort membership indexes
CREATE INDEX idx_actor_cohort_membership_actor_id ON cohorts.actor_cohort_membership(actor_id);
CREATE INDEX idx_actor_cohort_membership_cohort_id ON cohorts.actor_cohort_membership(cohort_id);
CREATE INDEX idx_actor_cohort_membership_active ON cohorts.actor_cohort_membership(is_active) WHERE is_active = true;
CREATE INDEX idx_actor_cohort_membership_confidence ON cohorts.actor_cohort_membership(membership_confidence);
CREATE INDEX idx_actor_cohort_membership_type ON cohorts.actor_cohort_membership(membership_type);

-- Cohort evolution log indexes
CREATE INDEX idx_cohort_evolution_log_cohort_id ON cohorts.cohort_evolution_log(cohort_id);
CREATE INDEX idx_cohort_evolution_log_brand_id ON cohorts.cohort_evolution_log(brand_id);
CREATE INDEX idx_cohort_evolution_log_event_type ON cohorts.cohort_evolution_log(event_type);
CREATE INDEX idx_cohort_evolution_log_timestamp ON cohorts.cohort_evolution_log(event_timestamp);
CREATE INDEX idx_cohort_evolution_log_requires_review ON cohorts.cohort_evolution_log(requires_review) WHERE requires_review = true;

-- Clustering runs indexes
CREATE INDEX idx_clustering_runs_brand_id ON cohorts.clustering_runs(brand_id);
CREATE INDEX idx_clustering_runs_algorithm ON cohorts.clustering_runs(algorithm_name);
CREATE INDEX idx_clustering_runs_status ON cohorts.clustering_runs(status);
CREATE INDEX idx_clustering_runs_started_at ON cohorts.clustering_runs(started_at);
CREATE INDEX idx_clustering_runs_type ON cohorts.clustering_runs(run_type);

-- Cohort characteristics indexes
CREATE INDEX idx_cohort_characteristics_cohort_id ON cohorts.cohort_characteristics(cohort_id);
CREATE INDEX idx_cohort_characteristics_type ON cohorts.cohort_characteristics(characteristic_type);
CREATE INDEX idx_cohort_characteristics_name ON cohorts.cohort_characteristics(characteristic_name);
CREATE INDEX idx_cohort_characteristics_current ON cohorts.cohort_characteristics(is_current) WHERE is_current = true;

-- Cohort similarity matrix indexes
CREATE INDEX idx_cohort_similarity_matrix_brand_id ON cohorts.cohort_similarity_matrix(brand_id);
CREATE INDEX idx_cohort_similarity_matrix_cohort_a ON cohorts.cohort_similarity_matrix(cohort_a_id);
CREATE INDEX idx_cohort_similarity_matrix_cohort_b ON cohorts.cohort_similarity_matrix(cohort_b_id);
CREATE INDEX idx_cohort_similarity_matrix_relationship ON cohorts.cohort_similarity_matrix(relationship_type);

-- Cohort performance metrics indexes
CREATE INDEX idx_cohort_performance_metrics_cohort_id ON cohorts.cohort_performance_metrics(cohort_id);
CREATE INDEX idx_cohort_performance_metrics_name ON cohorts.cohort_performance_metrics(metric_name);
CREATE INDEX idx_cohort_performance_metrics_measurement_date ON cohorts.cohort_performance_metrics(measurement_date);
CREATE INDEX idx_cohort_performance_metrics_context ON cohorts.cohort_performance_metrics(context_type);

-- Vector similarity search index for centroids
-- Note: Enable when pgvector extension is available
-- CREATE INDEX idx_cohorts_centroid_similarity 
-- ON cohorts.cohorts 
-- USING ivfflat (centroid_vector vector_cosine_ops) 
-- WITH (lists = 100);

-- =====================================================
-- TRIGGERS FOR COHORTS SCHEMA
-- =====================================================

-- Update cohort member count when membership changes
CREATE OR REPLACE FUNCTION cohorts.update_cohort_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.is_active = true THEN
        UPDATE cohorts.cohorts 
        SET member_count = member_count + 1,
            last_updated_at = NOW()
        WHERE cohort_id = NEW.cohort_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.is_active = true AND NEW.is_active = false THEN
            UPDATE cohorts.cohorts 
            SET member_count = member_count - 1,
                last_updated_at = NOW()
            WHERE cohort_id = NEW.cohort_id;
        ELSIF OLD.is_active = false AND NEW.is_active = true THEN
            UPDATE cohorts.cohorts 
            SET member_count = member_count + 1,
                last_updated_at = NOW()
            WHERE cohort_id = NEW.cohort_id;
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.is_active = true THEN
        UPDATE cohorts.cohorts 
        SET member_count = member_count - 1,
            last_updated_at = NOW()
        WHERE cohort_id = OLD.cohort_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Apply membership count triggers
CREATE TRIGGER update_cohort_member_count_trigger
    AFTER INSERT OR UPDATE OR DELETE ON cohorts.actor_cohort_membership
    FOR EACH ROW EXECUTE FUNCTION cohorts.update_cohort_member_count();

-- Update cohort timestamps
CREATE TRIGGER update_cohorts_updated_at 
    BEFORE UPDATE ON cohorts.cohorts 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

CREATE TRIGGER update_actor_cohort_membership_updated_at 
    BEFORE UPDATE ON cohorts.actor_cohort_membership 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- =====================================================
-- COMMENTS FOR COHORTS SCHEMA
-- =====================================================

COMMENT ON SCHEMA cohorts IS 'Emergent pattern discovery through unsupervised clustering of actors';
COMMENT ON TABLE cohorts.cohorts IS 'Discovered clusters with characteristics, stability metrics, and evolution tracking';
COMMENT ON TABLE cohorts.actor_cohort_membership IS 'Many-to-many relationship between actors and cohorts with confidence scores';
COMMENT ON TABLE cohorts.cohort_evolution_log IS 'Complete history of cohort changes including formation, splits, merges, and dissolutions';
COMMENT ON TABLE cohorts.clustering_runs IS 'Metadata about each clustering execution with performance metrics';
COMMENT ON TABLE cohorts.cohort_characteristics IS 'Detailed characteristics that define each cohort with statistical measures';
COMMENT ON TABLE cohorts.cohort_similarity_matrix IS 'Precomputed similarity scores between cohorts for relationship analysis';
COMMENT ON TABLE cohorts.cohort_performance_metrics IS 'Performance tracking for cohorts over time with statistical measures';

COMMENT ON COLUMN cohorts.cohorts.cohort_signature IS 'Key characteristics that define this cohort as JSONB';
COMMENT ON COLUMN cohorts.cohorts.centroid_vector IS 'Vector representation of cohort center for similarity calculations';
COMMENT ON COLUMN cohorts.cohorts.stability_score IS 'How stable this cohort is over time (0-1)';
COMMENT ON COLUMN cohorts.cohorts.coherence_score IS 'How coherent the cohort members are (0-1)';
COMMENT ON COLUMN cohorts.cohorts.separation_score IS 'How well separated this cohort is from others (0-1)';
COMMENT ON COLUMN cohorts.actor_cohort_membership.membership_confidence IS 'Confidence in this actor-cohort assignment (0-1)';
COMMENT ON COLUMN cohorts.actor_cohort_membership.distance_to_centroid IS 'Distance from actor to cohort centroid';
COMMENT ON COLUMN cohorts.cohort_evolution_log.event_type IS 'Type of evolution event: formed, split, merged, dissolved, etc.';
COMMENT ON COLUMN cohorts.cohort_evolution_log.before_state IS 'State of cohort before the event';
COMMENT ON COLUMN cohorts.cohort_evolution_log.after_state IS 'State of cohort after the event';
COMMENT ON COLUMN cohorts.cohort_characteristics.importance_score IS 'How important this characteristic is to the cohort (0-1)';
COMMENT ON COLUMN cohorts.cohort_characteristics.strength_score IS 'How strong this characteristic is in the cohort (0-1)';
COMMENT ON COLUMN cohorts.cohort_similarity_matrix.cosine_similarity IS 'Cosine similarity between cohort centroids';
COMMENT ON COLUMN cohorts.cohort_performance_metrics.percentile_rank IS 'Percentile rank of this cohort among all cohorts';
