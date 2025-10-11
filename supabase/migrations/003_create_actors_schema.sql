-- =====================================================
-- ACTORS SCHEMA - Bayesian Actor Profiles
-- =====================================================
-- This schema implements Bayesian actor profiles where every attribute has:
-- - Value (what we believe)
-- - Confidence (0-1, how certain we are)
-- - Evidence count (how many signals contributed)
-- - Timestamp (when last updated)
-- - Source signals (traceability)

-- Enable pgvector extension for belief vector similarity searches
CREATE EXTENSION IF NOT EXISTS vector;

-- =====================================================
-- ACTORS CORE TABLE
-- =====================================================
-- Central actor registry with basic identification
CREATE TABLE actors.actors (
    actor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Primary identification
    primary_identifier TEXT NOT NULL, -- Phone, email, or handle
    primary_identifier_type TEXT NOT NULL, -- 'phone', 'email', 'social_handle'
    
    -- Alternative identifiers
    identifiers JSONB DEFAULT '{}', -- Map of identifier_type -> value
    
    -- Actor status
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    verification_method TEXT, -- 'phone', 'email', 'social', 'manual'
    
    -- Creation and metadata
    first_seen_at TIMESTAMPTZ NOT NULL,
    last_seen_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Signal counts
    total_signals INTEGER DEFAULT 0,
    last_signal_at TIMESTAMPTZ,
    
    -- Quality metrics
    data_quality_score FLOAT DEFAULT 0.0, -- 0-1 overall data quality
    profile_completeness FLOAT DEFAULT 0.0, -- 0-1 how complete the profile is
    
    -- Constraints
    CONSTRAINT valid_identifier_type CHECK (primary_identifier_type IN ('phone', 'email', 'social_handle', 'customer_id')),
    CONSTRAINT valid_verification_method CHECK (verification_method IN ('phone', 'email', 'social', 'manual', 'none') OR verification_method IS NULL),
    CONSTRAINT valid_quality_scores CHECK (
        data_quality_score >= 0 AND data_quality_score <= 1 AND
        profile_completeness >= 0 AND profile_completeness <= 1
    ),
    CONSTRAINT unique_brand_identifier UNIQUE (brand_id, primary_identifier, primary_identifier_type)
);

-- =====================================================
-- ACTOR DEMOGRAPHICS TABLE
-- =====================================================
-- Bayesian demographic beliefs with uncertainty
CREATE TABLE actors.actor_demographics (
    demographic_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Demographic attributes
    attribute_name TEXT NOT NULL, -- 'age', 'gender', 'location', 'income_level', etc.
    attribute_value JSONB NOT NULL, -- The actual value (could be range, category, etc.)
    
    -- Bayesian metadata
    confidence FLOAT NOT NULL DEFAULT 0.0, -- 0-1 confidence in this belief
    evidence_count INTEGER NOT NULL DEFAULT 0, -- Number of signals that contributed
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Source tracking
    source_signals JSONB DEFAULT '[]', -- Array of signal_ids that contributed
    source_weights JSONB DEFAULT '[]', -- Weights for each source signal
    
    -- Uncertainty modeling
    uncertainty_type TEXT DEFAULT 'confidence', -- 'confidence', 'range', 'distribution'
    uncertainty_data JSONB DEFAULT '{}', -- Additional uncertainty information
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1),
    CONSTRAINT valid_evidence_count CHECK (evidence_count >= 0),
    CONSTRAINT valid_uncertainty_type CHECK (uncertainty_type IN ('confidence', 'range', 'distribution', 'categorical'))
);

-- =====================================================
-- ACTOR IDENTITY BELIEFS TABLE
-- =====================================================
-- How the actor sees themselves vs. how they behave
CREATE TABLE actors.actor_identity_beliefs (
    identity_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Identity attributes
    identity_dimension TEXT NOT NULL, -- 'health_conscious', 'price_sensitive', 'brand_loyal', etc.
    stated_value JSONB, -- What they say about themselves
    behavioral_value JSONB, -- What their behavior suggests
    alignment_score FLOAT, -- -1 to 1, how aligned stated vs. behavioral
    
    -- Bayesian metadata
    stated_confidence FLOAT DEFAULT 0.0, -- Confidence in stated value
    behavioral_confidence FLOAT DEFAULT 0.0, -- Confidence in behavioral value
    evidence_count INTEGER DEFAULT 0,
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Source tracking
    stated_sources JSONB DEFAULT '[]', -- Signals that support stated value
    behavioral_sources JSONB DEFAULT '[]', -- Signals that support behavioral value
    
    -- Contradiction tracking
    is_contradiction BOOLEAN DEFAULT false,
    contradiction_strength FLOAT DEFAULT 0.0, -- 0-1 how strong the contradiction
    contradiction_explanation TEXT,
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_confidence_scores CHECK (
        stated_confidence >= 0 AND stated_confidence <= 1 AND
        behavioral_confidence >= 0 AND behavioral_confidence <= 1
    ),
    CONSTRAINT valid_alignment_score CHECK (alignment_score >= -1 AND alignment_score <= 1),
    CONSTRAINT valid_contradiction_strength CHECK (contradiction_strength >= 0 AND contradiction_strength <= 1)
);

-- =====================================================
-- ACTOR BEHAVIORAL SCORES TABLE
-- =====================================================
-- Context-dependent behavioral patterns
CREATE TABLE actors.actor_behavioral_scores (
    behavioral_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Behavioral dimensions
    behavior_type TEXT NOT NULL, -- 'purchase_frequency', 'response_time', 'engagement_level', etc.
    context TEXT, -- 'weekday', 'weekend', 'morning', 'evening', 'high_stress', etc.
    score_value FLOAT NOT NULL, -- The behavioral score
    
    -- Bayesian metadata
    confidence FLOAT NOT NULL DEFAULT 0.0,
    evidence_count INTEGER NOT NULL DEFAULT 0,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Context sensitivity
    context_dependency FLOAT DEFAULT 0.0, -- 0-1 how much context matters
    context_weights JSONB DEFAULT '{}', -- Weights for different contexts
    
    -- Source tracking
    source_signals JSONB DEFAULT '[]',
    source_weights JSONB DEFAULT '[]',
    
    -- Temporal patterns
    temporal_stability FLOAT DEFAULT 0.0, -- 0-1 how stable over time
    seasonal_patterns JSONB DEFAULT '{}', -- Seasonal variations
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1),
    CONSTRAINT valid_evidence_count CHECK (evidence_count >= 0),
    CONSTRAINT valid_context_dependency CHECK (context_dependency >= 0 AND context_dependency <= 1),
    CONSTRAINT valid_temporal_stability CHECK (temporal_stability >= 0 AND temporal_stability <= 1)
);

-- =====================================================
-- ACTOR COMMUNICATION PROFILES TABLE
-- =====================================================
-- How to best communicate with this actor
CREATE TABLE actors.actor_communication_profiles (
    communication_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Communication preferences
    preferred_channel TEXT NOT NULL, -- 'whatsapp', 'email', 'sms', 'phone', 'social'
    preferred_tone TEXT, -- 'formal', 'casual', 'friendly', 'professional'
    preferred_frequency TEXT, -- 'daily', 'weekly', 'monthly', 'as_needed'
    preferred_time TEXT, -- 'morning', 'afternoon', 'evening', 'anytime'
    
    -- Response patterns
    avg_response_time INTEGER, -- Minutes
    response_rate FLOAT, -- 0-1 likelihood to respond
    engagement_level FLOAT, -- 0-1 how engaged they are
    
    -- Content preferences
    content_types JSONB DEFAULT '[]', -- ['text', 'images', 'videos', 'links']
    topic_interests JSONB DEFAULT '[]', -- Topics they engage with
    language_preference TEXT DEFAULT 'en',
    
    -- Bayesian metadata
    confidence FLOAT NOT NULL DEFAULT 0.0,
    evidence_count INTEGER NOT NULL DEFAULT 0,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Source tracking
    source_signals JSONB DEFAULT '[]',
    source_weights JSONB DEFAULT '[]',
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_channel CHECK (preferred_channel IN ('whatsapp', 'email', 'sms', 'phone', 'social', 'push', 'in_app')),
    CONSTRAINT valid_tone CHECK (preferred_tone IN ('formal', 'casual', 'friendly', 'professional', 'humorous', 'serious') OR preferred_tone IS NULL),
    CONSTRAINT valid_frequency CHECK (preferred_frequency IN ('daily', 'weekly', 'monthly', 'as_needed', 'never') OR preferred_frequency IS NULL),
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1),
    CONSTRAINT valid_rates CHECK (
        response_rate IS NULL OR (response_rate >= 0 AND response_rate <= 1) AND
        engagement_level IS NULL OR (engagement_level >= 0 AND engagement_level <= 1)
    )
);

-- =====================================================
-- ACTOR PSYCHOLOGICAL TRIGGERS TABLE
-- =====================================================
-- What motivates and influences this actor
CREATE TABLE actors.actor_psychological_triggers (
    trigger_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Trigger information
    trigger_type TEXT NOT NULL, -- 'fear', 'greed', 'social_proof', 'scarcity', 'authority', etc.
    trigger_description TEXT,
    trigger_strength FLOAT NOT NULL, -- 0-1 how strong this trigger is
    
    -- Context and conditions
    activation_context JSONB DEFAULT '{}', -- When this trigger activates
    deactivation_conditions JSONB DEFAULT '{}', -- When this trigger is suppressed
    
    -- Behavioral impact
    impact_on_behavior JSONB DEFAULT '{}', -- How this affects their actions
    success_rate FLOAT, -- 0-1 how often this trigger leads to desired action
    
    -- Bayesian metadata
    confidence FLOAT NOT NULL DEFAULT 0.0,
    evidence_count INTEGER NOT NULL DEFAULT 0,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Source tracking
    source_signals JSONB DEFAULT '[]',
    source_weights JSONB DEFAULT '[]',
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_trigger_type CHECK (trigger_type IN (
        'fear', 'greed', 'social_proof', 'scarcity', 'authority', 'reciprocity', 
        'commitment', 'consistency', 'curiosity', 'urgency', 'exclusivity', 'other'
    )),
    CONSTRAINT valid_strength CHECK (trigger_strength >= 0 AND trigger_strength <= 1),
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1),
    CONSTRAINT valid_success_rate CHECK (success_rate IS NULL OR (success_rate >= 0 AND success_rate <= 1))
);

-- =====================================================
-- ACTOR PREFERENCES TABLE
-- =====================================================
-- Stated vs. actual preferences with contradiction tracking
CREATE TABLE actors.actor_preferences (
    preference_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Preference information
    preference_category TEXT NOT NULL, -- 'food', 'price', 'service', 'convenience', etc.
    preference_dimension TEXT NOT NULL, -- 'spice_level', 'delivery_time', 'payment_method', etc.
    stated_preference JSONB, -- What they say they prefer
    actual_preference JSONB, -- What their behavior shows they prefer
    
    -- Preference strength and consistency
    stated_strength FLOAT, -- 0-1 how strongly they state this preference
    actual_strength FLOAT, -- 0-1 how strongly their behavior shows this preference
    consistency_score FLOAT, -- -1 to 1 how consistent stated vs. actual
    
    -- Bayesian metadata
    stated_confidence FLOAT DEFAULT 0.0,
    actual_confidence FLOAT DEFAULT 0.0,
    evidence_count INTEGER DEFAULT 0,
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Source tracking
    stated_sources JSONB DEFAULT '[]',
    actual_sources JSONB DEFAULT '[]',
    
    -- Contradiction tracking
    is_contradiction BOOLEAN DEFAULT false,
    contradiction_explanation TEXT,
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_strengths CHECK (
        (stated_strength IS NULL OR (stated_strength >= 0 AND stated_strength <= 1)) AND
        (actual_strength IS NULL OR (actual_strength >= 0 AND actual_strength <= 1))
    ),
    CONSTRAINT valid_consistency CHECK (consistency_score >= -1 AND consistency_score <= 1),
    CONSTRAINT valid_confidence_scores CHECK (
        stated_confidence >= 0 AND stated_confidence <= 1 AND
        actual_confidence >= 0 AND actual_confidence <= 1
    )
);

-- =====================================================
-- ACTOR MEMORY LOOPS TABLE
-- =====================================================
-- Recurring patterns and habits
CREATE TABLE actors.actor_memory_loops (
    memory_loop_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Loop information
    loop_type TEXT NOT NULL, -- 'purchase_pattern', 'communication_rhythm', 'seasonal_behavior', etc.
    loop_description TEXT,
    loop_frequency TEXT, -- 'daily', 'weekly', 'monthly', 'seasonal', 'irregular'
    
    -- Loop characteristics
    loop_strength FLOAT NOT NULL, -- 0-1 how strong this pattern is
    loop_consistency FLOAT, -- 0-1 how consistent the pattern is
    loop_duration INTEGER, -- Days this pattern has been observed
    
    -- Pattern details
    pattern_data JSONB NOT NULL, -- The actual pattern data
    triggers JSONB DEFAULT '[]', -- What triggers this loop
    outcomes JSONB DEFAULT '[]', -- What typically happens in this loop
    
    -- Bayesian metadata
    confidence FLOAT NOT NULL DEFAULT 0.0,
    evidence_count INTEGER NOT NULL DEFAULT 0,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Source tracking
    source_signals JSONB DEFAULT '[]',
    source_weights JSONB DEFAULT '[]',
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_loop_type CHECK (loop_type IN (
        'purchase_pattern', 'communication_rhythm', 'seasonal_behavior', 
        'weekly_routine', 'monthly_cycle', 'event_triggered', 'other'
    )),
    CONSTRAINT valid_frequency CHECK (loop_frequency IN (
        'daily', 'weekly', 'monthly', 'seasonal', 'irregular', 'unknown'
    )),
    CONSTRAINT valid_strength CHECK (loop_strength >= 0 AND loop_strength <= 1),
    CONSTRAINT valid_consistency CHECK (loop_consistency IS NULL OR (loop_consistency >= 0 AND loop_consistency <= 1)),
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1)
);

-- =====================================================
-- ACTOR FRICTION POINTS TABLE
-- =====================================================
-- What creates friction in their experience
CREATE TABLE actors.actor_friction_points (
    friction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Friction information
    friction_type TEXT NOT NULL, -- 'payment', 'delivery', 'communication', 'pricing', etc.
    friction_description TEXT,
    friction_severity FLOAT NOT NULL, -- 0-1 how severe this friction is
    
    -- Impact and context
    impact_on_behavior JSONB DEFAULT '{}', -- How this affects their actions
    context_when_occurs JSONB DEFAULT '{}', -- When this friction typically occurs
    resolution_attempts JSONB DEFAULT '[]', -- What has been tried to resolve it
    
    -- Bayesian metadata
    confidence FLOAT NOT NULL DEFAULT 0.0,
    evidence_count INTEGER NOT NULL DEFAULT 0,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Source tracking
    source_signals JSONB DEFAULT '[]',
    source_weights JSONB DEFAULT '[]',
    
    -- Status
    is_resolved BOOLEAN DEFAULT false,
    resolution_date TIMESTAMPTZ,
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_friction_type CHECK (friction_type IN (
        'payment', 'delivery', 'communication', 'pricing', 'quality', 
        'service', 'convenience', 'technical', 'other'
    )),
    CONSTRAINT valid_severity CHECK (friction_severity >= 0 AND friction_severity <= 1),
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1)
);

-- =====================================================
-- ACTOR CONTRADICTIONS TABLE
-- =====================================================
-- Explicit tracking of contradictions between beliefs and behavior
CREATE TABLE actors.actor_contradictions (
    contradiction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Contradiction details
    contradiction_type TEXT NOT NULL, -- 'stated_vs_behavior', 'belief_vs_action', 'preference_vs_choice', etc.
    contradiction_description TEXT NOT NULL,
    contradiction_strength FLOAT NOT NULL, -- 0-1 how strong the contradiction is
    
    -- Conflicting information
    stated_belief JSONB NOT NULL, -- What they say/claim
    actual_behavior JSONB NOT NULL, -- What they actually do
    evidence_for_stated JSONB DEFAULT '[]', -- Evidence supporting stated belief
    evidence_for_behavior JSONB DEFAULT '[]', -- Evidence supporting actual behavior
    
    -- Analysis
    possible_explanations JSONB DEFAULT '[]', -- Possible reasons for the contradiction
    resolution_hypothesis TEXT, -- How this might be resolved
    requires_investigation BOOLEAN DEFAULT false,
    
    -- Bayesian metadata
    confidence FLOAT NOT NULL DEFAULT 0.0,
    evidence_count INTEGER NOT NULL DEFAULT 0,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Source tracking
    source_signals JSONB DEFAULT '[]',
    source_weights JSONB DEFAULT '[]',
    
    -- Status
    is_resolved BOOLEAN DEFAULT false,
    resolution_date TIMESTAMPTZ,
    resolution_explanation TEXT,
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_contradiction_type CHECK (contradiction_type IN (
        'stated_vs_behavior', 'belief_vs_action', 'preference_vs_choice', 
        'intention_vs_outcome', 'self_vs_other_perception', 'other'
    )),
    CONSTRAINT valid_strength CHECK (contradiction_strength >= 0 AND contradiction_strength <= 1),
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1)
);

-- =====================================================
-- ACTOR BELIEF VECTORS TABLE
-- =====================================================
-- Numeric vector representation for clustering and similarity
CREATE TABLE actors.actor_belief_vectors (
    vector_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Vector information
    vector_name TEXT NOT NULL, -- 'primary', 'demographic', 'behavioral', 'preference', etc.
    vector_data VECTOR(1536), -- Embedding vector (adjust size as needed)
    vector_dimensions INTEGER NOT NULL,
    
    -- Vector metadata
    vector_type TEXT NOT NULL, -- 'demographic', 'behavioral', 'preference', 'combined'
    generation_method TEXT NOT NULL, -- 'manual', 'auto', 'ml_model'
    generation_parameters JSONB DEFAULT '{}',
    
    -- Quality metrics
    vector_quality FLOAT DEFAULT 0.0, -- 0-1 quality of the vector
    completeness_score FLOAT DEFAULT 0.0, -- 0-1 how complete the vector is
    
    -- Source tracking
    source_attributes JSONB DEFAULT '[]', -- Which attributes contributed to this vector
    source_weights JSONB DEFAULT '[]', -- Weights for each source attribute
    
    -- Temporal information
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_vector_type CHECK (vector_type IN ('demographic', 'behavioral', 'preference', 'combined', 'custom')),
    CONSTRAINT valid_generation_method CHECK (generation_method IN ('manual', 'auto', 'ml_model', 'hybrid')),
    CONSTRAINT valid_quality_scores CHECK (
        vector_quality >= 0 AND vector_quality <= 1 AND
        completeness_score >= 0 AND completeness_score <= 1
    ),
    CONSTRAINT valid_dimensions CHECK (vector_dimensions > 0)
);

-- =====================================================
-- ACTOR CLUSTERING METADATA TABLE
-- =====================================================
-- Metadata about how this actor has been clustered
CREATE TABLE actors.actor_clustering_metadata (
    clustering_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
    
    -- Clustering information
    clustering_run_id UUID NOT NULL, -- Will reference cohorts.clustering_runs
    algorithm_used TEXT NOT NULL,
    parameters JSONB DEFAULT '{}',
    
    -- Clustering results
    assigned_cohorts JSONB DEFAULT '[]', -- Array of cohort assignments
    distances_to_centroids JSONB DEFAULT '{}', -- Distance to each cohort centroid
    confidence_scores JSONB DEFAULT '{}', -- Confidence in each assignment
    
    -- Vector information
    vector_used UUID REFERENCES actors.actor_belief_vectors(vector_id),
    vector_similarity_scores JSONB DEFAULT '{}', -- Similarity to other actors
    
    -- Metadata
    clustered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_stable BOOLEAN DEFAULT true, -- Whether this assignment is stable
    
    -- Constraints
    CONSTRAINT valid_algorithm CHECK (algorithm_used IN ('kmeans', 'dbscan', 'hierarchical', 'gaussian_mixture', 'spectral', 'other'))
);

-- =====================================================
-- INDEXES FOR ACTORS SCHEMA
-- =====================================================

-- Actors core indexes
CREATE INDEX idx_actors_brand_id ON actors.actors(brand_id);
CREATE INDEX idx_actors_primary_identifier ON actors.actors(primary_identifier);
CREATE INDEX idx_actors_primary_identifier_type ON actors.actors(primary_identifier_type);
CREATE INDEX idx_actors_last_seen_at ON actors.actors(last_seen_at);
CREATE INDEX idx_actors_is_active ON actors.actors(is_active) WHERE is_active = true;

-- Demographics indexes
CREATE INDEX idx_actor_demographics_actor_id ON actors.actor_demographics(actor_id);
CREATE INDEX idx_actor_demographics_attribute_name ON actors.actor_demographics(attribute_name);
CREATE INDEX idx_actor_demographics_is_current ON actors.actor_demographics(is_current) WHERE is_current = true;

-- Identity beliefs indexes
CREATE INDEX idx_actor_identity_beliefs_actor_id ON actors.actor_identity_beliefs(actor_id);
CREATE INDEX idx_actor_identity_beliefs_dimension ON actors.actor_identity_beliefs(identity_dimension);
CREATE INDEX idx_actor_identity_beliefs_contradiction ON actors.actor_identity_beliefs(is_contradiction) WHERE is_contradiction = true;

-- Behavioral scores indexes
CREATE INDEX idx_actor_behavioral_scores_actor_id ON actors.actor_behavioral_scores(actor_id);
CREATE INDEX idx_actor_behavioral_scores_behavior_type ON actors.actor_behavioral_scores(behavior_type);
CREATE INDEX idx_actor_behavioral_scores_context ON actors.actor_behavioral_scores(context) WHERE context IS NOT NULL;

-- Communication profiles indexes
CREATE INDEX idx_actor_communication_profiles_actor_id ON actors.actor_communication_profiles(actor_id);
CREATE INDEX idx_actor_communication_profiles_channel ON actors.actor_communication_profiles(preferred_channel);

-- Psychological triggers indexes
CREATE INDEX idx_actor_psychological_triggers_actor_id ON actors.actor_psychological_triggers(actor_id);
CREATE INDEX idx_actor_psychological_triggers_type ON actors.actor_psychological_triggers(trigger_type);

-- Preferences indexes
CREATE INDEX idx_actor_preferences_actor_id ON actors.actor_preferences(actor_id);
CREATE INDEX idx_actor_preferences_category ON actors.actor_preferences(preference_category);
CREATE INDEX idx_actor_preferences_contradiction ON actors.actor_preferences(is_contradiction) WHERE is_contradiction = true;

-- Memory loops indexes
CREATE INDEX idx_actor_memory_loops_actor_id ON actors.actor_memory_loops(actor_id);
CREATE INDEX idx_actor_memory_loops_type ON actors.actor_memory_loops(loop_type);

-- Friction points indexes
CREATE INDEX idx_actor_friction_points_actor_id ON actors.actor_friction_points(actor_id);
CREATE INDEX idx_actor_friction_points_type ON actors.actor_friction_points(friction_type);
CREATE INDEX idx_actor_friction_points_resolved ON actors.actor_friction_points(is_resolved) WHERE is_resolved = false;

-- Contradictions indexes
CREATE INDEX idx_actor_contradictions_actor_id ON actors.actor_contradictions(actor_id);
CREATE INDEX idx_actor_contradictions_type ON actors.actor_contradictions(contradiction_type);
CREATE INDEX idx_actor_contradictions_resolved ON actors.actor_contradictions(is_resolved) WHERE is_resolved = false;

-- Belief vectors indexes
CREATE INDEX idx_actor_belief_vectors_actor_id ON actors.actor_belief_vectors(actor_id);
CREATE INDEX idx_actor_belief_vectors_type ON actors.actor_belief_vectors(vector_type);
CREATE INDEX idx_actor_belief_vectors_current ON actors.actor_belief_vectors(is_current) WHERE is_current = true;

-- Clustering metadata indexes
CREATE INDEX idx_actor_clustering_metadata_actor_id ON actors.actor_clustering_metadata(actor_id);
CREATE INDEX idx_actor_clustering_metadata_run_id ON actors.actor_clustering_metadata(clustering_run_id);
CREATE INDEX idx_actor_clustering_metadata_algorithm ON actors.actor_clustering_metadata(algorithm_used);

-- Vector similarity search index (using pgvector)
CREATE INDEX idx_actor_belief_vectors_similarity 
ON actors.actor_belief_vectors 
USING ivfflat (vector_data vector_cosine_ops) 
WITH (lists = 100);

-- =====================================================
-- TRIGGERS FOR ACTORS SCHEMA
-- =====================================================

-- Update actor last_seen_at when new signals arrive
CREATE OR REPLACE FUNCTION actors.update_actor_last_seen()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE actors.actors 
    SET 
        last_seen_at = NEW.received_at,
        total_signals = total_signals + 1,
        last_signal_at = NEW.received_at
    WHERE actor_id = NEW.actor_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update triggers
CREATE TRIGGER update_actor_last_seen_trigger
    AFTER INSERT ON signals.signals_base
    FOR EACH ROW 
    WHEN (NEW.actor_id IS NOT NULL)
    EXECUTE FUNCTION actors.update_actor_last_seen();

-- Update actor timestamps
CREATE TRIGGER update_actors_updated_at 
    BEFORE UPDATE ON actors.actors 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- =====================================================
-- COMMENTS FOR ACTORS SCHEMA
-- =====================================================

COMMENT ON SCHEMA actors IS 'Bayesian actor profiles with uncertainty modeling and contradiction tracking';
COMMENT ON TABLE actors.actors IS 'Central actor registry with basic identification and quality metrics';
COMMENT ON TABLE actors.actor_demographics IS 'Bayesian demographic beliefs with confidence scores and evidence tracking';
COMMENT ON TABLE actors.actor_identity_beliefs IS 'Stated vs. behavioral identity with alignment scoring';
COMMENT ON TABLE actors.actor_behavioral_scores IS 'Context-dependent behavioral patterns with temporal stability';
COMMENT ON TABLE actors.actor_communication_profiles IS 'Communication preferences and response patterns';
COMMENT ON TABLE actors.actor_psychological_triggers IS 'Motivational triggers and their behavioral impact';
COMMENT ON TABLE actors.actor_preferences IS 'Stated vs. actual preferences with contradiction detection';
COMMENT ON TABLE actors.actor_memory_loops IS 'Recurring behavioral patterns and habits';
COMMENT ON TABLE actors.actor_friction_points IS 'Experience friction points and their impact';
COMMENT ON TABLE actors.actor_contradictions IS 'Explicit tracking of belief-behavior contradictions';
COMMENT ON TABLE actors.actor_belief_vectors IS 'Numeric vector representations for clustering and similarity';
COMMENT ON TABLE actors.actor_clustering_metadata IS 'Metadata about actor clustering assignments';

COMMENT ON COLUMN actors.actors.data_quality_score IS 'Overall data quality score (0-1) based on completeness and reliability';
COMMENT ON COLUMN actors.actors.profile_completeness IS 'Profile completeness score (0-1) based on filled attributes';
COMMENT ON COLUMN actors.actor_demographics.confidence IS 'Confidence score (0-1) in this demographic belief';
COMMENT ON COLUMN actors.actor_demographics.evidence_count IS 'Number of signals that contributed to this belief';
COMMENT ON COLUMN actors.actor_identity_beliefs.alignment_score IS 'Alignment between stated and behavioral values (-1 to 1)';
COMMENT ON COLUMN actors.actor_behavioral_scores.context_dependency IS 'How much context matters for this behavioral score (0-1)';
COMMENT ON COLUMN actors.actor_communication_profiles.engagement_level IS 'Overall engagement level (0-1) across all channels';
COMMENT ON COLUMN actors.actor_psychological_triggers.trigger_strength IS 'Strength of this psychological trigger (0-1)';
COMMENT ON COLUMN actors.actor_preferences.consistency_score IS 'Consistency between stated and actual preferences (-1 to 1)';
COMMENT ON COLUMN actors.actor_memory_loops.loop_strength IS 'Strength of this behavioral pattern (0-1)';
COMMENT ON COLUMN actors.actor_friction_points.friction_severity IS 'Severity of this friction point (0-1)';
COMMENT ON COLUMN actors.actor_contradictions.contradiction_strength IS 'Strength of the contradiction (0-1)';
COMMENT ON COLUMN actors.actor_belief_vectors.vector_data IS 'Numeric vector for similarity search and clustering';
COMMENT ON COLUMN actors.actor_clustering_metadata.is_stable IS 'Whether this clustering assignment is stable over time';
