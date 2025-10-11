-- =====================================================
-- HELPER FUNCTIONS - Core System Operations
-- =====================================================
-- This migration creates PL/pgSQL function stubs for all core operations.
-- Full implementations will be built in Phase 3, but these provide the
-- foundation and interface for the system's intelligence.

-- =====================================================
-- SIGNAL PROCESSING FUNCTIONS
-- =====================================================

-- Match signal to existing actor or create new
CREATE OR REPLACE FUNCTION signals.match_or_create_actor(
    signal_data JSONB,
    identifier_value TEXT,
    identifier_type TEXT,
    brand_id UUID
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    actor_id UUID;
    confidence FLOAT;
BEGIN
    -- TODO: Implement actor matching logic
    -- For now, return a placeholder UUID
    -- This will be fully implemented in Phase 3
    
    -- Check if actor exists with this identifier
    SELECT a.actor_id INTO actor_id
    FROM actors.actors a
    WHERE a.brand_id = match_or_create_actor.brand_id
      AND a.primary_identifier = identifier_value
      AND a.primary_identifier_type = identifier_type
      AND a.is_active = true
    LIMIT 1;
    
    -- If actor exists, return their ID
    IF actor_id IS NOT NULL THEN
        RETURN actor_id;
    END IF;
    
    -- Create new actor
    INSERT INTO actors.actors (
        brand_id,
        primary_identifier,
        primary_identifier_type,
        first_seen_at,
        last_seen_at
    ) VALUES (
        brand_id,
        identifier_value,
        identifier_type,
        NOW(),
        NOW()
    ) RETURNING actor_id INTO actor_id;
    
    RETURN actor_id;
END;
$$;

-- Mark an outcome as a new signal for re-entry
CREATE OR REPLACE FUNCTION signals.mark_outcome_as_signal(
    outcome_id UUID
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    signal_id UUID;
    outcome_record RECORD;
BEGIN
    -- TODO: Implement outcome-to-signal conversion
    -- This will be fully implemented in Phase 3
    
    -- Get outcome details
    SELECT * INTO outcome_record
    FROM outcomes.outcomes
    WHERE outcome_id = mark_outcome_as_signal.outcome_id;
    
    -- Create new signal from outcome
    INSERT INTO signals.signals_base (
        signal_type,
        brand_id,
        raw_content,
        processed_content,
        actor_id,
        actor_identifier,
        actor_identifier_type,
        received_at,
        processed_at,
        processing_status,
        confidence_in_matching,
        source_platform,
        source_id,
        metadata
    ) VALUES (
        'outcome_signal',
        outcome_record.brand_id,
        outcome_record.outcome_description,
        jsonb_build_object(
            'outcome_type', outcome_record.outcome_type,
            'outcome_value', outcome_record.outcome_value,
            'outcome_unit', outcome_record.outcome_unit
        ),
        outcome_record.target_actor_id,
        NULL, -- Will be populated based on actor
        NULL, -- Will be populated based on actor
        outcome_record.outcome_timestamp,
        NOW(),
        'completed',
        1.0, -- High confidence since it's from our own system
        'internal',
        outcome_record.outcome_id::TEXT,
        jsonb_build_object('source_outcome_id', outcome_record.outcome_id)
    ) RETURNING signal_id INTO signal_id;
    
    RETURN signal_id;
END;
$$;

-- =====================================================
-- ACTOR MANAGEMENT FUNCTIONS
-- =====================================================

-- Bayesian belief update
CREATE OR REPLACE FUNCTION actors.update_actor_belief(
    actor_id UUID,
    belief_path TEXT,
    new_evidence JSONB,
    signal_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    result JSONB;
    current_belief RECORD;
    updated_confidence FLOAT;
    updated_evidence_count INTEGER;
BEGIN
    -- TODO: Implement Bayesian belief update logic
    -- This will be fully implemented in Phase 3
    
    -- For now, create a simple belief update
    -- In Phase 3, this will implement proper Bayesian updating
    
    -- Get current belief if it exists
    SELECT * INTO current_belief
    FROM actors.actor_demographics
    WHERE actor_id = update_actor_belief.actor_id
      AND attribute_name = belief_path
      AND is_current = true
    LIMIT 1;
    
    -- Calculate updated confidence (simplified)
    IF current_belief IS NOT NULL THEN
        updated_confidence := LEAST(1.0, current_belief.confidence + 0.1);
        updated_evidence_count := current_belief.evidence_count + 1;
    ELSE
        updated_confidence := 0.5; -- Initial confidence
        updated_evidence_count := 1;
    END IF;
    
    -- Update or insert belief
    INSERT INTO actors.actor_demographics (
        actor_id,
        attribute_name,
        attribute_value,
        confidence,
        evidence_count,
        last_updated_at,
        source_signals,
        source_weights
    ) VALUES (
        actor_id,
        belief_path,
        new_evidence,
        updated_confidence,
        updated_evidence_count,
        NOW(),
        jsonb_build_array(signal_id),
        jsonb_build_array(1.0)
    ) ON CONFLICT (actor_id, attribute_name, version) DO UPDATE SET
        attribute_value = EXCLUDED.attribute_value,
        confidence = EXCLUDED.confidence,
        evidence_count = EXCLUDED.evidence_count,
        last_updated_at = EXCLUDED.last_updated_at,
        source_signals = EXCLUDED.source_signals,
        source_weights = EXCLUDED.source_weights,
        is_current = true;
    
    -- Mark old versions as not current
    UPDATE actors.actor_demographics
    SET is_current = false
    WHERE actor_id = update_actor_belief.actor_id
      AND attribute_name = belief_path
      AND is_current = true
      AND demographic_id != (
          SELECT demographic_id
          FROM actors.actor_demographics
          WHERE actor_id = update_actor_belief.actor_id
            AND attribute_name = belief_path
            AND is_current = true
          ORDER BY last_updated_at DESC
          LIMIT 1
      );
    
    result := jsonb_build_object(
        'success', true,
        'updated_confidence', updated_confidence,
        'evidence_count', updated_evidence_count,
        'belief_path', belief_path
    );
    
    RETURN result;
END;
$$;

-- Detect contradictions between stated and behavior
CREATE OR REPLACE FUNCTION actors.detect_actor_contradictions(
    actor_id UUID,
    updated_beliefs TEXT[]
) RETURNS JSONB[]
LANGUAGE plpgsql
AS $$
DECLARE
    contradictions JSONB[] := '{}';
    contradiction JSONB;
    belief TEXT;
BEGIN
    -- TODO: Implement contradiction detection logic
    -- This will be fully implemented in Phase 3
    
    -- For now, return empty array
    -- In Phase 3, this will analyze beliefs for contradictions
    
    RETURN contradictions;
END;
$$;

-- Update belief vector after belief changes
CREATE OR REPLACE FUNCTION actors.update_belief_vector(
    actor_id UUID
) RETURNS FLOAT[]
LANGUAGE plpgsql
AS $$
DECLARE
    belief_vector FLOAT[] := '{}';
BEGIN
    -- TODO: Implement belief vector update logic
    -- This will be fully implemented in Phase 3
    
    -- For now, return empty array
    -- In Phase 3, this will generate numeric vector from beliefs
    
    RETURN belief_vector;
END;
$$;

-- =====================================================
-- CLUSTERING FUNCTIONS
-- =====================================================

-- Trigger clustering run
CREATE OR REPLACE FUNCTION cohorts.trigger_clustering_run(
    brand_id UUID,
    algorithm TEXT,
    parameters JSONB
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    run_id UUID;
BEGIN
    -- TODO: Implement clustering trigger logic
    -- This will be fully implemented in Phase 3
    
    -- Create clustering run record
    INSERT INTO cohorts.clustering_runs (
        brand_id,
        algorithm_name,
        parameters,
        input_actor_count,
        input_vector_type,
        input_vector_dimensions,
        status
    ) VALUES (
        brand_id,
        algorithm,
        parameters,
        0, -- Will be calculated in Phase 3
        'combined', -- Will be configurable in Phase 3
        1536, -- Will be configurable in Phase 3
        'running'
    ) RETURNING run_id INTO run_id;
    
    RETURN run_id;
END;
$$;

-- Assign actor to cohort
CREATE OR REPLACE FUNCTION cohorts.assign_actor_to_cohort(
    actor_id UUID,
    cohort_id UUID,
    distance FLOAT,
    confidence FLOAT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: Implement actor-cohort assignment logic
    -- This will be fully implemented in Phase 3
    
    -- Insert or update membership
    INSERT INTO cohorts.actor_cohort_membership (
        actor_id,
        cohort_id,
        membership_confidence,
        distance_to_centroid,
        assigned_by_algorithm,
        membership_strength
    ) VALUES (
        actor_id,
        cohort_id,
        confidence,
        distance,
        'system',
        confidence
    ) ON CONFLICT (actor_id, cohort_id) DO UPDATE SET
        membership_confidence = EXCLUDED.membership_confidence,
        distance_to_centroid = EXCLUDED.distance_to_centroid,
        membership_strength = EXCLUDED.membership_strength,
        last_updated_at = NOW();
END;
$$;

-- Log cohort evolution event
CREATE OR REPLACE FUNCTION cohorts.log_cohort_evolution(
    cohort_id UUID,
    event_type TEXT,
    before_state JSONB,
    after_state JSONB,
    trigger_reason TEXT
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    evolution_id UUID;
    brand_id UUID;
BEGIN
    -- Get brand_id from cohort
    SELECT c.brand_id INTO brand_id
    FROM cohorts.cohorts c
    WHERE c.cohort_id = log_cohort_evolution.cohort_id;
    
    -- Create evolution log entry
    INSERT INTO cohorts.cohort_evolution_log (
        cohort_id,
        brand_id,
        event_type,
        event_description,
        trigger_reason,
        before_state,
        after_state,
        event_confidence,
        event_importance
    ) VALUES (
        cohort_id,
        brand_id,
        event_type,
        'Cohort evolution event: ' || event_type,
        trigger_reason,
        before_state,
        after_state,
        1.0, -- Will be calculated in Phase 3
        0.5  -- Will be calculated in Phase 3
    ) RETURNING evolution_id INTO evolution_id;
    
    RETURN evolution_id;
END;
$$;

-- =====================================================
-- FUNCTION REGISTRY FUNCTIONS
-- =====================================================

-- Register a new logic function
CREATE OR REPLACE FUNCTION ai.register_function(
    function_name TEXT,
    function_type TEXT,
    version TEXT,
    parameters JSONB,
    description TEXT
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    function_id UUID;
BEGIN
    -- TODO: Implement function registration logic
    -- This will be fully implemented in Phase 3
    
    -- Insert function record
    INSERT INTO ai.functions (
        function_name,
        function_type,
        function_category,
        version,
        description,
        purpose,
        input_schema,
        output_schema,
        parameters,
        implementation_type,
        validation_status
    ) VALUES (
        function_name,
        function_type,
        'other', -- Will be determined in Phase 3
        version,
        description,
        description, -- Will be more detailed in Phase 3
        '{}', -- Will be populated in Phase 3
        '{}', -- Will be populated in Phase 3
        parameters,
        'plpgsql', -- Default for now
        'pending'
    ) RETURNING function_id INTO function_id;
    
    RETURN function_id;
END;
$$;

-- Log function call
CREATE OR REPLACE FUNCTION ai.log_function_call(
    function_id UUID,
    inputs JSONB,
    outputs JSONB,
    confidence FLOAT,
    execution_time_ms INTEGER
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    call_id UUID;
    brand_id UUID;
BEGIN
    -- Get brand_id from function
    SELECT f.brand_id INTO brand_id
    FROM ai.functions f
    WHERE f.function_id = log_function_call.function_id;
    
    -- Insert function call record
    INSERT INTO ai.function_calls (
        function_id,
        brand_id,
        call_type,
        input_data,
        output_data,
        execution_status,
        execution_time_ms,
        confidence_score
    ) VALUES (
        function_id,
        COALESCE(brand_id, '00000000-0000-0000-0000-000000000000'::UUID),
        'manual', -- Will be determined by caller in Phase 3
        inputs,
        outputs,
        'completed',
        execution_time_ms,
        confidence
    ) RETURNING call_id INTO call_id;
    
    RETURN call_id;
END;
$$;

-- =====================================================
-- OUTCOME PROCESSING FUNCTIONS
-- =====================================================

-- Process outcome and trigger learning
CREATE OR REPLACE FUNCTION outcomes.process_stimulus_outcome(
    outcome_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    result JSONB;
    outcome_record RECORD;
BEGIN
    -- TODO: Implement outcome processing logic
    -- This will be fully implemented in Phase 3
    
    -- Get outcome details
    SELECT * INTO outcome_record
    FROM outcomes.outcomes
    WHERE outcome_id = process_stimulus_outcome.outcome_id;
    
    -- Update processing status
    UPDATE outcomes.outcomes
    SET processing_status = 'processed',
        updated_at = NOW()
    WHERE outcome_id = process_stimulus_outcome.outcome_id;
    
    result := jsonb_build_object(
        'success', true,
        'outcome_id', outcome_id,
        'processing_status', 'processed'
    );
    
    RETURN result;
END;
$$;

-- Get stimulus effectiveness by cohort
CREATE OR REPLACE FUNCTION outcomes.get_stimulus_effectiveness_by_cohort(
    stimulus_id UUID
) RETURNS TABLE (
    cohort_id UUID,
    response_rate FLOAT,
    avg_outcome_value FLOAT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: Implement effectiveness calculation logic
    -- This will be fully implemented in Phase 3
    
    -- For now, return empty table
    -- In Phase 3, this will calculate actual effectiveness metrics
    
    RETURN QUERY
    SELECT 
        NULL::UUID as cohort_id,
        0.0::FLOAT as response_rate,
        0.0::FLOAT as avg_outcome_value,
        0.0::NUMERIC as total_revenue
    WHERE FALSE; -- Return no rows for now
END;
$$;

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Get actor profile summary
CREATE OR REPLACE FUNCTION actors.get_actor_profile_summary(
    actor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    profile JSONB;
    actor_record RECORD;
BEGIN
    -- Get basic actor information
    SELECT * INTO actor_record
    FROM actors.actors
    WHERE actor_id = get_actor_profile_summary.actor_id;
    
    -- Build profile summary
    profile := jsonb_build_object(
        'actor_id', actor_record.actor_id,
        'primary_identifier', actor_record.primary_identifier,
        'primary_identifier_type', actor_record.primary_identifier_type,
        'is_active', actor_record.is_active,
        'is_verified', actor_record.is_verified,
        'first_seen_at', actor_record.first_seen_at,
        'last_seen_at', actor_record.last_seen_at,
        'total_signals', actor_record.total_signals,
        'data_quality_score', actor_record.data_quality_score,
        'profile_completeness', actor_record.profile_completeness
    );
    
    RETURN profile;
END;
$$;

-- Get cohort summary
CREATE OR REPLACE FUNCTION cohorts.get_cohort_summary(
    cohort_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    summary JSONB;
    cohort_record RECORD;
BEGIN
    -- Get basic cohort information
    SELECT * INTO cohort_record
    FROM cohorts.cohorts
    WHERE cohort_id = get_cohort_summary.cohort_id;
    
    -- Build cohort summary
    summary := jsonb_build_object(
        'cohort_id', cohort_record.cohort_id,
        'cohort_name', cohort_record.cohort_name,
        'cohort_type', cohort_record.cohort_type,
        'cohort_status', cohort_record.cohort_status,
        'member_count', cohort_record.member_count,
        'stability_score', cohort_record.stability_score,
        'coherence_score', cohort_record.coherence_score,
        'separation_score', cohort_record.separation_score,
        'discovered_at', cohort_record.discovered_at,
        'last_updated_at', cohort_record.last_updated_at
    );
    
    RETURN summary;
END;
$$;

-- Get system health status
CREATE OR REPLACE FUNCTION ai.get_system_health_status(
    brand_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    health_status JSONB;
    system_state RECORD;
BEGIN
    -- Get system state
    SELECT * INTO system_state
    FROM ai.ai_system_state
    WHERE (brand_id IS NULL OR ai.ai_system_state.brand_id = get_system_health_status.brand_id)
    ORDER BY last_updated_at DESC
    LIMIT 1;
    
    -- Build health status
    health_status := jsonb_build_object(
        'overall_health_score', COALESCE(system_state.overall_health_score, 0.0),
        'learning_mode', COALESCE(system_state.learning_mode, 'disabled'),
        'total_function_calls', COALESCE(system_state.total_function_calls, 0),
        'successful_function_calls', COALESCE(system_state.successful_function_calls, 0),
        'failed_function_calls', COALESCE(system_state.failed_function_calls, 0),
        'average_response_time_ms', COALESCE(system_state.average_response_time_ms, 0.0),
        'memory_usage_percent', COALESCE(system_state.memory_usage_percent, 0.0),
        'cpu_usage_percent', COALESCE(system_state.cpu_usage_percent, 0.0),
        'last_updated_at', COALESCE(system_state.last_updated_at, NOW())
    );
    
    RETURN health_status;
END;
$$;

-- =====================================================
-- COMMENTS FOR FUNCTIONS
-- =====================================================

COMMENT ON FUNCTION signals.match_or_create_actor IS 'Match signal to existing actor or create new actor with confidence scoring';
COMMENT ON FUNCTION signals.mark_outcome_as_signal IS 'Convert outcome back to signal for re-entry into the system';
COMMENT ON FUNCTION actors.update_actor_belief IS 'Update actor belief using Bayesian inference with confidence tracking';
COMMENT ON FUNCTION actors.detect_actor_contradictions IS 'Detect contradictions between stated beliefs and actual behavior';
COMMENT ON FUNCTION actors.update_belief_vector IS 'Update numeric belief vector for clustering and similarity calculations';
COMMENT ON FUNCTION cohorts.trigger_clustering_run IS 'Trigger clustering algorithm execution with specified parameters';
COMMENT ON FUNCTION cohorts.assign_actor_to_cohort IS 'Assign actor to cohort with distance and confidence metrics';
COMMENT ON FUNCTION cohorts.log_cohort_evolution IS 'Log cohort evolution events for tracking and analysis';
COMMENT ON FUNCTION ai.register_function IS 'Register new logic function in the system registry';
COMMENT ON FUNCTION ai.log_function_call IS 'Log function execution with inputs, outputs, and performance metrics';
COMMENT ON FUNCTION outcomes.process_stimulus_outcome IS 'Process outcome and trigger learning mechanisms';
COMMENT ON FUNCTION outcomes.get_stimulus_effectiveness_by_cohort IS 'Calculate stimulus effectiveness metrics by cohort';
COMMENT ON FUNCTION actors.get_actor_profile_summary IS 'Get comprehensive actor profile summary';
COMMENT ON FUNCTION cohorts.get_cohort_summary IS 'Get comprehensive cohort summary';
COMMENT ON FUNCTION ai.get_system_health_status IS 'Get current AI system health and performance status';
