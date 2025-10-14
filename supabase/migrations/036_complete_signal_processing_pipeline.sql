-- =====================================================
-- COMPLETE SIGNAL PROCESSING PIPELINE
-- Phase 6: End-to-end driver-first psychology system
-- =====================================================

-- =====================================================
-- MAIN SIGNAL PROCESSING PIPELINE
-- =====================================================

CREATE OR REPLACE FUNCTION signals.process_signal_complete(
  p_signal_id UUID,
  p_signal_type TEXT,
  p_actor_id UUID DEFAULT NULL,
  p_force_processing BOOLEAN DEFAULT FALSE
)
RETURNS JSONB AS $$
DECLARE
  signal_data RECORD;
  signal_text TEXT;
  signal_context JSONB;
  decoder_result JSONB;
  profile_update_result JSONB;
  decoder_log_id UUID;
  processing_status TEXT;
  result JSONB;
BEGIN
  -- =====================================================
  -- STEP 1: EXTRACT SIGNAL DATA
  -- =====================================================
  
  -- Get signal data based on type
  CASE p_signal_type
    WHEN 'whatsapp' THEN
      SELECT 
        signal_id,
        message_text,
        sender_phone,
        message_timestamp,
        brand_id,
        actor_id as existing_actor_id
      INTO signal_data
      FROM signals.whatsapp_messages
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.message_text;
      signal_context := jsonb_build_object(
        'context', 'whatsapp_message',
        'sender_phone', signal_data.sender_phone,
        'timestamp', signal_data.message_timestamp,
        'brand_id', signal_data.brand_id
      );
      
    WHEN 'review' THEN
      SELECT 
        signal_id,
        review_text,
        reviewer_name,
        review_timestamp,
        brand_id,
        actor_id as existing_actor_id
      INTO signal_data
      FROM signals.reviews
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.review_text;
      signal_context := jsonb_build_object(
        'context', 'review',
        'reviewer_name', signal_data.reviewer_name,
        'timestamp', signal_data.review_timestamp,
        'brand_id', signal_data.brand_id
      );
      
    WHEN 'survey' THEN
      SELECT 
        signal_id,
        response_text,
        respondent_email,
        survey_timestamp,
        brand_id,
        actor_id as existing_actor_id
      INTO signal_data
      FROM signals.survey_responses
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.response_text;
      signal_context := jsonb_build_object(
        'context', 'survey_response',
        'respondent_email', signal_data.respondent_email,
        'timestamp', signal_data.survey_timestamp,
        'brand_id', signal_data.brand_id
      );
      
    WHEN 'order' THEN
      SELECT 
        signal_id,
        order_items::TEXT,
        customer_email,
        order_timestamp,
        brand_id,
        actor_id as existing_actor_id
      INTO signal_data
      FROM signals.orders
      WHERE signal_id = p_signal_id;
      
      signal_text := signal_data.order_items::TEXT;
      signal_context := jsonb_build_object(
        'context', 'order',
        'customer_email', signal_data.customer_email,
        'timestamp', signal_data.order_timestamp,
        'brand_id', signal_data.brand_id
      );
      
    ELSE
      RAISE EXCEPTION 'Unknown signal type: %', p_signal_type;
  END CASE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Signal not found: %', p_signal_id;
  END IF;
  
  -- Use existing actor_id if available, otherwise use provided one
  IF signal_data.existing_actor_id IS NOT NULL THEN
    p_actor_id := signal_data.existing_actor_id;
  END IF;
  
  -- =====================================================
  -- STEP 2: QUANTUM PSYCHOLOGY DECODING
  -- =====================================================
  
  -- Decode signal using quantum psychology decoder
  SELECT actors.decode_signal_quantum(
    signal_text,
    p_signal_type,
    signal_context,
    p_actor_id
  ) INTO decoder_result;
  
  -- =====================================================
  -- STEP 3: LOG DECODER OUTPUT
  -- =====================================================
  
  INSERT INTO actors.decoder_log (
    actor_id, signal_id,
    col1_actor_segment, col2_observed_behavior, col3_belief_inferred,
    col4_confidence_score, col5_friction_contradiction, col6_core_driver,
    col7_actionable_insight, full_reasoning_chain, decoder_output,
    signal_type, processing_confidence
  ) VALUES (
    p_actor_id, p_signal_id,
    decoder_result->'seven_column_output'->'col1_actor_segment',
    decoder_result->'seven_column_output'->'col2_observed_behavior',
    decoder_result->'seven_column_output'->'col3_belief_inferred',
    decoder_result->'seven_column_output'->'col4_confidence_score',
    decoder_result->'seven_column_output'->'col5_friction_contradiction',
    decoder_result->'seven_column_output'->'col6_core_driver',
    decoder_result->'seven_column_output'->'col7_actionable_insight',
    'Quantum psychology analysis completed for signal ' || p_signal_id,
    decoder_result,
    p_signal_type,
    (decoder_result->'seven_column_output'->'col4_confidence_score'->>'overall')::FLOAT
  ) RETURNING log_id INTO decoder_log_id;
  
  -- =====================================================
  -- STEP 4: UPDATE ACTOR PROFILE (if actor_id provided)
  -- =====================================================
  
  IF p_actor_id IS NOT NULL THEN
    -- Update actor profile with quantum psychology
    SELECT actors.update_actor_profile_quantum(
      p_actor_id,
      decoder_result->'signal_analysis',
      p_signal_id,
      p_signal_type,
      signal_context
    ) INTO profile_update_result;
    
    processing_status := 'completed_with_profile_update';
  ELSE
    profile_update_result := jsonb_build_object(
      'actor_id', NULL,
      'update_skipped', true,
      'reason', 'No actor_id provided'
    );
    processing_status := 'completed_without_profile_update';
  END IF;
  
  -- =====================================================
  -- STEP 5: UPDATE SIGNAL PROCESSING STATUS
  -- =====================================================
  
  -- Update signal processing status
  CASE p_signal_type
    WHEN 'whatsapp' THEN
      UPDATE signals.whatsapp_messages 
      SET 
        processing_status = processing_status,
        processed_at = NOW(),
        actor_id = p_actor_id
      WHERE signal_id = p_signal_id;
    WHEN 'review' THEN
      UPDATE signals.reviews 
      SET 
        processing_status = processing_status,
        processed_at = NOW(),
        actor_id = p_actor_id
      WHERE signal_id = p_signal_id;
    WHEN 'survey' THEN
      UPDATE signals.survey_responses 
      SET 
        processing_status = processing_status,
        processed_at = NOW(),
        actor_id = p_actor_id
      WHERE signal_id = p_signal_id;
    WHEN 'order' THEN
      UPDATE signals.orders 
      SET 
        processing_status = processing_status,
        processed_at = NOW(),
        actor_id = p_actor_id
      WHERE signal_id = p_signal_id;
  END CASE;
  
  -- =====================================================
  -- STEP 6: BUILD RESULT
  -- =====================================================
  
  result := jsonb_build_object(
    'signal_id', p_signal_id,
    'signal_type', p_signal_type,
    'actor_id', p_actor_id,
    'decoder_log_id', decoder_log_id,
    'processing_status', processing_status,
    'decoder_result', decoder_result,
    'profile_update', profile_update_result,
    'processing_timestamp', NOW(),
    'quantum_psychology_version', '1.0'
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- BATCH PROCESSING FUNCTIONS
-- =====================================================

-- Function to process all unprocessed signals
CREATE OR REPLACE FUNCTION signals.batch_process_all_signals(
  p_signal_types TEXT[] DEFAULT ARRAY['whatsapp', 'review', 'survey', 'order'],
  p_batch_size INTEGER DEFAULT 100,
  p_force_processing BOOLEAN DEFAULT FALSE
)
RETURNS JSONB AS $$
DECLARE
  signal_type TEXT;
  signal_count INTEGER;
  processed_count INTEGER := 0;
  total_processed INTEGER := 0;
  batch_result JSONB;
  results JSONB := '{}';
  signal_record RECORD;
  processing_result JSONB;
BEGIN
  -- Process each signal type
  FOREACH signal_type IN ARRAY p_signal_types
  LOOP
    -- Get count of unprocessed signals
    CASE signal_type
      WHEN 'whatsapp' THEN
        SELECT COUNT(*) INTO signal_count
        FROM signals.whatsapp_messages
        WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed');
      WHEN 'review' THEN
        SELECT COUNT(*) INTO signal_count
        FROM signals.reviews
        WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed');
      WHEN 'survey' THEN
        SELECT COUNT(*) INTO signal_count
        FROM signals.survey_responses
        WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed');
      WHEN 'order' THEN
        SELECT COUNT(*) INTO signal_count
        FROM signals.orders
        WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed');
    END CASE;
    
    -- Process signals in batches
    processed_count := 0;
    
    CASE signal_type
      WHEN 'whatsapp' THEN
        FOR signal_record IN 
          SELECT signal_id, actor_id
          FROM signals.whatsapp_messages
          WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed')
          LIMIT p_batch_size
        LOOP
          SELECT signals.process_signal_complete(
            signal_record.signal_id,
            'whatsapp',
            signal_record.actor_id,
            p_force_processing
          ) INTO processing_result;
          
          processed_count := processed_count + 1;
        END LOOP;
        
      WHEN 'review' THEN
        FOR signal_record IN 
          SELECT signal_id, actor_id
          FROM signals.reviews
          WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed')
          LIMIT p_batch_size
        LOOP
          SELECT signals.process_signal_complete(
            signal_record.signal_id,
            'review',
            signal_record.actor_id,
            p_force_processing
          ) INTO processing_result;
          
          processed_count := processed_count + 1;
        END LOOP;
        
      WHEN 'survey' THEN
        FOR signal_record IN 
          SELECT signal_id, actor_id
          FROM signals.survey_responses
          WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed')
          LIMIT p_batch_size
        LOOP
          SELECT signals.process_signal_complete(
            signal_record.signal_id,
            'survey',
            signal_record.actor_id,
            p_force_processing
          ) INTO processing_result;
          
          processed_count := processed_count + 1;
        END LOOP;
        
      WHEN 'order' THEN
        FOR signal_record IN 
          SELECT signal_id, actor_id
          FROM signals.orders
          WHERE processing_status = 'pending' OR (p_force_processing AND processing_status != 'completed')
          LIMIT p_batch_size
        LOOP
          SELECT signals.process_signal_complete(
            signal_record.signal_id,
            'order',
            signal_record.actor_id,
            p_force_processing
          ) INTO processing_result;
          
          processed_count := processed_count + 1;
        END LOOP;
    END CASE;
    
    total_processed := total_processed + processed_count;
    
    results := jsonb_set(results, ARRAY[signal_type], jsonb_build_object(
      'total_signals', signal_count,
      'processed', processed_count,
      'remaining', signal_count - processed_count
    ));
  END LOOP;
  
  batch_result := jsonb_build_object(
    'total_processed', total_processed,
    'signal_types', results,
    'processing_timestamp', NOW(),
    'batch_size', p_batch_size,
    'force_processing', p_force_processing
  );
  
  RETURN batch_result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ACTOR CREATION AND LINKING
-- =====================================================

-- Function to create or link actor based on signal
CREATE OR REPLACE FUNCTION signals.create_or_link_actor(
  p_signal_id UUID,
  p_signal_type TEXT,
  p_identifier TEXT,
  p_identifier_type TEXT,
  p_brand_id UUID
)
RETURNS UUID AS $$
DECLARE
  actor_id UUID;
  existing_actor_id UUID;
  new_actor_id UUID;
  result JSONB;
BEGIN
  -- Check if actor already exists
  SELECT a.actor_id INTO existing_actor_id
  FROM actors.actor_profiles a
  WHERE a.primary_identifier = p_identifier
    AND a.brand_id = p_brand_id;
  
  IF existing_actor_id IS NOT NULL THEN
    actor_id := existing_actor_id;
  ELSE
    -- Create new actor
    INSERT INTO actors.actor_profiles (
      identifiers,
      primary_identifier,
      driver_distribution,
      dominant_driver,
      driver_confidence,
      quantum_states,
      internal_contradictions,
      identity_markers,
      belief_network,
      signal_count,
      signal_sources,
      brand_id,
      profile_completeness,
      confidence_in_identity,
      entropy,
      information_gain
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
      '{"Safety": 0.16, "Connection": 0.16, "Status": 0.17, "Growth": 0.17, "Freedom": 0.17, "Purpose": 0.17}'::jsonb,
      'Safety', -- Default dominant driver
      0.5, -- Initial confidence
      '{}'::jsonb, -- Empty quantum states
      '[]'::jsonb, -- No contradictions initially
      '[]'::jsonb, -- No identity markers initially
      '{"priors": {"Safety": 0.16, "Connection": 0.16, "Status": 0.17, "Growth": 0.17, "Freedom": 0.17, "Purpose": 0.17}}'::jsonb,
      0,
      ARRAY[p_signal_type],
      p_brand_id,
      0.1, -- Low initial completeness
      0.9, -- High confidence in identity
      2.58, -- Maximum entropy initially
      0.0 -- No information gain yet
    ) RETURNING actor_id INTO new_actor_id;
    
    actor_id := new_actor_id;
  END IF;
  
  -- Link signal to actor
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
-- QUERY FUNCTIONS FOR ANALYSIS
-- =====================================================

-- Function to get actor profile summary
CREATE OR REPLACE FUNCTION actors.get_actor_summary(p_actor_id UUID)
RETURNS JSONB AS $$
DECLARE
  profile RECORD;
  recent_updates JSONB;
  decoder_logs JSONB;
  result JSONB;
BEGIN
  -- Get actor profile
  SELECT 
    actor_id,
    primary_identifier,
    driver_distribution,
    dominant_driver,
    driver_confidence,
    quantum_states,
    contradiction_complexity,
    resolution_capacity,
    identity_coherence,
    entropy,
    signal_count,
    signal_sources,
    last_updated
  INTO profile
  FROM actors.actor_profiles
  WHERE actor_id = p_actor_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('error', 'Actor not found');
  END IF;
  
  -- Get recent updates
  SELECT jsonb_agg(
    jsonb_build_object(
      'update_id', update_id,
      'signal_id', signal_id,
      'entropy_reduction', entropy_reduction,
      'information_gain', information_gain,
      'update_timestamp', update_timestamp
    )
  ) INTO recent_updates
  FROM actors.actor_updates
  WHERE actor_id = p_actor_id
  ORDER BY update_timestamp DESC
  LIMIT 10;
  
  -- Get recent decoder logs
  SELECT jsonb_agg(
    jsonb_build_object(
      'log_id', log_id,
      'signal_id', signal_id,
      'core_driver', col6_core_driver,
      'confidence', col4_confidence_score,
      'processed_at', processed_at
    )
  ) INTO decoder_logs
  FROM actors.decoder_log
  WHERE actor_id = p_actor_id
  ORDER BY processed_at DESC
  LIMIT 10;
  
  result := jsonb_build_object(
    'actor_id', profile.actor_id,
    'primary_identifier', profile.primary_identifier,
    'driver_distribution', profile.driver_distribution,
    'dominant_driver', profile.dominant_driver,
    'driver_confidence', profile.driver_confidence,
    'quantum_states', profile.quantum_states,
    'contradiction_complexity', profile.contradiction_complexity,
    'resolution_capacity', profile.resolution_capacity,
    'identity_coherence', profile.identity_coherence,
    'entropy', profile.entropy,
    'signal_count', profile.signal_count,
    'signal_sources', profile.signal_sources,
    'last_updated', profile.last_updated,
    'recent_updates', COALESCE(recent_updates, '[]'::jsonb),
    'recent_decoder_logs', COALESCE(decoder_logs, '[]'::jsonb)
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Test complete signal processing
SELECT signals.process_signal_complete(
  (SELECT signal_id FROM signals.whatsapp_messages LIMIT 1),
  'whatsapp',
  NULL,
  false
);

-- Test batch processing
SELECT signals.batch_process_all_signals(
  ARRAY['whatsapp'],
  5,
  false
);

-- Test actor creation and linking
SELECT signals.create_or_link_actor(
  (SELECT signal_id FROM signals.whatsapp_messages LIMIT 1),
  'whatsapp',
  '+1234567890',
  'phone',
  (SELECT brand_id FROM core.brands LIMIT 1)
);

-- Test actor summary
SELECT actors.get_actor_summary(
  (SELECT actor_id FROM actors.actor_profiles LIMIT 1)
);
