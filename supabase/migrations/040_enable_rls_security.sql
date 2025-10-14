-- =====================================================
-- ENABLE RLS SECURITY FOR ALL TABLES
-- =====================================================
-- This migration enables Row Level Security (RLS) on all tables
-- to ensure proper data isolation and access control

-- Enable RLS on all core tables
ALTER TABLE core.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.brand_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.system_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.brand_integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.audit_log ENABLE ROW LEVEL SECURITY;

-- Enable RLS on all signals tables
ALTER TABLE signals.whatsapp_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.social_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.order_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.web_behavior ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.email_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.survey_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.crm_events ENABLE ROW LEVEL SECURITY;

-- Enable RLS on all actors tables
ALTER TABLE actors.actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_demographics ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_identity_beliefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_behavioral_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_communication_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_psychological_triggers ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_memory_loops ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_friction_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_contradictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_quantum_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_entanglements ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_collapse_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_identifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.decoder_log ENABLE ROW LEVEL SECURITY;

-- Enable RLS on processing tables
ALTER TABLE public.signal_processing_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.decoder_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_usage ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CREATE RLS POLICIES
-- =====================================================

-- Service role has full access to everything
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

-- Signals tables - service role access
CREATE POLICY "Service role full access" ON signals.whatsapp_messages
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.reviews
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.signals
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

-- Actors tables - service role access
CREATE POLICY "Service role full access" ON actors.actors
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_profiles
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

CREATE POLICY "Service role full access" ON actors.actor_quantum_states
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_entanglements
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_measurements
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_collapse_events
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_identifiers
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_updates
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.decoder_log
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Processing tables - service role access
CREATE POLICY "Service role full access" ON public.signal_processing_state
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.decoder_log
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.api_usage
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- =====================================================
-- AUTHENTICATED USER POLICIES (for future web app)
-- =====================================================

-- Core tables - brand-scoped access for authenticated users
CREATE POLICY "Brand-scoped access" ON core.brands
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

CREATE POLICY "Brand-scoped access" ON core.users
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

CREATE POLICY "Brand-scoped access" ON core.brand_settings
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

CREATE POLICY "Brand-scoped access" ON core.brand_integrations
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

-- Signals tables - brand-scoped access for authenticated users
CREATE POLICY "Brand-scoped access" ON signals.whatsapp_messages
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

CREATE POLICY "Brand-scoped access" ON signals.reviews
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

CREATE POLICY "Brand-scoped access" ON signals.signals
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

-- Actors tables - brand-scoped access for authenticated users
CREATE POLICY "Brand-scoped access" ON actors.actors
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

CREATE POLICY "Brand-scoped access" ON actors.actor_profiles
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

-- Processing tables - brand-scoped access for authenticated users
CREATE POLICY "Brand-scoped access" ON public.signal_processing_state
    FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM signals.whatsapp_messages w 
        WHERE w.signal_id = public.signal_processing_state.signal_id 
        AND w.brand_id = auth.jwt() ->> 'brand_id'
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM signals.whatsapp_messages w 
        WHERE w.signal_id = public.signal_processing_state.signal_id 
        AND w.brand_id = auth.jwt() ->> 'brand_id'
    ));

-- =====================================================
-- DENY PUBLIC ACCESS
-- =====================================================

-- Revoke public access to all tables
REVOKE ALL ON ALL TABLES IN SCHEMA core FROM public;
REVOKE ALL ON ALL TABLES IN SCHEMA signals FROM public;
REVOKE ALL ON ALL TABLES IN SCHEMA actors FROM public;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;

-- Only allow service_role and authenticated users
GRANT USAGE ON SCHEMA core TO service_role, authenticated;
GRANT USAGE ON SCHEMA signals TO service_role, authenticated;
GRANT USAGE ON SCHEMA actors TO service_role, authenticated;
GRANT USAGE ON SCHEMA public TO service_role, authenticated;

-- Grant specific permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA core TO service_role, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA signals TO service_role, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA actors TO service_role, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO service_role, authenticated;

-- Grant usage on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA core TO service_role, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA signals TO service_role, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA actors TO service_role, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role, authenticated;
