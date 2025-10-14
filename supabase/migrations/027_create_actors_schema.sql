-- =====================================================
-- Stage 1: Actor Identification & Matching
-- Migration 027: Create Actors Schema
-- =====================================================

-- Create actors schema
CREATE SCHEMA IF NOT EXISTS actors;

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Table 1: actors.actors
-- Main actor profiles with identity and metadata
-- =====================================================
CREATE TABLE actors.actors (
  actor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Identity Information
  primary_phone TEXT, -- Most reliable identifier
  primary_email TEXT,
  primary_name TEXT,
  
  -- Profile Metadata
  first_seen TIMESTAMPTZ NOT NULL,
  last_seen TIMESTAMPTZ NOT NULL,
  signal_count INTEGER DEFAULT 0,
  signal_sources TEXT[] DEFAULT '{}', -- ['whatsapp', 'reviews', 'orders']
  
  -- Profile Completeness
  profile_completeness FLOAT DEFAULT 0.0 CHECK (profile_completeness >= 0 AND profile_completeness <= 1),
  confidence_in_identity FLOAT DEFAULT 0.0 CHECK (confidence_in_identity >= 0 AND confidence_in_identity <= 1),
  
  -- Identity Quality
  identity_quality TEXT DEFAULT 'unknown', -- 'high', 'medium', 'low', 'unknown'
  verification_status TEXT DEFAULT 'unverified', -- 'verified', 'unverified', 'flagged'
  
  -- Metadata
  created_from TEXT, -- 'whatsapp_message', 'google_review', 'order', etc.
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Raw data for debugging
  raw_metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes for fast lookups
CREATE INDEX idx_actors_primary_phone ON actors.actors(primary_phone);
CREATE INDEX idx_actors_primary_email ON actors.actors(primary_email);
CREATE INDEX idx_actors_primary_name ON actors.actors(primary_name);
CREATE INDEX idx_actors_first_seen ON actors.actors(first_seen);
CREATE INDEX idx_actors_signal_count ON actors.actors(signal_count);

-- =====================================================
-- Table 2: actors.actor_identifiers
-- All known identifiers for an actor (phone, email, name, social handles)
-- =====================================================
CREATE TABLE actors.actor_identifiers (
  identifier_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
  
  -- Identifier Details
  identifier_type TEXT NOT NULL, -- 'phone', 'email', 'name', 'social_handle', 'order_id'
  identifier_value TEXT NOT NULL,
  identifier_confidence FLOAT DEFAULT 1.0 CHECK (identifier_confidence >= 0 AND identifier_confidence <= 1),
  
  -- Source Information
  source_signal_id UUID, -- Links back to original signal
  source_signal_type TEXT, -- 'whatsapp_message', 'google_review', 'order', etc.
  first_seen TIMESTAMPTZ NOT NULL,
  last_seen TIMESTAMPTZ NOT NULL,
  
  -- Verification
  is_verified BOOLEAN DEFAULT FALSE,
  verification_method TEXT, -- 'exact_match', 'fuzzy_match', 'cross_reference'
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_actor_identifiers_actor_id ON actors.actor_identifiers(actor_id);
CREATE INDEX idx_actor_identifiers_type_value ON actors.actor_identifiers(identifier_type, identifier_value);
CREATE INDEX idx_actor_identifiers_source ON actors.actor_identifiers(source_signal_id, source_signal_type);

-- =====================================================
-- Table 3: actors.actor_signals
-- Links signals to actors (many-to-many relationship)
-- =====================================================
CREATE TABLE actors.actor_signals (
  link_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID NOT NULL REFERENCES actors.actors(actor_id) ON DELETE CASCADE,
  
  -- Signal Reference
  signal_id UUID NOT NULL,
  signal_type TEXT NOT NULL, -- 'whatsapp_message', 'google_review', 'order', etc.
  signal_table TEXT NOT NULL, -- 'signals.whatsapp_messages', 'signals.reviews', etc.
  
  -- Linking Information
  link_confidence FLOAT DEFAULT 1.0 CHECK (link_confidence >= 0 AND link_confidence <= 1),
  link_method TEXT NOT NULL, -- 'exact_match', 'fuzzy_match', 'cross_reference'
  link_identifier TEXT, -- Which identifier was used for the match
  
  -- Metadata
  linked_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_actor_signals_actor_id ON actors.actor_signals(actor_id);
CREATE INDEX idx_actor_signals_signal ON actors.actor_signals(signal_id, signal_type);
CREATE INDEX idx_actor_signals_confidence ON actors.actor_signals(link_confidence);

-- =====================================================
-- Table 4: actors.actor_matches
-- Log of actor matching decisions and confidence scores
-- =====================================================
CREATE TABLE actors.actor_matches (
  match_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Match Details
  signal_id UUID NOT NULL,
  signal_type TEXT NOT NULL,
  matched_actor_id UUID REFERENCES actors.actors(actor_id),
  
  -- Match Quality
  match_confidence FLOAT NOT NULL CHECK (match_confidence >= 0 AND match_confidence <= 1),
  match_method TEXT NOT NULL, -- 'exact_phone', 'exact_email', 'fuzzy_name', 'cross_reference'
  match_identifiers TEXT[], -- Which identifiers matched
  
  -- Decision
  decision TEXT NOT NULL, -- 'matched', 'created_new', 'flagged_for_review'
  decision_reason TEXT,
  
  -- Metadata
  processed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_actor_matches_signal ON actors.actor_matches(signal_id, signal_type);
CREATE INDEX idx_actor_matches_actor ON actors.actor_matches(matched_actor_id);
CREATE INDEX idx_actor_matches_confidence ON actors.actor_matches(match_confidence);

-- =====================================================
-- Table 5: actors.actor_merges
-- Log of actor merges when duplicates are discovered
-- =====================================================
CREATE TABLE actors.actor_merges (
  merge_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Merge Details
  primary_actor_id UUID NOT NULL REFERENCES actors.actors(actor_id),
  merged_actor_id UUID NOT NULL REFERENCES actors.actors(actor_id),
  
  -- Merge Information
  merge_reason TEXT NOT NULL,
  merge_confidence FLOAT NOT NULL CHECK (merge_confidence >= 0 AND merge_confidence <= 1),
  merge_identifiers TEXT[], -- Which identifiers caused the merge
  
  -- Metadata
  merged_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_actor_merges_primary ON actors.actor_merges(primary_actor_id);
CREATE INDEX idx_actor_merges_merged ON actors.actor_merges(merged_actor_id);

-- =====================================================
-- Helper Functions
-- =====================================================

-- Function to update actor statistics
CREATE OR REPLACE FUNCTION actors.update_actor_stats(actor_uuid UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE actors.actors 
  SET 
    signal_count = (
      SELECT COUNT(*) 
      FROM actors.actor_signals 
      WHERE actor_id = actor_uuid
    ),
    signal_sources = (
      SELECT ARRAY_AGG(DISTINCT signal_type)
      FROM actors.actor_signals 
      WHERE actor_id = actor_uuid
    ),
    last_seen = (
      SELECT MAX(linked_at)
      FROM actors.actor_signals 
      WHERE actor_id = actor_uuid
    ),
    updated_at = NOW()
  WHERE actor_id = actor_uuid;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate profile completeness
CREATE OR REPLACE FUNCTION actors.calculate_profile_completeness(actor_uuid UUID)
RETURNS FLOAT AS $$
DECLARE
  completeness FLOAT := 0.0;
  has_phone BOOLEAN := FALSE;
  has_email BOOLEAN := FALSE;
  has_name BOOLEAN := FALSE;
  signal_count INTEGER := 0;
BEGIN
  -- Check for identifiers
  SELECT 
    COUNT(*) > 0,
    (SELECT COUNT(*) > 0 FROM actors.actor_identifiers WHERE actor_id = actor_uuid AND identifier_type = 'email'),
    (SELECT COUNT(*) > 0 FROM actors.actor_identifiers WHERE actor_id = actor_uuid AND identifier_type = 'name')
  INTO has_phone, has_email, has_name
  FROM actors.actor_identifiers 
  WHERE actor_id = actor_uuid AND identifier_type = 'phone';
  
  -- Get signal count
  SELECT COUNT(*) INTO signal_count
  FROM actors.actor_signals 
  WHERE actor_id = actor_uuid;
  
  -- Calculate completeness (0-1 scale)
  completeness := 0.0;
  IF has_phone THEN completeness := completeness + 0.3; END IF;
  IF has_email THEN completeness := completeness + 0.2; END IF;
  IF has_name THEN completeness := completeness + 0.2; END IF;
  IF signal_count >= 5 THEN completeness := completeness + 0.3; END IF;
  
  RETURN LEAST(completeness, 1.0);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Comments for documentation
-- =====================================================
COMMENT ON SCHEMA actors IS 'Actor Identification & Matching - Core actor profiles and identity management';
COMMENT ON TABLE actors.actors IS 'Main actor profiles with identity and metadata';
COMMENT ON TABLE actors.actor_identifiers IS 'All known identifiers for an actor (phone, email, name, social handles)';
COMMENT ON TABLE actors.actor_signals IS 'Links signals to actors (many-to-many relationship)';
COMMENT ON TABLE actors.actor_matches IS 'Log of actor matching decisions and confidence scores';
COMMENT ON TABLE actors.actor_merges IS 'Log of actor merges when duplicates are discovered';
