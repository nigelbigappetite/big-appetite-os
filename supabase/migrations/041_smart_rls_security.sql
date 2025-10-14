-- =====================================================
-- SMART RLS SECURITY - SECURE BUT NOT BLOCKING
-- =====================================================
-- This migration enables RLS with smart policies that:
-- 1. Allow service_role full access (for processing)
-- 2. Block public access (security)
-- 3. Allow authenticated users brand-scoped access (future web app)
-- 4. Don't break existing processing flows

-- =====================================================
-- ENABLE RLS ON CRITICAL TABLES ONLY
-- =====================================================

-- Enable RLS on tables that contain sensitive data
ALTER TABLE signals.whatsapp_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actors ENABLE ROW LEVEL SECURITY;

-- Enable RLS on processing tables
ALTER TABLE public.signal_processing_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.decoder_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_usage ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- SERVICE ROLE POLICIES (ALLOWS PROCESSING)
-- =====================================================

-- Service role has FULL access to everything - this keeps processing working
CREATE POLICY "Service role full access" ON signals.whatsapp_messages
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.reviews
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON signals.signals
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actor_profiles
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON actors.actors
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.signal_processing_state
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.decoder_log
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.api_usage
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- =====================================================
-- PUBLIC ACCESS BLOCKING (SECURITY)
-- =====================================================

-- Block public access to sensitive data
CREATE POLICY "Block public access" ON signals.whatsapp_messages
    FOR ALL TO public USING (false) WITH CHECK (false);

CREATE POLICY "Block public access" ON signals.reviews
    FOR ALL TO public USING (false) WITH CHECK (false);

CREATE POLICY "Block public access" ON signals.signals
    FOR ALL TO public USING (false) WITH CHECK (false);

CREATE POLICY "Block public access" ON actors.actor_profiles
    FOR ALL TO public USING (false) WITH CHECK (false);

CREATE POLICY "Block public access" ON actors.actors
    FOR ALL TO public USING (false) WITH CHECK (false);

CREATE POLICY "Block public access" ON public.signal_processing_state
    FOR ALL TO public USING (false) WITH CHECK (false);

CREATE POLICY "Block public access" ON public.decoder_log
    FOR ALL TO public USING (false) WITH CHECK (false);

CREATE POLICY "Block public access" ON public.api_usage
    FOR ALL TO public USING (false) WITH CHECK (false);

-- =====================================================
-- AUTHENTICATED USER POLICIES (FUTURE WEB APP)
-- =====================================================

-- Brand-scoped access for authenticated users (when you build a web app)
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

CREATE POLICY "Brand-scoped access" ON actors.actor_profiles
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

CREATE POLICY "Brand-scoped access" ON actors.actors
    FOR ALL TO authenticated
    USING (brand_id = auth.jwt() ->> 'brand_id')
    WITH CHECK (brand_id = auth.jwt() ->> 'brand_id');

-- Processing tables - allow access if user has access to the underlying signal
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
-- REVOKE PUBLIC PERMISSIONS
-- =====================================================

-- Remove public access to sensitive tables
REVOKE ALL ON signals.whatsapp_messages FROM public;
REVOKE ALL ON signals.reviews FROM public;
REVOKE ALL ON signals.signals FROM public;
REVOKE ALL ON actors.actor_profiles FROM public;
REVOKE ALL ON actors.actors FROM public;
REVOKE ALL ON public.signal_processing_state FROM public;
REVOKE ALL ON public.decoder_log FROM public;
REVOKE ALL ON public.api_usage FROM public;

-- =====================================================
-- GRANT APPROPRIATE PERMISSIONS
-- =====================================================

-- Service role gets full access
GRANT ALL ON signals.whatsapp_messages TO service_role;
GRANT ALL ON signals.reviews TO service_role;
GRANT ALL ON signals.signals TO service_role;
GRANT ALL ON actors.actor_profiles TO service_role;
GRANT ALL ON actors.actors TO service_role;
GRANT ALL ON public.signal_processing_state TO service_role;
GRANT ALL ON public.decoder_log TO service_role;
GRANT ALL ON public.api_usage TO service_role;

-- Authenticated users get read/write access (for future web app)
GRANT SELECT, INSERT, UPDATE, DELETE ON signals.whatsapp_messages TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON signals.reviews TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON signals.signals TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON actors.actor_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON actors.actors TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.signal_processing_state TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.decoder_log TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.api_usage TO authenticated;

-- =====================================================
-- TEST QUERY (COMMENTED OUT)
-- =====================================================

-- Test that service role still works:
-- SELECT COUNT(*) FROM signals.whatsapp_messages;
-- SELECT COUNT(*) FROM public.signal_processing_state;
-- SELECT COUNT(*) FROM public.decoder_log;
