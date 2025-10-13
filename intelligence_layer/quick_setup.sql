-- Quick setup for testing the intelligence layer
-- Run this in Supabase SQL Editor

-- Create actors schema
CREATE SCHEMA IF NOT EXISTS actors;

-- Create drivers table
CREATE TABLE actors.drivers (
  driver_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_name TEXT NOT NULL UNIQUE,
  core_meaning TEXT NOT NULL,
  core_need TEXT NOT NULL,
  emotional_tone TEXT,
  typical_behaviors TEXT[],
  language_patterns TEXT[],
  friction_indicators TEXT[],
  driver_dynamics JSONB DEFAULT '{}'
);

-- Insert basic driver data
INSERT INTO actors.drivers (driver_name, core_meaning, core_need, emotional_tone, typical_behaviors, language_patterns, friction_indicators, driver_dynamics) VALUES
('Safety', 'Security and predictability', 'Security', 'Calm, reassured, stable', 
 ARRAY['Orders same items repeatedly', 'Complains about inconsistency', 'Seeks reassurance'],
 ARRAY['always get the same', 'usually order', 'reliable', 'consistent', 'what I know'],
 ARRAY['Mentions inconsistency', 'Complains about changes', 'Expresses anxiety'],
 '{}'),
 
('Connection', 'Belonging and intimacy', 'Community', 'Warm, connected, appreciated',
 ARRAY['Social eating', 'Friend recommendations', 'Community engagement'],
 ARRAY['together', 'family', 'friends', 'everyone loved it', 'brings us together'],
 ARRAY['Loneliness', 'Isolation', 'Feels left out'],
 '{}'),
 
('Status', 'Recognition and respect', 'Validation', 'Proud, validated, recognized',
 ARRAY['Photo-sharing', 'Brand display', 'Trendy choices', 'Public reviews'],
 ARRAY['premium', 'exclusive', 'best', 'impressed', 'special'],
 ARRAY['Inferiority', 'Rejection', 'Not good enough'],
 '{}'),
 
('Growth', 'Mastery and development', 'Competence', 'Accomplished, progressing, capable',
 ARRAY['Skill development', 'Expanding palate', 'Taking on challenges'],
 ARRAY['trying to', 'building my tolerance', 'getting better at', 'learning'],
 ARRAY['Stagnation', 'Boredom', 'Not improving'],
 '{}'),
 
('Freedom', 'Autonomy and exploration', 'Independence', 'Excited, liberated, curious',
 ARRAY['Menu exploration', 'Experimentation', 'Spontaneous choices'],
 ARRAY['new', 'different', 'never tried', 'change it up', 'explore'],
 ARRAY['Constraint', 'Boredom', 'Feels trapped'],
 '{}'),
 
('Purpose', 'Meaning and values', 'Significance', 'Fulfilled, meaningful, aligned',
 ARRAY['Value-driven choices', 'Cause-alignment', 'Principle-based decisions'],
 ARRAY['supports', 'ethical', 'sustainable', 'matters', 'stands for'],
 ARRAY['Meaninglessness', 'Apathy', 'No direction'],
 '{}');

-- Create actor_profiles table
CREATE TABLE actors.actor_profiles (
  actor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  primary_identifier TEXT,
  identifiers JSONB DEFAULT '{}',
  brand_id UUID,
  driver_distribution JSONB DEFAULT '{}',
  dominant_driver TEXT,
  driver_confidence FLOAT DEFAULT 0.0,
  driver_entropy FLOAT DEFAULT 0.0,
  quantum_states JSONB DEFAULT '{}',
  internal_contradictions JSONB[] DEFAULT '{}',
  identity_markers JSONB[] DEFAULT '{}',
  belief_network JSONB DEFAULT '{}',
  first_seen TIMESTAMP DEFAULT NOW(),
  last_updated TIMESTAMP DEFAULT NOW()
);

-- Create actor_updates table
CREATE TABLE actors.actor_updates (
  update_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID REFERENCES actors.actor_profiles(actor_id),
  signal_id UUID,
  update_timestamp TIMESTAMP DEFAULT NOW(),
  driver_distribution_before JSONB,
  driver_distribution_after JSONB,
  quantum_state_changes JSONB,
  contradiction_updates JSONB,
  identity_fragment_updates JSONB,
  entropy_before FLOAT,
  entropy_after FLOAT,
  information_gain FLOAT,
  kl_divergence FLOAT,
  reasoning_chain TEXT
);

-- Create decoder_log table
CREATE TABLE actors.decoder_log (
  log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  signal_id UUID,
  actor_id UUID,
  decoder_output JSONB,
  processing_timestamp TIMESTAMP DEFAULT NOW(),
  model_used TEXT,
  api_cost FLOAT DEFAULT 0.0
);
