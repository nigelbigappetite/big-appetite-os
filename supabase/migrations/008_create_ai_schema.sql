-- =====================================================
-- AI SCHEMA - Reasoning & Learning
-- =====================================================
-- This schema manages the AI reasoning and learning capabilities of the system,
-- including function registry, reasoning logs, learning logs, and contradiction tracking.
-- This is the "brain" of the system that makes decisions and learns from experience.

-- =====================================================
-- FUNCTIONS TABLE
-- =====================================================
-- Registry of all logic functions used by the system
CREATE TABLE ai.functions (
    function_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE CASCADE, -- NULL for global functions
    
    -- Function identification
    function_name TEXT NOT NULL,
    function_type TEXT NOT NULL, -- 'signal_processing', 'actor_matching', 'clustering', 'stimulus_generation', 'learning'
    function_category TEXT NOT NULL, -- 'matching', 'clustering', 'reasoning', 'learning', 'prediction', 'optimization'
    version TEXT NOT NULL DEFAULT '1.0.0',
    
    -- Function details
    description TEXT,
    purpose TEXT NOT NULL, -- What this function does
    input_schema JSONB NOT NULL, -- Expected input parameters
    output_schema JSONB NOT NULL, -- Expected output format
    parameters JSONB DEFAULT '{}', -- Function-specific parameters
    
    -- Implementation details
    implementation_type TEXT NOT NULL, -- 'sql', 'plpgsql', 'python', 'javascript', 'external_api'
    implementation_code TEXT, -- Actual implementation code
    external_endpoint TEXT, -- For external API functions
    external_credentials JSONB DEFAULT '{}', -- Encrypted credentials for external functions
    
    -- Performance and reliability
    expected_execution_time_ms INTEGER,
    memory_requirements_mb INTEGER,
    cpu_requirements_percent FLOAT,
    reliability_score FLOAT DEFAULT 0.0, -- 0-1 historical reliability
    
    -- Usage tracking
    total_calls INTEGER DEFAULT 0,
    successful_calls INTEGER DEFAULT 0,
    failed_calls INTEGER DEFAULT 0,
    average_execution_time_ms FLOAT,
    last_called_at TIMESTAMPTZ,
    
    -- Status and lifecycle
    is_active BOOLEAN DEFAULT true,
    is_deprecated BOOLEAN DEFAULT false,
    deprecation_reason TEXT,
    replacement_function_id UUID REFERENCES ai.functions(function_id),
    
    -- Quality and validation
    validation_status TEXT DEFAULT 'pending', -- 'pending', 'validated', 'failed', 'needs_review'
    validation_notes TEXT,
    test_coverage FLOAT DEFAULT 0.0, -- 0-1 test coverage
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES core.users(user_id),
    
    -- Constraints
    CONSTRAINT valid_function_type CHECK (function_type IN (
        'signal_processing', 'actor_matching', 'clustering', 'stimulus_generation', 'learning',
        'prediction', 'optimization', 'validation', 'transformation', 'analysis', 'other'
    )),
    CONSTRAINT valid_function_category CHECK (function_category IN (
        'matching', 'clustering', 'reasoning', 'learning', 'prediction', 'optimization',
        'validation', 'transformation', 'analysis', 'communication', 'other'
    )),
    CONSTRAINT valid_implementation_type CHECK (implementation_type IN (
        'sql', 'plpgsql', 'python', 'javascript', 'external_api', 'hybrid'
    )),
    CONSTRAINT valid_validation_status CHECK (validation_status IN (
        'pending', 'validated', 'failed', 'needs_review', 'in_testing'
    )),
    CONSTRAINT valid_scores CHECK (
        reliability_score >= 0 AND reliability_score <= 1 AND
        test_coverage >= 0 AND test_coverage <= 1
    ),
    CONSTRAINT valid_calls CHECK (
        total_calls >= 0 AND successful_calls >= 0 AND failed_calls >= 0 AND
        successful_calls + failed_calls <= total_calls
    ),
    CONSTRAINT unique_function_name UNIQUE (brand_id, function_name, version)
);

-- =====================================================
-- FUNCTION CALLS TABLE
-- =====================================================
-- Log of every function execution with inputs and outputs
CREATE TABLE ai.function_calls (
    call_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    function_id UUID NOT NULL REFERENCES ai.functions(function_id) ON DELETE CASCADE,
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Call details
    call_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    call_type TEXT NOT NULL, -- 'scheduled', 'triggered', 'manual', 'batch', 'real_time'
    call_priority TEXT DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    -- Input and output
    input_data JSONB NOT NULL, -- Input parameters passed to function
    output_data JSONB, -- Output returned by function
    error_data JSONB, -- Error information if call failed
    
    -- Execution details
    execution_status TEXT NOT NULL, -- 'pending', 'running', 'completed', 'failed', 'timeout', 'cancelled'
    execution_time_ms INTEGER,
    memory_used_mb INTEGER,
    cpu_time_ms INTEGER,
    
    -- Context and traceability
    triggered_by TEXT, -- What triggered this function call
    parent_call_id UUID REFERENCES ai.function_calls(call_id), -- For nested calls
    related_entity_type TEXT, -- 'actor', 'cohort', 'stimulus', 'outcome', 'signal'
    related_entity_id UUID, -- ID of the related entity
    
    -- Quality and confidence
    input_quality_score FLOAT DEFAULT 0.0, -- 0-1 quality of input data
    output_quality_score FLOAT DEFAULT 0.0, -- 0-1 quality of output data
    confidence_score FLOAT DEFAULT 0.0, -- 0-1 confidence in the result
    
    -- Performance metrics
    queue_time_ms INTEGER, -- Time spent in queue
    processing_time_ms INTEGER, -- Actual processing time
    total_time_ms INTEGER, -- Total end-to-end time
    
    -- Error handling
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    retry_reason TEXT,
    
    -- Metadata
    execution_node TEXT, -- Which node/instance executed this
    session_id TEXT, -- Session identifier
    user_id UUID REFERENCES core.users(user_id), -- User who triggered the call
    
    -- Constraints
    CONSTRAINT valid_call_type CHECK (call_type IN (
        'scheduled', 'triggered', 'manual', 'batch', 'real_time', 'replay'
    )),
    CONSTRAINT valid_priority CHECK (call_priority IN ('low', 'normal', 'high', 'urgent')),
    CONSTRAINT valid_execution_status CHECK (execution_status IN (
        'pending', 'running', 'completed', 'failed', 'timeout', 'cancelled', 'retrying'
    )),
    CONSTRAINT valid_quality_scores CHECK (
        input_quality_score >= 0 AND input_quality_score <= 1 AND
        output_quality_score >= 0 AND output_quality_score <= 1 AND
        confidence_score >= 0 AND confidence_score <= 1
    ),
    CONSTRAINT valid_times CHECK (
        execution_time_ms IS NULL OR execution_time_ms >= 0 AND
        memory_used_mb IS NULL OR memory_used_mb >= 0 AND
        cpu_time_ms IS NULL OR cpu_time_ms >= 0 AND
        queue_time_ms IS NULL OR queue_time_ms >= 0 AND
        processing_time_ms IS NULL OR processing_time_ms >= 0 AND
        total_time_ms IS NULL OR total_time_ms >= 0
    ),
    CONSTRAINT valid_retries CHECK (retry_count >= 0 AND max_retries >= 0)
);

-- =====================================================
-- REASONING LOGS TABLE
-- =====================================================
-- Detailed reasoning behind every decision made by the system
CREATE TABLE ai.reasoning_logs (
    reasoning_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Reasoning context
    reasoning_type TEXT NOT NULL, -- 'actor_matching', 'cohort_assignment', 'stimulus_generation', 'learning_update'
    reasoning_scope TEXT NOT NULL, -- 'global', 'cohort', 'actor', 'stimulus', 'outcome'
    scope_id UUID, -- ID of the specific scope
    
    -- Decision details
    decision_made TEXT NOT NULL, -- What decision was made
    decision_confidence FLOAT NOT NULL, -- 0-1 confidence in the decision
    decision_alternatives JSONB DEFAULT '[]', -- Alternative decisions considered
    
    -- Reasoning process
    reasoning_steps JSONB NOT NULL, -- Step-by-step reasoning process
    evidence_used JSONB NOT NULL, -- Evidence that supported the decision
    assumptions_made JSONB DEFAULT '[]', -- Assumptions made during reasoning
    constraints_applied JSONB DEFAULT '[]', -- Constraints that were applied
    
    -- Function calls involved
    function_calls_used JSONB NOT NULL, -- Function calls that contributed to this reasoning
    data_sources_used JSONB DEFAULT '[]', -- Data sources that were consulted
    
    -- Quality and validation
    reasoning_quality FLOAT DEFAULT 0.0, -- 0-1 quality of reasoning process
    evidence_strength FLOAT DEFAULT 0.0, -- 0-1 strength of evidence
    logic_consistency FLOAT DEFAULT 0.0, -- 0-1 consistency of logic
    
    -- Traceability
    triggered_by TEXT, -- What triggered this reasoning
    related_entity_type TEXT, -- Type of entity this reasoning relates to
    related_entity_id UUID, -- ID of the related entity
    
    -- Timing
    reasoning_started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reasoning_completed_at TIMESTAMPTZ,
    reasoning_duration_ms INTEGER,
    
    -- Metadata
    reasoning_version TEXT DEFAULT '1.0',
    is_reviewed BOOLEAN DEFAULT false,
    reviewed_by UUID REFERENCES core.users(user_id),
    review_notes TEXT,
    
    -- Constraints
    CONSTRAINT valid_reasoning_type CHECK (reasoning_type IN (
        'actor_matching', 'cohort_assignment', 'stimulus_generation', 'learning_update',
        'belief_update', 'preference_inference', 'behavior_prediction', 'anomaly_detection', 'other'
    )),
    CONSTRAINT valid_reasoning_scope CHECK (reasoning_scope IN (
        'global', 'cohort', 'actor', 'stimulus', 'outcome', 'signal', 'system'
    )),
    CONSTRAINT valid_confidence_scores CHECK (
        decision_confidence >= 0 AND decision_confidence <= 1 AND
        reasoning_quality >= 0 AND reasoning_quality <= 1 AND
        evidence_strength >= 0 AND evidence_strength <= 1 AND
        logic_consistency >= 0 AND logic_consistency <= 1
    )
);

-- =====================================================
-- LEARNING LOGS TABLE
-- =====================================================
-- What the system learned and how it updated its knowledge
CREATE TABLE ai.learning_logs (
    learning_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Learning details
    learning_type TEXT NOT NULL, -- 'belief_update', 'pattern_discovery', 'rule_creation', 'model_update'
    learning_category TEXT NOT NULL, -- 'actor_behavior', 'cohort_characteristics', 'stimulus_effectiveness', 'system_performance'
    
    -- What was learned
    learning_description TEXT NOT NULL,
    knowledge_gained JSONB NOT NULL, -- Specific knowledge gained
    confidence_in_learning FLOAT NOT NULL, -- 0-1 confidence in this learning
    
    -- Learning process
    learning_method TEXT NOT NULL, -- 'statistical', 'ml', 'rule_based', 'hybrid', 'expert'
    learning_algorithm TEXT, -- Specific algorithm used
    learning_parameters JSONB DEFAULT '{}', -- Parameters used in learning
    
    -- Source data
    source_data JSONB NOT NULL, -- Data that led to this learning
    source_outcomes JSONB DEFAULT '[]', -- Outcome IDs that contributed
    source_analysis_id UUID REFERENCES outcomes.outcome_analysis(analysis_id),
    
    -- Impact and application
    impact_scope TEXT NOT NULL, -- 'global', 'cohort_specific', 'actor_specific', 'stimulus_specific'
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
    decay_rate FLOAT DEFAULT 0.0, -- Rate at which this learning decays
    last_reinforced_at TIMESTAMPTZ, -- When this learning was last reinforced
    reinforcement_count INTEGER DEFAULT 0, -- How many times this learning was reinforced
    
    -- Quality metrics
    learning_quality FLOAT DEFAULT 0.0, -- 0-1 quality of learning process
    data_quality FLOAT DEFAULT 0.0, -- 0-1 quality of source data
    generalizability FLOAT DEFAULT 0.0, -- 0-1 how generalizable this learning is
    
    -- Metadata
    learned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ, -- When this learning expires
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    
    -- Constraints
    CONSTRAINT valid_learning_type CHECK (learning_type IN (
        'belief_update', 'pattern_discovery', 'rule_creation', 'model_update',
        'preference_update', 'behavior_prediction', 'anomaly_detection', 'optimization', 'other'
    )),
    CONSTRAINT valid_learning_category CHECK (learning_category IN (
        'actor_behavior', 'cohort_characteristics', 'stimulus_effectiveness', 'system_performance',
        'market_conditions', 'seasonal_patterns', 'external_factors', 'user_preferences', 'other'
    )),
    CONSTRAINT valid_learning_method CHECK (learning_method IN (
        'statistical', 'ml', 'rule_based', 'hybrid', 'expert', 'reinforcement', 'other'
    )),
    CONSTRAINT valid_impact_scope CHECK (impact_scope IN (
        'global', 'cohort_specific', 'actor_specific', 'stimulus_specific', 'temporal', 'contextual'
    )),
    CONSTRAINT valid_implementation_status CHECK (implementation_status IN (
        'pending', 'implemented', 'rejected', 'testing', 'paused', 'deprecated'
    )),
    CONSTRAINT valid_validation_status CHECK (validation_status IN (
        'pending', 'validated', 'invalidated', 'needs_more_data', 'partially_validated'
    )),
    CONSTRAINT valid_confidence_scores CHECK (
        confidence_in_learning >= 0 AND confidence_in_learning <= 1 AND
        validation_confidence >= 0 AND validation_confidence <= 1 AND
        learning_strength >= 0 AND learning_strength <= 1 AND
        decay_rate >= 0 AND decay_rate <= 1 AND
        learning_quality >= 0 AND learning_quality <= 1 AND
        data_quality >= 0 AND data_quality <= 1 AND
        generalizability >= 0 AND generalizability <= 1
    )
);

-- =====================================================
-- CONTRADICTION LOGS TABLE
-- =====================================================
-- Track when beliefs conflict with behavior or other beliefs
CREATE TABLE ai.contradiction_logs (
    contradiction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Contradiction details
    contradiction_type TEXT NOT NULL, -- 'belief_vs_behavior', 'stated_vs_actual', 'belief_vs_belief', 'prediction_vs_outcome'
    contradiction_severity TEXT NOT NULL, -- 'low', 'medium', 'high', 'critical'
    contradiction_description TEXT NOT NULL,
    
    -- Conflicting information
    belief_a JSONB NOT NULL, -- First conflicting belief/statement
    belief_b JSONB NOT NULL, -- Second conflicting belief/statement
    evidence_for_a JSONB DEFAULT '[]', -- Evidence supporting belief A
    evidence_for_b JSONB DEFAULT '[]', -- Evidence supporting belief B
    
    -- Context and scope
    scope_type TEXT NOT NULL, -- 'actor', 'cohort', 'global', 'stimulus', 'outcome'
    scope_id UUID, -- ID of the specific scope
    context_data JSONB DEFAULT '{}', -- Additional context information
    
    -- Analysis
    contradiction_strength FLOAT NOT NULL, -- 0-1 how strong the contradiction is
    possible_explanations JSONB DEFAULT '[]', -- Possible explanations for the contradiction
    resolution_hypothesis TEXT, -- How this might be resolved
    requires_investigation BOOLEAN DEFAULT false,
    
    -- Resolution
    resolution_status TEXT DEFAULT 'unresolved', -- 'unresolved', 'investigating', 'resolved', 'irreconcilable'
    resolution_notes TEXT,
    resolution_date TIMESTAMPTZ,
    resolved_by TEXT,
    
    -- Impact assessment
    impact_on_system JSONB DEFAULT '{}', -- How this contradiction affects the system
    affected_functions JSONB DEFAULT '[]', -- Functions affected by this contradiction
    affected_decisions JSONB DEFAULT '[]', -- Decisions that may be affected
    
    -- Quality metrics
    detection_confidence FLOAT DEFAULT 0.0, -- 0-1 confidence in contradiction detection
    analysis_quality FLOAT DEFAULT 0.0, -- 0-1 quality of contradiction analysis
    
    -- Source tracking
    source_data JSONB DEFAULT '{}', -- Data that revealed this contradiction
    source_functions JSONB DEFAULT '[]', -- Functions that detected this contradiction
    
    -- Timing
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_contradiction_type CHECK (contradiction_type IN (
        'belief_vs_behavior', 'stated_vs_actual', 'belief_vs_belief', 'prediction_vs_outcome',
        'preference_vs_choice', 'intention_vs_action', 'self_vs_other_perception', 'other'
    )),
    CONSTRAINT valid_severity CHECK (contradiction_severity IN ('low', 'medium', 'high', 'critical')),
    CONSTRAINT valid_scope_type CHECK (scope_type IN (
        'actor', 'cohort', 'global', 'stimulus', 'outcome', 'signal', 'system'
    )),
    CONSTRAINT valid_resolution_status CHECK (resolution_status IN (
        'unresolved', 'investigating', 'resolved', 'irreconcilable', 'dismissed'
    )),
    CONSTRAINT valid_strength CHECK (contradiction_strength >= 0 AND contradiction_strength <= 1),
    CONSTRAINT valid_confidence_scores CHECK (
        detection_confidence >= 0 AND detection_confidence <= 1 AND
        analysis_quality >= 0 AND analysis_quality <= 1
    )
);

-- =====================================================
-- AI SYSTEM STATE TABLE
-- =====================================================
-- Current state of the AI system for monitoring and debugging
CREATE TABLE ai.ai_system_state (
    state_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE CASCADE, -- NULL for global state
    
    -- System state
    system_version TEXT NOT NULL,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Active functions
    active_functions JSONB DEFAULT '[]', -- Currently active functions
    function_health_scores JSONB DEFAULT '{}', -- Health scores for each function
    
    -- Learning state
    learning_mode TEXT DEFAULT 'active', -- 'active', 'paused', 'disabled', 'maintenance'
    learning_rate FLOAT DEFAULT 0.1, -- Current learning rate
    knowledge_base_size INTEGER DEFAULT 0, -- Number of knowledge items
    last_learning_update TIMESTAMPTZ,
    
    -- Performance metrics
    total_function_calls INTEGER DEFAULT 0,
    successful_function_calls INTEGER DEFAULT 0,
    failed_function_calls INTEGER DEFAULT 0,
    average_response_time_ms FLOAT,
    
    -- System health
    overall_health_score FLOAT DEFAULT 0.0, -- 0-1 overall system health
    memory_usage_percent FLOAT,
    cpu_usage_percent FLOAT,
    disk_usage_percent FLOAT,
    
    -- Alerts and issues
    active_alerts JSONB DEFAULT '[]', -- Currently active alerts
    recent_errors JSONB DEFAULT '[]', -- Recent errors and their counts
    
    -- Configuration
    system_config JSONB DEFAULT '{}', -- Current system configuration
    feature_flags JSONB DEFAULT '{}', -- Active feature flags
    
    -- Constraints
    CONSTRAINT valid_learning_mode CHECK (learning_mode IN (
        'active', 'paused', 'disabled', 'maintenance', 'testing'
    )),
    CONSTRAINT valid_learning_rate CHECK (learning_rate >= 0 AND learning_rate <= 1),
    CONSTRAINT valid_health_scores CHECK (
        overall_health_score >= 0 AND overall_health_score <= 1 AND
        (memory_usage_percent IS NULL OR (memory_usage_percent >= 0 AND memory_usage_percent <= 100)) AND
        (cpu_usage_percent IS NULL OR (cpu_usage_percent >= 0 AND cpu_usage_percent <= 100)) AND
        (disk_usage_percent IS NULL OR (disk_usage_percent >= 0 AND disk_usage_percent <= 100))
    ),
    CONSTRAINT valid_calls CHECK (
        total_function_calls >= 0 AND successful_function_calls >= 0 AND failed_function_calls >= 0 AND
        successful_function_calls + failed_function_calls <= total_function_calls
    )
);

-- =====================================================
-- INDEXES FOR AI SCHEMA
-- =====================================================

-- Functions indexes
CREATE INDEX idx_functions_brand_id ON ai.functions(brand_id) WHERE brand_id IS NOT NULL;
CREATE INDEX idx_functions_name ON ai.functions(function_name);
CREATE INDEX idx_functions_type ON ai.functions(function_type);
CREATE INDEX idx_functions_category ON ai.functions(function_category);
CREATE INDEX idx_functions_active ON ai.functions(is_active) WHERE is_active = true;
CREATE INDEX idx_functions_deprecated ON ai.functions(is_deprecated) WHERE is_deprecated = true;
CREATE INDEX idx_functions_validation_status ON ai.functions(validation_status);

-- Function calls indexes
CREATE INDEX idx_function_calls_function_id ON ai.function_calls(function_id);
CREATE INDEX idx_function_calls_brand_id ON ai.function_calls(brand_id);
CREATE INDEX idx_function_calls_timestamp ON ai.function_calls(call_timestamp);
CREATE INDEX idx_function_calls_type ON ai.function_calls(call_type);
CREATE INDEX idx_function_calls_status ON ai.function_calls(execution_status);
CREATE INDEX idx_function_calls_related_entity ON ai.function_calls(related_entity_type, related_entity_id) WHERE related_entity_id IS NOT NULL;
CREATE INDEX idx_function_calls_parent ON ai.function_calls(parent_call_id) WHERE parent_call_id IS NOT NULL;

-- Reasoning logs indexes
CREATE INDEX idx_reasoning_logs_brand_id ON ai.reasoning_logs(brand_id);
CREATE INDEX idx_reasoning_logs_type ON ai.reasoning_logs(reasoning_type);
CREATE INDEX idx_reasoning_logs_scope ON ai.reasoning_logs(reasoning_scope);
CREATE INDEX idx_reasoning_logs_scope_id ON ai.reasoning_logs(scope_id) WHERE scope_id IS NOT NULL;
CREATE INDEX idx_reasoning_logs_started_at ON ai.reasoning_logs(reasoning_started_at);
CREATE INDEX idx_reasoning_logs_reviewed ON ai.reasoning_logs(is_reviewed) WHERE is_reviewed = true;

-- Learning logs indexes
CREATE INDEX idx_learning_logs_brand_id ON ai.learning_logs(brand_id);
CREATE INDEX idx_learning_logs_type ON ai.learning_logs(learning_type);
CREATE INDEX idx_learning_logs_category ON ai.learning_logs(learning_category);
CREATE INDEX idx_learning_logs_method ON ai.learning_logs(learning_method);
CREATE INDEX idx_learning_logs_impact_scope ON ai.learning_logs(impact_scope);
CREATE INDEX idx_learning_logs_implementation_status ON ai.learning_logs(implementation_status);
CREATE INDEX idx_learning_logs_validation_status ON ai.learning_logs(validation_status);
CREATE INDEX idx_learning_logs_active ON ai.learning_logs(is_active) WHERE is_active = true;
CREATE INDEX idx_learning_logs_learned_at ON ai.learning_logs(learned_at);

-- Contradiction logs indexes
CREATE INDEX idx_contradiction_logs_brand_id ON ai.contradiction_logs(brand_id);
CREATE INDEX idx_contradiction_logs_type ON ai.contradiction_logs(contradiction_type);
CREATE INDEX idx_contradiction_logs_severity ON ai.contradiction_logs(contradiction_severity);
CREATE INDEX idx_contradiction_logs_scope_type ON ai.contradiction_logs(scope_type);
CREATE INDEX idx_contradiction_logs_scope_id ON ai.contradiction_logs(scope_id) WHERE scope_id IS NOT NULL;
CREATE INDEX idx_contradiction_logs_resolution_status ON ai.contradiction_logs(resolution_status);
CREATE INDEX idx_contradiction_logs_detected_at ON ai.contradiction_logs(detected_at);
CREATE INDEX idx_contradiction_logs_investigation ON ai.contradiction_logs(requires_investigation) WHERE requires_investigation = true;

-- AI system state indexes
CREATE INDEX idx_ai_system_state_brand_id ON ai.ai_system_state(brand_id) WHERE brand_id IS NOT NULL;
CREATE INDEX idx_ai_system_state_version ON ai.ai_system_state(system_version);
CREATE INDEX idx_ai_system_state_last_updated ON ai.ai_system_state(last_updated_at);
CREATE INDEX idx_ai_system_state_learning_mode ON ai.ai_system_state(learning_mode);

-- =====================================================
-- TRIGGERS FOR AI SCHEMA
-- =====================================================

-- Update function statistics when calls are made
CREATE OR REPLACE FUNCTION ai.update_function_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update function call statistics
    UPDATE ai.functions 
    SET 
        total_calls = total_calls + 1,
        successful_calls = CASE WHEN NEW.execution_status = 'completed' THEN successful_calls + 1 ELSE successful_calls END,
        failed_calls = CASE WHEN NEW.execution_status = 'failed' THEN failed_calls + 1 ELSE failed_calls END,
        last_called_at = NEW.call_timestamp,
        updated_at = NOW()
    WHERE function_id = NEW.function_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_function_stats_trigger
    AFTER INSERT ON ai.function_calls
    FOR EACH ROW EXECUTE FUNCTION ai.update_function_stats();

-- Update timestamps
CREATE TRIGGER update_functions_updated_at 
    BEFORE UPDATE ON ai.functions 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

CREATE TRIGGER update_contradiction_logs_updated_at 
    BEFORE UPDATE ON ai.contradiction_logs 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- =====================================================
-- COMMENTS FOR AI SCHEMA
-- =====================================================

COMMENT ON SCHEMA ai IS 'AI reasoning and learning capabilities - the brain of the system';
COMMENT ON TABLE ai.functions IS 'Registry of all logic functions used by the system with performance tracking';
COMMENT ON TABLE ai.function_calls IS 'Log of every function execution with inputs, outputs, and performance metrics';
COMMENT ON TABLE ai.reasoning_logs IS 'Detailed reasoning behind every decision made by the system';
COMMENT ON TABLE ai.learning_logs IS 'What the system learned and how it updated its knowledge';
COMMENT ON TABLE ai.contradiction_logs IS 'Track when beliefs conflict with behavior or other beliefs';
COMMENT ON TABLE ai.ai_system_state IS 'Current state of the AI system for monitoring and debugging';

COMMENT ON COLUMN ai.functions.reliability_score IS 'Historical reliability score based on success/failure rates (0-1)';
COMMENT ON COLUMN ai.functions.test_coverage IS 'Test coverage for this function (0-1)';
COMMENT ON COLUMN ai.function_calls.confidence_score IS 'Confidence in the function call result (0-1)';
COMMENT ON COLUMN ai.function_calls.retry_count IS 'Number of retry attempts for this call';
COMMENT ON COLUMN ai.reasoning_logs.decision_confidence IS 'Confidence in the decision made (0-1)';
COMMENT ON COLUMN ai.reasoning_logs.reasoning_steps IS 'Step-by-step reasoning process as JSONB';
COMMENT ON COLUMN ai.learning_logs.knowledge_gained IS 'Specific knowledge gained from this learning';
COMMENT ON COLUMN ai.learning_logs.learning_strength IS 'How strong this learning is (0-1)';
COMMENT ON COLUMN ai.contradiction_logs.contradiction_strength IS 'How strong the contradiction is (0-1)';
COMMENT ON COLUMN ai.ai_system_state.overall_health_score IS 'Overall system health score (0-1)';
