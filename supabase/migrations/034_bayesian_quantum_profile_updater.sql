-- =====================================================
-- BAYESIAN + QUANTUM PROFILE UPDATE SYSTEM
-- Phase 4: Complete profile update with quantum psychology
-- =====================================================

-- =====================================================
-- BAYESIAN UPDATE FUNCTIONS
-- =====================================================

-- Function to apply Bayesian update to driver distribution
CREATE OR REPLACE FUNCTION actors.apply_bayesian_update(
  prior_distribution JSONB,
  likelihood_distribution JSONB,
  signal_confidence FLOAT DEFAULT 0.5
)
RETURNS JSONB AS $$
DECLARE
  driver TEXT;
  prior_prob FLOAT;
  likelihood_prob FLOAT;
  posterior_prob FLOAT;
  posterior_distribution JSONB := '{}';
  total_posterior FLOAT := 0.0;
  normalization_factor FLOAT;
  result JSONB;
BEGIN
  -- Apply Bayes' theorem: P(Driver|Signal) = P(Signal|Driver) × P(Driver) / P(Signal)
  -- Simplified: posterior = (likelihood * prior) / normalization
  
  -- Calculate unnormalized posteriors
  FOR driver IN SELECT key FROM jsonb_each(prior_distribution)
  LOOP
    prior_prob := (prior_distribution->>driver)::FLOAT;
    likelihood_prob := COALESCE((likelihood_distribution->>driver)::FLOAT, 0.0);
    
    -- Apply confidence weighting
    likelihood_prob := likelihood_prob * signal_confidence;
    
    -- Bayesian update with smoothing
    posterior_prob := (likelihood_prob * prior_prob) + (prior_prob * (1.0 - signal_confidence));
    
    posterior_distribution := jsonb_set(posterior_distribution, ARRAY[driver], to_jsonb(posterior_prob));
    total_posterior := total_posterior + posterior_prob;
  END LOOP;
  
  -- Normalize to ensure probabilities sum to 1
  normalization_factor := 1.0 / total_posterior;
  
  FOR driver IN SELECT key FROM jsonb_each(posterior_distribution)
  LOOP
    posterior_prob := (posterior_distribution->>driver)::FLOAT * normalization_factor;
    posterior_distribution := jsonb_set(posterior_distribution, ARRAY[driver], to_jsonb(posterior_prob));
  END LOOP;
  
  result := jsonb_build_object(
    'posterior_distribution', posterior_distribution,
    'normalization_factor', normalization_factor,
    'total_posterior_before_normalization', total_posterior
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate information gain from update
CREATE OR REPLACE FUNCTION actors.calculate_information_gain(
  prior_distribution JSONB,
  posterior_distribution JSONB
)
RETURNS JSONB AS $$
DECLARE
  prior_entropy FLOAT;
  posterior_entropy FLOAT;
  information_gain FLOAT;
  kl_divergence FLOAT;
  driver TEXT;
  prior_prob FLOAT;
  posterior_prob FLOAT;
  result JSONB;
BEGIN
  -- Calculate entropy before and after
  SELECT actors.calculate_entropy(prior_distribution) INTO prior_entropy;
  SELECT actors.calculate_entropy(posterior_distribution) INTO posterior_entropy;
  
  -- Information gain = reduction in entropy
  information_gain := prior_entropy - posterior_entropy;
  
  -- Calculate KL divergence (Kullback-Leibler divergence)
  kl_divergence := 0.0;
  FOR driver IN SELECT key FROM jsonb_each(prior_distribution)
  LOOP
    prior_prob := (prior_distribution->>driver)::FLOAT;
    posterior_prob := (posterior_distribution->>driver)::FLOAT;
    
    IF prior_prob > 0 AND posterior_prob > 0 THEN
      kl_divergence := kl_divergence + (posterior_prob * LN(posterior_prob / prior_prob));
    END IF;
  END LOOP;
  
  result := jsonb_build_object(
    'prior_entropy', prior_entropy,
    'posterior_entropy', posterior_entropy,
    'information_gain', information_gain,
    'kl_divergence', kl_divergence,
    'learning_rate', information_gain / prior_entropy -- Normalized learning rate
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- IDENTITY FRAGMENT MANAGEMENT
-- =====================================================

-- Function to update identity fragments based on signal
CREATE OR REPLACE FUNCTION actors.update_identity_fragments(
  current_fragments JSONB,
  signal_analysis JSONB,
  signal_context JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  fragment JSONB;
  updated_fragments JSONB := current_fragments;
  new_fragments JSONB := '[]';
  reinforced_fragments JSONB := '[]';
  weakened_fragments JSONB := '[]';
  identity_signals JSONB;
  fragment_label TEXT;
  confidence_change FLOAT;
  result JSONB;
BEGIN
  -- Extract identity signals from analysis
  identity_signals := COALESCE(signal_analysis->'identity_signals', '[]'::jsonb);
  
  -- Process each identity signal
  FOR fragment IN SELECT * FROM jsonb_array_elements(identity_signals)
  LOOP
    fragment_label := fragment->>'label';
    
    -- Check if fragment already exists
    IF EXISTS (
      SELECT 1 FROM jsonb_array_elements(current_fragments) 
      WHERE value->>'label' = fragment_label
    ) THEN
      -- Update existing fragment
      SELECT jsonb_set(
        current_fragments,
        ARRAY[
          (SELECT ordinality - 1 FROM jsonb_array_elements(current_fragments) WITH ORDINALITY 
           WHERE value->>'label' = fragment_label LIMIT 1)::TEXT
        ],
        jsonb_build_object(
          'label', fragment_label,
          'archetype', COALESCE(fragment->>'archetype', 'unknown'),
          'confidence', LEAST(
            COALESCE(
              (SELECT (value->>'confidence')::FLOAT FROM jsonb_array_elements(current_fragments) 
               WHERE value->>'label' = fragment_label),
              0.0
            ) + 0.05, -- Small confidence boost
            1.0
          ),
          'behavioral_evidence', COALESCE(fragment->'behavioral_evidence', '[]'::jsonb),
          'last_reinforced', NOW(),
          'reinforcement_count', COALESCE(
            (SELECT (value->>'reinforcement_count')::INTEGER FROM jsonb_array_elements(current_fragments) 
             WHERE value->>'label' = fragment_label),
            0
          ) + 1
        )
      ) INTO updated_fragments;
      
      reinforced_fragments := reinforced_fragments || jsonb_build_object(
        'label', fragment_label,
        'confidence_change', 0.05,
        'evidence', fragment->'behavioral_evidence'
      );
    ELSE
      -- Add new fragment
      new_fragments := new_fragments || jsonb_build_object(
        'label', fragment_label,
        'archetype', COALESCE(fragment->>'archetype', 'unknown'),
        'confidence', 0.5, -- Initial confidence
        'behavioral_evidence', COALESCE(fragment->'behavioral_evidence', '[]'::jsonb),
        'first_detected', NOW(),
        'last_reinforced', NOW(),
        'reinforcement_count', 1
      );
    END IF;
  END LOOP;
  
  -- Apply entropy decay to unreinforced fragments
  FOR fragment IN SELECT * FROM jsonb_array_elements(updated_fragments)
  LOOP
    fragment_label := fragment->>'label';
    
    -- If fragment wasn't reinforced, apply small decay
    IF NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(reinforced_fragments) 
      WHERE value->>'label' = fragment_label
    ) THEN
      confidence_change := -0.02; -- Small decay
      
      SELECT jsonb_set(
        updated_fragments,
        ARRAY[
          (SELECT ordinality - 1 FROM jsonb_array_elements(updated_fragments) WITH ORDINALITY 
           WHERE value->>'label' = fragment_label LIMIT 1)::TEXT
        ],
        jsonb_set(
          fragment,
          ARRAY['confidence'],
          to_jsonb(GREATEST(0.0, (fragment->>'confidence')::FLOAT + confidence_change))
        )
      ) INTO updated_fragments;
      
      weakened_fragments := weakened_fragments || jsonb_build_object(
        'label', fragment_label,
        'confidence_change', confidence_change,
        'reason', 'entropy_decay'
      );
    END IF;
  END LOOP;
  
  -- Add new fragments
  updated_fragments := updated_fragments || new_fragments;
  
  result := jsonb_build_object(
    'updated_fragments', updated_fragments,
    'reinforced_fragments', reinforced_fragments,
    'weakened_fragments', weakened_fragments,
    'new_fragments', new_fragments,
    'fragment_count', jsonb_array_length(updated_fragments)
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMPLETE PROFILE UPDATE FUNCTION
-- =====================================================

-- Main function to update actor profile with quantum psychology
CREATE OR REPLACE FUNCTION actors.update_actor_profile_quantum(
  p_actor_id UUID,
  signal_analysis JSONB,
  signal_id UUID DEFAULT NULL,
  signal_type TEXT DEFAULT 'unknown',
  signal_context JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  current_profile RECORD;
  prior_distribution JSONB;
  likelihood_distribution JSONB;
  bayesian_result JSONB;
  posterior_distribution JSONB;
  quantum_states JSONB;
  identity_updates JSONB;
  contradiction_analysis JSONB;
  information_metrics JSONB;
  update_log_id UUID;
  result JSONB;
BEGIN
  -- Get current profile
  SELECT 
    driver_distribution,
    quantum_states,
    identity_markers,
    entropy,
    signal_count,
    signal_sources
  INTO current_profile
  FROM actors.actor_profiles
  WHERE actor_id = p_actor_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Actor profile not found: %', p_actor_id;
  END IF;
  
  prior_distribution := current_profile.driver_distribution;
  likelihood_distribution := signal_analysis->'driver_inference';
  
  -- Apply Bayesian update
  SELECT actors.apply_bayesian_update(
    prior_distribution,
    likelihood_distribution,
    COALESCE((signal_analysis->>'signal_confidence')::FLOAT, 0.5)
  ) INTO bayesian_result;
  
  posterior_distribution := bayesian_result->'posterior_distribution';
  
  -- Update quantum states
  SELECT actors.update_quantum_states(
    p_actor_id,
    posterior_distribution,
    signal_context
  ) INTO quantum_states;
  
  -- Update identity fragments
  SELECT actors.update_identity_fragments(
    current_profile.identity_markers,
    signal_analysis,
    signal_context
  ) INTO identity_updates;
  
  -- Detect contradictions
  SELECT actors.calculate_contradiction_complexity(
    posterior_distribution,
    identity_updates->'updated_fragments',
    signal_context
  ) INTO contradiction_analysis;
  
  -- Calculate information metrics
  SELECT actors.calculate_information_gain(
    prior_distribution,
    posterior_distribution
  ) INTO information_metrics;
  
  -- Update actor profile
  UPDATE actors.actor_profiles SET
    driver_distribution = posterior_distribution,
    dominant_driver = (
      SELECT key FROM jsonb_each(posterior_distribution)
      ORDER BY value::FLOAT DESC LIMIT 1
    ),
    driver_confidence = COALESCE((signal_analysis->>'driver_confidence')::FLOAT, 0.0),
    quantum_states = quantum_states,
    identity_markers = identity_updates->'updated_fragments',
    internal_contradictions = contradiction_analysis->'driver_conflicts'->'conflicts',
    contradiction_complexity = (contradiction_analysis->>'overall_complexity')::FLOAT,
    resolution_capacity = (contradiction_analysis->>'resolution_capacity')::FLOAT,
    identity_coherence = (contradiction_analysis->'identity_fragmentation'->>'overall_coherence')::FLOAT,
    entropy = (information_metrics->>'posterior_entropy')::FLOAT,
    last_entropy_reduction = (information_metrics->>'information_gain')::FLOAT,
    information_gain = COALESCE(information_gain, 0.0) + (information_metrics->>'information_gain')::FLOAT,
    signal_count = signal_count + 1,
    signal_sources = CASE 
      WHEN NOT (signal_sources @> ARRAY[signal_type]) THEN signal_sources || ARRAY[signal_type]
      ELSE signal_sources
    END,
    last_updated = NOW()
  WHERE actor_id = p_actor_id;
  
  -- Log the update
  INSERT INTO actors.actor_updates (
    actor_id, signal_id,
    driver_distribution_before, driver_distribution_after,
    driver_deltas, quantum_state_changes, contradiction_updates,
    identity_fragment_updates, entropy_before, entropy_after,
    entropy_reduction, information_gain, kl_divergence,
    reasoning_chain, contextual_factors, update_type, confidence_score
  ) VALUES (
    p_actor_id, signal_id,
    prior_distribution, posterior_distribution,
    jsonb_build_object(
      'Safety', (posterior_distribution->>'Safety')::FLOAT - (prior_distribution->>'Safety')::FLOAT,
      'Connection', (posterior_distribution->>'Connection')::FLOAT - (prior_distribution->>'Connection')::FLOAT,
      'Status', (posterior_distribution->>'Status')::FLOAT - (prior_distribution->>'Status')::FLOAT,
      'Growth', (posterior_distribution->>'Growth')::FLOAT - (prior_distribution->>'Growth')::FLOAT,
      'Freedom', (posterior_distribution->>'Freedom')::FLOAT - (prior_distribution->>'Freedom')::FLOAT,
      'Purpose', (posterior_distribution->>'Purpose')::FLOAT - (prior_distribution->>'Purpose')::FLOAT
    ),
    quantum_states, contradiction_analysis,
    identity_updates,
    (information_metrics->>'prior_entropy')::FLOAT,
    (information_metrics->>'posterior_entropy')::FLOAT,
    (information_metrics->>'information_gain')::FLOAT,
    (information_metrics->>'information_gain')::FLOAT,
    (information_metrics->>'kl_divergence')::FLOAT,
    signal_analysis, signal_context,
    'signal_processing',
    COALESCE((signal_analysis->>'signal_confidence')::FLOAT, 0.5)
  ) RETURNING update_id INTO update_log_id;
  
  result := jsonb_build_object(
    'actor_id', p_actor_id,
    'update_log_id', update_log_id,
    'prior_distribution', prior_distribution,
    'posterior_distribution', posterior_distribution,
    'information_gain', information_metrics->>'information_gain',
    'entropy_reduction', information_metrics->>'information_gain',
    'quantum_states', quantum_states,
    'contradiction_analysis', contradiction_analysis,
    'identity_updates', identity_updates,
    'update_successful', true
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SIGNAL PROCESSING PIPELINE
-- =====================================================

-- Function to process signal through complete quantum psychology pipeline
CREATE OR REPLACE FUNCTION actors.process_signal_quantum(
  p_signal_id UUID,
  p_signal_type TEXT,
  p_signal_text TEXT,
  p_actor_id UUID DEFAULT NULL,
  p_signal_context JSONB DEFAULT '{}'
)
RETURNS JSONB AS $$
DECLARE
  signal_analysis JSONB;
  driver_inference JSONB;
  identity_inference JSONB;
  quantum_effects JSONB;
  contradiction_detection JSONB;
  complete_analysis JSONB;
  profile_update_result JSONB;
  result JSONB;
BEGIN
  -- Step 1: Driver inference (simplified for now)
  driver_inference := jsonb_build_object(
    'Safety', 0.0,
    'Connection', 0.0,
    'Status', 0.0,
    'Growth', 0.0,
    'Freedom', 0.0,
    'Purpose', 0.0
  );
  
  -- Basic keyword matching for driver inference
  IF p_signal_text ILIKE '%safe%' OR p_signal_text ILIKE '%reliable%' OR p_signal_text ILIKE '%consistent%' THEN
    driver_inference := jsonb_set(driver_inference, ARRAY['Safety'], to_jsonb(0.7));
  END IF;
  
  IF p_signal_text ILIKE '%family%' OR p_signal_text ILIKE '%together%' OR p_signal_text ILIKE '%share%' THEN
    driver_inference := jsonb_set(driver_inference, ARRAY['Connection'], to_jsonb(0.6));
  END IF;
  
  IF p_signal_text ILIKE '%premium%' OR p_signal_text ILIKE '%exclusive%' OR p_signal_text ILIKE '%best%' THEN
    driver_inference := jsonb_set(driver_inference, ARRAY['Status'], to_jsonb(0.8));
  END IF;
  
  IF p_signal_text ILIKE '%try%' OR p_signal_text ILIKE '%learn%' OR p_signal_text ILIKE '%improve%' THEN
    driver_inference := jsonb_set(driver_inference, ARRAY['Growth'], to_jsonb(0.5));
  END IF;
  
  IF p_signal_text ILIKE '%new%' OR p_signal_text ILIKE '%different%' OR p_signal_text ILIKE '%explore%' THEN
    driver_inference := jsonb_set(driver_inference, ARRAY['Freedom'], to_jsonb(0.6));
  END IF;
  
  IF p_signal_text ILIKE '%values%' OR p_signal_text ILIKE '%meaning%' OR p_signal_text ILIKE '%purpose%' THEN
    driver_inference := jsonb_set(driver_inference, ARRAY['Purpose'], to_jsonb(0.7));
  END IF;
  
  -- Step 2: Identity inference
  identity_inference := jsonb_build_object(
    'identity_signals', '[]'::jsonb
  );
  
  -- Step 3: Quantum effects
  quantum_effects := jsonb_build_object(
    'superposition_detected', false,
    'entanglement_detected', false,
    'coherence_level', 0.5
  );
  
  -- Step 4: Contradiction detection
  SELECT actors.detect_driver_conflicts(driver_inference, p_signal_context) INTO contradiction_detection;
  
  -- Step 5: Complete analysis
  complete_analysis := jsonb_build_object(
    'driver_inference', driver_inference,
    'identity_inference', identity_inference,
    'quantum_effects', quantum_effects,
    'contradiction_detection', contradiction_detection,
    'signal_confidence', 0.6,
    'signal_text', p_signal_text,
    'signal_context', p_signal_context
  );
  
  -- Step 6: Update profile if actor_id provided
  IF p_actor_id IS NOT NULL THEN
    SELECT actors.update_actor_profile_quantum(
      p_actor_id,
      complete_analysis,
      p_signal_id,
      p_signal_type,
      p_signal_context
    ) INTO profile_update_result;
  ELSE
    profile_update_result := jsonb_build_object('actor_id', NULL, 'update_skipped', true);
  END IF;
  
  result := jsonb_build_object(
    'signal_id', p_signal_id,
    'signal_type', p_signal_type,
    'signal_analysis', complete_analysis,
    'profile_update', profile_update_result,
    'processing_successful', true
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Test Bayesian update
SELECT actors.apply_bayesian_update(
  '{"Safety": 0.5, "Connection": 0.3, "Status": 0.2, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
  '{"Safety": 0.2, "Connection": 0.1, "Status": 0.7, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
  0.8
);

-- Test information gain calculation
SELECT actors.calculate_information_gain(
  '{"Safety": 0.5, "Connection": 0.3, "Status": 0.2, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb,
  '{"Safety": 0.3, "Connection": 0.2, "Status": 0.5, "Growth": 0.0, "Freedom": 0.0, "Purpose": 0.0}'::jsonb
);

-- Test signal processing
SELECT actors.process_signal_quantum(
  gen_random_uuid(),
  'whatsapp',
  'I love the premium wings, they are so exclusive and everyone is talking about them!',
  NULL,
  '{"context": "social_setting", "audience": "friends"}'::jsonb
);
