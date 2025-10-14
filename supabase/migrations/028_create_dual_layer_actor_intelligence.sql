-- =====================================================
-- DUAL-LAYER ACTOR INTELLIGENCE SYSTEM
-- Phase 1: Foundation - Database Schema + Driver Ontology
-- =====================================================

-- =====================================================
-- TABLE 1: actors.actor_profiles (Enhanced)
-- =====================================================

-- Drop existing table if it exists and recreate with enhanced structure
DROP TABLE IF EXISTS actors.actor_profiles CASCADE;

CREATE TABLE actors.actor_profiles (
  actor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Identity
  identifiers JSONB, -- {phones: [], emails: [], names: [], social_handles: []}
  primary_identifier TEXT, -- Main way to reference this person
  
  -- LAYER 1: PREFERENCES (Surface Understanding)
  preferences JSONB, -- Product/flavor preferences with confidence
  -- Structure: {
  --   "sweet_preference": {"value": 0.85, "confidence": 0.78, "evidence_count": 4},
  --   "spice_tolerance": {"value": 0.72, "confidence": 0.81, "evidence_count": 5},
  --   ...
  -- }
  
  -- LAYER 2: DRIVERS (Deep Understanding)
  driver_distribution JSONB NOT NULL, -- Bayesian belief state
  -- Structure: {
  --   "Buffer": 0.62,
  --   "Bond": 0.18,
  --   "Badge": 0.15,
  --   "Build": 0.05,
  --   "Breadth": 0.00,
  --   "Meaning": 0.00
  -- }
  
  dominant_driver TEXT, -- Primary driver (highest probability)
  driver_confidence FLOAT, -- Confidence in driver inference
  
  -- Contradictions & Tensions
  contradictions JSONB[], -- Array of detected contradictions
  -- Structure: {
  --   "type": "stated_vs_behavioral",
  --   "tension": "Says wants variety, seeks stability",
  --   "strength": 0.74,
  --   "collapse_strategy": "Reliable variety messaging"
  -- }
  
  -- Metadata
  first_seen TIMESTAMPTZ DEFAULT NOW(),
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  signal_count INTEGER DEFAULT 0,
  signal_sources TEXT[], -- ["whatsapp", "reviews", "orders"]
  brand_id UUID REFERENCES core.brands(brand_id),
  
  -- Profile Quality
  profile_completeness FLOAT, -- 0-1 score
  confidence_in_identity FLOAT, -- How sure we are this is one person
  data_quality_score FLOAT,
  
  -- Learning Metrics
  entropy FLOAT, -- Uncertainty in driver distribution
  last_entropy_reduction FLOAT, -- How much last update reduced uncertainty
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_actors_primary_identifier ON actors.actor_profiles(primary_identifier);
CREATE INDEX idx_actors_brand ON actors.actor_profiles(brand_id);
CREATE INDEX idx_actors_dominant_driver ON actors.actor_profiles(dominant_driver);
CREATE INDEX idx_actors_last_updated ON actors.actor_profiles(last_updated);

-- =====================================================
-- TABLE 2: actors.drivers (Core Driver Ontology)
-- =====================================================

CREATE TABLE actors.drivers (
  driver_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_name TEXT NOT NULL UNIQUE, -- Buffer, Bond, Badge, Build, Breadth, Meaning
  
  -- Core Definition
  core_meaning TEXT NOT NULL, -- What this driver represents
  core_need TEXT NOT NULL, -- The fundamental need being met
  emotional_tone TEXT, -- The feeling state associated
  
  -- Behavioral Signatures
  typical_behaviors TEXT[], -- Observable behaviors indicating this driver
  language_patterns TEXT[], -- Common phrases/words used
  friction_indicators TEXT[], -- Signs of tension in this driver
  
  -- Contradictions
  internal_contradictions JSONB, -- Self-contradictory aspects
  conflicts_with TEXT[], -- Other drivers this conflicts with
  collapse_triggers TEXT[], -- What resolves tension
  
  -- Brand Expression
  stimuli_cues JSONB, -- How to speak to this driver
  -- Structure: {
  --   "messaging_tone": "reassuring",
  --   "offer_types": ["consistency guarantees", "familiar options"],
  --   "content_themes": ["reliability", "trust", "safety"]
  -- }
  
  -- Metadata
  description TEXT,
  examples TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 3: actors.actor_updates (Learning Memory)
-- =====================================================

CREATE TABLE actors.actor_updates (
  update_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID REFERENCES actors.actor_profiles(actor_id) ON DELETE CASCADE,
  signal_id UUID, -- Link to the signal that triggered this update
  signal_type TEXT, -- whatsapp, review, order, etc.
  
  -- What Changed
  update_type TEXT, -- preference_update, driver_update, contradiction_detected, etc.
  
  -- PREFERENCE LAYER UPDATES
  preferences_before JSONB,
  preferences_after JSONB,
  preference_changes JSONB, -- Specific changes made
  
  -- DRIVER LAYER UPDATES
  drivers_before JSONB, -- Distribution before update
  drivers_after JSONB, -- Distribution after update
  driver_shift JSONB, -- How much each driver changed
  
  -- Learning Metrics
  entropy_before FLOAT,
  entropy_after FLOAT,
  entropy_reduction FLOAT, -- How much uncertainty decreased
  confidence_delta FLOAT, -- Change in overall confidence
  
  -- Reasoning
  reasoning TEXT, -- Why this update was made
  evidence TEXT[], -- What signals/behaviors led to this
  
  -- Contradictions
  contradictions_detected JSONB[], -- Any new contradictions found
  
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_updates_actor ON actors.actor_updates(actor_id);
CREATE INDEX idx_updates_signal ON actors.actor_updates(signal_id);
CREATE INDEX idx_updates_timestamp ON actors.actor_updates(updated_at);

-- =====================================================
-- TABLE 4: actors.decoder_log (7-Column Output)
-- =====================================================

CREATE TABLE actors.decoder_log (
  log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID REFERENCES actors.actor_profiles(actor_id),
  signal_id UUID, -- The signal being analyzed
  
  -- THE 7 COLUMNS
  col1_actor_segment TEXT, -- Actor ID / Segment
  col2_observed_behavior TEXT, -- Observed Behaviour / Feedback
  col3_belief_inferred TEXT, -- Belief Inferred
  col4_confidence_score FLOAT, -- Confidence Score (0-1)
  col5_friction_contradiction TEXT, -- Friction / Contradiction
  col6_core_driver TEXT, -- Core Driver (Buffer/Bond/Badge/Build/Breadth/Meaning)
  col7_actionable_insight TEXT, -- Actionable Insight / Next Step
  
  -- Full structured output
  decoder_output JSONB, -- Complete analysis result
  
  processed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_decoder_actor ON actors.decoder_log(actor_id);
CREATE INDEX idx_decoder_driver ON actors.decoder_log(col6_core_driver);

-- =====================================================
-- POPULATE CORE DRIVER ONTOLOGY
-- =====================================================

INSERT INTO actors.drivers (
  driver_name, core_meaning, core_need, emotional_tone,
  typical_behaviors, language_patterns, friction_indicators,
  collapse_triggers, stimuli_cues, description
) VALUES
(
  'Buffer',
  'Safety, comfort, predictability',
  'Security',
  'Calm, reassured, stable',
  ARRAY[
    'Orders same items repeatedly',
    'Complains about inconsistency',
    'Expresses concern about changes',
    'Seeks reassurance',
    'Values reliability mentions'
  ],
  ARRAY[
    'always get the same',
    'usually order',
    'reliable',
    'consistent',
    'what I know',
    'comfortable with'
  ],
  ARRAY[
    'Mentions inconsistency',
    'Complains about changes',
    'Expresses uncertainty',
    'Worried about quality variation'
  ],
  ARRAY[
    'Reassurance of consistency',
    'Quality guarantees',
    'Familiar options highlighted',
    'Track record messaging'
  ],
  '{"messaging_tone": "reassuring", "offer_types": ["loyalty rewards", "consistency guarantees"], "content_themes": ["reliability", "trust", "same great quality"]}'::jsonb,
  'Seeks stability and predictability. Values knowing what to expect. Uncomfortable with change or inconsistency.'
),
(
  'Bond',
  'Connection, trust, belonging',
  'Intimacy',
  'Warm, connected, appreciated',
  ARRAY[
    'Mentions community/friends',
    'Shares experiences socially',
    'Responds to personalization',
    'Values relationship building',
    'Appreciates human touch'
  ],
  ARRAY[
    'we always',
    'my friends and I',
    'love coming here',
    'feel at home',
    'part of',
    'belong'
  ],
  ARRAY[
    'Feels anonymous or unrecognized',
    'Mentions impersonal service',
    'Lacks connection language'
  ],
  ARRAY[
    'Personalized recognition',
    'Community-building',
    'Relationship acknowledgment',
    'Insider status'
  ],
  '{"messaging_tone": "warm and personal", "offer_types": ["refer-a-friend", "VIP treatment"], "content_themes": ["community", "family", "together"]}'::jsonb,
  'Seeks connection and belonging. Values relationships and shared experiences. Wants to feel recognized and part of something.'
),
(
  'Badge',
  'Recognition, identity, status',
  'Validation',
  'Proud, distinguished, admired',
  ARRAY[
    'Mentions exclusivity',
    'Posts about experiences',
    'Values status markers',
    'Seeks recognition',
    'Shares achievements'
  ],
  ARRAY[
    'first to try',
    'exclusive',
    'special',
    'unique',
    'limited edition',
    'VIP'
  ],
  ARRAY[
    'Feels unrecognized',
    'Not differentiated from others',
    'Missing status signals'
  ],
  ARRAY[
    'Recognition of status',
    'Exclusive access',
    'Limited availability',
    'Special treatment'
  ],
  '{"messaging_tone": "aspirational and exclusive", "offer_types": ["limited releases", "VIP access", "early access"], "content_themes": ["exclusive", "elite", "first"]}'::jsonb,
  'Seeks recognition and status. Values being distinguished from others. Wants identity validation through special access or treatment.'
),
(
  'Build',
  'Growth, mastery, self-improvement',
  'Progress',
  'Accomplished, developing, advancing',
  ARRAY[
    'Tries new items progressively',
    'Mentions spice tolerance growth',
    'Tracks own journey',
    'Values skill development',
    'Embraces challenges'
  ],
  ARRAY[
    'working my way up',
    'challenge',
    'next level',
    'getting better at',
    'can now handle',
    'progress'
  ],
  ARRAY[
    'Stagnation',
    'No growth opportunity',
    'Same level offerings only'
  ],
  ARRAY[
    'Progressive challenges',
    'Achievement tracking',
    'Skill validation',
    'Level-up opportunities'
  ],
  '{"messaging_tone": "encouraging and progressive", "offer_types": ["spice challenges", "achievement badges", "progress tracking"], "content_themes": ["growth", "challenge", "level up"]}'::jsonb,
  'Seeks growth and mastery. Values progressive challenges and skill development. Wants to see their own advancement.'
),
(
  'Breadth',
  'Exploration, variety, novelty',
  'Freedom',
  'Excited, curious, adventurous',
  ARRAY[
    'Tries many different items',
    'Seeks new menu additions',
    'Experiments with flavors',
    'Values variety',
    'Avoids repetition'
  ],
  ARRAY[
    'something new',
    'different',
    'try everything',
    'variety',
    'never had before',
    'exploring'
  ],
  ARRAY[
    'Limited options',
    'Same old offerings',
    'Repetitive menu',
    'Lack of novelty'
  ],
  ARRAY[
    'New product launches',
    'Variety packs',
    'Rotating specials',
    'Exploration incentives'
  ],
  '{"messaging_tone": "adventurous and exciting", "offer_types": ["tasting menus", "new releases", "variety packs"], "content_themes": ["new", "explore", "discover"]}'::jsonb,
  'Seeks variety and novelty. Values exploration and new experiences. Gets bored with repetition.'
),
(
  'Meaning',
  'Purpose, depth, contribution',
  'Significance',
  'Fulfilled, purposeful, connected to values',
  ARRAY[
    'Asks about sourcing/ethics',
    'Values brand mission',
    'Cares about impact',
    'Seeks deeper purpose',
    'Aligns with values'
  ],
  ARRAY[
    'stands for something',
    'values',
    'purpose',
    'meaningful',
    'makes a difference',
    'authentic'
  ],
  ARRAY[
    'Feels shallow or empty',
    'No values alignment',
    'Missing purpose connection'
  ],
  ARRAY[
    'Mission communication',
    'Values alignment',
    'Impact stories',
    'Authentic connection'
  ],
  '{"messaging_tone": "authentic and purposeful", "offer_types": ["cause-related", "values-driven", "impact-focused"], "content_themes": ["purpose", "values", "impact"]}'::jsonb,
  'Seeks purpose and significance. Values deeper meaning beyond transactions. Wants to align with brand values and feel their choices matter.'
);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check tables created
SELECT 
  schemaname,
  tablename,
  tableowner
FROM pg_tables 
WHERE schemaname = 'actors' 
ORDER BY tablename;

-- Check drivers populated
SELECT 
  driver_name,
  core_meaning,
  core_need
FROM actors.drivers 
ORDER BY driver_name;

-- Check table structures
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'actors' 
  AND table_name = 'actor_profiles'
ORDER BY ordinal_position;
