-- =====================================================
-- SEED DATA FOR WORKING CORE - WING SHACK
-- =====================================================
-- This file contains sample data that matches the working core schema

-- =====================================================
-- BRAND SETUP
-- =====================================================

-- Wing Shack brand
INSERT INTO core.brands (brand_id, brand_name, brand_slug, description, is_active) VALUES
('a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Wing Shack', 'wing-shack', 'Sample brand for Big Appetite OS', true)
ON CONFLICT (brand_id) DO NOTHING;

-- =====================================================
-- SAMPLE USERS
-- =====================================================

-- Admin user for Wing Shack
INSERT INTO core.users (user_id, brand_id, email, full_name, is_active) VALUES
('u1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'admin@wingshack.com', 'Wing Shack Admin', true)
ON CONFLICT (user_id) DO NOTHING;

-- =====================================================
-- SAMPLE ACTORS (CUSTOMERS)
-- =====================================================

-- Sarah - Spice Lover
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, identifier_type, is_active, first_seen_at, last_seen_at) VALUES
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'sarah.johnson@email.com', 'email', true, NOW() - INTERVAL '6 months', NOW() - INTERVAL '2 days')
ON CONFLICT (actor_id) DO NOTHING;

-- Mike - Health Conscious
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, identifier_type, is_active, first_seen_at, last_seen_at) VALUES
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'mike.chen@email.com', 'email', true, NOW() - INTERVAL '4 months', NOW() - INTERVAL '1 week')
ON CONFLICT (actor_id) DO NOTHING;

-- Lisa - Value Seeker
INSERT INTO actors.actors (actor_id, brand_id, primary_identifier, identifier_type, is_active, first_seen_at, last_seen_at) VALUES
('550e8400-e29b-41d4-a716-446655440102'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'lisa.smith@email.com', 'email', true, NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 days')
ON CONFLICT (actor_id) DO NOTHING;

-- =====================================================
-- SAMPLE WHATSAPP MESSAGES
-- =====================================================

-- Sarah asking about spicy wings
INSERT INTO signals.whatsapp_messages (signal_id, brand_id, sender_phone, message_text, message_direction, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('w1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, '+1234567890', 'Can I get extra spicy wings?', 'inbound', '550e8400-e29b-41d4-a716-446655440100'::UUID, 'sarah.johnson@email.com', NOW() - INTERVAL '2 days', 'processed', '{"raw": "Can I get extra spicy wings?"}', '{"intent": "order_inquiry", "spice_level": "extra_spicy"}')
ON CONFLICT (signal_id) DO NOTHING;

-- Mike asking about healthy options
INSERT INTO signals.whatsapp_messages (signal_id, brand_id, sender_phone, message_text, message_direction, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('w2b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, '+1234567891', 'What are your healthiest options?', 'inbound', '550e8400-e29b-41d4-a716-446655440101'::UUID, 'mike.chen@email.com', NOW() - INTERVAL '1 week', 'processed', '{"raw": "What are your healthiest options?"}', '{"intent": "nutrition_inquiry", "health_focus": true}')
ON CONFLICT (signal_id) DO NOTHING;

-- =====================================================
-- SAMPLE REVIEWS
-- =====================================================

-- Sarah's positive review
INSERT INTO signals.reviews (signal_id, brand_id, review_text, rating, review_source, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('r1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Amazing wings! So spicy and delicious!', 5, 'google', '550e8400-e29b-41d4-a716-446655440100'::UUID, 'sarah.johnson@email.com', NOW() - INTERVAL '3 days', 'processed', '{"raw": "Amazing wings! So spicy and delicious!"}', '{"sentiment": "positive", "spice_mention": true}')
ON CONFLICT (signal_id) DO NOTHING;

-- Lisa's mixed review
INSERT INTO signals.reviews (signal_id, brand_id, review_text, rating, review_source, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('r2b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'Good wings but too expensive for the portion size', 3, 'google', '550e8400-e29b-41d4-a716-446655440102'::UUID, 'lisa.smith@email.com', NOW() - INTERVAL '1 week', 'processed', '{"raw": "Good wings but too expensive for the portion size"}', '{"sentiment": "mixed", "price_concern": true}')
ON CONFLICT (signal_id) DO NOTHING;

-- =====================================================
-- SAMPLE ORDERS
-- =====================================================

-- Sarah's spicy wings order
INSERT INTO signals.orders (signal_id, brand_id, order_id, order_total, order_items, order_status, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('o1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'ORD-12345', 24.99, '["spicy_wings", "fries"]'::jsonb, 'completed', '550e8400-e29b-41d4-a716-446655440100'::UUID, 'sarah.johnson@email.com', NOW() - INTERVAL '2 days', 'processed', '{"raw": "Order #12345"}', '{"items": ["spicy_wings", "fries"], "total": 24.99}')
ON CONFLICT (signal_id) DO NOTHING;

-- Mike's healthy order
INSERT INTO signals.orders (signal_id, brand_id, order_id, order_total, order_items, order_status, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('o2b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'ORD-12346', 18.99, '["grilled_wings", "salad"]'::jsonb, 'completed', '550e8400-e29b-41d4-a716-446655440101'::UUID, 'mike.chen@email.com', NOW() - INTERVAL '1 week', 'processed', '{"raw": "Order #12346"}', '{"items": ["grilled_wings", "salad"], "total": 18.99}')
ON CONFLICT (signal_id) DO NOTHING;

-- =====================================================
-- SAMPLE WEB BEHAVIOR
-- =====================================================

-- Sarah viewing spicy wings page
INSERT INTO signals.web_behavior (signal_id, brand_id, page_url, action_type, session_id, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('b1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'https://wingshack.com/menu/spicy-wings', 'page_view', 'sess_123', '550e8400-e29b-41d4-a716-446655440100'::UUID, 'sarah.johnson@email.com', NOW() - INTERVAL '1 day', 'processed', '{"raw": "page_view"}', '{"page": "spicy_wings", "duration": 45}')
ON CONFLICT (signal_id) DO NOTHING;

-- Mike viewing nutrition info
INSERT INTO signals.web_behavior (signal_id, brand_id, page_url, action_type, session_id, actor_id, actor_identifier, received_at, processing_status, raw_content, processed_content) VALUES
('b2b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'a1b2c3d4-e5f6-7890-1234-567890abcdef'::UUID, 'https://wingshack.com/nutrition', 'page_view', 'sess_124', '550e8400-e29b-41d4-a716-446655440101'::UUID, 'mike.chen@email.com', NOW() - INTERVAL '2 days', 'processed', '{"raw": "page_view"}', '{"page": "nutrition", "duration": 120}')
ON CONFLICT (signal_id) DO NOTHING;
