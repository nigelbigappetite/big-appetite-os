-- =====================================================
-- SEED DATA FOR BIG APPETITE OS - WING SHACK
-- =====================================================
-- This file contains minimal sample data to demonstrate the system

-- =====================================================
-- BRAND SETUP
-- =====================================================

-- Wing Shack brand
INSERT INTO core.brands (brand_id, brand_name, brand_slug, description, is_active, created_at, updated_at) VALUES
('a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Wing Shack', 'wing-shack', 'Sample brand for Big Appetite OS', true, NOW(), NOW())
ON CONFLICT (brand_id) DO NOTHING;

-- =====================================================
-- SAMPLE ACTORS (CUSTOMERS)
-- =====================================================

-- Sarah - Spice Lover
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'sarah.johnson@email.com', 'email', NOW() - INTERVAL '6 months', NOW() - INTERVAL '2 days', true)
ON CONFLICT (actor_id) DO NOTHING;

-- Mike - Health Conscious
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'mike.chen@email.com', 'email', NOW() - INTERVAL '4 months', NOW() - INTERVAL '1 week', true)
ON CONFLICT (actor_id) DO NOTHING;

-- Lisa - Value Seeker
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440102'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'lisa.smith@email.com', 'email', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 days', true)
ON CONFLICT (actor_id) DO NOTHING;

-- =====================================================
-- SAMPLE COHORTS
-- =====================================================

-- Spice Lovers cohort
INSERT INTO cohorts.cohorts (cohort_id, brand_id, cohort_name, cohort_type, cohort_status, discovered_at, discovery_algorithm, cohort_signature, member_count, stability_score) VALUES
('b1c2d3e4-f5g6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Spice Lovers', 'behavioral', 'active', NOW() - INTERVAL '1 month', 'kmeans', '{"preferences": ["spicy_food"], "behavior": ["frequent_orders"], "demographics": ["young_adults"]}'::jsonb, 1, 0.85)
ON CONFLICT (cohort_id) DO NOTHING;

-- Health Conscious cohort
INSERT INTO cohorts.cohorts (cohort_id, brand_id, cohort_name, cohort_type, cohort_status, discovered_at, discovery_algorithm, cohort_signature, member_count, stability_score) VALUES
('c1d2e3f4-g5h6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Health Conscious', 'behavioral', 'active', NOW() - INTERVAL '1 month', 'kmeans', '{"preferences": ["healthy_options"], "behavior": ["asks_nutrition"], "demographics": ["middle_aged"]}'::jsonb, 1, 0.80)
ON CONFLICT (cohort_id) DO NOTHING;

-- =====================================================
-- COHORT MEMBERSHIPS
-- =====================================================

INSERT INTO cohorts.actor_cohort_membership (actor_id, cohort_id, membership_type, membership_confidence, joined_at, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'b1c2d3e4-f5g6-7890-1234-567890abcdef'::UUID, 'primary', 0.9, NOW() - INTERVAL '1 month', true),
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'c1d2e3f4-g5h6-7890-1234-567890abcdef'::UUID, 'primary', 0.85, NOW() - INTERVAL '1 month', true)
ON CONFLICT (actor_id, cohort_id) DO NOTHING;