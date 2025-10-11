-- =====================================================
-- OUTCOMES SCHEMA - Results Tracking
-- =====================================================
-- This schema tracks the results and outcomes of stimuli deployment,
-- enabling the system to learn from what worked and what didn't.
-- Outcomes feed back into the learning loop to improve future decisions.

-- =====================================================
-- OUTCOMES TABLE
-- =====================================================
-- Central outcomes tracking with full traceability
CREATE TABLE outcomes.outcomes (
    outcome_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Source stimulus
    stimulus_id UUID REFERENCES stimuli.stimuli_base(stimulus_id),
    stimulus_type TEXT, -- Redundant but useful for queries
    
    -- Target information
    target_cohort_id UUID REFERENCES cohorts.cohorts(cohort_id),
    target_actor_id UUID REFERENCES actors.actors(actor_id),
    
    -- Outcome details
    outcome_type TEXT NOT NULL, -- 'conversion', 'engagement', 'revenue', 'satisfaction', 'churn', 'feedback'
    outcome_category TEXT, -- 'positive', 'negative', 'neutral', 'mixed'
    outcome_description TEXT,
    
    -- Outcome value and metrics
    outcome_value FLOAT NOT NULL, -- Numeric value of the outcome
    outcome_unit TEXT, -- 'currency', 'count', 'percentage', 'score', 'rating'
    outcome_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in outcome measurement
    
    -- Timing information
    outcome_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    stimulus_deployed_at TIMESTAMPTZ, -- When the stimulus was deployed
    time_to_outcome INTEGER, -- Seconds/minutes from stimulus to outcome
    
    -- Context and conditions
    context_data JSONB DEFAULT '{}', -- Context when outcome occurred
    external_factors JSONB DEFAULT '[]', -- External factors that may have influenced outcome
    
    -- Attribution and causality
    attribution_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence that stimulus caused outcome
    causal_factors JSONB DEFAULT '[]', -- Factors that contributed to the outcome
    counterfactual_analysis JSONB DEFAULT '{}', -- What might have happened without stimulus
    
    -- Quality and reliability
    data_quality_score FLOAT DEFAULT 0.0, -- 0-1 quality of outcome data
    measurement_reliability FLOAT DEFAULT 0.0, -- 0-1 reliability of measurement method
    source_systems JSONB DEFAULT '[]', -- Which systems provided this outcome data
    
    -- Learning and analysis
    learning_insights JSONB DEFAULT '[]', -- Key insights from this outcome
    pattern_matches JSONB DEFAULT '[]', -- Patterns this outcome matches
    anomaly_flags JSONB DEFAULT '[]', -- Anomalies detected in this outcome
    
    -- Status and processing
    processing_status TEXT DEFAULT 'pending', -- 'pending', 'processed', 'analyzed', 'learned'
    requires_review BOOLEAN DEFAULT false,
    review_notes TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_outcome_type CHECK (outcome_type IN (
        'conversion', 'engagement', 'revenue', 'satisfaction', 'churn', 'feedback',
        'click', 'open', 'purchase', 'signup', 'unsubscribe', 'complaint', 'other'
    )),
    CONSTRAINT valid_outcome_category CHECK (outcome_category IN ('positive', 'negative', 'neutral', 'mixed')),
    CONSTRAINT valid_processing_status CHECK (processing_status IN (
        'pending', 'processed', 'analyzed', 'learned', 'failed', 'skipped'
    )),
    CONSTRAINT valid_confidence_scores CHECK (
        outcome_confidence >= 0 AND outcome_confidence <= 1 AND
        attribution_confidence >= 0 AND attribution_confidence <= 1 AND
        data_quality_score >= 0 AND data_quality_score <= 1 AND
        measurement_reliability >= 0 AND measurement_reliability <= 1
    )
);

-- =====================================================
-- COHORT OUTCOME SUMMARY TABLE
-- =====================================================
-- Aggregate outcome data by cohort for analysis
CREATE TABLE outcomes.cohort_outcome_summary (
    summary_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    cohort_id UUID NOT NULL REFERENCES cohorts.cohorts(cohort_id) ON DELETE CASCADE,
    stimulus_id UUID REFERENCES stimuli.stimuli_base(stimulus_id),
    
    -- Summary period
    summary_period_start TIMESTAMPTZ NOT NULL,
    summary_period_end TIMESTAMPTZ NOT NULL,
    summary_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Outcome metrics
    outcome_type TEXT NOT NULL,
    total_outcomes INTEGER NOT NULL DEFAULT 0,
    positive_outcomes INTEGER DEFAULT 0,
    negative_outcomes INTEGER DEFAULT 0,
    neutral_outcomes INTEGER DEFAULT 0,
    
    -- Statistical measures
    mean_outcome_value FLOAT,
    median_outcome_value FLOAT,
    standard_deviation FLOAT,
    min_outcome_value FLOAT,
    max_outcome_value FLOAT,
    
    -- Rates and percentages
    outcome_rate FLOAT DEFAULT 0.0, -- 0-1 rate of outcomes per cohort member
    positive_rate FLOAT DEFAULT 0.0, -- 0-1 rate of positive outcomes
    negative_rate FLOAT DEFAULT 0.0, -- 0-1 rate of negative outcomes
    
    -- Cohort context
    cohort_size INTEGER NOT NULL, -- Size of cohort at time of summary
    active_members INTEGER, -- Active members during period
    new_members INTEGER, -- New members during period
    churned_members INTEGER, -- Members who churned during period
    
    -- Performance comparison
    baseline_value FLOAT, -- Baseline for comparison
    improvement_over_baseline FLOAT, -- Improvement percentage
    percentile_rank FLOAT, -- Percentile rank among cohorts
    
    -- Quality metrics
    data_quality_score FLOAT DEFAULT 0.0, -- 0-1 quality of underlying data
    sample_size_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence based on sample size
    
    -- Constraints
    CONSTRAINT valid_outcome_type CHECK (outcome_type IN (
        'conversion', 'engagement', 'revenue', 'satisfaction', 'churn', 'feedback',
        'click', 'open', 'purchase', 'signup', 'unsubscribe', 'complaint', 'other'
    )),
    CONSTRAINT valid_counts CHECK (
        total_outcomes >= 0 AND positive_outcomes >= 0 AND negative_outcomes >= 0 AND
        neutral_outcomes >= 0 AND positive_outcomes + negative_outcomes + neutral_outcomes <= total_outcomes
    ),
    CONSTRAINT valid_rates CHECK (
        outcome_rate >= 0 AND outcome_rate <= 1 AND
        positive_rate >= 0 AND positive_rate <= 1 AND
        negative_rate >= 0 AND negative_rate <= 1
    ),
    CONSTRAINT valid_period CHECK (summary_period_start < summary_period_end),
    CONSTRAINT valid_quality_scores CHECK (
        data_quality_score >= 0 AND data_quality_score <= 1 AND
        sample_size_confidence >= 0 AND sample_size_confidence <= 1
    )
);

-- =====================================================
-- OUTCOME ANALYSIS TABLE
-- =====================================================
-- Detailed analysis of outcome patterns and success factors
CREATE TABLE outcomes.outcome_analysis (
    analysis_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Analysis scope
    analysis_type TEXT NOT NULL, -- 'stimulus_effectiveness', 'cohort_performance', 'temporal_patterns', 'causal_analysis'
    analysis_scope TEXT NOT NULL, -- 'global', 'cohort', 'stimulus', 'time_period'
    scope_id UUID, -- ID of the specific scope (cohort_id, stimulus_id, etc.)
    
    -- Analysis period
    analysis_period_start TIMESTAMPTZ NOT NULL,
    analysis_period_end TIMESTAMPTZ NOT NULL,
    analysis_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Analysis results
    key_findings JSONB NOT NULL, -- Main findings from the analysis
    success_factors JSONB DEFAULT '[]', -- Factors that led to success
    failure_factors JSONB DEFAULT '[]', -- Factors that led to failure
    patterns_detected JSONB DEFAULT '[]', -- Patterns discovered in the data
    
    -- Statistical analysis
    correlation_analysis JSONB DEFAULT '{}', -- Correlations found
    regression_analysis JSONB DEFAULT '{}', -- Regression analysis results
    significance_tests JSONB DEFAULT '{}', -- Statistical significance tests
    
    -- Predictive insights
    predictive_insights JSONB DEFAULT '[]', -- Predictive insights from analysis
    recommendations JSONB DEFAULT '[]', -- Recommendations based on analysis
    confidence_scores JSONB DEFAULT '{}', -- Confidence in various findings
    
    -- Methodology
    analysis_method TEXT NOT NULL, -- 'statistical', 'ml', 'rule_based', 'hybrid'
    analysis_parameters JSONB DEFAULT '{}', -- Parameters used in analysis
    data_sources JSONB DEFAULT '[]', -- Data sources used
    
    -- Quality and validation
    analysis_quality FLOAT DEFAULT 0.0, -- 0-1 quality of analysis
    validation_score FLOAT DEFAULT 0.0, -- 0-1 validation of findings
    peer_review_status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    
    -- Metadata
    created_by TEXT, -- Who created this analysis
    analysis_version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_analysis_type CHECK (analysis_type IN (
        'stimulus_effectiveness', 'cohort_performance', 'temporal_patterns', 'causal_analysis',
        'segmentation_analysis', 'churn_analysis', 'lifetime_value_analysis', 'other'
    )),
    CONSTRAINT valid_analysis_scope CHECK (analysis_scope IN ('global', 'cohort', 'stimulus', 'time_period', 'actor')),
    CONSTRAINT valid_analysis_method CHECK (analysis_method IN ('statistical', 'ml', 'rule_based', 'hybrid', 'expert')),
    CONSTRAINT valid_period CHECK (analysis_period_start < analysis_period_end),
    CONSTRAINT valid_quality_scores CHECK (
        analysis_quality >= 0 AND analysis_quality <= 1 AND
        validation_score >= 0 AND validation_score <= 1
    ),
    CONSTRAINT valid_review_status CHECK (peer_review_status IN ('pending', 'approved', 'rejected', 'needs_revision'))
);

-- =====================================================
-- OUTCOME LEARNING TABLE
-- =====================================================
-- What the system learned from outcomes
CREATE TABLE outcomes.outcome_learning (
    learning_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Learning details
    learning_type TEXT NOT NULL, -- 'belief_update', 'pattern_discovery', 'rule_creation', 'model_update'
    learning_category TEXT NOT NULL, -- 'actor_behavior', 'cohort_characteristics', 'stimulus_effectiveness', 'system_performance'
    
    -- What was learned
    learning_description TEXT NOT NULL,
    learned_facts JSONB NOT NULL, -- Specific facts learned
    confidence_in_learning FLOAT NOT NULL, -- 0-1 confidence in this learning
    
    -- Source of learning
    source_outcomes JSONB NOT NULL, -- Outcome IDs that contributed to this learning
    source_analysis_id UUID REFERENCES outcomes.outcome_analysis(analysis_id),
    learning_algorithm TEXT, -- Algorithm that generated this learning
    
    -- Impact and application
    impact_scope TEXT NOT NULL, -- 'global', 'cohort_specific', 'stimulus_specific', 'actor_specific'
    impact_scope_id UUID, -- Specific scope ID
    expected_impact JSONB DEFAULT '{}', -- Expected impact of this learning
    
    -- Implementation
    implementation_status TEXT DEFAULT 'pending', -- 'pending', 'implemented', 'rejected', 'testing'
    implementation_notes TEXT,
    implemented_at TIMESTAMPTZ,
    implemented_by TEXT,
    
    -- Validation and testing
    validation_status TEXT DEFAULT 'pending', -- 'pending', 'validated', 'invalidated', 'needs_more_data'
    validation_results JSONB DEFAULT '{}', -- Results of validation
    validation_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in validation
    
    -- Learning lifecycle
    learning_strength FLOAT DEFAULT 1.0, -- 0-1 how strong this learning is
    decay_rate FLOAT DEFAULT 0.0, -- Rate at which this learning decays over time
    last_reinforced_at TIMESTAMPTZ, -- When this learning was last reinforced
    
    -- Metadata
    learned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ, -- When this learning expires
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_learning_type CHECK (learning_type IN (
        'belief_update', 'pattern_discovery', 'rule_creation', 'model_update',
        'preference_update', 'behavior_prediction', 'anomaly_detection', 'other'
    )),
    CONSTRAINT valid_learning_category CHECK (learning_category IN (
        'actor_behavior', 'cohort_characteristics', 'stimulus_effectiveness', 'system_performance',
        'market_conditions', 'seasonal_patterns', 'external_factors', 'other'
    )),
    CONSTRAINT valid_impact_scope CHECK (impact_scope IN ('global', 'cohort_specific', 'stimulus_specific', 'actor_specific', 'temporal')),
    CONSTRAINT valid_implementation_status CHECK (implementation_status IN (
        'pending', 'implemented', 'rejected', 'testing', 'paused'
    )),
    CONSTRAINT valid_validation_status CHECK (validation_status IN (
        'pending', 'validated', 'invalidated', 'needs_more_data', 'partially_validated'
    )),
    CONSTRAINT valid_confidence_scores CHECK (
        confidence_in_learning >= 0 AND confidence_in_learning <= 1 AND
        validation_confidence >= 0 AND validation_confidence <= 1 AND
        learning_strength >= 0 AND learning_strength <= 1 AND
        decay_rate >= 0 AND decay_rate <= 1
    )
);

-- =====================================================
-- OUTCOME FEEDBACK LOOP TABLE
-- =====================================================
-- Track how outcomes feed back into the system
CREATE TABLE outcomes.outcome_feedback_loop (
    feedback_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Feedback details
    feedback_type TEXT NOT NULL, -- 'actor_update', 'cohort_update', 'stimulus_update', 'system_update'
    feedback_trigger TEXT NOT NULL, -- What triggered this feedback
    feedback_description TEXT NOT NULL,
    
    -- Source outcome
    source_outcome_id UUID REFERENCES outcomes.outcomes(outcome_id),
    source_analysis_id UUID REFERENCES outcomes.outcome_analysis(analysis_id),
    source_learning_id UUID REFERENCES outcomes.outcome_learning(learning_id),
    
    -- Feedback target
    target_entity_type TEXT NOT NULL, -- 'actor', 'cohort', 'stimulus', 'system'
    target_entity_id UUID NOT NULL, -- ID of the target entity
    target_attribute TEXT, -- Specific attribute being updated
    
    -- Feedback content
    feedback_data JSONB NOT NULL, -- Data to be fed back
    feedback_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in feedback
    feedback_priority TEXT DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    -- Processing status
    processing_status TEXT DEFAULT 'pending', -- 'pending', 'processing', 'applied', 'rejected', 'failed'
    processing_attempts INTEGER DEFAULT 0,
    processing_errors JSONB DEFAULT '[]',
    
    -- Application details
    applied_at TIMESTAMPTZ,
    applied_by TEXT,
    application_notes TEXT,
    application_results JSONB DEFAULT '{}',
    
    -- Validation
    validation_required BOOLEAN DEFAULT false,
    validation_status TEXT DEFAULT 'pending', -- 'pending', 'validated', 'rejected'
    validation_notes TEXT,
    
    -- Timing
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT valid_feedback_type CHECK (feedback_type IN (
        'actor_update', 'cohort_update', 'stimulus_update', 'system_update',
        'belief_update', 'preference_update', 'behavior_update', 'other'
    )),
    CONSTRAINT valid_target_entity_type CHECK (target_entity_type IN ('actor', 'cohort', 'stimulus', 'system', 'model')),
    CONSTRAINT valid_priority CHECK (feedback_priority IN ('low', 'normal', 'high', 'urgent')),
    CONSTRAINT valid_processing_status CHECK (processing_status IN (
        'pending', 'processing', 'applied', 'rejected', 'failed', 'expired'
    )),
    CONSTRAINT valid_validation_status CHECK (validation_status IN ('pending', 'validated', 'rejected', 'expired')),
    CONSTRAINT valid_confidence CHECK (feedback_confidence >= 0 AND feedback_confidence <= 1),
    CONSTRAINT valid_attempts CHECK (processing_attempts >= 0)
);

-- =====================================================
-- INDEXES FOR OUTCOMES SCHEMA
-- =====================================================

-- Outcomes indexes
CREATE INDEX IF NOT EXISTS idx_outcomes_brand_id ON outcomes.outcomes(brand_id);
CREATE INDEX IF NOT EXISTS idx_outcomes_stimulus_id ON outcomes.outcomes(stimulus_id) WHERE stimulus_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_outcomes_target_cohort_id ON outcomes.outcomes(target_cohort_id) WHERE target_cohort_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_outcomes_target_actor_id ON outcomes.outcomes(target_actor_id) WHERE target_actor_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_outcomes_type ON outcomes.outcomes(outcome_type);
CREATE INDEX IF NOT EXISTS idx_outcomes_category ON outcomes.outcomes(outcome_category);
CREATE INDEX IF NOT EXISTS idx_outcomes_timestamp ON outcomes.outcomes(outcome_timestamp);
CREATE INDEX IF NOT EXISTS idx_outcomes_processing_status ON outcomes.outcomes(processing_status);

-- Cohort outcome summary indexes
CREATE INDEX IF NOT EXISTS idx_cohort_outcome_summary_brand_id ON outcomes.cohort_outcome_summary(brand_id);
CREATE INDEX IF NOT EXISTS idx_cohort_outcome_summary_cohort_id ON outcomes.cohort_outcome_summary(cohort_id);
CREATE INDEX IF NOT EXISTS idx_cohort_outcome_summary_stimulus_id ON outcomes.cohort_outcome_summary(stimulus_id) WHERE stimulus_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_cohort_outcome_summary_type ON outcomes.cohort_outcome_summary(outcome_type);
CREATE INDEX IF NOT EXISTS idx_cohort_outcome_summary_period_start ON outcomes.cohort_outcome_summary(summary_period_start);
CREATE INDEX IF NOT EXISTS idx_cohort_outcome_summary_period_end ON outcomes.cohort_outcome_summary(summary_period_end);

-- Outcome analysis indexes
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_brand_id ON outcomes.outcome_analysis(brand_id);
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_type ON outcomes.outcome_analysis(analysis_type);
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_scope ON outcomes.outcome_analysis(analysis_scope);
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_scope_id ON outcomes.outcome_analysis(scope_id) WHERE scope_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_period_start ON outcomes.outcome_analysis(analysis_period_start);
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_period_end ON outcomes.outcome_analysis(analysis_period_end);
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_current ON outcomes.outcome_analysis(is_current) WHERE is_current = true;

-- Outcome learning indexes
CREATE INDEX IF NOT EXISTS idx_outcome_learning_brand_id ON outcomes.outcome_learning(brand_id);
CREATE INDEX IF NOT EXISTS idx_outcome_learning_type ON outcomes.outcome_learning(learning_type);
CREATE INDEX IF NOT EXISTS idx_outcome_learning_category ON outcomes.outcome_learning(learning_category);
CREATE INDEX IF NOT EXISTS idx_outcome_learning_impact_scope ON outcomes.outcome_learning(impact_scope);
CREATE INDEX IF NOT EXISTS idx_outcome_learning_impact_scope_id ON outcomes.outcome_learning(impact_scope_id) WHERE impact_scope_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_outcome_learning_implementation_status ON outcomes.outcome_learning(implementation_status);
CREATE INDEX IF NOT EXISTS idx_outcome_learning_validation_status ON outcomes.outcome_learning(validation_status);
CREATE INDEX IF NOT EXISTS idx_outcome_learning_active ON outcomes.outcome_learning(is_active) WHERE is_active = true;

-- Outcome feedback loop indexes
CREATE INDEX IF NOT EXISTS idx_outcome_feedback_loop_brand_id ON outcomes.outcome_feedback_loop(brand_id);
CREATE INDEX IF NOT EXISTS idx_outcome_feedback_loop_type ON outcomes.outcome_feedback_loop(feedback_type);
CREATE INDEX IF NOT EXISTS idx_outcome_feedback_loop_target_entity_type ON outcomes.outcome_feedback_loop(target_entity_type);
CREATE INDEX IF NOT EXISTS idx_outcome_feedback_loop_target_entity_id ON outcomes.outcome_feedback_loop(target_entity_id);
CREATE INDEX IF NOT EXISTS idx_outcome_feedback_loop_processing_status ON outcomes.outcome_feedback_loop(processing_status);
CREATE INDEX IF NOT EXISTS idx_outcome_feedback_loop_priority ON outcomes.outcome_feedback_loop(feedback_priority);
CREATE INDEX IF NOT EXISTS idx_outcome_feedback_loop_created_at ON outcomes.outcome_feedback_loop(created_at);

-- =====================================================
-- TRIGGERS FOR OUTCOMES SCHEMA
-- =====================================================

-- Update timestamps
CREATE TRIGGER update_outcomes_updated_at 
    BEFORE UPDATE ON outcomes.outcomes 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Auto-process outcomes when they reach certain thresholds
CREATE OR REPLACE FUNCTION outcomes.auto_process_outcomes()
RETURNS TRIGGER AS $$
BEGIN
    -- Auto-process outcomes with high confidence and quality
    IF NEW.outcome_confidence >= 0.8 AND NEW.data_quality_score >= 0.8 THEN
        NEW.processing_status = 'processed';
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER auto_process_outcomes_trigger
    BEFORE INSERT OR UPDATE ON outcomes.outcomes
    FOR EACH ROW EXECUTE FUNCTION outcomes.auto_process_outcomes();

-- =====================================================
-- COMMENTS FOR OUTCOMES SCHEMA
-- =====================================================

COMMENT ON SCHEMA outcomes IS 'Results tracking and learning from stimulus outcomes to improve future decisions';
COMMENT ON TABLE outcomes.outcomes IS 'Central outcomes tracking with full traceability to stimuli and actors';
COMMENT ON TABLE outcomes.cohort_outcome_summary IS 'Aggregate outcome data by cohort for performance analysis';
COMMENT ON TABLE outcomes.outcome_analysis IS 'Detailed analysis of outcome patterns and success factors';
COMMENT ON TABLE outcomes.outcome_learning IS 'What the system learned from outcomes to improve future performance';
COMMENT ON TABLE outcomes.outcome_feedback_loop IS 'Track how outcomes feed back into the system for continuous improvement';

COMMENT ON COLUMN outcomes.outcomes.outcome_value IS 'Numeric value of the outcome in the specified unit';
COMMENT ON COLUMN outcomes.outcomes.attribution_confidence IS 'Confidence that the stimulus caused this outcome (0-1)';
COMMENT ON COLUMN outcomes.outcomes.causal_factors IS 'Factors that contributed to the outcome';
COMMENT ON COLUMN outcomes.cohort_outcome_summary.outcome_rate IS 'Rate of outcomes per cohort member (0-1)';
COMMENT ON COLUMN outcomes.cohort_outcome_summary.percentile_rank IS 'Percentile rank of this cohort among all cohorts';
COMMENT ON COLUMN outcomes.outcome_analysis.key_findings IS 'Main findings from the analysis as JSONB';
COMMENT ON COLUMN outcomes.outcome_analysis.success_factors IS 'Factors that led to success';
COMMENT ON COLUMN outcomes.outcome_learning.learned_facts IS 'Specific facts learned from outcomes';
COMMENT ON COLUMN outcomes.outcome_learning.learning_strength IS 'How strong this learning is (0-1)';
COMMENT ON COLUMN outcomes.outcome_feedback_loop.feedback_data IS 'Data to be fed back into the system';
