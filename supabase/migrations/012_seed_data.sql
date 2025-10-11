-- =====================================================
-- SEED DATA FOR BIG APPETITE OS - WING SHACK
-- =====================================================
-- This file contains sample data to demonstrate the system
-- with realistic Wing Shack customer profiles and interactions

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
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'sarah.johnson@email.com', 'email', NOW() - INTERVAL '6 months', NOW() - INTERVAL '2 days', true, '{"notes": "Loves spicy wings, orders weekly"}'::jsonb)
ON CONFLICT (actor_id) DO NOTHING;

-- Mike - Health Conscious
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'mike.chen@email.com', 'email', NOW() - INTERVAL '4 months', NOW() - INTERVAL '1 week', true, '{"notes": "Prefers grilled options, asks about nutrition"}'::jsonb)
ON CONFLICT (actor_id) DO NOTHING;

-- Lisa - Value Seeker
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440102'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'lisa.smith@email.com', 'email', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 days', true, '{"notes": "Always looks for deals and promotions"}'::jsonb)
ON CONFLICT (actor_id) DO NOTHING;

-- Tom - Social Butterfly
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440103'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'tom.wilson@email.com', 'email', NOW() - INTERVAL '8 months', NOW() - INTERVAL '1 day', true, '{"notes": "Orders for groups, very social"}'::jsonb)
ON CONFLICT (actor_id) DO NOTHING;

-- Emma - Occasional Customer
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, primary_identifier_type, first_seen_at, last_seen_at, is_active, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440104'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'emma.davis@email.com', 'email', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 weeks', true, '{"notes": "Orders occasionally, prefers delivery"}'::jsonb)
ON CONFLICT (actor_id) DO NOTHING;

-- =====================================================
-- SAMPLE SIGNALS
-- =====================================================

-- WhatsApp messages
INSERT INTO signals.whatsapp_messages (signal_id, raw_content, processed_content, actor_id, actor_identifier, brand_id, received_at, processing_status, sender_phone_number, message_text, message_direction) VALUES
('sig_001'::UUID, '{"raw": "Can I get extra spicy wings?"}'::jsonb, '{"intent": "order_inquiry", "spice_level": "extra_spicy"}'::jsonb, '550e8400-e29b-41d4-a716-446655440100'::UUID, '+1234567890', 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, NOW() - INTERVAL '2 days', 'processed', '+1234567890', 'Can I get extra spicy wings?', 'inbound'),
('sig_002'::UUID, '{"raw": "What are your healthiest options?"}'::jsonb, '{"intent": "nutrition_inquiry", "health_focus": true}'::jsonb, '550e8400-e29b-41d4-a716-446655440101'::UUID, '+1234567891', 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, NOW() - INTERVAL '1 week', 'processed', '+1234567891', 'What are your healthiest options?', 'inbound')
ON CONFLICT (signal_id) DO NOTHING;

-- Reviews
INSERT INTO signals.reviews (signal_id, raw_content, processed_content, actor_id, actor_identifier, brand_id, received_at, processing_status, review_text, rating, review_source) VALUES
('sig_003'::UUID, '{"raw": "Amazing wings! So spicy!"}'::jsonb, '{"sentiment": "positive", "spice_mention": true}'::jsonb, '550e8400-e29b-41d4-a716-446655440100'::UUID, 'sarah.johnson@email.com', 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, NOW() - INTERVAL '3 days', 'processed', 'Amazing wings! So spicy!', 5, 'google'),
('sig_004'::UUID, '{"raw": "Good but too expensive"}'::jsonb, '{"sentiment": "mixed", "price_concern": true}'::jsonb, '550e8400-e29b-41d4-a716-446655440102'::UUID, 'lisa.smith@email.com', 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, NOW() - INTERVAL '1 week', 'processed', 'Good but too expensive', 3, 'google')
ON CONFLICT (signal_id) DO NOTHING;

-- Order history
INSERT INTO signals.order_history (signal_id, raw_content, processed_content, actor_id, actor_identifier, brand_id, received_at, processing_status, order_id, order_total, order_items, order_status) VALUES
('sig_005'::UUID, '{"raw": "Order #12345"}'::jsonb, '{"items": ["spicy_wings", "fries"], "total": 24.99}'::jsonb, '550e8400-e29b-41d4-a716-446655440100'::UUID, 'sarah.johnson@email.com', 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, NOW() - INTERVAL '2 days', 'processed', 'ORD-12345', 24.99, '["spicy_wings", "fries"]'::jsonb, 'completed'),
('sig_006'::UUID, '{"raw": "Order #12346"}'::jsonb, '{"items": ["grilled_wings", "salad"], "total": 18.99}'::jsonb, '550e8400-e29b-41d4-a716-446655440101'::UUID, 'mike.chen@email.com', 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, NOW() - INTERVAL '1 week', 'processed', 'ORD-12346', 18.99, '["grilled_wings", "salad"]'::jsonb, 'completed')
ON CONFLICT (signal_id) DO NOTHING;

-- =====================================================
-- SAMPLE COHORTS
-- =====================================================

-- Spice Lovers cohort
INSERT INTO cohorts.cohorts (cohort_id, brand_id, cohort_name, cohort_type, cohort_status, discovered_at, discovery_algorithm, cohort_signature, member_count, stability_score, metadata) VALUES
('cohort_001'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Spice Lovers', 'behavioral', 'active', NOW() - INTERVAL '1 month', 'kmeans', '{"preferences": ["spicy_food"], "behavior": ["frequent_orders"], "demographics": ["young_adults"]}'::jsonb, 1, 0.85, '{"description": "Customers who prefer spicy options"}'::jsonb)
ON CONFLICT (cohort_id) DO NOTHING;

-- Health Conscious cohort
INSERT INTO cohorts.cohorts (cohort_id, brand_id, cohort_name, cohort_type, cohort_status, discovered_at, discovery_algorithm, cohort_signature, member_count, stability_score, metadata) VALUES
('cohort_002'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Health Conscious', 'behavioral', 'active', NOW() - INTERVAL '1 month', 'kmeans', '{"preferences": ["healthy_options"], "behavior": ["asks_nutrition"], "demographics": ["middle_aged"]}'::jsonb, 1, 0.80, '{"description": "Customers focused on healthy eating"}'::jsonb)
ON CONFLICT (cohort_id) DO NOTHING;

-- =====================================================
-- COHORT MEMBERSHIPS
-- =====================================================

INSERT INTO cohorts.actor_cohort_membership (actor_id, cohort_id, membership_type, membership_confidence, joined_at, is_active, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'cohort_001'::UUID, 'primary', 0.9, NOW() - INTERVAL '1 month', true, '{"reason": "Frequent spicy wing orders"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'cohort_002'::UUID, 'primary', 0.85, NOW() - INTERVAL '1 month', true, '{"reason": "Asks about nutrition, orders grilled options"}'::jsonb)
ON CONFLICT (actor_id, cohort_id) DO NOTHING;

-- =====================================================
-- SAMPLE STIMULI
-- =====================================================

-- Spicy wings promotion
INSERT INTO stimuli.stimuli (stimulus_id, brand_id, stimulus_type, name, content, target_cohort_id, confidence_in_choice, created_at) VALUES
('stim_001'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'offer', 'Extra Spicy Wings Deal', '{"title": "Extra Spicy Wings Deal", "description": "20% off all spicy wings this week!", "discount": 20, "valid_until": "2024-02-15"}'::jsonb, 'cohort_001'::UUID, 0.9, NOW())
ON CONFLICT (stimulus_id) DO NOTHING;

-- =====================================================
-- SAMPLE OUTCOMES
-- =====================================================

-- Sarah's response to spicy wings deal
INSERT INTO outcomes.outcomes (outcome_id, brand_id, stimulus_id, actor_id, outcome_type, outcome_value, occurred_at, metadata) VALUES
('outcome_001'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'stim_001'::UUID, '550e8400-e29b-41d4-a716-446655440100'::UUID, 'purchase', 24.99, NOW() - INTERVAL '1 day', '{"order_id": "ORD-12347", "items": ["spicy_wings"], "discount_applied": true}'::jsonb)
ON CONFLICT (outcome_id) DO NOTHING;