-- =====================================================
-- TESTING AND VALIDATION
-- Phase 7: Complete system testing
-- =====================================================

-- =====================================================
-- TEST DATA SETUP
-- =====================================================

-- Create test brand if not exists
INSERT INTO core.brands (brand_name, brand_slug, description, is_active)
VALUES ('Wing Shack Co', 'wing-shack-co', 'Premium chicken wing restaurant chain', true)
ON CONFLICT (brand_name) DO NOTHING;

-- Get test brand ID
DO $$
DECLARE
  test_brand_id UUID;
BEGIN
  SELECT brand_id INTO test_brand_id FROM core.brands WHERE brand_name = 'Wing Shack Co' LIMIT 1;
  
  -- Create test actors
  INSERT INTO actors.actor_profiles (
    identifiers, primary_identifier, driver_distribution, dominant_driver,
    driver_confidence, brand_id, signal_count, signal_sources
  ) VALUES 
  (
    '{"phones": ["+1234567890"]}'::jsonb,
    '+1234567890',
    '{"Safety": 0.6, "Connection": 0.3, "Status": 0.1, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
    'Safety',
    0.8,
    test_brand_id,
    0,
    '{}'::TEXT[]
  ),
  (
    '{"emails": ["test@example.com"]}'::jsonb,
    'test@example.com',
    '{"Safety": 0.2, "Connection": 0.2, "Status": 0.4, "Growth": 0.2, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
    'Status',
    0.7,
    test_brand_id,
    0,
    '{}'::TEXT[]
  )
  ON CONFLICT DO NOTHING;
END $$;

-- =====================================================
-- COMPREHENSIVE TESTING FUNCTIONS
-- =====================================================

-- Function to run comprehensive system tests
DROP FUNCTION IF EXISTS actors.run_system_tests();
CREATE OR REPLACE FUNCTION actors.run_system_tests()
RETURNS JSONB AS $$
DECLARE
  test_results JSONB := '{}';
  test_result JSONB;
  test_name TEXT;
  test_passed BOOLEAN;
  error_message TEXT;
  overall_passed BOOLEAN := true;
  test_count INTEGER;
BEGIN
  -- =====================================================
  -- TEST 1: DRIVER CONFLICT MATRICES
  -- =====================================================
  test_name := 'driver_conflict_matrices';
  BEGIN
    -- Test Safety vs Freedom conflict
    SELECT actors.calculate_entanglement('Safety', 'Freedom', '{"behavior": "chose_familiar_but_photographed"}'::jsonb)
    INTO test_result;
    
    test_passed := (test_result->>'correlation')::FLOAT < -0.5; -- Should be negative correlation
    error_message := CASE WHEN NOT test_passed THEN 'Safety-Freedom correlation not negative enough' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  test_results := jsonb_set(test_results, ARRAY[test_name], jsonb_build_object(
    'passed', test_passed,
    'error', error_message,
    'result', test_result
  ));
  
  IF NOT test_passed THEN overall_passed := false; END IF;
  
  -- =====================================================
  -- TEST 2: QUANTUM SUPERPOSITION DETECTION
  -- =====================================================
  test_name := 'quantum_superposition';
  BEGIN
    -- Test with balanced driver distribution
    SELECT actors.detect_superposition(
      '{"Safety": 0.45, "Status": 0.40, "Connection": 0.10, "Growth": 0.05, "Freedom": 0.00, "Purpose": 0.00}'::jsonb,
      '{"context": "social_setting"}'::jsonb
    ) INTO test_result;
    
    test_passed := (test_result->>'superposition_detected')::BOOLEAN = true;
    error_message := CASE WHEN NOT test_passed THEN 'Superposition not detected in balanced distribution' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  test_results := jsonb_set(test_results, ARRAY[test_name], jsonb_build_object(
    'passed', test_passed,
    'error', error_message,
    'result', test_result
  ));
  
  IF NOT test_passed THEN overall_passed := false; END IF;
  
  -- =====================================================
  -- TEST 3: BAYESIAN UPDATE SYSTEM
  -- =====================================================
  test_name := 'bayesian_update';
  BEGIN
    SELECT actors.apply_bayesian_update(
      '{"Safety": 0.5, "Connection": 0.3, "Status": 0.2, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
      '{"Safety": 0.2, "Connection": 0.1, "Status": 0.7, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
      0.8
    ) INTO test_result;
    
    test_passed := (test_result->'posterior_distribution'->>'Status')::FLOAT > 0.5; -- Status should increase
    error_message := CASE WHEN NOT test_passed THEN 'Bayesian update not working correctly' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  test_results := jsonb_set(test_results, ARRAY[test_name], jsonb_build_object(
    'passed', test_passed,
    'error', error_message,
    'result', test_result
  ));
  
  IF NOT test_passed THEN overall_passed := false; END IF;
  
  -- =====================================================
  -- TEST 4: QUANTUM PSYCHOLOGY DECODER
  -- =====================================================
  test_name := 'quantum_decoder';
  BEGIN
    SELECT actors.decode_signal_simple(
      'I love the premium wings, they are so exclusive and everyone is talking about them!',
      'whatsapp'
    ) INTO test_result;
    
    test_passed := (test_result->'seven_column_output'->'col6_core_driver'->>'primary') = 'Status';
    error_message := CASE WHEN NOT test_passed THEN 'Decoder not correctly identifying Status driver' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  test_results := jsonb_set(test_results, ARRAY[test_name], jsonb_build_object(
    'passed', test_passed,
    'error', error_message,
    'result', test_result
  ));
  
  IF NOT test_passed THEN overall_passed := false; END IF;
  
  -- =====================================================
  -- TEST 5: CONTRADICTION DETECTION
  -- =====================================================
  test_name := 'contradiction_detection';
  BEGIN
    SELECT actors.detect_driver_conflicts(
      '{"Safety": 0.45, "Status": 0.40, "Connection": 0.10, "Growth": 0.05, "Freedom": 0.00, "Purpose": 0.00}'::jsonb,
      '{"context": "social_setting"}'::jsonb
    ) INTO test_result;
    
    test_passed := (test_result->>'contradictions_detected')::BOOLEAN = true;
    error_message := CASE WHEN NOT test_passed THEN 'Driver conflicts not detected' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  test_results := jsonb_set(test_results, ARRAY[test_name], jsonb_build_object(
    'passed', test_passed,
    'error', error_message,
    'result', test_result
  ));
  
  IF NOT test_passed THEN overall_passed := false; END IF;
  
  -- =====================================================
  -- TEST 6: IDENTITY FRAGMENT DETECTION
  -- =====================================================
  test_name := 'identity_fragments';
  BEGIN
    SELECT actors.detect_identity_fragmentation(
      '[
        {"label": "protector", "confidence": 0.82, "reinforcement_count": 23},
        {"label": "aspiring_connoisseur", "confidence": 0.45, "reinforcement_count": 7}
      ]'::jsonb
    ) INTO test_result;
    
    test_passed := (test_result->>'fragmentation_detected')::BOOLEAN = true;
    error_message := CASE WHEN NOT test_passed THEN 'Identity fragmentation not detected' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  test_results := jsonb_set(test_results, ARRAY[test_name], jsonb_build_object(
    'passed', test_passed,
    'error', error_message,
    'result', test_result
  ));
  
  IF NOT test_passed THEN overall_passed := false; END IF;
  
  -- =====================================================
  -- TEST 7: COMPLETE SIGNAL PROCESSING
  -- =====================================================
  test_name := 'signal_processing';
  BEGIN
    -- Create a test signal
    INSERT INTO signals.whatsapp_messages (
      message_text, sender_phone, message_timestamp, brand_id, processing_status
    ) VALUES (
      'I always get the same thing, I know what I like and it never disappoints',
      '+1234567890',
      NOW(),
      (SELECT brand_id FROM core.brands WHERE brand_name = 'Wing Shack Co' LIMIT 1),
      'pending'
    ) RETURNING signal_id INTO test_result;
    
    -- Process the signal
    SELECT signals.process_signal_complete(
      test_result,
      'whatsapp',
      (SELECT actor_id FROM actors.actor_profiles WHERE primary_identifier = '+1234567890' LIMIT 1),
      false
    ) INTO test_result;
    
    test_passed := (test_result->>'processing_status')::TEXT = 'completed_with_profile_update';
    error_message := CASE WHEN NOT test_passed THEN 'Signal processing failed' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  test_results := jsonb_set(test_results, ARRAY[test_name], jsonb_build_object(
    'passed', test_passed,
    'error', error_message,
    'result', test_result
  ));
  
  IF NOT test_passed THEN overall_passed := false; END IF;
  
  -- =====================================================
  -- FINAL RESULT
  -- =====================================================
  
  -- Build result with explicit count calculation
  SELECT COUNT(*) INTO test_count FROM jsonb_object_keys(test_results);
  
  RETURN jsonb_build_object(
    'overall_passed', overall_passed,
    'test_count', test_count,
    'test_results', test_results,
    'test_timestamp', NOW(),
    'quantum_psychology_version', '1.0'
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PERFORMANCE TESTING
-- =====================================================

-- Function to test system performance
DROP FUNCTION IF EXISTS actors.test_system_performance();
CREATE OR REPLACE FUNCTION actors.test_system_performance()
RETURNS JSONB AS $$
DECLARE
  start_time TIMESTAMPTZ;
  end_time TIMESTAMPTZ;
  duration_ms INTEGER;
  test_results JSONB := '{}';
  test_result JSONB;
  i INTEGER;
  test_count INTEGER := 10;
BEGIN
  -- =====================================================
  -- TEST 1: DECODER PERFORMANCE
  -- =====================================================
  start_time := clock_timestamp();
  
  FOR i IN 1..test_count LOOP
    PERFORM actors.decode_signal_simple(
      'I love the premium wings, they are so exclusive and everyone is talking about them!',
      'whatsapp'
    );
  END LOOP;
  
  end_time := clock_timestamp();
  duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
  
  test_results := jsonb_set(test_results, ARRAY['decoder_performance'], jsonb_build_object(
    'test_count', test_count,
    'total_duration_ms', duration_ms,
    'average_duration_ms', duration_ms / test_count,
    'performance_rating', CASE 
      WHEN duration_ms / test_count < 100 THEN 'excellent'
      WHEN duration_ms / test_count < 500 THEN 'good'
      WHEN duration_ms / test_count < 1000 THEN 'acceptable'
      ELSE 'poor'
    END
  ));
  
  -- =====================================================
  -- TEST 2: BAYESIAN UPDATE PERFORMANCE
  -- =====================================================
  start_time := clock_timestamp();
  
  FOR i IN 1..test_count LOOP
    PERFORM actors.apply_bayesian_update(
      '{"Safety": 0.5, "Connection": 0.3, "Status": 0.2, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
      '{"Safety": 0.2, "Connection": 0.1, "Status": 0.7, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
      0.8
    );
  END LOOP;
  
  end_time := clock_timestamp();
  duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
  
  test_results := jsonb_set(test_results, ARRAY['bayesian_performance'], jsonb_build_object(
    'test_count', test_count,
    'total_duration_ms', duration_ms,
    'average_duration_ms', duration_ms / test_count,
    'performance_rating', CASE 
      WHEN duration_ms / test_count < 50 THEN 'excellent'
      WHEN duration_ms / test_count < 200 THEN 'good'
      WHEN duration_ms / test_count < 500 THEN 'acceptable'
      ELSE 'poor'
    END
  ));
  
  -- =====================================================
  -- TEST 3: QUANTUM STATE CALCULATION PERFORMANCE
  -- =====================================================
  start_time := clock_timestamp();
  
  FOR i IN 1..test_count LOOP
    PERFORM actors.detect_superposition(
      '{"Safety": 0.45, "Status": 0.40, "Connection": 0.10, "Growth": 0.05, "Freedom": 0.00, "Purpose": 0.00}'::jsonb,
      '{"context": "social_setting"}'::jsonb
    );
  END LOOP;
  
  end_time := clock_timestamp();
  duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
  
  test_results := jsonb_set(test_results, ARRAY['quantum_performance'], jsonb_build_object(
    'test_count', test_count,
    'total_duration_ms', duration_ms,
    'average_duration_ms', duration_ms / test_count,
    'performance_rating', CASE 
      WHEN duration_ms / test_count < 50 THEN 'excellent'
      WHEN duration_ms / test_count < 200 THEN 'good'
      WHEN duration_ms / test_count < 500 THEN 'acceptable'
      ELSE 'poor'
    END
  ));
  
  RETURN jsonb_build_object(
    'performance_tests', test_results,
    'test_timestamp', NOW(),
    'overall_rating', CASE 
      WHEN (
        (test_results->'decoder_performance'->>'performance_rating') IN ('excellent', 'good') AND
        (test_results->'bayesian_performance'->>'performance_rating') IN ('excellent', 'good') AND
        (test_results->'quantum_performance'->>'performance_rating') IN ('excellent', 'good')
      ) THEN 'excellent'
      ELSE 'needs_optimization'
    END
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- INTEGRATION TESTING
-- =====================================================

-- Function to test complete integration
DROP FUNCTION IF EXISTS actors.test_integration();
CREATE OR REPLACE FUNCTION actors.test_integration()
RETURNS JSONB AS $$
DECLARE
  test_actor_id UUID;
  test_signal_id UUID;
  processing_result JSONB;
  profile_result JSONB;
  test_passed BOOLEAN := true;
  error_message TEXT;
BEGIN
  -- Get test actor
  SELECT actor_id INTO test_actor_id 
  FROM actors.actor_profiles 
  WHERE primary_identifier = '+1234567890' 
  LIMIT 1;
  
  IF test_actor_id IS NULL THEN
    RETURN jsonb_build_object(
      'passed', false,
      'error', 'Test actor not found',
      'step', 'actor_lookup'
    );
  END IF;
  
  -- Create test signal
  INSERT INTO signals.whatsapp_messages (
    message_text, sender_phone, message_timestamp, brand_id, processing_status
  ) VALUES (
    'I am trying to build my tolerance for spicy food, getting better at it!',
    '+1234567890',
    NOW(),
    (SELECT brand_id FROM core.brands WHERE brand_name = 'Wing Shack Co' LIMIT 1),
    'pending'
  ) RETURNING signal_id INTO test_signal_id;
  
  -- Process signal
  BEGIN
    SELECT signals.process_signal_complete(
      test_signal_id,
      'whatsapp',
      test_actor_id,
      false
    ) INTO processing_result;
    
    test_passed := (processing_result->>'processing_status')::TEXT = 'completed_with_profile_update';
    error_message := CASE WHEN NOT test_passed THEN 'Signal processing failed' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  IF NOT test_passed THEN
    RETURN jsonb_build_object(
      'passed', false,
      'error', error_message,
      'step', 'signal_processing',
      'processing_result', processing_result
    );
  END IF;
  
  -- Check profile update
  BEGIN
    SELECT actors.get_actor_summary(test_actor_id) INTO profile_result;
    
    test_passed := (profile_result->>'signal_count')::INTEGER > 0;
    error_message := CASE WHEN NOT test_passed THEN 'Profile not updated' ELSE NULL END;
  EXCEPTION WHEN OTHERS THEN
    test_passed := false;
    error_message := SQLERRM;
  END;
  
  IF NOT test_passed THEN
    RETURN jsonb_build_object(
      'passed', false,
      'error', error_message,
      'step', 'profile_update',
      'profile_result', profile_result
    );
  END IF;
  
  RETURN jsonb_build_object(
    'passed', true,
    'test_actor_id', test_actor_id,
    'test_signal_id', test_signal_id,
    'processing_result', processing_result,
    'profile_result', profile_result,
    'integration_successful', true
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Run all tests
SELECT jsonb_pretty(actors.run_system_tests());

-- Test performance
SELECT jsonb_pretty(actors.test_system_performance());

-- Test integration
SELECT jsonb_pretty(actors.test_integration());

-- Quick decoder test
SELECT jsonb_pretty(
  actors.decode_signal_simple(
    'I love the premium wings, they are so exclusive and everyone is talking about them!',
    'whatsapp'
  )
);
