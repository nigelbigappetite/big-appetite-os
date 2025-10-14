-- Unified signals view and processing state
-- Run this in Supabase SQL editor to enable unified signal processing

-- 1. Create processing state table
CREATE TABLE IF NOT EXISTS public.signal_processing_state (
  signal_id UUID PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'queued', -- queued|processed|error
  processed_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index for unprocessed signals
CREATE INDEX IF NOT EXISTS signal_processing_state_unprocessed_idx 
ON public.signal_processing_state (processed_at) 
WHERE processed_at IS NULL;

-- 2. Create unified signals view
CREATE OR REPLACE VIEW public.signals_unified AS
-- WhatsApp messages
SELECT
  w.signal_id,
  w.brand_id,
  'whatsapp'::text AS signal_type,
  'whatsapp'::text AS source_platform,
  'public.whatsapp_messages'::text AS source_table,
  w.signal_id::text AS source_pk,
  w.message_text AS signal_text,
  w.raw_content,
  w.raw_metadata,
  w.message_timestamp AS source_timestamp,
  w.received_at,
  w.created_at,
  w.message_direction
FROM public.whatsapp_messages w
UNION ALL
-- Reviews
SELECT
  r.signal_id,
  r.brand_id,
  'review'::text AS signal_type,
  COALESCE(r.review_source, 'review')::text AS source_platform,
  'public.reviews'::text AS source_table,
  r.signal_id::text AS source_pk,
  r.review_text AS signal_text,
  r.raw_content,
  r.raw_metadata,
  r.review_timestamp AS source_timestamp,
  r.received_at,
  r.created_at,
  NULL::text AS message_direction
FROM public.reviews r
UNION ALL
-- Signals table (if it has data)
SELECT
  s.signal_id,
  s.brand_id,
  COALESCE(s.signal_type, 'signal')::text AS signal_type,
  COALESCE(s.source_platform, 'unknown')::text AS source_platform,
  'public.signals'::text AS source_table,
  s.signal_id::text AS source_pk,
  s.raw_content AS signal_text,
  s.raw_content,
  s.raw_metadata,
  s.source_timestamp,
  s.received_at,
  s.created_at,
  NULL::text AS message_direction
FROM public.signals s
WHERE s.raw_content IS NOT NULL;

-- 3. Grant permissions
GRANT SELECT ON public.signals_unified TO service_role;
GRANT ALL ON public.signal_processing_state TO service_role;

-- 4. Create RPC function for complex queries (if needed)
CREATE OR REPLACE FUNCTION public.get_unprocessed_signals(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
  signal_id UUID,
  brand_id UUID,
  signal_type TEXT,
  source_platform TEXT,
  signal_text TEXT,
  raw_content TEXT,
  raw_metadata JSONB,
  source_timestamp TIMESTAMPTZ,
  received_at TIMESTAMPTZ
)
LANGUAGE SQL
AS $$
  SELECT 
    s.signal_id,
    s.brand_id,
    s.signal_type,
    s.source_platform,
    s.signal_text,
    s.raw_content,
    s.raw_metadata,
    s.source_timestamp,
    s.received_at
  FROM public.signals_unified s
  LEFT JOIN public.signal_processing_state p ON s.signal_id = p.signal_id
  WHERE p.processed_at IS NULL
  ORDER BY s.source_timestamp DESC NULLS LAST
  LIMIT limit_count;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_unprocessed_signals(INTEGER) TO service_role;

-- 5. Optional: Create materialized view for better performance (refresh periodically)
-- CREATE MATERIALIZED VIEW public.signals_unified_mv AS
-- SELECT * FROM public.signals_unified;
-- 
-- CREATE INDEX signals_unified_mv_timestamp_idx ON public.signals_unified_mv (source_timestamp);
-- CREATE INDEX signals_unified_mv_type_idx ON public.signals_unified_mv (signal_type);
-- 
-- -- Refresh function
-- CREATE OR REPLACE FUNCTION public.refresh_signals_unified()
-- RETURNS void
-- LANGUAGE SQL
-- AS $$
--   REFRESH MATERIALIZED VIEW public.signals_unified_mv;
-- $$;

-- 6. Sample query to test
-- SELECT signal_id, signal_type, source_platform, LEFT(signal_text, 50) as preview
-- FROM public.signals_unified 
-- ORDER BY source_timestamp DESC 
-- LIMIT 5;
