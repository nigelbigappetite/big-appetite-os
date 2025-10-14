-- Fix signals_unified view to include message_direction field for proper outbound filtering
-- This ensures outbound WhatsApp messages are not processed for customer sentiment analysis

-- Drop and recreate the unified signals view with message_direction field
DROP VIEW IF EXISTS public.signals_unified;

CREATE VIEW public.signals_unified AS
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

-- Grant permissions
GRANT SELECT ON public.signals_unified TO service_role;
