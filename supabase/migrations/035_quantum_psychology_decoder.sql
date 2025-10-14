-- =====================================================
-- QUANTUM PSYCHOLOGY DECODER - 7-COLUMN OUTPUT
-- Phase 5: Complete decoder for driver-first analysis
-- =====================================================

-- =====================================================
-- MAIN QUANTUM PSYCHOLOGY DECODER FUNCTION
-- =====================================================

DROP FUNCTION IF EXISTS actors.decode_signal_quantum(TEXT, TEXT, JSONB, UUID);
CREATE OR REPLACE FUNCTION actors.decode_signal_quantum(
  p_signal_text TEXT,
  p_signal_type TEXT DEFAULT 'whatsapp',
  p_signal_context JSONB DEFAULT '{}',
  p_actor_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  -- Driver inference variables
  driver_weights JSONB := '{"Safety": 0, "Connection": 0, "Status": 0, "Growth": 0, "Freedom": 0, "Purpose": 0}';
  driver_signatures JSONB;
  driver TEXT;
  pattern TEXT;
  weight FLOAT;
  total_weight FLOAT := 0;
  normalized_distribution JSONB;
  dominant_driver TEXT;
  secondary_driver TEXT;
  driver_confidence FLOAT;
  
  -- Identity inference variables
  identity_signals JSONB := '[]';
  identity_fragment JSONB;
  role_indicators JSONB;
  archetype_signals JSONB;
  
  -- Quantum effects variables
  superposition JSONB;
  entanglement JSONB;
  coherence JSONB;
  quantum_effects JSONB;
  
  -- Contradiction detection variables
  contradiction_analysis JSONB;
  driver_conflicts JSONB;
  identity_fragmentation JSONB;
  
  -- 7-Column output variables
  col1_actor_segment JSONB;
  col2_observed_behavior JSONB;
  col3_belief_inferred JSONB;
  col4_confidence_score JSONB;
  col5_friction_contradiction JSONB;
  col6_core_driver JSONB;
  col7_actionable_insight JSONB;
  
  -- Final result
  result JSONB;
BEGIN
  -- =====================================================
  -- STEP 1: DRIVER INFERENCE (DEEP PSYCHOLOGY)
  -- =====================================================
  
  -- Get driver signatures from ontology
  SELECT jsonb_object_agg(driver_name, jsonb_build_object(
    'patterns', language_patterns,
    'behaviors', typical_behaviors,
    'friction', friction_indicators
  )) INTO driver_signatures
  FROM actors.drivers;
  
  -- Calculate weights for each driver
  FOR driver IN SELECT unnest(ARRAY['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose'])
  LOOP
    weight := 0;
    
    -- Check language patterns (higher weight)
    FOR pattern IN SELECT jsonb_array_elements_text(driver_signatures->driver->'patterns')
    LOOP
      IF p_signal_text ILIKE '%' || pattern || '%' THEN
        weight := weight + 1.0;
      END IF;
    END LOOP;
    
    -- Check behavioral indicators (medium weight)
    FOR pattern IN SELECT jsonb_array_elements_text(driver_signatures->driver->'behaviors')
    LOOP
      IF p_signal_text ILIKE '%' || pattern || '%' THEN
        weight := weight + 0.7;
      END IF;
    END LOOP;
    
    -- Check friction indicators (lower weight, but important)
    FOR pattern IN SELECT jsonb_array_elements_text(driver_signatures->driver->'friction')
    LOOP
      IF p_signal_text ILIKE '%' || pattern || '%' THEN
        weight := weight + 0.3;
      END IF;
    END LOOP;
    
    driver_weights := jsonb_set(driver_weights, ARRAY[driver], to_jsonb(weight));
    total_weight := total_weight + weight;
  END LOOP;
  
  -- Normalize to probability distribution
  normalized_distribution := '{}';
  FOR driver IN SELECT key FROM jsonb_each(driver_weights)
  LOOP
    weight := (driver_weights->>driver)::FLOAT;
    IF total_weight > 0 THEN
      normalized_distribution := jsonb_set(
        normalized_distribution, 
        ARRAY[driver], 
        to_jsonb(weight / total_weight)
      );
    ELSE
      normalized_distribution := jsonb_set(
        normalized_distribution, 
        ARRAY[driver], 
        to_jsonb(1.0 / 6.0) -- Equal distribution if no signals
      );
    END IF;
  END LOOP;
  
  -- Find dominant and secondary drivers
  SELECT key INTO dominant_driver
  FROM jsonb_each(normalized_distribution)
  ORDER BY value::FLOAT DESC
  LIMIT 1;
  
  SELECT key INTO secondary_driver
  FROM jsonb_each(normalized_distribution)
  ORDER BY value::FLOAT DESC
  LIMIT 1 OFFSET 1;
  
  driver_confidence := LEAST((normalized_distribution->>dominant_driver)::FLOAT * 2.0, 1.0);
  
  -- =====================================================
  -- STEP 2: IDENTITY INFERENCE (WHO THEY SEE THEMSELVES AS)
  -- =====================================================
  
  -- Detect role-based identities
  role_indicators := jsonb_build_object(
    'protector', CASE 
      WHEN p_signal_text ILIKE '%family%' OR p_signal_text ILIKE '%for everyone%' OR p_signal_text ILIKE '%take care%' 
      THEN 0.8 ELSE 0.0 END,
    'provider', CASE 
      WHEN p_signal_text ILIKE '%order%' OR p_signal_text ILIKE '%get%' OR p_signal_text ILIKE '%bring%' 
      THEN 0.6 ELSE 0.0 END,
    'explorer', CASE 
      WHEN p_signal_text ILIKE '%try%' OR p_signal_text ILIKE '%new%' OR p_signal_text ILIKE '%different%' 
      THEN 0.7 ELSE 0.0 END,
    'connoisseur', CASE 
      WHEN p_signal_text ILIKE '%sophisticated%' OR p_signal_text ILIKE '%quality%' OR p_signal_text ILIKE '%expert%' 
      THEN 0.8 ELSE 0.0 END,
    'rebel', CASE 
      WHEN p_signal_text ILIKE '%against%' OR p_signal_text ILIKE '%different from%' OR p_signal_text ILIKE '%unique%' 
      THEN 0.6 ELSE 0.0 END,
    'connector', CASE 
      WHEN p_signal_text ILIKE '%together%' OR p_signal_text ILIKE '%share%' OR p_signal_text ILIKE '%community%' 
      THEN 0.7 ELSE 0.0 END
  );
  
  -- Build identity fragments
  FOR driver IN SELECT key FROM jsonb_each(role_indicators)
  LOOP
    IF (role_indicators->>driver)::FLOAT > 0.5 THEN
      identity_fragment := jsonb_build_object(
        'label', driver,
        'archetype', CASE driver
          WHEN 'protector' THEN 'caregiver'
          WHEN 'provider' THEN 'nurturer'
          WHEN 'explorer' THEN 'seeker'
          WHEN 'connoisseur' THEN 'expert'
          WHEN 'rebel' THEN 'individualist'
          WHEN 'connector' THEN 'socializer'
          ELSE 'unknown'
        END,
        'confidence', (role_indicators->>driver)::FLOAT,
        'behavioral_evidence', ARRAY[p_signal_text],
        'driver_alignment', jsonb_build_object(
          'Safety', CASE WHEN driver = 'protector' THEN 0.8 ELSE 0.2 END,
          'Connection', CASE WHEN driver = 'connector' THEN 0.9 ELSE 0.3 END,
          'Status', CASE WHEN driver = 'connoisseur' THEN 0.8 ELSE 0.2 END,
          'Growth', CASE WHEN driver = 'explorer' THEN 0.8 ELSE 0.3 END,
          'Freedom', CASE WHEN driver = 'rebel' THEN 0.9 ELSE 0.2 END,
          'Purpose', CASE WHEN driver = 'provider' THEN 0.7 ELSE 0.2 END
        )
      );
      identity_signals := identity_signals || identity_fragment;
    END IF;
  END LOOP;
  
  -- =====================================================
  -- STEP 3: QUANTUM EFFECTS DETECTION
  -- =====================================================
  
  -- Detect superposition
  SELECT actors.detect_superposition(normalized_distribution, p_signal_context) INTO superposition;
  
  -- Calculate entanglement
  entanglement := jsonb_build_object(
    'driver_pairs', '[]'::jsonb,
    'overall_entanglement', 0.0
  );
  
  -- Calculate coherence
  SELECT actors.calculate_coherence(normalized_distribution, '{}'::jsonb, '[]'::jsonb) INTO coherence;
  
  quantum_effects := jsonb_build_object(
    'superposition', superposition,
    'entanglement', entanglement,
    'coherence', coherence,
    'quantum_signature', jsonb_build_object(
      'is_quantum', (superposition->>'superposition_detected')::BOOLEAN,
      'coherence_level', (coherence->>'coherence')::FLOAT,
      'measurement_effect', (coherence->>'measurement_collapse')::TEXT
    )
  );
  
  -- =====================================================
  -- STEP 4: CONTRADICTION DETECTION
  -- =====================================================
  
  -- Detect driver conflicts
  SELECT actors.detect_driver_conflicts(normalized_distribution, p_signal_context) INTO driver_conflicts;
  
  -- Detect identity fragmentation
  SELECT actors.detect_identity_fragmentation(identity_signals) INTO identity_fragmentation;
  
  contradiction_analysis := jsonb_build_object(
    'driver_conflicts', driver_conflicts,
    'identity_fragmentation', identity_fragmentation,
    'overall_contradiction', (driver_conflicts->>'contradictions_detected')::BOOLEAN
  );
  
  -- =====================================================
  -- STEP 5: BUILD 7-COLUMN OUTPUT
  -- =====================================================
  
  -- Column 1: Actor/Segment
  col1_actor_segment := jsonb_build_object(
    'current_identity', (
      SELECT ARRAY_AGG(value->>'label') 
      FROM jsonb_array_elements(identity_signals) 
      WHERE (value->>'confidence')::FLOAT > 0.5
    ),
    'dominant_driver', dominant_driver,
    'driver_confidence', driver_confidence,
    'quantum_state', CASE 
      WHEN (superposition->>'superposition_detected')::BOOLEAN THEN 'superposition'
      ELSE 'collapsed'
    END
  );
  
  -- Column 2: Observed Behavior
  col2_observed_behavior := jsonb_build_object(
    'action', 'Analyzed signal for psychological patterns',
    'verbatim_quote', p_signal_text,
    'context', p_signal_context,
    'emotional_tone', CASE
      WHEN p_signal_text ILIKE '%love%' OR p_signal_text ILIKE '%amazing%' THEN 'enthusiastic'
      WHEN p_signal_text ILIKE '%hate%' OR p_signal_text ILIKE '%terrible%' THEN 'negative'
      WHEN p_signal_text ILIKE '%okay%' OR p_signal_text ILIKE '%fine%' THEN 'neutral'
      ELSE 'mixed'
    END,
    'behavioral_indicators', (
      SELECT ARRAY_AGG(pattern) 
      FROM unnest(ARRAY['sharing', 'seeking', 'exploring', 'displaying', 'learning', 'valuing']) AS pattern
      WHERE p_signal_text ILIKE '%' || pattern || '%'
    )
  );
  
  -- Column 3: Belief Inferred (Driver updates and quantum effects)
  col3_belief_inferred := jsonb_build_object(
    'driver_update', jsonb_build_object(
      dominant_driver, jsonb_build_object(
        'delta', (normalized_distribution->>dominant_driver)::FLOAT,
        'reasoning', 'Signal analysis revealed ' || dominant_driver || ' driver activation',
        'contextual_activation', true,
        'activation_trigger', p_signal_context->>'context'
      )
    ),
    'quantum_effects', jsonb_build_object(
      'superposition_collapse', CASE 
        WHEN (superposition->>'superposition_detected')::BOOLEAN THEN 'partial'
        ELSE 'full'
      END,
      'collapsed_to', dominant_driver,
      'collapse_trigger', p_signal_context->>'context',
      'residual_superposition', CASE 
        WHEN (superposition->>'superposition_detected')::BOOLEAN THEN ARRAY[secondary_driver]
        ELSE '[]'::TEXT[]
      END
    ),
    'identity_update', jsonb_build_object(
      'reinforced', (
        SELECT ARRAY_AGG(value->>'label') 
        FROM jsonb_array_elements(identity_signals) 
        WHERE (value->>'confidence')::FLOAT > 0.6
      ),
      'weakened', '[]'::TEXT[],
      'new_fragment_detected', jsonb_array_length(identity_signals) > 0
    )
  );
  
  -- Column 4: Confidence Score
  col4_confidence_score := jsonb_build_object(
    'overall', driver_confidence,
    'factors', jsonb_build_object(
      'signal_strength', LEAST(total_weight / 5.0, 1.0),
      'prior_evidence', CASE WHEN p_actor_id IS NOT NULL THEN 0.7 ELSE 0.3 END,
      'consistency', 0.6,
      'quantum_clarity', (coherence->>'coherence')::FLOAT
    ),
    'uncertainty_sources', CASE 
      WHEN total_weight < 2.0 THEN ARRAY['weak_signal', 'ambiguous_language']
      WHEN (superposition->>'superposition_detected')::BOOLEAN THEN ARRAY['quantum_superposition']
      ELSE ARRAY['moderate_confidence']
    END
  );
  
  -- Column 5: Friction/Contradiction
  col5_friction_contradiction := jsonb_build_object(
    'detected', (driver_conflicts->>'contradictions_detected')::BOOLEAN,
    'type', CASE 
      WHEN (driver_conflicts->>'contradictions_detected')::BOOLEAN THEN 'driver_conflict'
      WHEN (identity_fragmentation->>'fragmentation_detected')::BOOLEAN THEN 'identity_fragmentation'
      ELSE 'none'
    END,
    'drivers_in_tension', driver_conflicts->'conflicts'->0->'drivers_in_tension',
    'conflict_strength', driver_conflicts->'conflicts'->0->>'tension_strength',
    'tension', CASE 
      WHEN (driver_conflicts->>'contradictions_detected')::BOOLEAN THEN
        'Driver conflict detected: ' || (driver_conflicts->'conflicts'->0->>'manifestation')
      ELSE 'No significant contradictions detected'
    END,
    'entanglement', jsonb_build_object(
      'correlation', -0.5, -- Placeholder
      'measurement_effect', 'Observation affects driver probabilities'
    ),
    'quantum_signature', jsonb_build_object(
      'superposition_active', (superposition->>'superposition_detected')::BOOLEAN,
      'interference_pattern', (superposition->>'interference_pattern')::FLOAT,
      'coherence_level', (coherence->>'coherence')::FLOAT
    )
  );
  
  -- Column 6: Core Driver
  col6_core_driver := jsonb_build_object(
    'primary', dominant_driver,
    'probability', (normalized_distribution->>dominant_driver)::FLOAT,
    'reasoning', 'Signal analysis revealed strong ' || dominant_driver || ' driver activation through language patterns and behavioral indicators',
    'secondary', secondary_driver,
    'secondary_probability', (normalized_distribution->>secondary_driver)::FLOAT,
    'secondary_reasoning', 'Secondary ' || secondary_driver || ' driver detected with moderate activation',
    'quantum_effects', jsonb_build_object(
      'superposition', (superposition->>'superposition_detected')::BOOLEAN,
      'entanglement_strength', 0.0, -- Placeholder
      'coherence', (coherence->>'coherence')::FLOAT
    )
  );
  
  -- Column 7: Actionable Insight
  col7_actionable_insight := jsonb_build_object(
    'strategy', CASE 
      WHEN (superposition->>'superposition_detected')::BOOLEAN THEN 'Collapse strategy for quantum superposition'
      WHEN (driver_conflicts->>'contradictions_detected')::BOOLEAN THEN 'Resolution strategy for driver conflicts'
      ELSE 'Reinforcement strategy for dominant driver'
    END,
    'recommendation', CASE dominant_driver
      WHEN 'Safety' THEN 'Position offerings as reliable and consistent choices'
      WHEN 'Connection' THEN 'Emphasize shared experiences and community'
      WHEN 'Status' THEN 'Highlight premium positioning and exclusivity'
      WHEN 'Growth' THEN 'Offer challenging and skill-building options'
      WHEN 'Freedom' THEN 'Provide variety and exploration opportunities'
      WHEN 'Purpose' THEN 'Align with values and meaningful impact'
      ELSE 'General engagement strategy'
    END,
    'next_signal_needed', 'Track behavioral patterns to confirm driver stability',
    'confidence_threshold', 'Need 2-3 more signals to confirm driver dominance',
    'quantum_considerations', jsonb_build_object(
      'honor_superposition', (superposition->>'superposition_detected')::BOOLEAN,
      'measurement_awareness', 'Observation may change actor state',
      'coherence_management', 'Maintain psychological coherence in messaging'
    ),
    'collapse_strategies', CASE 
      WHEN (superposition->>'superposition_detected')::BOOLEAN THEN ARRAY['contextual_positioning', 'dual_identity_messaging']
      ELSE ARRAY['single_driver_focus']
    END
  );
  
  -- =====================================================
  -- STEP 6: BUILD COMPLETE RESULT
  -- =====================================================
  
  result := jsonb_build_object(
    'signal_analysis', jsonb_build_object(
      'driver_inference', normalized_distribution,
      'identity_inference', identity_signals,
      'quantum_effects', quantum_effects,
      'contradiction_analysis', contradiction_analysis,
      'signal_confidence', driver_confidence
    ),
    'seven_column_output', jsonb_build_object(
      'col1_actor_segment', col1_actor_segment,
      'col2_observed_behavior', col2_observed_behavior,
      'col3_belief_inferred', col3_belief_inferred,
      'col4_confidence_score', col4_confidence_score,
      'col5_friction_contradiction', col5_friction_contradiction,
      'col6_core_driver', col6_core_driver,
      'col7_actionable_insight', col7_actionable_insight
    ),
    'processing_metadata', jsonb_build_object(
      'signal_type', p_signal_type,
      'signal_context', p_signal_context,
      'actor_id', p_actor_id,
      'processing_timestamp', NOW(),
      'quantum_psychology_version', '1.0'
    )
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SIMPLIFIED DECODER FOR TESTING
-- =====================================================

DROP FUNCTION IF EXISTS actors.decode_signal_simple(TEXT, TEXT);
CREATE OR REPLACE FUNCTION actors.decode_signal_simple(
  p_signal_text TEXT,
  p_signal_type TEXT DEFAULT 'whatsapp'
)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  -- Use the full quantum decoder with minimal context
  SELECT actors.decode_signal_quantum(
    p_signal_text,
    p_signal_type,
    '{"context": "general", "audience": "unknown"}'::jsonb,
    NULL
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Test the quantum psychology decoder
SELECT jsonb_pretty(
  actors.decode_signal_simple(
    'I love the premium wings, they are so exclusive and everyone is talking about them!',
    'whatsapp'
  )
);

-- Test with different signal types
SELECT jsonb_pretty(
  actors.decode_signal_simple(
    'I always get the same thing, I know what I like and it never disappoints',
    'whatsapp'
  )
);

-- Test with family/social context
SELECT jsonb_pretty(
  actors.decode_signal_simple(
    'Perfect for sharing with the family, brings us all together!',
    'whatsapp'
  )
);

-- Test with growth/learning signals
SELECT jsonb_pretty(
  actors.decode_signal_simple(
    'I am trying to build my tolerance for spicy food, getting better at it!',
    'whatsapp'
  )
);
