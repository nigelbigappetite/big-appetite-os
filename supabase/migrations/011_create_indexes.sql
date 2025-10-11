-- =====================================================
-- ADDITIONAL PERFORMANCE INDEXES
-- =====================================================
-- This migration creates additional performance indexes for common query patterns
-- that weren't covered in the individual schema migrations.

-- =====================================================
-- CROSS-SCHEMA RELATIONSHIP INDEXES
-- =====================================================

-- Actor identifier lookups across schemas
CREATE INDEX IF NOT EXISTS idx_actors_identifier_lookup ON actors.actors(brand_id, primary_identifier, primary_identifier_type) WHERE is_active = true;

-- Signal-actor relationship indexes
CREATE INDEX IF NOT EXISTS idx_signals_actor_lookup ON signals.signals_base(brand_id, actor_id, received_at) WHERE actor_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_signals_identifier_lookup ON signals.signals_base(brand_id, actor_identifier, actor_identifier_type, received_at) WHERE actor_identifier IS NOT NULL;

-- Stimulus-target relationship indexes
CREATE INDEX IF NOT EXISTS idx_stimuli_target_cohort ON stimuli.stimuli_base(brand_id, target_cohort_id, created_at) WHERE target_cohort_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_stimuli_target_actor ON stimuli.stimuli_base(brand_id, target_actor_id, created_at) WHERE target_actor_id IS NOT NULL;

-- Outcome-source relationship indexes
CREATE INDEX IF NOT EXISTS idx_outcomes_stimulus ON outcomes.outcomes(brand_id, stimulus_id, outcome_timestamp) WHERE stimulus_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_outcomes_target_cohort ON outcomes.outcomes(brand_id, target_cohort_id, outcome_timestamp) WHERE target_cohort_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_outcomes_target_actor ON outcomes.outcomes(brand_id, target_actor_id, outcome_timestamp) WHERE target_actor_id IS NOT NULL;

-- =====================================================
-- TEMPORAL QUERY INDEXES
-- =====================================================

-- Time-based queries for signals
CREATE INDEX IF NOT EXISTS idx_signals_temporal_brand ON signals.signals_base(brand_id, received_at DESC) WHERE processing_status = 'completed';
CREATE INDEX IF NOT EXISTS idx_signals_temporal_type ON signals.signals_base(signal_type, received_at DESC) WHERE processing_status = 'completed';

-- Time-based queries for actors
CREATE INDEX IF NOT EXISTS idx_actors_temporal_brand ON actors.actors(brand_id, last_seen_at DESC) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_actors_temporal_signals ON actors.actors(brand_id, last_signal_at DESC) WHERE last_signal_at IS NOT NULL;

-- Time-based queries for cohorts
CREATE INDEX IF NOT EXISTS idx_cohorts_temporal_brand ON cohorts.cohorts(brand_id, discovered_at DESC) WHERE cohort_status = 'active';
CREATE INDEX IF NOT EXISTS idx_cohorts_temporal_updated ON cohorts.cohorts(brand_id, last_updated_at DESC) WHERE cohort_status = 'active';

-- Time-based queries for stimuli
CREATE INDEX IF NOT EXISTS idx_stimuli_temporal_brand ON stimuli.stimuli_base(brand_id, created_at DESC) WHERE status IN ('active', 'scheduled');
CREATE INDEX IF NOT EXISTS idx_stimuli_temporal_scheduled ON stimuli.stimuli_base(scheduled_for, status) WHERE scheduled_for IS NOT NULL AND status = 'scheduled';

-- Time-based queries for outcomes
CREATE INDEX IF NOT EXISTS idx_outcomes_temporal_brand ON outcomes.outcomes(brand_id, outcome_timestamp DESC) WHERE processing_status = 'completed';
CREATE INDEX IF NOT EXISTS idx_outcomes_temporal_type ON outcomes.outcomes(outcome_type, outcome_timestamp DESC) WHERE processing_status = 'completed';

-- =====================================================
-- QUALITY AND CONFIDENCE INDEXES
-- =====================================================

-- High-quality signals
CREATE INDEX IF NOT EXISTS idx_signals_high_quality ON signals.signals_base(brand_id, quality_score DESC, received_at DESC) WHERE quality_score >= 0.8;

-- High-confidence actor matches
CREATE INDEX IF NOT EXISTS idx_signals_high_confidence ON signals.signals_base(brand_id, confidence_in_matching DESC, received_at DESC) WHERE confidence_in_matching >= 0.8;

-- High-quality actors
CREATE INDEX IF NOT EXISTS idx_actors_high_quality ON actors.actors(brand_id, data_quality_score DESC, last_seen_at DESC) WHERE data_quality_score >= 0.8;

-- High-confidence beliefs
CREATE INDEX IF NOT EXISTS idx_actor_demographics_high_confidence ON actors.actor_demographics(actor_id, confidence DESC) WHERE confidence >= 0.8 AND is_current = true;

-- High-stability cohorts
CREATE INDEX IF NOT EXISTS idx_cohorts_high_stability ON cohorts.cohorts(brand_id, stability_score DESC, member_count DESC) WHERE stability_score >= 0.8 AND cohort_status = 'active';

-- High-confidence memberships
CREATE INDEX IF NOT EXISTS idx_membership_high_confidence ON cohorts.actor_cohort_membership(cohort_id, membership_confidence DESC) WHERE membership_confidence >= 0.8 AND is_active = true;

-- =====================================================
-- PERFORMANCE METRICS INDEXES
-- =====================================================

-- Stimulus performance by cohort
CREATE INDEX IF NOT EXISTS idx_stimulus_performance_cohort ON stimuli.stimulus_performance_metrics(stimulus_id, context_id, measurement_date DESC) WHERE context_type = 'by_cohort';

-- Cohort performance over time
CREATE INDEX IF NOT EXISTS idx_cohort_performance_temporal ON cohorts.cohort_performance_metrics(cohort_id, measurement_date DESC, metric_name);

-- Function call performance
CREATE INDEX IF NOT EXISTS idx_function_calls_performance ON ai.function_calls(function_id, execution_time_ms, call_timestamp DESC) WHERE execution_status = 'completed';

-- Learning effectiveness
CREATE INDEX IF NOT EXISTS idx_learning_effectiveness ON ai.learning_logs(brand_id, learning_quality DESC, learned_at DESC) WHERE learning_quality >= 0.8 AND is_active = true;

-- =====================================================
-- SEARCH AND DISCOVERY INDEXES
-- =====================================================

-- Text search indexes for signals
CREATE INDEX IF NOT EXISTS idx_signals_text_search ON signals.signals_base USING gin(to_tsvector('english', raw_content)) WHERE processing_status = 'completed';

-- Text search indexes for reviews
CREATE INDEX IF NOT EXISTS idx_reviews_text_search ON signals.reviews USING gin(to_tsvector('english', review_text)) WHERE review_text IS NOT NULL;

-- Text search indexes for social comments
CREATE INDEX IF NOT EXISTS idx_social_comments_text_search ON signals.social_comments USING gin(to_tsvector('english', comment_text)) WHERE comment_text IS NOT NULL;

-- Text search indexes for reasoning logs
CREATE INDEX IF NOT EXISTS idx_reasoning_logs_text_search ON ai.reasoning_logs USING gin(to_tsvector('english', decision_made));

-- Text search indexes for learning logs
CREATE INDEX IF NOT EXISTS idx_learning_logs_text_search ON ai.learning_logs USING gin(to_tsvector('english', learning_description || ' ' || COALESCE(knowledge_gained::text, '')));

-- =====================================================
-- ANALYTICAL QUERY INDEXES
-- =====================================================

-- Actor behavior patterns
CREATE INDEX IF NOT EXISTS idx_actor_behavioral_patterns ON actors.actor_behavioral_scores(actor_id, behavior_type, context, last_updated_at DESC) WHERE is_current = true;

-- Cohort characteristics analysis
CREATE INDEX IF NOT EXISTS idx_cohort_characteristics_analysis ON cohorts.cohort_characteristics(cohort_id, characteristic_type, importance_score DESC) WHERE is_current = true;

-- Outcome analysis by type
CREATE INDEX IF NOT EXISTS idx_outcome_analysis_type ON outcomes.outcome_analysis(analysis_type, analysis_period_start DESC) WHERE is_current = true;

-- Contradiction analysis
CREATE INDEX IF NOT EXISTS idx_contradiction_analysis ON ai.contradiction_logs(brand_id, contradiction_type, contradiction_severity, detected_at DESC) WHERE resolution_status = 'unresolved';

-- =====================================================
-- MAINTENANCE AND CLEANUP INDEXES
-- =====================================================

-- Note: Cleanup indexes with NOW() functions are commented out
-- as they cause issues with index predicates. Use application-level
-- cleanup instead.

-- Old signals cleanup (commented out - use application logic)
-- CREATE INDEX IF NOT EXISTS idx_signals_cleanup ON signals.signals_base(received_at) WHERE received_at < NOW() - INTERVAL '2 years';

-- Inactive actors cleanup (commented out - use application logic)
-- CREATE INDEX IF NOT EXISTS idx_actors_cleanup ON actors.actors(last_seen_at) WHERE is_active = false AND last_seen_at < NOW() - INTERVAL '1 year';

-- Completed function calls cleanup (commented out - use application logic)
-- CREATE INDEX IF NOT EXISTS idx_function_calls_cleanup ON ai.function_calls(call_timestamp) WHERE execution_status = 'completed' AND call_timestamp < NOW() - INTERVAL '6 months';

-- Old learning logs cleanup (commented out - use application logic)
-- CREATE INDEX IF NOT EXISTS idx_learning_logs_cleanup ON ai.learning_logs(learned_at) WHERE is_active = false AND learned_at < NOW() - INTERVAL '1 year';

-- =====================================================
-- COMPOSITE INDEXES FOR COMPLEX QUERIES
-- =====================================================

-- Actor-cohort-stimulus-outcome chain
CREATE INDEX IF NOT EXISTS idx_actor_cohort_stimulus_outcome ON outcomes.outcomes(target_actor_id, target_cohort_id, stimulus_id, outcome_timestamp DESC) WHERE processing_status = 'completed';

-- Signal processing pipeline
CREATE INDEX IF NOT EXISTS idx_signal_processing_pipeline ON signals.signals_base(brand_id, processing_status, received_at) WHERE processing_status IN ('pending', 'processing');

-- Cohort evolution tracking
CREATE INDEX IF NOT EXISTS idx_cohort_evolution_tracking ON cohorts.cohort_evolution_log(cohort_id, event_type, event_timestamp DESC);

-- Function call chain tracking
CREATE INDEX IF NOT EXISTS idx_function_call_chain ON ai.function_calls(parent_call_id, call_timestamp) WHERE parent_call_id IS NOT NULL;

-- =====================================================
-- PARTIAL INDEXES FOR SPECIFIC CONDITIONS
-- =====================================================

-- Active memberships only
CREATE INDEX IF NOT EXISTS idx_active_memberships ON cohorts.actor_cohort_membership(actor_id, cohort_id, membership_confidence) WHERE is_active = true;

-- Current beliefs only
CREATE INDEX IF NOT EXISTS idx_current_beliefs ON actors.actor_demographics(actor_id, attribute_name, confidence) WHERE is_current = true;

-- Active cohorts only
CREATE INDEX IF NOT EXISTS idx_active_cohorts ON cohorts.cohorts(brand_id, member_count, stability_score) WHERE cohort_status = 'active';

-- Pending processing only
CREATE INDEX IF NOT EXISTS idx_pending_processing ON signals.signals_base(brand_id, received_at) WHERE processing_status = 'pending';

-- High-priority stimuli only
CREATE INDEX IF NOT EXISTS idx_high_priority_stimuli ON stimuli.stimuli_base(brand_id, scheduled_for) WHERE priority > 0 AND status = 'scheduled';

-- =====================================================
-- STATISTICS AND MONITORING INDEXES
-- =====================================================

-- System health monitoring
CREATE INDEX IF NOT EXISTS idx_system_health_monitoring ON ai.ai_system_state(last_updated_at DESC) WHERE overall_health_score IS NOT NULL;

-- Performance monitoring
CREATE INDEX IF NOT EXISTS idx_performance_monitoring ON ai.function_calls(call_timestamp, execution_time_ms) WHERE execution_status = 'completed';

-- Error monitoring
CREATE INDEX IF NOT EXISTS idx_error_monitoring ON ai.function_calls(call_timestamp, execution_status) WHERE execution_status = 'failed';

-- Learning progress monitoring
CREATE INDEX IF NOT EXISTS idx_learning_progress ON ai.learning_logs(brand_id, learned_at, learning_quality) WHERE is_active = true;

-- =====================================================
-- COMMENTS FOR INDEXES
-- =====================================================

COMMENT ON INDEX idx_actors_identifier_lookup IS 'Fast lookup of actors by identifier across schemas';
COMMENT ON INDEX idx_signals_actor_lookup IS 'Fast lookup of signals by actor for relationship queries';
COMMENT ON INDEX idx_stimuli_target_cohort IS 'Fast lookup of stimuli by target cohort';
COMMENT ON INDEX idx_outcomes_stimulus IS 'Fast lookup of outcomes by source stimulus';
COMMENT ON INDEX idx_signals_temporal_brand IS 'Time-based queries for signals by brand';
COMMENT ON INDEX idx_actors_temporal_brand IS 'Time-based queries for actors by brand';
COMMENT ON INDEX idx_cohorts_temporal_brand IS 'Time-based queries for cohorts by brand';
COMMENT ON INDEX idx_signals_high_quality IS 'High-quality signals for analysis';
COMMENT ON INDEX idx_actors_high_quality IS 'High-quality actors for analysis';
COMMENT ON INDEX idx_cohorts_high_stability IS 'High-stability cohorts for analysis';
COMMENT ON INDEX idx_signals_text_search IS 'Full-text search on signal content';
COMMENT ON INDEX idx_reviews_text_search IS 'Full-text search on review content';
COMMENT ON INDEX idx_social_comments_text_search IS 'Full-text search on social comment content';
COMMENT ON INDEX idx_actor_cohort_stimulus_outcome IS 'Complete actor-cohort-stimulus-outcome chain';
COMMENT ON INDEX idx_signal_processing_pipeline IS 'Signal processing pipeline status';
COMMENT ON INDEX idx_cohort_evolution_tracking IS 'Cohort evolution event tracking';
COMMENT ON INDEX idx_active_memberships IS 'Active cohort memberships only';
COMMENT ON INDEX idx_current_beliefs IS 'Current actor beliefs only';
COMMENT ON INDEX idx_active_cohorts IS 'Active cohorts only';
COMMENT ON INDEX idx_pending_processing IS 'Signals pending processing';
COMMENT ON INDEX idx_high_priority_stimuli IS 'High-priority scheduled stimuli';
COMMENT ON INDEX idx_system_health_monitoring IS 'System health monitoring queries';
COMMENT ON INDEX idx_performance_monitoring IS 'Function call performance monitoring';
COMMENT ON INDEX idx_error_monitoring IS 'Function call error monitoring';
COMMENT ON INDEX idx_learning_progress IS 'Learning progress monitoring';
