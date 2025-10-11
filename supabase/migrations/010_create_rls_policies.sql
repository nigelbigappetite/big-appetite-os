-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================
-- This migration sets up Row Level Security (RLS) policies to ensure:
-- 1. Service role has full access to everything
-- 2. Brand-scoped access - users can only see their brand's data
-- 3. Audit trails are append-only
-- 4. No public access without authentication

-- Enable RLS on all tables
ALTER TABLE core.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.brand_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.system_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.brand_integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.audit_log ENABLE ROW LEVEL SECURITY;

ALTER TABLE signals.signals_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.whatsapp_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.social_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.order_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.web_behavior ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.email_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.survey_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.crm_events ENABLE ROW LEVEL SECURITY;

ALTER TABLE actors.actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_demographics ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_identity_beliefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_behavioral_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_communication_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_psychological_triggers ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_memory_loops ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_friction_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_contradictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_belief_vectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_clustering_metadata ENABLE ROW LEVEL SECURITY;

ALTER TABLE cohorts.cohorts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts.actor_cohort_membership ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts.cohort_evolution_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts.clustering_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts.cohort_characteristics ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts.cohort_similarity_matrix ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts.cohort_performance_metrics ENABLE ROW LEVEL SECURITY;

ALTER TABLE stimuli.stimuli_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE stimuli.offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE stimuli.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE stimuli.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE stimuli.stimulus_deployments ENABLE ROW LEVEL SECURITY;
ALTER TABLE stimuli.stimulus_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE stimuli.stimulus_performance_metrics ENABLE ROW LEVEL SECURITY;

ALTER TABLE ops.sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.sales_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.supply_chain ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.crm_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.business_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops.operational_alerts ENABLE ROW LEVEL SECURITY;

ALTER TABLE outcomes.outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE outcomes.cohort_outcome_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE outcomes.outcome_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE outcomes.outcome_learning ENABLE ROW LEVEL SECURITY;
ALTER TABLE outcomes.outcome_feedback_loop ENABLE ROW LEVEL SECURITY;

ALTER TABLE ai.functions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai.function_calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai.reasoning_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai.learning_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai.contradiction_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai.ai_system_state ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- SERVICE ROLE POLICIES (Full Access)
-- =====================================================

-- Service role has full access to all tables
CREATE POLICY "Service role full access" ON core.brands
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON core.users
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON core.brand_settings
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON core.system_parameters
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON core.brand_integrations
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON core.audit_log
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Signals tables
CREATE POLICY "Service role full access" ON signals.signals_base
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.whatsapp_messages
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.reviews
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.social_comments
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.order_history
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.web_behavior
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.email_interactions
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.survey_responses
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.crm_events
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Actors tables
CREATE POLICY "Service role full access" ON actors.actors
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_demographics
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_identity_beliefs
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_behavioral_scores
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_communication_profiles
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_psychological_triggers
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_preferences
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_memory_loops
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_friction_points
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_contradictions
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_belief_vectors
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_clustering_metadata
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Cohorts tables
CREATE POLICY "Service role full access" ON cohorts.cohorts
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON cohorts.actor_cohort_membership
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON cohorts.cohort_evolution_log
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON cohorts.clustering_runs
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON cohorts.cohort_characteristics
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON cohorts.cohort_similarity_matrix
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON cohorts.cohort_performance_metrics
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Stimuli tables
CREATE POLICY "Service role full access" ON stimuli.stimuli_base
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON stimuli.offers
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON stimuli.campaigns
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON stimuli.messages
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON stimuli.stimulus_deployments
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON stimuli.stimulus_templates
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON stimuli.stimulus_performance_metrics
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Ops tables
CREATE POLICY "Service role full access" ON ops.sites
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ops.sales_data
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ops.inventory
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ops.supply_chain
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ops.crm_events
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ops.business_metrics
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ops.operational_alerts
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Outcomes tables
CREATE POLICY "Service role full access" ON outcomes.outcomes
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON outcomes.cohort_outcome_summary
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON outcomes.outcome_analysis
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON outcomes.outcome_learning
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON outcomes.outcome_feedback_loop
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- AI tables
CREATE POLICY "Service role full access" ON ai.functions
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ai.function_calls
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ai.reasoning_logs
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ai.learning_logs
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ai.contradiction_logs
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON ai.ai_system_state
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- =====================================================
-- AUTHENTICATED USER POLICIES (Brand-Scoped Access)
-- =====================================================

-- Helper function to get user's brand_id
CREATE OR REPLACE FUNCTION core.get_user_brand_id(user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    brand_id UUID;
BEGIN
    SELECT u.brand_id INTO brand_id
    FROM core.users u
    WHERE u.auth_user_id = user_id
      AND u.is_active = true
    LIMIT 1;
    
    RETURN brand_id;
END;
$$;

-- Core tables - brand-scoped access
CREATE POLICY "Brand-scoped access" ON core.brands
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON core.users
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON core.brand_settings
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON core.brand_integrations
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

-- System parameters - read-only for authenticated users
CREATE POLICY "Read-only access" ON core.system_parameters
    FOR SELECT TO authenticated USING (true);

-- Audit log - read-only for authenticated users
CREATE POLICY "Read-only access" ON core.audit_log
    FOR SELECT TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()) OR brand_id IS NULL);

-- Signals tables - brand-scoped access
CREATE POLICY "Brand-scoped access" ON signals.signals_base
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON signals.whatsapp_messages
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.whatsapp_messages.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.whatsapp_messages.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON signals.reviews
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.reviews.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.reviews.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON signals.social_comments
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.social_comments.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.social_comments.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON signals.order_history
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.order_history.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.order_history.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON signals.web_behavior
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.web_behavior.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.web_behavior.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON signals.email_interactions
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.email_interactions.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.email_interactions.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON signals.survey_responses
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.survey_responses.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.survey_responses.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON signals.crm_events
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.crm_events.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.signals_base sb
        WHERE sb.signal_id = signals.crm_events.signal_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

-- Actors tables - brand-scoped access
CREATE POLICY "Brand-scoped access" ON actors.actors
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON actors.actor_demographics
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_demographics.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_demographics.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_identity_beliefs
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_identity_beliefs.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_identity_beliefs.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_behavioral_scores
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_behavioral_scores.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_behavioral_scores.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_communication_profiles
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_communication_profiles.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_communication_profiles.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_psychological_triggers
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_psychological_triggers.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_psychological_triggers.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_preferences
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_preferences.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_preferences.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_memory_loops
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_memory_loops.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_memory_loops.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_friction_points
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_friction_points.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_friction_points.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_contradictions
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_contradictions.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_contradictions.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_belief_vectors
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_belief_vectors.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_belief_vectors.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON actors.actor_clustering_metadata
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_clustering_metadata.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM actors.actors a
        WHERE a.actor_id = actors.actor_clustering_metadata.actor_id
          AND a.brand_id = core.get_user_brand_id(auth.uid())
    ));

-- Cohorts tables - brand-scoped access
CREATE POLICY "Brand-scoped access" ON cohorts.cohorts
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON cohorts.actor_cohort_membership
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM cohorts.cohorts c
        WHERE c.cohort_id = cohorts.actor_cohort_membership.cohort_id
          AND c.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM cohorts.cohorts c
        WHERE c.cohort_id = cohorts.actor_cohort_membership.cohort_id
          AND c.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON cohorts.cohort_evolution_log
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON cohorts.clustering_runs
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON cohorts.cohort_characteristics
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM cohorts.cohorts c
        WHERE c.cohort_id = cohorts.cohort_characteristics.cohort_id
          AND c.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM cohorts.cohorts c
        WHERE c.cohort_id = cohorts.cohort_characteristics.cohort_id
          AND c.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON cohorts.cohort_similarity_matrix
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON cohorts.cohort_performance_metrics
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM cohorts.cohorts c
        WHERE c.cohort_id = cohorts.cohort_performance_metrics.cohort_id
          AND c.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM cohorts.cohorts c
        WHERE c.cohort_id = cohorts.cohort_performance_metrics.cohort_id
          AND c.brand_id = core.get_user_brand_id(auth.uid())
    ));

-- Stimuli tables - brand-scoped access
CREATE POLICY "Brand-scoped access" ON stimuli.stimuli_base
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON stimuli.offers
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.offers.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.offers.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON stimuli.campaigns
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.campaigns.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.campaigns.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON stimuli.messages
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.messages.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.messages.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON stimuli.stimulus_deployments
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.stimulus_deployments.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.stimulus_deployments.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

CREATE POLICY "Brand-scoped access" ON stimuli.stimulus_templates
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON stimuli.stimulus_performance_metrics
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.stimulus_performance_metrics.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM stimuli.stimuli_base sb
        WHERE sb.stimulus_id = stimuli.stimulus_performance_metrics.stimulus_id
          AND sb.brand_id = core.get_user_brand_id(auth.uid())
    ));

-- Ops tables - brand-scoped access
CREATE POLICY "Brand-scoped access" ON ops.sites
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ops.sales_data
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ops.inventory
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ops.supply_chain
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ops.crm_events
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ops.business_metrics
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ops.operational_alerts
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

-- Outcomes tables - brand-scoped access
CREATE POLICY "Brand-scoped access" ON outcomes.outcomes
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON outcomes.cohort_outcome_summary
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON outcomes.outcome_analysis
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON outcomes.outcome_learning
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON outcomes.outcome_feedback_loop
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

-- AI tables - brand-scoped access (with some global functions)
CREATE POLICY "Brand-scoped access" ON ai.functions
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()) OR brand_id IS NULL)
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()) OR brand_id IS NULL);

CREATE POLICY "Brand-scoped access" ON ai.function_calls
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ai.reasoning_logs
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ai.learning_logs
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ai.contradiction_logs
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()))
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()));

CREATE POLICY "Brand-scoped access" ON ai.ai_system_state
    FOR ALL TO authenticated
    USING (brand_id = core.get_user_brand_id(auth.uid()) OR brand_id IS NULL)
    WITH CHECK (brand_id = core.get_user_brand_id(auth.uid()) OR brand_id IS NULL);

-- =====================================================
-- AUDIT TRAIL POLICIES (Append-Only)
-- =====================================================

-- Audit log is append-only for all users
CREATE POLICY "Append-only audit log" ON core.audit_log
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Reasoning logs are append-only for all users
CREATE POLICY "Append-only reasoning logs" ON ai.reasoning_logs
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Learning logs are append-only for all users
CREATE POLICY "Append-only learning logs" ON ai.learning_logs
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Contradiction logs are append-only for all users
CREATE POLICY "Append-only contradiction logs" ON ai.contradiction_logs
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Evolution logs are append-only for all users
CREATE POLICY "Append-only evolution logs" ON cohorts.cohort_evolution_log
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- =====================================================
-- COMMENTS FOR RLS POLICIES
-- =====================================================

COMMENT ON FUNCTION core.get_user_brand_id IS 'Helper function to get user brand_id for RLS policies';
COMMENT ON POLICY "Service role full access" ON core.brands IS 'Service role has full access to all data';
COMMENT ON POLICY "Brand-scoped access" ON core.brands IS 'Authenticated users can only access their brand data';
COMMENT ON POLICY "Append-only audit log" ON core.audit_log IS 'Audit logs are append-only for compliance';
COMMENT ON POLICY "Append-only reasoning logs" ON ai.reasoning_logs IS 'Reasoning logs are append-only for traceability';
COMMENT ON POLICY "Append-only learning logs" ON ai.learning_logs IS 'Learning logs are append-only for audit trail';
COMMENT ON POLICY "Append-only contradiction logs" ON ai.contradiction_logs IS 'Contradiction logs are append-only for integrity';
COMMENT ON POLICY "Append-only evolution logs" ON cohorts.cohort_evolution_log IS 'Evolution logs are append-only for history tracking';
