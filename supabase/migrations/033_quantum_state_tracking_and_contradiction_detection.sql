-- =====================================================
-- QUANTUM STATE TRACKING & CONTRADICTION DETECTION
-- Phase 3: Implement quantum psychology functions
-- =====================================================

-- =====================================================
-- QUANTUM STATE TRACKING FUNCTIONS
-- =====================================================

-- Function to detect quantum superposition states
CREATE OR REPLACE FUNCTION actors.detect_superposition(
  driver_distribution JSONB,
  context JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  driver TEXT;
  probability FLOAT;
  max_prob FLOAT := 0;
  second_max FLOAT := 0;
  primary_driver TEXT;
  secondary_driver TEXT;
  interference_strength FLOAT;
  superposition_detected BOOLEAN := false;
  result JSONB;
BEGIN
  -- Find primary and secondary drivers
  FOR driver IN SELECT key FROM jsonb_each(driver_distribution)
  LOOP
    probability := (driver_distribution->>driver)::FLOAT;
    
    IF probability > max_prob THEN
      second_max := max_prob;
      max_prob := probability;
      secondary_driver := primary_driver;
      primary_driver := driver;
    ELSIF probability > second_max THEN
      second_max := probability;
      secondary_driver := driver;
    END IF;
  END LOOP;
  
  -- Detect superposition if two drivers are close in probability
  interference_strength := ABS(max_prob - second_max);
  
  IF interference_strength < 0.15 AND max_prob > 0.25 AND second_max > 0.25 THEN
    superposition_detected := true;
  END IF;
  
  result := jsonb_build_object(
    'superposition_detected', superposition_detected,
    'primary_state', primary_driver,
    'secondary_state', secondary_driver,
    'interference_pattern', interference_strength,
    'collapse_probability', CASE 
      WHEN superposition_detected THEN 1.0 - interference_strength
      ELSE 1.0
    END,
    'contextual_factors', context
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate driver entanglement
CREATE OR REPLACE FUNCTION actors.calculate_entanglement(
  driver_a TEXT,
  driver_b TEXT,
  behavioral_evidence JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  conflict_data JSONB;
  correlation FLOAT;
  entanglement_strength FLOAT;
  measurement_effect FLOAT;
  result JSONB;
BEGIN
  -- Get conflict data from driver ontology
  SELECT driver_dynamics->'conflicts_with' INTO conflict_data
  FROM actors.drivers
  WHERE driver_name = driver_a;
  
  -- Find specific conflict with driver_b
  SELECT jsonb_path_query_first(
    conflict_data,
    '$[*] ? (@.driver == $driver_b)',
    jsonb_build_object('driver_b', driver_b)
  ) INTO conflict_data;
  
  IF conflict_data IS NOT NULL THEN
    correlation := -(conflict_data->>'conflict_strength')::FLOAT;
    entanglement_strength := (conflict_data->>'conflict_strength')::FLOAT;
  ELSE
    -- Check if they reinforce each other
    SELECT driver_dynamics->'reinforces_with' INTO conflict_data
    FROM actors.drivers
    WHERE driver_name = driver_a;
    
    SELECT jsonb_path_query_first(
      conflict_data,
      '$[*] ? (@.driver == $driver_b)',
      jsonb_build_object('driver_b', driver_b)
    ) INTO conflict_data;
    
    IF conflict_data IS NOT NULL THEN
      correlation := (conflict_data->>'reinforcement_strength')::FLOAT;
      entanglement_strength := (conflict_data->>'reinforcement_strength')::FLOAT;
    ELSE
      correlation := 0.0;
      entanglement_strength := 0.0;
    END IF;
  END IF;
  
  -- Calculate measurement effect (how observation affects the system)
  measurement_effect := entanglement_strength * 0.8; -- Observation amplifies entanglement
  
  result := jsonb_build_object(
    'driver_a', driver_a,
    'driver_b', driver_b,
    'correlation', correlation,
    'entanglement_strength', entanglement_strength,
    'measurement_effect', measurement_effect,
    'complementarity', ABS(correlation) > 0.7, -- High correlation = complementarity
    'behavioral_evidence', behavioral_evidence
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate wave function coherence
CREATE OR REPLACE FUNCTION actors.calculate_coherence(
  driver_distribution JSONB,
  quantum_states JSONB DEFAULT '{}',
  signal_history JSONB DEFAULT '[]'
)
RETURNS JSONB AS $$
DECLARE
  entropy FLOAT;
  max_entropy FLOAT := 2.58; -- Maximum entropy for 6 drivers
  coherence FLOAT;
  decoherence_rate FLOAT;
  measurement_collapse TEXT;
  result JSONB;
BEGIN
  -- Calculate current entropy
  SELECT actors.calculate_entropy(driver_distribution) INTO entropy;
  
  -- Coherence is inverse of entropy (normalized)
  coherence := 1.0 - (entropy / max_entropy);
  
  -- Decoherence rate based on signal frequency and consistency
  decoherence_rate := CASE 
    WHEN jsonb_array_length(signal_history) = 0 THEN 0.0
    WHEN jsonb_array_length(signal_history) < 5 THEN 0.1
    WHEN jsonb_array_length(signal_history) < 20 THEN 0.05
    ELSE 0.02
  END;
  
  -- Determine measurement collapse type
  measurement_collapse := CASE
    WHEN coherence > 0.8 THEN 'full'
    WHEN coherence > 0.5 THEN 'partial'
    ELSE 'none'
  END;
  
  result := jsonb_build_object(
    'coherence', coherence,
    'decoherence_rate', decoherence_rate,
    'measurement_collapse', measurement_collapse,
    'entropy', entropy,
    'stability', coherence > 0.6
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- CONTRADICTION DETECTION FUNCTIONS
-- =====================================================

-- Function to detect driver-level contradictions
CREATE OR REPLACE FUNCTION actors.detect_driver_conflicts(
  driver_distribution JSONB,
  signal_context JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  driver TEXT;
  probability FLOAT;
  conflicts JSONB := '[]';
  conflict JSONB;
  driver_a TEXT;
  driver_b TEXT;
  conflict_strength FLOAT;
  tension_manifestation TEXT;
  result JSONB;
BEGIN
  -- Check all driver pairs for conflicts
  FOR driver_a IN SELECT key FROM jsonb_each(driver_distribution)
  LOOP
    FOR driver_b IN SELECT key FROM jsonb_each(driver_distribution)
    LOOP
      IF driver_a != driver_b THEN
        -- Get conflict strength from driver ontology
        SELECT 
          (d.driver_dynamics->'conflicts_with'->0->>'conflict_strength')::FLOAT,
          d.driver_dynamics->'conflicts_with'->0->>'tension_manifestation'
        INTO conflict_strength, tension_manifestation
        FROM actors.drivers d
        WHERE d.driver_name = driver_a
          AND EXISTS (
            SELECT 1 FROM jsonb_array_elements(d.driver_dynamics->'conflicts_with') 
            WHERE value->>'driver' = driver_b
          );
        
        -- If both drivers are active and in conflict
        IF conflict_strength > 0.5 
           AND (driver_distribution->>driver_a)::FLOAT > 0.3 
           AND (driver_distribution->>driver_b)::FLOAT > 0.3 THEN
          
          conflict := jsonb_build_object(
            'type', 'driver_conflict',
            'drivers_in_tension', ARRAY[driver_a, driver_b],
            'tension_strength', conflict_strength,
            'manifestation', tension_manifestation,
            'driver_a_probability', (driver_distribution->>driver_a)::FLOAT,
            'driver_b_probability', (driver_distribution->>driver_b)::FLOAT,
            'context', signal_context
          );
          
          conflicts := conflicts || conflict;
        END IF;
      END IF;
    END LOOP;
  END LOOP;
  
  result := jsonb_build_object(
    'contradictions_detected', jsonb_array_length(conflicts) > 0,
    'conflict_count', jsonb_array_length(conflicts),
    'conflicts', conflicts,
    'overall_tension', CASE 
      WHEN jsonb_array_length(conflicts) = 0 THEN 0.0
      ELSE (
        SELECT AVG((value->>'tension_strength')::FLOAT)
        FROM jsonb_array_elements(conflicts)
      )
    END
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to detect identity fragmentation
CREATE OR REPLACE FUNCTION actors.detect_identity_fragmentation(
  identity_markers JSONB,
  behavioral_evidence JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  fragment JSONB;
  fragments JSONB := '[]';
  fragment_count INTEGER;
  coherence_scores FLOAT[];
  overall_coherence FLOAT;
  fragmentation_detected BOOLEAN := false;
  result JSONB;
BEGIN
  -- Count identity fragments
  fragment_count := jsonb_array_length(identity_markers);
  
  -- Calculate coherence between fragments
  FOR fragment IN SELECT * FROM jsonb_array_elements(identity_markers)
  LOOP
    -- Simple coherence based on confidence and evidence count
    coherence_scores := coherence_scores || (
      (fragment->>'confidence')::FLOAT * 
      LEAST((fragment->>'reinforcement_count')::INTEGER / 10.0, 1.0)
    );
  END LOOP;
  
  -- Calculate overall coherence
  IF array_length(coherence_scores, 1) > 0 THEN
    overall_coherence := (
      SELECT AVG(score) FROM unnest(coherence_scores) AS score
    );
  ELSE
    overall_coherence := 1.0;
  END IF;
  
  -- Detect fragmentation if multiple fragments with low coherence
  fragmentation_detected := fragment_count > 1 AND overall_coherence < 0.6;
  
  result := jsonb_build_object(
    'fragmentation_detected', fragmentation_detected,
    'fragment_count', fragment_count,
    'overall_coherence', overall_coherence,
    'fragments', identity_markers,
    'integration_status', CASE
      WHEN overall_coherence > 0.8 THEN 'integrated'
      WHEN overall_coherence > 0.6 THEN 'partially_integrated'
      ELSE 'fragmented'
    END
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate overall contradiction complexity
CREATE OR REPLACE FUNCTION actors.calculate_contradiction_complexity(
  driver_distribution JSONB,
  identity_markers JSONB,
  signal_context JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  driver_conflicts JSONB;
  identity_fragmentation JSONB;
  driver_tension FLOAT;
  identity_tension FLOAT;
  overall_complexity FLOAT;
  resolution_capacity FLOAT;
  result JSONB;
BEGIN
  -- Detect driver conflicts
  SELECT actors.detect_driver_conflicts(driver_distribution, signal_context) INTO driver_conflicts;
  
  -- Detect identity fragmentation
  SELECT actors.detect_identity_fragmentation(identity_markers) INTO identity_fragmentation;
  
  -- Calculate tension scores
  driver_tension := COALESCE((driver_conflicts->>'overall_tension')::FLOAT, 0.0);
  identity_tension := 1.0 - COALESCE((identity_fragmentation->>'overall_coherence')::FLOAT, 1.0);
  
  -- Calculate overall complexity (weighted average)
  overall_complexity := (driver_tension * 0.6) + (identity_tension * 0.4);
  
  -- Calculate resolution capacity (inverse of complexity with some baseline)
  resolution_capacity := GREATEST(0.0, 1.0 - overall_complexity + 0.2);
  
  result := jsonb_build_object(
    'driver_tension', driver_tension,
    'identity_tension', identity_tension,
    'overall_complexity', overall_complexity,
    'resolution_capacity', resolution_capacity,
    'driver_conflicts', driver_conflicts,
    'identity_fragmentation', identity_fragmentation,
    'complexity_level', CASE
      WHEN overall_complexity > 0.8 THEN 'high'
      WHEN overall_complexity > 0.5 THEN 'medium'
      ELSE 'low'
    END
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- QUANTUM STATE UPDATE FUNCTIONS
-- =====================================================

-- Function to update quantum states after signal processing
CREATE OR REPLACE FUNCTION actors.update_quantum_states(
  actor_id UUID,
  new_driver_distribution JSONB,
  signal_context JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  current_quantum_states JSONB;
  current_driver_distribution JSONB;
  superposition JSONB;
  entanglement JSONB;
  wave_function JSONB;
  coherence JSONB;
  result JSONB;
BEGIN
  -- Get current quantum states
  SELECT quantum_states, driver_distribution 
  INTO current_quantum_states, current_driver_distribution
  FROM actors.actor_profiles
  WHERE actor_id = actor_id;
  
  -- Detect new superposition
  SELECT actors.detect_superposition(new_driver_distribution, signal_context) INTO superposition;
  
  -- Calculate entanglement patterns
  entanglement := jsonb_build_object(
    'driver_pairs', '[]'::jsonb,
    'overall_entanglement', 0.0
  );
  
  -- Calculate wave function coherence
  SELECT actors.calculate_coherence(
    new_driver_distribution, 
    current_quantum_states,
    signal_context->'signal_history'
  ) INTO coherence;
  
  -- Build wave function
  wave_function := jsonb_build_object(
    'coherence', coherence->>'coherence',
    'decoherence_rate', coherence->>'decoherence_rate',
    'measurement_collapse', coherence->>'measurement_collapse',
    'stability', (coherence->>'stability')::BOOLEAN
  );
  
  -- Build updated quantum states
  result := jsonb_build_object(
    'superposition', superposition,
    'entanglement', entanglement,
    'wave_function', wave_function,
    'last_updated', NOW(),
    'signal_context', signal_context
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Function to calculate entropy (for coherence calculation)
CREATE OR REPLACE FUNCTION actors.calculate_entropy(
  driver_distribution JSONB
)
RETURNS FLOAT AS $$
DECLARE
  driver TEXT;
  probability FLOAT;
  entropy FLOAT := 0.0;
BEGIN
  FOR driver IN SELECT key FROM jsonb_each(driver_distribution)
  LOOP
    probability := (driver_distribution->>driver)::FLOAT;
    IF probability > 0 THEN
      entropy := entropy - (probability * LN(probability));
    END IF;
  END LOOP;
  
  RETURN entropy;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Test superposition detection
SELECT actors.detect_superposition(
  '{"Safety": 0.45, "Status": 0.40, "Connection": 0.10, "Growth": 0.05, "Freedom": 0.00, "Purpose": 0.00}'::jsonb,
  '{"context": "social_setting", "audience": "friends"}'::jsonb
);

-- Test entanglement calculation
SELECT actors.calculate_entanglement('Safety', 'Freedom', '{"behavior": "chose_familiar_but_photographed"}'::jsonb);

-- Test contradiction detection
SELECT actors.detect_driver_conflicts(
  '{"Safety": 0.45, "Status": 0.40, "Connection": 0.10, "Growth": 0.05, "Freedom": 0.00, "Purpose": 0.00}'::jsonb,
  '{"context": "social_setting"}'::jsonb
);

-- Test identity fragmentation
SELECT actors.detect_identity_fragmentation(
  '[
    {"label": "protector", "confidence": 0.82, "reinforcement_count": 23},
    {"label": "aspiring_connoisseur", "confidence": 0.45, "reinforcement_count": 7}
  ]'::jsonb
);

-- Test overall contradiction complexity
SELECT actors.calculate_contradiction_complexity(
  '{"Safety": 0.45, "Status": 0.40, "Connection": 0.10, "Growth": 0.05, "Freedom": 0.00, "Purpose": 0.00}'::jsonb,
  '[
    {"label": "protector", "confidence": 0.82, "reinforcement_count": 23},
    {"label": "aspiring_connoisseur", "confidence": 0.45, "reinforcement_count": 7}
  ]'::jsonb,
  '{"context": "social_setting"}'::jsonb
);
