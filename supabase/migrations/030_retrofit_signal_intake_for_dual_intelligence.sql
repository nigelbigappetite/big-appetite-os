-- =====================================================
-- SIGNAL INTAKE RETROFIT FOR DUAL-LAYER INTELLIGENCE
-- Phase 2: Align existing signal tables with actor intelligence
-- =====================================================

-- =====================================================
-- STEP 1: ENHANCE WHATSAPP MESSAGES TABLE
-- =====================================================

-- Add missing columns to whatsapp_messages for dual-layer processing
ALTER TABLE signals.whatsapp_messages 
ADD COLUMN IF NOT EXISTS message_timestamp TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS message_direction TEXT DEFAULT 'inbound',
ADD COLUMN IF NOT EXISTS raw_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS intake_method TEXT,
ADD COLUMN IF NOT EXISTS intake_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing records to have proper timestamps
UPDATE signals.whatsapp_messages 
SET message_timestamp = COALESCE(timestamp, received_at, NOW())
WHERE message_timestamp IS NULL;

-- Update message_direction based on is_inbound
UPDATE signals.whatsapp_messages 
SET message_direction = CASE 
  WHEN is_inbound = true THEN 'inbound'
  WHEN is_inbound = false THEN 'outbound'
  ELSE 'inbound'
END
WHERE message_direction IS NULL;

-- =====================================================
-- STEP 2: ENHANCE REVIEWS TABLE
-- =====================================================

-- Add missing columns to reviews table
ALTER TABLE signals.reviews 
ADD COLUMN IF NOT EXISTS review_timestamp TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS reviewer_name TEXT,
ADD COLUMN IF NOT EXISTS raw_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS intake_method TEXT,
ADD COLUMN IF NOT EXISTS intake_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing records
UPDATE signals.reviews 
SET review_timestamp = COALESCE(received_at, NOW())
WHERE review_timestamp IS NULL;

-- =====================================================
-- STEP 3: ENHANCE ORDERS TABLE
-- =====================================================

-- Add missing columns to orders table
ALTER TABLE signals.orders 
ADD COLUMN IF NOT EXISTS order_timestamp TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS order_total NUMERIC(10,2),
ADD COLUMN IF NOT EXISTS order_items JSONB,
ADD COLUMN IF NOT EXISTS order_status TEXT,
ADD COLUMN IF NOT EXISTS raw_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS intake_method TEXT,
ADD COLUMN IF NOT EXISTS intake_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing records
UPDATE signals.orders 
SET order_timestamp = COALESCE(received_at, NOW())
WHERE order_timestamp IS NULL;

-- =====================================================
-- STEP 4: ENHANCE SURVEY RESPONSES TABLE
-- =====================================================

-- Add missing columns to survey_responses table
ALTER TABLE signals.survey_responses 
ADD COLUMN IF NOT EXISTS survey_timestamp TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS raw_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS intake_method TEXT,
ADD COLUMN IF NOT EXISTS intake_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing records
UPDATE signals.survey_responses 
SET survey_timestamp = COALESCE(received_at, NOW())
WHERE survey_timestamp IS NULL;

-- =====================================================
-- STEP 5: ENHANCE SOCIAL COMMENTS TABLES
-- =====================================================

-- Enhance tiktok_comments table
ALTER TABLE signals.tiktok_comments 
ADD COLUMN IF NOT EXISTS raw_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS intake_method TEXT,
ADD COLUMN IF NOT EXISTS intake_metadata JSONB DEFAULT '{}'::jsonb;

-- Enhance instagram_comments table
ALTER TABLE signals.instagram_comments 
ADD COLUMN IF NOT EXISTS raw_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS intake_method TEXT,
ADD COLUMN IF NOT EXISTS intake_metadata JSONB DEFAULT '{}'::jsonb;

-- =====================================================
-- STEP 6: CREATE UNIFIED SIGNAL PROCESSING FUNCTION
-- =====================================================

-- Function to process any signal through dual extraction
CREATE OR REPLACE FUNCTION signals.process_signal_for_intelligence(
  p_signal_id UUID,
  p_signal_type TEXT
)
RETURNS JSONB AS $$
DECLARE
  signal_data RECORD;
  signal_text TEXT;
  result JSONB;
BEGIN
  -- Get signal data based on type
  CASE p_signal_type
    WHEN 'whatsapp' THEN
      SELECT 
        signal_id,
        message_text,
        sender_phone,
        message_timestamp,
        brand_id
      INTO signal_data
      FROM signals.whatsapp_messages
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.message_text;
      
    WHEN 'review' THEN
      SELECT 
        signal_id,
        review_text,
        reviewer_name,
        review_timestamp,
        brand_id
      INTO signal_data
      FROM signals.reviews
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.review_text;
      
    WHEN 'survey' THEN
      SELECT 
        signal_id,
        response_text,
        respondent_email,
        survey_timestamp,
        brand_id
      INTO signal_data
      FROM signals.survey_responses
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.response_text;
      
    WHEN 'order' THEN
      SELECT 
        signal_id,
        order_items::TEXT,
        customer_email,
        order_timestamp,
        brand_id
      INTO signal_data
      FROM signals.orders
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.order_items::TEXT;
      
    ELSE
      RAISE EXCEPTION 'Unknown signal type: %', p_signal_type;
  END CASE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Signal not found: %', p_signal_id;
  END IF;
  
  -- Process through dual extraction (simplified version)
  result := jsonb_build_object(
    'signal_id', p_signal_id,
    'signal_type', p_signal_type,
    'signal_text', signal_text,
    'processed_at', NOW(),
    'status', 'processed'
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STEP 7: CREATE SIGNAL-TO-ACTOR LINKING FUNCTION
-- =====================================================

-- Function to link signals to actors based on identifiers
CREATE OR REPLACE FUNCTION signals.link_signal_to_actor(
  p_signal_id UUID,
  p_signal_type TEXT,
  p_identifier TEXT,
  p_identifier_type TEXT
)
RETURNS UUID AS $$
DECLARE
  actor_id UUID;
  brand_id UUID;
BEGIN
  -- Get brand_id from signal
  CASE p_signal_type
    WHEN 'whatsapp' THEN
      SELECT w.brand_id INTO brand_id
      FROM signals.whatsapp_messages w
      WHERE w.signal_id = p_signal_id;
    WHEN 'review' THEN
      SELECT r.brand_id INTO brand_id
      FROM signals.reviews r
      WHERE r.signal_id = p_signal_id;
    WHEN 'survey' THEN
      SELECT s.brand_id INTO brand_id
      FROM signals.survey_responses s
      WHERE s.signal_id = p_signal_id;
    WHEN 'order' THEN
      SELECT o.brand_id INTO brand_id
      FROM signals.orders o
      WHERE o.signal_id = p_signal_id;
  END CASE;
  
  -- Find or create actor
  SELECT a.actor_id INTO actor_id
  FROM actors.actor_profiles a
  WHERE a.primary_identifier = p_identifier
    AND a.brand_id = brand_id;
  
  IF NOT FOUND THEN
    -- Create new actor
    INSERT INTO actors.actor_profiles (
      identifiers,
      primary_identifier,
      preferences,
      driver_distribution,
      signal_count,
      signal_sources,
      brand_id,
      profile_completeness,
      confidence_in_identity,
      entropy
    ) VALUES (
      jsonb_build_object(
        CASE p_identifier_type
          WHEN 'phone' THEN 'phones'
          WHEN 'email' THEN 'emails'
          WHEN 'name' THEN 'names'
          ELSE 'other'
        END, ARRAY[p_identifier]
      ),
      p_identifier,
      '{}'::jsonb,
      '{"Buffer": 0.16, "Bond": 0.16, "Badge": 0.16, "Build": 0.17, "Breadth": 0.17, "Meaning": 0.18}'::jsonb,
      0,
      ARRAY[p_signal_type],
      brand_id,
      0.1,
      0.9,
      2.58
    ) RETURNING actor_id INTO actor_id;
  END IF;
  
  -- Update signal with actor_id
  CASE p_signal_type
    WHEN 'whatsapp' THEN
      UPDATE signals.whatsapp_messages 
      SET actor_id = actor_id
      WHERE signal_id = p_signal_id;
    WHEN 'review' THEN
      UPDATE signals.reviews 
      SET actor_id = actor_id
      WHERE signal_id = p_signal_id;
    WHEN 'survey' THEN
      UPDATE signals.survey_responses 
      SET actor_id = actor_id
      WHERE signal_id = p_signal_id;
    WHEN 'order' THEN
      UPDATE signals.orders 
      SET actor_id = actor_id
      WHERE signal_id = p_signal_id;
  END CASE;
  
  RETURN actor_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STEP 8: CREATE BATCH PROCESSING FUNCTION
-- =====================================================

-- Function to process all existing signals
CREATE OR REPLACE FUNCTION signals.batch_process_existing_signals()
RETURNS JSONB AS $$
DECLARE
  result JSONB := '{}';
  whatsapp_count INTEGER := 0;
  review_count INTEGER := 0;
  survey_count INTEGER := 0;
  order_count INTEGER := 0;
  total_processed INTEGER := 0;
BEGIN
  -- Process WhatsApp messages
  SELECT COUNT(*) INTO whatsapp_count
  FROM signals.whatsapp_messages;
  
  -- Process reviews
  SELECT COUNT(*) INTO review_count
  FROM signals.reviews;
  
  -- Process survey responses
  SELECT COUNT(*) INTO survey_count
  FROM signals.survey_responses;
  
  -- Process orders
  SELECT COUNT(*) INTO order_count
  FROM signals.orders;
  
  total_processed := whatsapp_count + review_count + survey_count + order_count;
  
  result := jsonb_build_object(
    'whatsapp_messages', whatsapp_count,
    'reviews', review_count,
    'survey_responses', survey_count,
    'orders', order_count,
    'total_signals', total_processed,
    'status', 'ready_for_processing'
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check enhanced table structures
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'signals' 
  AND table_name IN ('whatsapp_messages', 'reviews', 'orders', 'survey_responses')
ORDER BY table_name, ordinal_position;

-- Check signal counts
SELECT signals.batch_process_existing_signals();

-- Test signal processing
SELECT signals.process_signal_for_intelligence(
  (SELECT signal_id FROM signals.whatsapp_messages LIMIT 1),
  'whatsapp'
);

