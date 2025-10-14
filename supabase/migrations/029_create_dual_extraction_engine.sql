-- =====================================================
-- DUAL EXTRACTION ENGINE - PHASE 2
-- Core Intelligence System for Actor Analysis
-- =====================================================

-- =====================================================
-- SYSTEM 1: PREFERENCE EXTRACTION FUNCTIONS
-- =====================================================

-- Function to extract preferences from signal text using product intelligence
CREATE OR REPLACE FUNCTION actors.extract_preferences(
  signal_text TEXT,
  signal_type TEXT DEFAULT 'whatsapp'
)
RETURNS JSONB AS $$
DECLARE
  preferences JSONB := '{}';
  mentions JSONB;
  mention JSONB;
  attributes JSONB;
  preference_name TEXT;
  preference_value FLOAT;
  confidence FLOAT;
BEGIN
  -- Step 1: Detect product mentions using existing product intelligence
  SELECT products.detect_product_mention(signal_text) INTO mentions;
  
  -- Step 2: Process each mention
  FOR mention IN SELECT * FROM jsonb_array_elements(mentions)
  LOOP
    -- Get sauce attributes
    SELECT products.get_sauce_attributes(mention->>'entity_name') INTO attributes;
    
    -- Extract preferences based on sauce attributes
    IF attributes IS NOT NULL THEN
      -- Sweet preference
      IF (attributes->>'sweetness')::FLOAT >= 7 THEN
        preference_name := 'sweet_preference';
        preference_value := (attributes->>'sweetness')::FLOAT / 10.0;
        confidence := (mention->>'confidence')::FLOAT * 0.8;
        
        preferences := jsonb_set(preferences, 
          ARRAY[preference_name], 
          jsonb_build_object(
            'value', preference_value,
            'confidence', confidence,
            'evidence', 'Mentioned ' || (mention->>'entity_name') || ' (sweetness: ' || (attributes->>'sweetness') || ')',
            'evidence_count', 1
          )
        );
      END IF;
      
      -- Spice tolerance
      IF (attributes->>'spice_level')::INTEGER >= 3 THEN
        preference_name := 'spice_tolerance';
        preference_value := (attributes->>'spice_level')::FLOAT / 10.0;
        confidence := (mention->>'confidence')::FLOAT * 0.8;
        
        preferences := jsonb_set(preferences, 
          ARRAY[preference_name], 
          jsonb_build_object(
            'value', preference_value,
            'confidence', confidence,
            'evidence', 'Mentioned ' || (mention->>'entity_name') || ' (spice: ' || (attributes->>'spice_level') || ')',
            'evidence_count', 1
          )
        );
      END IF;
      
      -- Flavor preferences
      IF (attributes->>'smokiness')::FLOAT >= 5 THEN
        preference_name := 'smoky_preference';
        preference_value := (attributes->>'smokiness')::FLOAT / 10.0;
        confidence := (mention->>'confidence')::FLOAT * 0.7;
        
        preferences := jsonb_set(preferences, 
          ARRAY[preference_name], 
          jsonb_build_object(
            'value', preference_value,
            'confidence', confidence,
            'evidence', 'Mentioned ' || (mention->>'entity_name') || ' (smokiness: ' || (attributes->>'smokiness') || ')',
            'evidence_count', 1
          )
        );
      END IF;
      
      IF (attributes->>'tanginess')::FLOAT >= 5 THEN
        preference_name := 'tangy_preference';
        preference_value := (attributes->>'tanginess')::FLOAT / 10.0;
        confidence := (mention->>'confidence')::FLOAT * 0.7;
        
        preferences := jsonb_set(preferences, 
          ARRAY[preference_name], 
          jsonb_build_object(
            'value', preference_value,
            'confidence', confidence,
            'evidence', 'Mentioned ' || (mention->>'entity_name') || ' (tanginess: ' || (attributes->>'tanginess') || ')',
            'evidence_count', 1
          )
        );
      END IF;
    END IF;
  END LOOP;
  
  -- Step 3: Extract behavioral preferences from signal content
  -- Quality sensitivity
  IF signal_text ILIKE '%quality%' OR signal_text ILIKE '%good%' OR signal_text ILIKE '%bad%' THEN
    preferences := jsonb_set(preferences, 
      ARRAY['quality_sensitivity'], 
      jsonb_build_object(
        'value', 0.8,
        'confidence', 0.6,
        'evidence', 'Mentioned quality in signal',
        'evidence_count', 1
      )
    );
  END IF;
  
  -- Price sensitivity
  IF signal_text ILIKE '%price%' OR signal_text ILIKE '%expensive%' OR signal_text ILIKE '%cheap%' THEN
    preferences := jsonb_set(preferences, 
      ARRAY['price_sensitivity'], 
      jsonb_build_object(
        'value', 0.7,
        'confidence', 0.6,
        'evidence', 'Mentioned price in signal',
        'evidence_count', 1
      )
    );
  END IF;
  
  -- Speed sensitivity
  IF signal_text ILIKE '%fast%' OR signal_text ILIKE '%slow%' OR signal_text ILIKE '%quick%' THEN
    preferences := jsonb_set(preferences, 
      ARRAY['speed_sensitivity'], 
      jsonb_build_object(
        'value', 0.7,
        'confidence', 0.6,
        'evidence', 'Mentioned speed in signal',
        'evidence_count', 1
      )
    );
  END IF;
  
  RETURN preferences;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SYSTEM 2: DRIVER DECODER (7-Column Analysis)
-- =====================================================

-- Function to decode drivers from signal text
DROP FUNCTION IF EXISTS actors.decode_drivers(TEXT, UUID);
CREATE OR REPLACE FUNCTION actors.decode_drivers(
  signal_text TEXT,
  actor_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
  driver_weights JSONB := '{}';
  total_weight FLOAT := 0;
  dominant_driver TEXT;
  belief_inferred TEXT;
  confidence_score FLOAT;
  friction TEXT;
  actionable_insight TEXT;
  driver_signatures JSONB;
  driver TEXT;
  pattern TEXT;
  weight FLOAT;
BEGIN
  -- Initialize driver weights
  driver_weights := jsonb_build_object(
    'Buffer', 0,
    'Bond', 0,
    'Badge', 0,
    'Build', 0,
    'Breadth', 0,
    'Meaning', 0
  );
  
  -- Get driver signatures from ontology
  SELECT jsonb_object_agg(driver_name, jsonb_build_object(
    'patterns', language_patterns,
    'behaviors', typical_behaviors,
    'friction', friction_indicators
  )) INTO driver_signatures
  FROM actors.drivers;
  
  -- Calculate weights for each driver
  FOR driver IN SELECT unnest(ARRAY['Buffer', 'Bond', 'Badge', 'Build', 'Breadth', 'Meaning'])
  LOOP
    weight := 0;
    
    -- Check language patterns
    FOR pattern IN SELECT jsonb_array_elements_text(driver_signatures->driver->'patterns')
    LOOP
      IF signal_text ILIKE '%' || pattern || '%' THEN
        weight := weight + 1;
      END IF;
    END LOOP;
    
    -- Check behavioral indicators
    FOR pattern IN SELECT jsonb_array_elements_text(driver_signatures->driver->'behaviors')
    LOOP
      IF signal_text ILIKE '%' || pattern || '%' THEN
        weight := weight + 0.5;
      END IF;
    END LOOP;
    
    driver_weights := jsonb_set(driver_weights, ARRAY[driver], to_jsonb(weight));
    total_weight := total_weight + weight;
  END LOOP;
  
  -- Find dominant driver
  SELECT key INTO dominant_driver
  FROM jsonb_each(driver_weights)
  ORDER BY value::FLOAT DESC
  LIMIT 1;
  
  -- Calculate confidence score
  confidence_score := LEAST((driver_weights->>dominant_driver)::FLOAT / 3.0, 1.0);
  
  -- Infer belief based on dominant driver
  belief_inferred := CASE dominant_driver
    WHEN 'Buffer' THEN 'Seeks predictability and consistency'
    WHEN 'Bond' THEN 'Values connection and belonging'
    WHEN 'Badge' THEN 'Desires recognition and status'
    WHEN 'Build' THEN 'Seeks growth and mastery'
    WHEN 'Breadth' THEN 'Craves variety and novelty'
    WHEN 'Meaning' THEN 'Seeks purpose and significance'
    ELSE 'Unclear motivational pattern'
  END;
  
  -- Detect friction
  friction := '';
  FOR driver IN SELECT unnest(ARRAY['Buffer', 'Bond', 'Badge', 'Build', 'Breadth', 'Meaning'])
  LOOP
    FOR pattern IN SELECT jsonb_array_elements_text(driver_signatures->driver->'friction')
    LOOP
      IF signal_text ILIKE '%' || pattern || '%' THEN
        friction := friction || ' ' || pattern;
      END IF;
    END LOOP;
  END LOOP;
  
  -- Generate actionable insight based on dominant driver
  actionable_insight := CASE dominant_driver
    WHEN 'Buffer' THEN 'Offer consistency guarantees and familiar options'
    WHEN 'Bond' THEN 'Create community connection and personalized recognition'
    WHEN 'Badge' THEN 'Provide exclusive access and status recognition'
    WHEN 'Build' THEN 'Offer progressive challenges and skill development'
    WHEN 'Breadth' THEN 'Introduce new products and variety options'
    WHEN 'Meaning' THEN 'Communicate brand mission and values alignment'
    ELSE 'Gather more signals to understand motivations'
  END;
  
  -- Build result
  result := jsonb_build_object(
    'col1_actor_segment', actor_id::TEXT,
    'col2_observed_behavior', signal_text,
    'col3_belief_inferred', belief_inferred,
    'col4_confidence_score', confidence_score,
    'col5_friction_contradiction', TRIM(friction),
    'col6_core_driver', dominant_driver,
    'col7_actionable_insight', actionable_insight,
    'driver_weights', driver_weights,
    'total_weight', total_weight
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SYSTEM 3: BAYESIAN UPDATE LOGIC
-- =====================================================

-- Function to update actor profile with new evidence
CREATE OR REPLACE FUNCTION actors.update_actor_profile(
  p_actor_id UUID,
  p_preferences JSONB,
  p_drivers JSONB,
  p_signal_id UUID,
  p_signal_type TEXT
)
RETURNS JSONB AS $$
DECLARE
  current_actor RECORD;
  updated_preferences JSONB;
  updated_drivers JSONB;
  entropy_before FLOAT;
  entropy_after FLOAT;
  entropy_reduction FLOAT;
  driver_shift JSONB;
  update_result JSONB;
BEGIN
  -- Get current actor state
  SELECT * INTO current_actor
  FROM actors.actor_profiles
  WHERE actor_id = p_actor_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Actor not found: %', p_actor_id;
  END IF;
  
  -- Calculate entropy before update
  entropy_before := current_actor.entropy;
  
  -- Update preferences (Bayesian merge)
  updated_preferences := current_actor.preferences;
  
  -- For each new preference, merge with existing
  FOR preference_name IN SELECT jsonb_object_keys(p_preferences)
  LOOP
    DECLARE
      new_pref JSONB := p_preferences->preference_name;
      old_pref JSONB := current_actor.preferences->preference_name;
      merged_pref JSONB;
    BEGIN
      IF old_pref IS NULL THEN
        -- New preference
        merged_pref := jsonb_set(new_pref, '{confidence}', 
          to_jsonb((new_pref->>'confidence')::FLOAT * 0.5)
        );
      ELSE
        -- Bayesian update
        DECLARE
          old_weight FLOAT := (old_pref->>'confidence')::FLOAT * (old_pref->>'evidence_count')::FLOAT;
          new_weight FLOAT := (new_pref->>'confidence')::FLOAT;
          total_weight FLOAT := old_weight + new_weight;
          new_value FLOAT;
          new_confidence FLOAT;
          new_evidence_count INTEGER;
        BEGIN
          new_value := ((old_pref->>'value')::FLOAT * old_weight + (new_pref->>'value')::FLOAT * new_weight) / total_weight;
          new_confidence := LEAST(SQRT(POWER((old_pref->>'confidence')::FLOAT, 2) + POWER((new_pref->>'confidence')::FLOAT, 2)), 1.0);
          new_evidence_count := (old_pref->>'evidence_count')::INTEGER + 1;
          
          merged_pref := jsonb_build_object(
            'value', new_value,
            'confidence', new_confidence,
            'evidence_count', new_evidence_count,
            'evidence', (old_pref->>'evidence') || '; ' || (new_pref->>'evidence')
          );
        END;
      END IF;
      
      updated_preferences := jsonb_set(updated_preferences, ARRAY[preference_name], merged_pref);
    END;
  END LOOP;
  
  -- Update driver distribution (Bayesian)
  DECLARE
    old_distribution JSONB := current_actor.driver_distribution;
    new_driver TEXT := p_drivers->>'col6_core_driver';
    new_confidence FLOAT := (p_drivers->>'col4_confidence_score')::FLOAT;
    update_strength FLOAT := new_confidence * 0.1; -- Max 10% shift per signal
    driver TEXT;
    new_prob FLOAT;
    sum_prob FLOAT := 0;
  BEGIN
    updated_drivers := '{}';
    
    -- Calculate new probabilities
    FOR driver IN SELECT unnest(ARRAY['Buffer', 'Bond', 'Badge', 'Build', 'Breadth', 'Meaning'])
    LOOP
      IF driver = new_driver THEN
        new_prob := (old_distribution->>driver)::FLOAT + update_strength;
      ELSE
        new_prob := (old_distribution->>driver)::FLOAT * (1 - update_strength / 5);
      END IF;
      
      updated_drivers := jsonb_set(updated_drivers, ARRAY[driver], to_jsonb(new_prob));
      sum_prob := sum_prob + new_prob;
    END LOOP;
    
    -- Normalize to sum to 1.0
    FOR driver IN SELECT unnest(ARRAY['Buffer', 'Bond', 'Badge', 'Build', 'Breadth', 'Meaning'])
    LOOP
      updated_drivers := jsonb_set(updated_drivers, ARRAY[driver], 
        to_jsonb((updated_drivers->>driver)::FLOAT / sum_prob)
      );
    END LOOP;
  END;
  
  -- Calculate entropy after update
  entropy_after := 0;
  FOR driver IN SELECT unnest(ARRAY['Buffer', 'Bond', 'Badge', 'Build', 'Breadth', 'Meaning'])
  LOOP
    DECLARE
      prob FLOAT := (updated_drivers->>driver)::FLOAT;
    BEGIN
      IF prob > 0 THEN
        entropy_after := entropy_after - (prob * LOG(2, prob));
      END IF;
    END;
  END LOOP;
  
  entropy_reduction := entropy_before - entropy_after;
  
  -- Calculate driver shift
  driver_shift := '{}';
  FOR driver IN SELECT unnest(ARRAY['Buffer', 'Bond', 'Badge', 'Build', 'Breadth', 'Meaning'])
  LOOP
    driver_shift := jsonb_set(driver_shift, ARRAY[driver], 
      to_jsonb((updated_drivers->>driver)::FLOAT - (old_distribution->>driver)::FLOAT)
    );
  END LOOP;
  
  -- Update actor profile
  UPDATE actors.actor_profiles SET
    preferences = updated_preferences,
    driver_distribution = updated_drivers,
    dominant_driver = (
      SELECT key FROM jsonb_each(updated_drivers) 
      ORDER BY value::FLOAT DESC LIMIT 1
    ),
    driver_confidence = new_confidence,
    entropy = entropy_after,
    last_entropy_reduction = entropy_reduction,
    signal_count = signal_count + 1,
    last_updated = NOW()
  WHERE actor_id = p_actor_id;
  
  -- Log the update
  INSERT INTO actors.actor_updates (
    actor_id, signal_id, signal_type, update_type,
    preferences_before, preferences_after,
    drivers_before, drivers_after, driver_shift,
    entropy_before, entropy_after, entropy_reduction,
    reasoning, evidence
  ) VALUES (
    p_actor_id, p_signal_id, p_signal_type, 'dual_layer_update',
    current_actor.preferences, updated_preferences,
    old_distribution, updated_drivers, driver_shift,
    entropy_before, entropy_after, entropy_reduction,
    'Updated from signal: ' || (p_drivers->>'col3_belief_inferred'),
    ARRAY[p_preferences::TEXT, p_drivers::TEXT]
  );
  
  -- Return update summary
  update_result := jsonb_build_object(
    'actor_id', p_actor_id,
    'preferences_updated', updated_preferences,
    'drivers_updated', updated_drivers,
    'entropy_reduction', entropy_reduction,
    'driver_shift', driver_shift,
    'update_successful', true
  );
  
  RETURN update_result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- MAIN PROCESSING FUNCTION
-- =====================================================

-- Function to process a single signal through dual extraction
CREATE OR REPLACE FUNCTION actors.process_signal(
  p_signal_id UUID,
  p_signal_text TEXT,
  p_signal_type TEXT,
  p_actor_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
  preferences JSONB;
  drivers JSONB;
  update_result JSONB;
  decoder_log_id UUID;
BEGIN
  -- Step 1: Extract preferences
  SELECT actors.extract_preferences(p_signal_text, p_signal_type) INTO preferences;
  
  -- Step 2: Decode drivers
  SELECT actors.decode_drivers(p_signal_text, p_actor_id) INTO drivers;
  
  -- Step 3: Log decoder output
  INSERT INTO actors.decoder_log (
    actor_id, signal_id,
    col1_actor_segment, col2_observed_behavior, col3_belief_inferred,
    col4_confidence_score, col5_friction_contradiction, col6_core_driver,
    col7_actionable_insight, decoder_output
  ) VALUES (
    p_actor_id, p_signal_id,
    drivers->>'col1_actor_segment', drivers->>'col2_observed_behavior', drivers->>'col3_belief_inferred',
    (drivers->>'col4_confidence_score')::FLOAT, drivers->>'col5_friction_contradiction', drivers->>'col6_core_driver',
    drivers->>'col7_actionable_insight', jsonb_build_object('preferences', preferences, 'drivers', drivers)
  ) RETURNING log_id INTO decoder_log_id;
  
  -- Step 4: Update actor profile (if actor_id provided)
  IF p_actor_id IS NOT NULL THEN
    SELECT actors.update_actor_profile(p_actor_id, preferences, drivers, p_signal_id, p_signal_type) INTO update_result;
  ELSE
    update_result := jsonb_build_object('actor_id', NULL, 'update_skipped', true);
  END IF;
  
  -- Step 5: Return complete result
  result := jsonb_build_object(
    'signal_id', p_signal_id,
    'actor_id', p_actor_id,
    'preferences', preferences,
    'drivers', drivers,
    'update_result', update_result,
    'decoder_log_id', decoder_log_id,
    'processing_successful', true
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Test preference extraction
SELECT actors.extract_preferences('I love the honey sesame wings, they are so sweet and perfect!', 'whatsapp');

-- Test driver decoding
SELECT actors.decode_drivers('I always get the same thing, I know what I like and it never disappoints', '123e4567-e89b-12d3-a456-426614174000'::UUID);

-- Test complete signal processing
SELECT actors.process_signal(
  '123e4567-e89b-12d3-a456-426614174000'::UUID,
  'I love trying new flavors, what do you recommend?',
  'whatsapp',
  '123e4567-e89b-12d3-a456-426614174000'::UUID
);
