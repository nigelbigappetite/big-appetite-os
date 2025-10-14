-- =====================================================
-- QUANTUM PSYCHOLOGY ACTOR SYSTEM - PHASE 1
-- Redesign actor profiles for driver-first architecture
-- =====================================================

-- =====================================================
-- STEP 1: DROP PREFERENCE LAYER - DRIVERS ONLY
-- =====================================================

-- Drop existing actor_profiles table (we're rebuilding from scratch)
DROP TABLE IF EXISTS actors.actor_profiles CASCADE;

-- =====================================================
-- STEP 2: NEW ACTOR PROFILES - QUANTUM PSYCHOLOGY
-- =====================================================

CREATE TABLE actors.actor_profiles (
  actor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- IDENTITY LAYER
  identifiers JSONB NOT NULL DEFAULT '{}', -- {phones: [], emails: [], names: [], social_handles: []}
  primary_identifier TEXT NOT NULL, -- Main way to reference this person
  brand_id UUID NOT NULL REFERENCES core.brands(brand_id),
  
  -- DRIVER LAYER (CORE - PRIMARY) - 6D probability space
  driver_distribution JSONB NOT NULL DEFAULT '{"Safety": 0.16, "Connection": 0.16, "Status": 0.17, "Growth": 0.17, "Freedom": 0.17, "Purpose": 0.17}',
  dominant_driver TEXT, -- Highest probability driver
  driver_confidence FLOAT DEFAULT 0.0, -- Overall certainty in driver inference
  driver_entropy FLOAT DEFAULT 2.58, -- Uncertainty in distribution (max entropy = 2.58 for 6 drivers)
  
  -- QUANTUM STATE LAYER (ADVANCED)
  quantum_states JSONB DEFAULT '{}', -- Superposition, entanglement, coherence tracking
  -- Structure: {
  --   "superposition": {
  --     "primary_state": "Safety",
  --     "secondary_state": "Status", 
  --     "interference_pattern": 0.68,
  --     "collapse_probability": 0.72
  --   },
  --   "entanglement": {
  --     "driver_pairs": [
  --       {"driver_a": "Safety", "driver_b": "Status", "correlation": -0.65, "entanglement_strength": 0.78}
  --     ]
  --   },
  --   "wave_function": {
  --     "coherence": 0.68,
  --     "decoherence_rate": 0.12,
  --     "measurement_collapse": "partial"
  --   }
  -- }
  
  -- INTERNAL CONTRADICTION LAYER (DRIVER-LEVEL ONLY)
  internal_contradictions JSONB DEFAULT '[]', -- Driver conflicts, identity fragmentation
  -- Structure: [
  --   {
  --     "type": "driver_conflict",
  --     "drivers_in_tension": ["Safety", "Status"],
  --     "tension_strength": 0.68,
  --     "manifestation": "Wants predictability but seeks recognition",
  --     "behavioral_signature": ["Orders familiar but photographs them"],
  --     "resolution_pattern": "intermittent_oscillation",
  --     "collapse_trigger": "social_context",
  --     "collapse_strategy": "Exclusive classics - reliable items with status signals"
  --   }
  -- ]
  contradiction_complexity FLOAT DEFAULT 0.0, -- Overall measure of internal tension
  resolution_capacity FLOAT DEFAULT 0.0, -- Ability to integrate contradictions
  
  -- IDENTITY LAYER (WHO THEY SEE THEMSELVES AS)
  identity_markers JSONB DEFAULT '[]', -- Role identities, archetypes, self-concept
  -- Structure: [
  --   {
  --     "label": "protector",
  --     "archetype": "caregiver", 
  --     "confidence": 0.82,
  --     "behavioral_evidence": ["Orders for family consistently"],
  --     "driver_alignment": {"Safety": 0.90, "Connection": 0.85},
  --     "first_detected": "timestamp",
  --     "last_reinforced": "timestamp",
  --     "reinforcement_count": 23
  --   }
  -- ]
  identity_coherence FLOAT DEFAULT 0.0, -- How integrated are multiple identities
  identity_fluidity FLOAT DEFAULT 0.0, -- How much identity shifts with context
  
  -- BAYESIAN BELIEF NETWORK
  belief_network JSONB DEFAULT '{}', -- Priors, likelihoods, posteriors, evidence tracking
  -- Structure: {
  --   "priors": {"Safety": 0.50, "Connection": 0.20, ...},
  --   "likelihood_weights": {"language_signals": 0.40, "behavioral_signals": 0.45, "contextual_signals": 0.15},
  --   "posterior_updates": [...],
  --   "evidence_strength": {"total_signals": 47, "high_confidence_signals": 28, ...}
  -- }
  
  -- METADATA LAYER
  first_seen TIMESTAMPTZ DEFAULT NOW(),
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  signal_count INTEGER DEFAULT 0,
  signal_sources TEXT[] DEFAULT '{}', -- ["whatsapp", "reviews", "orders"]
  
  -- LEARNING METRICS
  entropy FLOAT DEFAULT 2.58, -- Current uncertainty (max = 2.58 for 6 drivers)
  last_entropy_reduction FLOAT DEFAULT 0.0, -- How much last update reduced uncertainty
  information_gain FLOAT DEFAULT 0.0, -- Cumulative learning from signals
  convergence_rate FLOAT DEFAULT 0.0, -- How fast understanding is stabilizing
  
  -- PROFILE QUALITY
  profile_completeness FLOAT DEFAULT 0.0, -- 0-1 score
  confidence_in_identity FLOAT DEFAULT 0.0, -- How sure we are this is one person
  data_quality_score FLOAT DEFAULT 0.0,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_actors_primary_identifier ON actors.actor_profiles(primary_identifier);
CREATE INDEX idx_actors_brand ON actors.actor_profiles(brand_id);
CREATE INDEX idx_actors_dominant_driver ON actors.actor_profiles(dominant_driver);
CREATE INDEX idx_actors_entropy ON actors.actor_profiles(entropy);
CREATE INDEX idx_actors_contradiction_complexity ON actors.actor_profiles(contradiction_complexity);
CREATE INDEX idx_actors_last_updated ON actors.actor_profiles(last_updated);

-- =====================================================
-- STEP 3: ENHANCED DRIVERS TABLE WITH CONFLICT MATRICES
-- =====================================================

-- Drop and recreate drivers table with conflict dynamics
DROP TABLE IF EXISTS actors.drivers CASCADE;

CREATE TABLE actors.drivers (
  driver_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_name TEXT NOT NULL UNIQUE, -- Safety, Connection, Status, Growth, Freedom, Purpose
  
  -- CORE DEFINITION
  core_meaning TEXT NOT NULL, -- What this driver represents
  core_need TEXT NOT NULL, -- The fundamental need being met
  emotional_tone TEXT, -- The feeling state associated
  
  -- BEHAVIORAL SIGNATURES
  typical_behaviors TEXT[], -- Observable behaviors indicating this driver
  language_patterns TEXT[], -- Common phrases/words used
  friction_indicators TEXT[], -- Signs of tension in this driver
  
  -- DRIVER DYNAMICS (CONFLICT MATRICES)
  driver_dynamics JSONB DEFAULT '{}', -- Conflict/reinforcement relationships
  -- Structure: {
  --   "conflicts_with": [
  --     {
  --       "driver": "Freedom",
  --       "conflict_strength": 0.85,
  --       "tension_manifestation": "Predictability vs spontaneity",
  --       "common_behavioral_patterns": ["Orders familiar but expresses curiosity"],
  --       "collapse_strategies": ["Familiar innovation - new items as extensions of known favorites"]
  --     }
  --   ],
  --   "reinforces_with": [
  --     {
  --       "driver": "Connection",
  --       "reinforcement_strength": 0.82,
  --       "synergy_manifestation": "Shared comfort and belonging"
  --     }
  --   ],
  --   "entanglement_patterns": {
  --     "quantum_correlation": "When Safety is high, Growth is suppressed (-0.72 correlation)",
  --     "measurement_effect": "Observing Safety behaviors strengthens Safety driver",
  --     "complementarity": "Cannot be simultaneously high in Safety and Freedom"
  --   }
  -- }
  
  -- BRAND EXPRESSION
  stimuli_cues JSONB DEFAULT '{}', -- How to speak to this driver
  -- Structure: {
  --   "messaging_tone": "reassuring",
  --   "offer_types": ["consistency guarantees", "familiar options"],
  --   "content_themes": ["reliability", "trust", "safety"]
  -- }
  
  -- METADATA
  description TEXT,
  examples TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- STEP 4: ENHANCED ACTOR UPDATES WITH QUANTUM TRACKING
-- =====================================================

-- Drop and recreate actor_updates table
DROP TABLE IF EXISTS actors.actor_updates CASCADE;

CREATE TABLE actors.actor_updates (
  update_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID NOT NULL REFERENCES actors.actor_profiles(actor_id),
  signal_id UUID, -- The signal that triggered this update
  
  -- DRIVER EVOLUTION
  driver_distribution_before JSONB NOT NULL, -- Prior distribution
  driver_distribution_after JSONB NOT NULL, -- Posterior distribution
  driver_deltas JSONB NOT NULL, -- Changes in each driver probability
  -- Structure: {
  --   "Safety": {"delta": -0.10, "reasoning": "Chose unfamiliar option", "contextual_suppression": true},
  --   "Status": {"delta": +0.08, "reasoning": "Sought novelty/intensity", "contextual_activation": true}
  -- }
  
  -- QUANTUM STATE CHANGES
  quantum_state_changes JSONB DEFAULT '{}', -- Superposition, entanglement, collapse events
  -- Structure: {
  --   "superposition_detected": true,
  --   "interfering_drivers": ["Safety", "Status"],
  --   "interference_strength": 0.72,
  --   "collapse_events": [
  --     {"trigger": "social_context", "collapsed_to": "Status", "residual_superposition": ["Safety"]}
  --   ],
  --   "entanglement_updates": [
  --     {"driver_a": "Safety", "driver_b": "Status", "correlation_change": -0.05}
  --   ]
  -- }
  
  -- CONTRADICTION UPDATES
  contradiction_updates JSONB DEFAULT '{}', -- New conflicts, resolved tensions
  -- Structure: {
  --   "new_conflicts": [
  --     {"type": "driver_conflict", "drivers": ["Safety", "Freedom"], "strength": 0.78}
  --   ],
  --   "resolved_tensions": [
  --     {"type": "identity_fragmentation", "resolution": "contextual_switching"}
  --   ],
  --   "complexity_change": 0.12
  -- }
  
  -- IDENTITY FRAGMENT UPDATES
  identity_fragment_updates JSONB DEFAULT '{}', -- Reinforced, weakened, integrated
  -- Structure: {
  --   "reinforced": [
  --     {"label": "protector", "confidence_change": +0.05, "evidence": "Ordered for family"}
  --   ],
  --   "weakened": [
  --     {"label": "aspiring_connoisseur", "confidence_change": -0.02, "reason": "No sophistication signals"}
  --   ],
  --   "new_fragments": [
  --     {"label": "rebellious_individualist", "confidence": 0.45, "evidence": "Counter-cultural language"}
  --   ]
  -- }
  
  -- LEARNING METRICS
  entropy_before FLOAT NOT NULL, -- Uncertainty before update
  entropy_after FLOAT NOT NULL, -- Uncertainty after update
  entropy_reduction FLOAT NOT NULL, -- How much uncertainty reduced
  information_gain FLOAT NOT NULL, -- How much we learned
  kl_divergence FLOAT NOT NULL, -- How much belief changed (Kullback-Leibler divergence)
  
  -- REASONING CHAIN
  reasoning_chain JSONB NOT NULL, -- Complete analysis and inference process
  contextual_factors JSONB DEFAULT '{}', -- What influenced the update
  
  -- METADATA
  update_timestamp TIMESTAMPTZ DEFAULT NOW(),
  update_type TEXT DEFAULT 'signal_processing', -- 'signal_processing', 'manual_adjustment', 'batch_update'
  confidence_score FLOAT DEFAULT 0.0 -- Overall confidence in this update
);

-- Indexes
CREATE INDEX idx_actor_updates_actor ON actors.actor_updates(actor_id);
CREATE INDEX idx_actor_updates_signal ON actors.actor_updates(signal_id);
CREATE INDEX idx_actor_updates_timestamp ON actors.actor_updates(update_timestamp);
CREATE INDEX idx_actor_updates_entropy_reduction ON actors.actor_updates(entropy_reduction);

-- =====================================================
-- STEP 5: ENHANCED DECODER LOG WITH QUANTUM OUTPUT
-- =====================================================

-- Drop and recreate decoder_log table
DROP TABLE IF EXISTS actors.decoder_log CASCADE;

CREATE TABLE actors.decoder_log (
  log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID REFERENCES actors.actor_profiles(actor_id),
  signal_id UUID, -- The signal being analyzed
  
  -- THE 7 COLUMNS (QUANTUM PSYCHOLOGY VERSION)
  col1_actor_segment JSONB, -- Identity and dominant driver
  -- Structure: {
  --   "current_identity": ["comfort-seeker", "occasional adventurer"],
  --   "dominant_driver": "Safety",
  --   "driver_confidence": 0.72
  -- }
  
  col2_observed_behavior JSONB, -- Observable facts, context, emotion
  -- Structure: {
  --   "action": "Ordered spicy wings after typically ordering mild",
  --   "verbatim_quote": "I loved the spicy wings!",
  --   "context": "Friday night, with friends, social setting",
  --   "emotional_tone": "Excited, enthusiastic, proud"
  -- }
  
  col3_belief_inferred JSONB, -- Driver updates and quantum effects (NO PREFERENCES)
  -- Structure: {
  --   "driver_update": {
  --     "Safety": {"delta": -0.10, "reasoning": "Chose unfamiliar option", "contextual_suppression": true},
  --     "Status": {"delta": +0.08, "reasoning": "Sought novelty/intensity", "contextual_activation": true}
  --   },
  --   "quantum_effects": {
  --     "superposition_collapse": "partial",
  --     "collapsed_to": "Status",
  --     "collapse_trigger": "social_observation",
  --     "residual_superposition": ["Safety", "Freedom"]
  --   },
  --   "identity_update": {
  --     "reinforced": ["aspiring_connoisseur"],
  --     "weakened": ["comfort_seeker"],
  --     "new_fragment_detected": false
  --   }
  -- }
  
  col4_confidence_score JSONB, -- Confidence breakdown
  -- Structure: {
  --   "overall": 0.68,
  --   "factors": {
  --     "signal_strength": 0.75,
  --     "prior_evidence": 0.45,
  --     "consistency": 0.60
  --   }
  -- }
  
  col5_friction_contradiction JSONB, -- Driver conflicts and entanglement
  -- Structure: {
  --   "detected": true,
  --   "type": "driver_conflict",
  --   "drivers_in_tension": ["Safety", "Status"],
  --   "conflict_strength": 0.68,
  --   "tension": "Safety baseline (0.45) suppressed by Status activation (0.35) in social context",
  --   "entanglement": {
  --     "correlation": -0.72,
  --     "measurement_effect": "Observing behavior reinforces Status, suppresses Safety"
  --   }
  -- }
  
  col6_core_driver JSONB, -- Primary/secondary driver inference
  -- Structure: {
  --   "primary": "Status",
  --   "probability": 0.45,
  --   "reasoning": "Social context + display behavior + enthusiastic sharing",
  --   "secondary": "Freedom",
  --   "secondary_probability": 0.30
  -- }
  
  col7_actionable_insight JSONB, -- Collapse strategies and integration paths
  -- Structure: {
  --   "strategy": "Collapse strategy for Safety/Status tension",
  --   "recommendation": "Position spicy items as 'crowd-favorite bold option'",
  --   "next_signal_needed": "Track if spicy orders repeat when alone or only in groups",
  --   "confidence_threshold": "Need 2 more spicy orders to confirm preference shift"
  -- }
  
  -- FULL REASONING CHAIN
  full_reasoning_chain TEXT, -- Complete analysis narrative
  decoder_output JSONB, -- Complete structured analysis result
  
  -- METADATA
  processed_at TIMESTAMPTZ DEFAULT NOW(),
  signal_type TEXT, -- 'whatsapp', 'review', 'order', 'survey'
  processing_confidence FLOAT DEFAULT 0.0
);

-- Indexes
CREATE INDEX idx_decoder_actor ON actors.decoder_log(actor_id);
CREATE INDEX idx_decoder_signal ON actors.decoder_log(signal_id);
CREATE INDEX idx_decoder_driver ON actors.decoder_log((col6_core_driver->>'primary'));
CREATE INDEX idx_decoder_processed_at ON actors.decoder_log(processed_at);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check new table structures
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'actors' 
  AND table_name IN ('actor_profiles', 'drivers', 'actor_updates', 'decoder_log')
ORDER BY table_name, ordinal_position;

-- Test JSONB structure validation
SELECT 
  'actor_profiles' as table_name,
  jsonb_pretty(
    jsonb_build_object(
      'driver_distribution', '{"Safety": 0.45, "Connection": 0.25, "Status": 0.15, "Growth": 0.10, "Freedom": 0.05, "Purpose": 0.00}',
      'quantum_states', '{"superposition": {"primary_state": "Safety", "secondary_state": "Status", "interference_pattern": 0.68}}',
      'internal_contradictions', '[{"type": "driver_conflict", "drivers_in_tension": ["Safety", "Status"], "tension_strength": 0.68}]',
      'identity_markers', '[{"label": "protector", "archetype": "caregiver", "confidence": 0.82}]'
    )
  ) as sample_data;
