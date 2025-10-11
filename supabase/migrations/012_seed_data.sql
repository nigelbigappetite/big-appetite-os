-- =====================================================
-- SEED DATA - Wing Shack Sample Data
-- =====================================================
-- This migration creates realistic sample data for Wing Shack to demonstrate
-- the full system working, including the complete signal → actor → cohort → stimulus → outcome loop.

-- =====================================================
-- BRAND SETUP
-- =====================================================

-- Insert Wing Shack brand
INSERT INTO core.brands (
    brand_id,
    brand_name,
    brand_slug,
    description,
    primary_phone,
    primary_email,
    website_url,
    timezone,
    currency,
    language,
    settings,
    is_active,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'Wing Shack',
    'wing-shack',
    'Brooklyn''s premier destination for authentic buffalo wings and craft beer',
    '+1-555-WINGS',
    'hello@wingshack.com',
    'https://wingshack.com',
    'America/New_York',
    'USD',
    'en',
    '{"cuisine_type": "American", "specialty": "Buffalo Wings", "target_demographic": "Young Adults", "price_range": "$$"}',
    true,
    NOW()
);

-- Insert sample user
INSERT INTO core.users (
    user_id,
    brand_id,
    email,
    full_name,
    role,
    permissions,
    is_active,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'admin@wingshack.com',
    'Wing Shack Admin',
    'owner',
    '{"all": true}',
    true,
    NOW()
);

-- =====================================================
-- SITES SETUP
-- =====================================================

-- Insert Wing Shack locations
INSERT INTO ops.sites (
    site_id,
    brand_id,
    site_name,
    site_code,
    site_type,
    address_line1,
    city,
    state_province,
    postal_code,
    country,
    latitude,
    longitude,
    phone,
    email,
    timezone,
    max_capacity,
    delivery_radius,
    pickup_available,
    delivery_available,
    dine_in_available,
    is_active,
    opening_date,
    created_at
) VALUES 
(
    '550e8400-e29b-41d4-a716-446655440010'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'Wing Shack Brooklyn',
    'WS-BK',
    'physical',
    '123 Flavor Street',
    'Brooklyn',
    'NY',
    '11201',
    'USA',
    40.6782,
    -73.9442,
    '+1-555-WINGS',
    'brooklyn@wingshack.com',
    'America/New_York',
    50,
    5,
    true,
    true,
    true,
    true,
    '2023-01-15',
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440011'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'Wing Shack Manhattan',
    'WS-MN',
    'physical',
    '456 Spice Avenue',
    'New York',
    'NY',
    '10001',
    'USA',
    40.7505,
    -73.9934,
    '+1-555-WINGS',
    'manhattan@wingshack.com',
    'America/New_York',
    75,
    3,
    true,
    true,
    true,
    true,
    '2023-06-01',
    NOW()
);

-- =====================================================
-- SAMPLE ACTORS (5-10 diverse profiles)
-- =====================================================

-- Actor 1: Spice Lover Sarah
INSERT INTO actors.actors (
    actor_id,
    brand_id,
    primary_identifier,
    primary_identifier_type,
    identifiers,
    is_active,
    is_verified,
    verification_method,
    first_seen_at,
    last_seen_at,
    total_signals,
    data_quality_score,
    profile_completeness,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440100'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    '+1-555-0001',
    'phone',
    '{"email": "sarah.spice@email.com", "social_handle": "@spicelover_sarah"}',
    true,
    true,
    'phone',
    NOW() - INTERVAL '6 months',
    NOW() - INTERVAL '2 days',
    15,
    0.9,
    0.85,
    NOW()
);

-- Actor 2: Health-Conscious Mike
INSERT INTO actors.actors (
    actor_id,
    brand_id,
    primary_identifier,
    primary_identifier_type,
    identifiers,
    is_active,
    is_verified,
    verification_method,
    first_seen_at,
    last_seen_at,
    total_signals,
    data_quality_score,
    profile_completeness,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440101'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    '+1-555-0002',
    'phone',
    '{"email": "mike.healthy@email.com", "social_handle": "@healthy_mike"}',
    true,
    true,
    'email',
    NOW() - INTERVAL '4 months',
    NOW() - INTERVAL '1 week',
    8,
    0.7,
    0.6,
    NOW()
);

-- Actor 3: Value Seeker Lisa
INSERT INTO actors.actors (
    actor_id,
    brand_id,
    primary_identifier,
    primary_identifier_type,
    identifiers,
    is_active,
    is_verified,
    verification_method,
    first_seen_at,
    last_seen_at,
    total_signals,
    data_quality_score,
    profile_completeness,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440102'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    '+1-555-0003',
    'phone',
    '{"email": "lisa.value@email.com", "social_handle": "@value_lisa"}',
    true,
    false,
    'phone',
    NOW() - INTERVAL '2 months',
    NOW() - INTERVAL '3 days',
    12,
    0.6,
    0.5,
    NOW()
);

-- Actor 4: Social Butterfly Tom
INSERT INTO actors.actors (
    actor_id,
    brand_id,
    primary_identifier,
    primary_identifier_type,
    identifiers,
    is_active,
    is_verified,
    verification_method,
    first_seen_at,
    last_seen_at,
    total_signals,
    data_quality_score,
    profile_completeness,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440103'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    '+1-555-0004',
    'phone',
    '{"email": "tom.social@email.com", "social_handle": "@social_tom"}',
    true,
    true,
    'social',
    NOW() - INTERVAL '8 months',
    NOW() - INTERVAL '1 day',
    25,
    0.8,
    0.9,
    NOW()
);

-- Actor 5: Occasional Customer Emma
INSERT INTO actors.actors (
    actor_id,
    brand_id,
    primary_identifier,
    primary_identifier_type,
    identifiers,
    is_active,
    is_verified,
    verification_method,
    first_seen_at,
    last_seen_at,
    total_signals,
    data_quality_score,
    profile_completeness,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440104'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    '+1-555-0005',
    'phone',
    '{"email": "emma.occasional@email.com"}',
    true,
    false,
    'phone',
    NOW() - INTERVAL '3 months',
    NOW() - INTERVAL '2 weeks',
    3,
    0.4,
    0.3,
    NOW()
);

-- =====================================================
-- ACTOR DEMOGRAPHICS AND BELIEFS
-- =====================================================

-- Sarah's demographics (Spice Lover)
INSERT INTO actors.actor_demographics (actor_id, attribute_name, attribute_value, confidence, evidence_count, last_updated_at, source_signals, source_weights) VALUES
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'age_range', '{"min": 25, "max": 35}', 0.9, 8, NOW(), '["sig_001", "sig_002", "sig_003"]', '[0.3, 0.4, 0.3]'),
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'gender', 'female', 0.95, 10, NOW(), '["sig_001", "sig_002", "sig_003", "sig_004"]', '[0.25, 0.25, 0.25, 0.25]'),
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'location', '{"city": "Brooklyn", "state": "NY", "zip": "11201"}', 0.85, 6, NOW(), '["sig_001", "sig_002", "sig_003"]', '[0.33, 0.33, 0.34]'),
('550e8400-e29b-41d4-a716-446655440100'::UUID, 'income_level', 'middle', 0.7, 4, NOW(), '["sig_001", "sig_002"]', '[0.5, 0.5]');

-- Mike's demographics (Health-Conscious)
INSERT INTO actors.actor_demographics (actor_id, attribute_name, attribute_value, confidence, evidence_count, last_updated_at, source_signals, source_weights) VALUES
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'age_range', '{"min": 30, "max": 40}', 0.8, 5, NOW(), '["sig_005", "sig_006"]', '[0.6, 0.4]'),
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'gender', 'male', 0.9, 6, NOW(), '["sig_005", "sig_006", "sig_007"]', '[0.33, 0.33, 0.34]'),
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'location', '{"city": "Manhattan", "state": "NY", "zip": "10001"}', 0.75, 4, NOW(), '["sig_005", "sig_006"]', '[0.5, 0.5]'),
('550e8400-e29b-41d4-a716-446655440101'::UUID, 'income_level', 'upper_middle', 0.6, 3, NOW(), '["sig_005"]', '[1.0]');

-- Lisa's demographics (Value Seeker)
INSERT INTO actors.actor_demographics (actor_id, attribute_name, attribute_value, confidence, evidence_count, last_updated_at, source_signals, source_weights) VALUES
('550e8400-e29b-41d4-a716-446655440102'::UUID, 'age_range', '{"min": 22, "max": 28}', 0.7, 4, NOW(), '["sig_008", "sig_009"]', '[0.5, 0.5]'),
('550e8400-e29b-41d4-a716-446655440102'::UUID, 'gender', 'female', 0.8, 5, NOW(), '["sig_008", "sig_009", "sig_010"]', '[0.33, 0.33, 0.34]'),
('550e8400-e29b-41d4-a716-446655440102'::UUID, 'location', '{"city": "Brooklyn", "state": "NY", "zip": "11215"}', 0.6, 3, NOW(), '["sig_008", "sig_009"]', '[0.5, 0.5]'),
('550e8400-e29b-41d4-a716-446655440102'::UUID, 'income_level', 'lower_middle', 0.5, 2, NOW(), '["sig_008"]', '[1.0]');

-- Tom's demographics (Social Butterfly)
INSERT INTO actors.actor_demographics (actor_id, attribute_name, attribute_value, confidence, evidence_count, last_updated_at, source_signals, source_weights) VALUES
('550e8400-e29b-41d4-a716-446655440103'::UUID, 'age_range', '{"min": 28, "max": 35}', 0.9, 12, NOW(), '["sig_011", "sig_012", "sig_013", "sig_014"]', '[0.25, 0.25, 0.25, 0.25]'),
('550e8400-e29b-41d4-a716-446655440103'::UUID, 'gender', 'male', 0.95, 15, NOW(), '["sig_011", "sig_012", "sig_013", "sig_014", "sig_015"]', '[0.2, 0.2, 0.2, 0.2, 0.2]'),
('550e8400-e29b-41d4-a716-446655440103'::UUID, 'location', '{"city": "Manhattan", "state": "NY", "zip": "10003"}', 0.85, 8, NOW(), '["sig_011", "sig_012", "sig_013", "sig_014"]', '[0.25, 0.25, 0.25, 0.25]'),
('550e8400-e29b-41d4-a716-446655440103'::UUID, 'income_level', 'middle', 0.8, 6, NOW(), '["sig_011", "sig_012", "sig_013"]', '[0.33, 0.33, 0.34]');

-- Emma's demographics (Occasional Customer)
INSERT INTO actors.actor_demographics (actor_id, attribute_name, attribute_value, confidence, evidence_count, last_updated_at, source_signals, source_weights) VALUES
('550e8400-e29b-41d4-a716-446655440104'::UUID, 'age_range', '{"min": 35, "max": 45}', 0.6, 2, NOW(), '["sig_016", "sig_017"]', '[0.5, 0.5]'),
('550e8400-e29b-41d4-a716-446655440104'::UUID, 'gender', 'female', 0.7, 3, NOW(), '["sig_016", "sig_017", "sig_018"]', '[0.33, 0.33, 0.34]'),
('550e8400-e29b-41d4-a716-446655440104'::UUID, 'location', '{"city": "Brooklyn", "state": "NY", "zip": "11220"}', 0.5, 2, NOW(), '["sig_016", "sig_017"]', '[0.5, 0.5]'),
('550e8400-e29b-41d4-a716-446655440104'::UUID, 'income_level', 'middle', 0.4, 1, NOW(), '["sig_016"]', '[1.0]');

-- =====================================================
-- SAMPLE SIGNALS (20-30 mixed signals)
-- =====================================================

-- WhatsApp Messages (5-7)
INSERT INTO signals.signals_base (signal_id, signal_type, brand_id, raw_content, processed_content, actor_id, actor_identifier, actor_identifier_type, received_at, processed_at, processing_status, confidence_in_matching, source_platform, source_id, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440200'::UUID, 'whatsapp_message', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Hey! Do you have any extra spicy wings today? I need something that will make me sweat! 🔥', '{"intent": "inquiry", "sentiment": "positive", "urgency": "high", "spice_preference": "extra_spicy"}', '550e8400-e29b-41d4-a716-446655440100'::UUID, '+1-555-0001', 'phone', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', 'completed', 0.95, 'whatsapp', 'wa_msg_001', '{"message_id": "wa_msg_001", "conversation_id": "conv_001"}'),
('550e8400-e29b-41d4-a716-446655440201'::UUID, 'whatsapp_message', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'What are your healthiest wing options? Trying to stay on my diet but craving wings', '{"intent": "inquiry", "sentiment": "neutral", "health_conscious": true, "dietary_restrictions": "healthy"}', '550e8400-e29b-41d4-a716-446655440101'::UUID, '+1-555-0002', 'phone', NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week', 'completed', 0.9, 'whatsapp', 'wa_msg_002', '{"message_id": "wa_msg_002", "conversation_id": "conv_002"}'),
('550e8400-e29b-41d4-a716-446655440202'::UUID, 'whatsapp_message', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Any deals today? Looking for a good value meal', '{"intent": "inquiry", "sentiment": "neutral", "price_sensitive": true, "deal_seeking": true}', '550e8400-e29b-41d4-a716-446655440102'::UUID, '+1-555-0003', 'phone', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', 'completed', 0.85, 'whatsapp', 'wa_msg_003', '{"message_id": "wa_msg_003", "conversation_id": "conv_003"}'),
('550e8400-e29b-41d4-a716-446655440203'::UUID, 'whatsapp_message', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Hey! Can I get a table for 6 people tonight? We want to try all your wing flavors!', '{"intent": "reservation", "sentiment": "positive", "group_size": 6, "social_dining": true, "exploration": true}', '550e8400-e29b-41d4-a716-446655440103'::UUID, '+1-555-0004', 'phone', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', 'completed', 0.9, 'whatsapp', 'wa_msg_004', '{"message_id": "wa_msg_004", "conversation_id": "conv_004"}'),
('550e8400-e29b-41d4-a716-446655440204'::UUID, 'whatsapp_message', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Do you deliver to Bay Ridge?', '{"intent": "inquiry", "sentiment": "neutral", "delivery_inquiry": true, "location": "Bay Ridge"}', '550e8400-e29b-41d4-a716-446655440104'::UUID, '+1-555-0005', 'phone', NOW() - INTERVAL '2 weeks', NOW() - INTERVAL '2 weeks', 'completed', 0.8, 'whatsapp', 'wa_msg_005', '{"message_id": "wa_msg_005", "conversation_id": "conv_005"}');

-- Reviews (5-7)
INSERT INTO signals.signals_base (signal_id, signal_type, brand_id, raw_content, processed_content, actor_id, actor_identifier, actor_identifier_type, received_at, processed_at, processing_status, confidence_in_matching, source_platform, source_id, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440205'::UUID, 'review', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Best wings in Brooklyn! The extra hot sauce is incredible 🔥🔥🔥', '{"rating": 5, "sentiment": "positive", "spice_rating": "extra_hot", "location_mention": "Brooklyn"}', '550e8400-e29b-41d4-a716-446655440100'::UUID, 'sarah.spice@email.com', 'email', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month', 'completed', 0.9, 'google', 'google_rev_001', '{"review_id": "google_rev_001", "platform_url": "https://google.com/reviews/001"}'),
('550e8400-e29b-41d4-a716-446655440206'::UUID, 'review', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Good wings but wish they had more healthy options. The grilled wings were decent though.', '{"rating": 3, "sentiment": "neutral", "health_focus": true, "grilled_preference": true}', '550e8400-e29b-41d4-a716-446655440101'::UUID, 'mike.healthy@email.com', 'email', NOW() - INTERVAL '2 weeks', NOW() - INTERVAL '2 weeks', 'completed', 0.85, 'yelp', 'yelp_rev_001', '{"review_id": "yelp_rev_001", "platform_url": "https://yelp.com/reviews/001"}'),
('550e8400-e29b-41d4-a716-446655440207'::UUID, 'review', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Great value for money! The combo deals are amazing and portions are huge.', '{"rating": 4, "sentiment": "positive", "value_focus": true, "portion_size": "large", "deal_mention": true}', '550e8400-e29b-41d4-a716-446655440102'::UUID, 'lisa.value@email.com', 'email', NOW() - INTERVAL '3 weeks', NOW() - INTERVAL '3 weeks', 'completed', 0.8, 'google', 'google_rev_002', '{"review_id": "google_rev_002", "platform_url": "https://google.com/reviews/002"}'),
('550e8400-e29b-41d4-a716-446655440208'::UUID, 'review', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Perfect spot for group dinners! Great atmosphere and the staff is super friendly. Will definitely be back!', '{"rating": 5, "sentiment": "positive", "group_dining": true, "atmosphere": "positive", "staff": "friendly", "return_intent": true}', '550e8400-e29b-41d4-a716-446655440103'::UUID, 'tom.social@email.com', 'email', NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week', 'completed', 0.9, 'facebook', 'fb_rev_001', '{"review_id": "fb_rev_001", "platform_url": "https://facebook.com/reviews/001"}'),
('550e8400-e29b-41d4-a716-446655440209'::UUID, 'review', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Decent wings but nothing special. Service was slow.', '{"rating": 2, "sentiment": "negative", "service_issue": true, "mediocre_rating": true}', '550e8400-e29b-41d4-a716-446655440104'::UUID, 'emma.occasional@email.com', 'email', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month', 'completed', 0.7, 'google', 'google_rev_003', '{"review_id": "google_rev_003", "platform_url": "https://google.com/reviews/003"}');

-- Order History (8-10)
INSERT INTO signals.signals_base (signal_id, signal_type, brand_id, raw_content, processed_content, actor_id, actor_identifier, actor_identifier_type, received_at, processed_at, processing_status, confidence_in_matching, source_platform, source_id, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440210'::UUID, 'order', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Order #WS-001: 12 Extra Hot Wings, 6 Honey BBQ Wings, 2 Sides of Ranch, 2 Beers', '{"order_items": [{"item": "Extra Hot Wings", "quantity": 12, "spice_level": "extra_hot"}, {"item": "Honey BBQ Wings", "quantity": 6, "spice_level": "mild"}, {"item": "Ranch", "quantity": 2}, {"item": "Beer", "quantity": 2}], "total_items": 22, "spice_preference": "mixed", "alcohol": true}', '550e8400-e29b-41d4-a716-446655440100'::UUID, '+1-555-0001', 'phone', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', 'completed', 0.95, 'pos_system', 'order_001', '{"order_number": "WS-001", "site_id": "550e8400-e29b-41d4-a716-446655440010"}'),
('550e8400-e29b-41d4-a716-446655440211'::UUID, 'order', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Order #WS-002: 6 Grilled Wings, Side Salad, Water', '{"order_items": [{"item": "Grilled Wings", "quantity": 6, "cooking_method": "grilled"}, {"item": "Side Salad", "quantity": 1}, {"item": "Water", "quantity": 1}], "total_items": 8, "health_conscious": true, "grilled_preference": true}', '550e8400-e29b-41d4-a716-446655440101'::UUID, '+1-555-0002', 'phone', NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week', 'completed', 0.9, 'pos_system', 'order_002', '{"order_number": "WS-002", "site_id": "550e8400-e29b-41d4-a716-446655440011"}'),
('550e8400-e29b-41d4-a716-446655440212'::UUID, 'order', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Order #WS-003: Wing Combo Deal - 20 Wings (Mixed), 2 Sides, 2 Drinks', '{"order_items": [{"item": "Wing Combo Deal", "quantity": 1, "wings": 20, "sides": 2, "drinks": 2}], "total_items": 1, "combo_deal": true, "value_seeking": true}', '550e8400-e29b-41d4-a716-446655440102'::UUID, '+1-555-0003', 'phone', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', 'completed', 0.85, 'pos_system', 'order_003', '{"order_number": "WS-003", "site_id": "550e8400-e29b-41d4-a716-446655440010"}'),
('550e8400-e29b-41d4-a716-446655440213'::UUID, 'order', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Order #WS-004: 24 Wings (All Flavors), 4 Beers, 2 Appetizers', '{"order_items": [{"item": "Wings All Flavors", "quantity": 24, "variety_seeking": true}, {"item": "Beer", "quantity": 4}, {"item": "Appetizers", "quantity": 2}], "total_items": 30, "group_order": true, "variety_seeking": true, "alcohol": true}', '550e8400-e29b-41d4-a716-446655440103'::UUID, '+1-555-0004', 'phone', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', 'completed', 0.9, 'pos_system', 'order_004', '{"order_number": "WS-004", "site_id": "550e8400-e29b-41d4-a716-446655440011"}'),
('550e8400-e29b-41d4-a716-446655440214'::UUID, 'order', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Order #WS-005: 6 Mild Wings, Delivery', '{"order_items": [{"item": "Mild Wings", "quantity": 6, "spice_level": "mild"}], "total_items": 6, "delivery": true, "conservative_spice": true}', '550e8400-e29b-41d4-a716-446655440104'::UUID, '+1-555-0005', 'phone', NOW() - INTERVAL '2 weeks', NOW() - INTERVAL '2 weeks', 'completed', 0.8, 'pos_system', 'order_005', '{"order_number": "WS-005", "site_id": "550e8400-e29b-41d4-a716-446655440010"}');

-- Social Comments (5-7)
INSERT INTO signals.signals_base (signal_id, signal_type, brand_id, raw_content, processed_content, actor_id, actor_identifier, actor_identifier_type, received_at, processed_at, processing_status, confidence_in_matching, source_platform, source_id, metadata) VALUES
('550e8400-e29b-41d4-a716-446655440215'::UUID, 'social_comment', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Just had the hottest wings ever at @wingshack! My mouth is still burning 🔥🔥🔥 #WingShack #SpicyWings', '{"sentiment": "positive", "hashtags": ["#WingShack", "#SpicyWings"], "spice_rating": "hottest", "brand_mention": true}', '550e8400-e29b-41d4-a716-446655440100'::UUID, '@spicelover_sarah', 'social_handle', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', 'completed', 0.9, 'instagram', 'ig_comment_001', '{"post_id": "ig_post_001", "comment_id": "ig_comment_001"}'),
('550e8400-e29b-41d4-a716-446655440216'::UUID, 'social_comment', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Love that @wingshack has grilled options! Finally a place that cares about health-conscious diners 💪', '{"sentiment": "positive", "hashtags": [], "health_focus": true, "grilled_preference": true, "brand_mention": true}', '550e8400-e29b-41d4-a716-446655440101'::UUID, '@healthy_mike', 'social_handle', NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week', 'completed', 0.85, 'twitter', 'tw_comment_001', '{"post_id": "tw_post_001", "comment_id": "tw_comment_001"}'),
('550e8400-e29b-41d4-a716-446655440217'::UUID, 'social_comment', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Best deal in town! @wingshack combo meals are unbeatable 💰', '{"sentiment": "positive", "hashtags": [], "value_focus": true, "deal_mention": true, "brand_mention": true}', '550e8400-e29b-41d4-a716-446655440102'::UUID, '@value_lisa', 'social_handle', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', 'completed', 0.8, 'facebook', 'fb_comment_001', '{"post_id": "fb_post_001", "comment_id": "fb_comment_001"}'),
('550e8400-e29b-41d4-a716-446655440218'::UUID, 'social_comment', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Had an amazing time at @wingshack with friends! Great vibes and even better wings 🍗', '{"sentiment": "positive", "hashtags": [], "social_dining": true, "atmosphere": "positive", "brand_mention": true}', '550e8400-e29b-41d4-a716-446655440103'::UUID, '@social_tom', 'social_handle', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', 'completed', 0.9, 'instagram', 'ig_comment_002', '{"post_id": "ig_post_002", "comment_id": "ig_comment_002"}'),
('550e8400-e29b-41d4-a716-446655440219'::UUID, 'social_comment', '550e8400-e29b-41d4-a716-446655440000'::UUID, 'Wings were okay, nothing special. Service was slow though', '{"sentiment": "negative", "hashtags": [], "mediocre_rating": true, "service_issue": true}', '550e8400-e29b-41d4-a716-446655440104'::UUID, '@emma_occasional', 'social_handle', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month', 'completed', 0.7, 'yelp', 'yelp_comment_001', '{"post_id": "yelp_post_001", "comment_id": "yelp_comment_001"}');

-- =====================================================
-- SAMPLE COHORTS (1-2 emergent cohorts)
-- =====================================================

-- Spice Enthusiasts Cohort
INSERT INTO cohorts.cohorts (
    cohort_id,
    brand_id,
    cohort_name,
    cohort_type,
    cohort_status,
    discovered_at,
    discovery_algorithm,
    discovery_parameters,
    discovery_confidence,
    cohort_signature,
    member_count,
    stability_score,
    coherence_score,
    separation_score,
    first_formed_at,
    last_updated_at,
    data_quality_score,
    representativeness_score
) VALUES (
    '550e8400-e29b-41d4-a716-446655440300'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'Spice Enthusiasts',
    'behavioral',
    'active',
    NOW() - INTERVAL '1 month',
    'kmeans',
    '{"n_clusters": 3, "random_state": 42}',
    0.85,
    '{"spice_preference": "high", "heat_tolerance": "extra_hot", "adventure_seeking": true, "social_sharing": true}',
    2,
    0.9,
    0.85,
    0.8,
    NOW() - INTERVAL '1 month',
    NOW() - INTERVAL '1 week',
    0.9,
    0.8
);

-- Value Seekers Cohort
INSERT INTO cohorts.cohorts (
    cohort_id,
    brand_id,
    cohort_name,
    cohort_type,
    cohort_status,
    discovered_at,
    discovery_algorithm,
    discovery_parameters,
    discovery_confidence,
    cohort_signature,
    member_count,
    stability_score,
    coherence_score,
    separation_score,
    first_formed_at,
    last_updated_at,
    data_quality_score,
    representativeness_score
) VALUES (
    '550e8400-e29b-41d4-a716-446655440301'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'Value Seekers',
    'behavioral',
    'active',
    NOW() - INTERVAL '1 month',
    'kmeans',
    '{"n_clusters": 3, "random_state": 42}',
    0.8,
    '{"price_sensitive": true, "deal_seeking": true, "combo_preference": true, "portion_focus": "large"}',
    2,
    0.85,
    0.8,
    0.75,
    NOW() - INTERVAL '1 month',
    NOW() - INTERVAL '1 week',
    0.8,
    0.75
);

-- =====================================================
-- COHORT MEMBERSHIPS
-- =====================================================

-- Assign actors to cohorts
INSERT INTO cohorts.actor_cohort_membership (actor_id, cohort_id, membership_type, membership_confidence, distance_to_centroid, assigned_by_algorithm, membership_strength, fit_score, contribution_score) VALUES
('550e8400-e29b-41d4-a716-446655440100'::UUID, '550e8400-e29b-41d4-a716-446655440300'::UUID, 'primary', 0.95, 0.15, 'kmeans', 0.9, 0.9, 0.85),
('550e8400-e29b-41d4-a716-446655440103'::UUID, '550e8400-e29b-41d4-a716-446655440300'::UUID, 'secondary', 0.7, 0.35, 'kmeans', 0.6, 0.7, 0.6),
('550e8400-e29b-41d4-a716-446655440102'::UUID, '550e8400-e29b-41d4-a716-446655440301'::UUID, 'primary', 0.9, 0.2, 'kmeans', 0.85, 0.85, 0.8),
('550e8400-e29b-41d4-a716-446655440104'::UUID, '550e8400-e29b-41d4-a716-446655440301'::UUID, 'secondary', 0.6, 0.4, 'kmeans', 0.5, 0.6, 0.5);

-- =====================================================
-- SAMPLE STIMULUS (1 campaign)
-- =====================================================

-- Spice Lovers Campaign
INSERT INTO stimuli.stimuli_base (
    stimulus_id,
    brand_id,
    stimulus_type,
    stimulus_name,
    stimulus_description,
    content_data,
    target_cohort_id,
    generated_by,
    generation_algorithm,
    generation_confidence,
    status,
    priority,
    created_at,
    scheduled_for,
    quality_score,
    relevance_score,
    effectiveness_score
) VALUES (
    '550e8400-e29b-41d4-a716-446655440400'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'campaign',
    'Spice Lovers Challenge',
    'Targeted campaign for spice enthusiasts offering exclusive hot wing challenges',
    '{"subject": "🔥 SPICE CHALLENGE: Can You Handle Our Hottest Wings?", "headline": "Exclusive Spice Challenge for Heat Seekers", "body": "Think you can handle the heat? Try our new Ghost Pepper Wings and get 20% off your next order!", "cta": "Accept the Challenge", "offer": "20% off next order", "challenge": "Ghost Pepper Wings"}',
    '550e8400-e29b-41d4-a716-446655440300'::UUID,
    'system',
    'cohort_targeting',
    0.9,
    'active',
    1,
    NOW() - INTERVAL '1 week',
    NOW() - INTERVAL '1 week',
    0.9,
    0.95,
    0.85
);

-- =====================================================
-- SAMPLE OUTCOME (1 result)
-- =====================================================

-- Campaign outcome
INSERT INTO outcomes.outcomes (
    outcome_id,
    brand_id,
    stimulus_id,
    stimulus_type,
    target_cohort_id,
    target_actor_id,
    outcome_type,
    outcome_category,
    outcome_description,
    outcome_value,
    outcome_unit,
    outcome_confidence,
    outcome_timestamp,
    stimulus_deployed_at,
    time_to_outcome,
    attribution_confidence,
    processing_status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440500'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    '550e8400-e29b-41d4-a716-446655440400'::UUID,
    'campaign',
    '550e8400-e29b-41d4-a716-446655440300'::UUID,
    '550e8400-e29b-41d4-a716-446655440100'::UUID,
    'conversion',
    'positive',
    'Sarah ordered Ghost Pepper Wings and used the 20% discount',
    1.0,
    'count',
    0.9,
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '1 week',
    4 * 24 * 60 * 60, -- 4 days in seconds
    0.85,
    'completed',
    NOW()
);

-- =====================================================
-- COHORT EVOLUTION LOG
-- =====================================================

-- Log cohort formation
INSERT INTO cohorts.cohort_evolution_log (
    evolution_id,
    cohort_id,
    brand_id,
    event_type,
    event_description,
    trigger_reason,
    trigger_algorithm,
    before_state,
    after_state,
    changed_attributes,
    affected_actor_count,
    event_confidence,
    event_importance
) VALUES (
    '550e8400-e29b-41d4-a716-446655440600'::UUID,
    '550e8400-e29b-41d4-a716-446655440300'::UUID,
    '550e8400-e29b-41d4-a716-446655440000'::UUID,
    'formed',
    'Spice Enthusiasts cohort discovered through clustering analysis',
    'Sufficient data accumulated for clustering analysis',
    'kmeans',
    '{}',
    '{"cohort_name": "Spice Enthusiasts", "member_count": 2, "stability_score": 0.9}',
    '["cohort_name", "member_count", "stability_score"]',
    2,
    0.9,
    0.8
);

-- =====================================================
-- AI FUNCTION REGISTRY
-- =====================================================

-- Register core functions
INSERT INTO ai.functions (
    function_id,
    function_name,
    function_type,
    function_category,
    version,
    description,
    purpose,
    input_schema,
    output_schema,
    implementation_type,
    is_active,
    validation_status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440700'::UUID,
    'match_or_create_actor',
    'signal_processing',
    'matching',
    '1.0.0',
    'Match signal to existing actor or create new actor',
    'Process incoming signals and match them to actors or create new actor profiles',
    '{"signal_data": "object", "identifier_value": "string", "identifier_type": "string", "brand_id": "uuid"}',
    '{"actor_id": "uuid", "confidence": "float"}',
    'plpgsql',
    true,
    'validated',
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440701'::UUID,
    'update_actor_belief',
    'signal_processing',
    'learning',
    '1.0.0',
    'Update actor belief using Bayesian inference',
    'Update actor beliefs based on new evidence using Bayesian updating',
    '{"actor_id": "uuid", "belief_path": "string", "new_evidence": "object", "signal_id": "uuid"}',
    '{"success": "boolean", "updated_confidence": "float", "evidence_count": "integer"}',
    'plpgsql',
    true,
    'validated',
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440702'::UUID,
    'trigger_clustering_run',
    'clustering',
    'clustering',
    '1.0.0',
    'Trigger clustering algorithm execution',
    'Execute clustering algorithm to discover new cohorts',
    '{"brand_id": "uuid", "algorithm": "string", "parameters": "object"}',
    '{"run_id": "uuid", "status": "string"}',
    'plpgsql',
    true,
    'validated',
    NOW()
);

-- =====================================================
-- SYSTEM PARAMETERS
-- =====================================================

-- Insert system parameters
INSERT INTO core.system_parameters (
    parameter_id,
    parameter_key,
    parameter_value,
    parameter_type,
    description,
    is_editable,
    requires_restart,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440800'::UUID,
    'clustering_interval_hours',
    '24',
    'number',
    'Hours between automatic clustering runs',
    true,
    false,
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440801'::UUID,
    'min_cohort_size',
    '2',
    'number',
    'Minimum number of actors required to form a cohort',
    true,
    false,
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440802'::UUID,
    'max_cohort_size',
    '1000',
    'number',
    'Maximum number of actors allowed in a single cohort',
    true,
    false,
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440803'::UUID,
    'learning_rate',
    '0.1',
    'number',
    'Learning rate for belief updates',
    true,
    false,
    NOW()
);

-- =====================================================
-- COMMENTS FOR SEED DATA
-- =====================================================

COMMENT ON TABLE core.brands IS 'Wing Shack brand with Brooklyn focus and wing specialty';
COMMENT ON TABLE actors.actors IS '5 diverse actor profiles: Spice Lover Sarah, Health-Conscious Mike, Value Seeker Lisa, Social Butterfly Tom, Occasional Customer Emma';
COMMENT ON TABLE signals.signals_base IS '20+ mixed signals: WhatsApp messages, reviews, orders, social comments showing different customer behaviors';
COMMENT ON TABLE cohorts.cohorts IS '2 emergent cohorts: Spice Enthusiasts and Value Seekers discovered through clustering';
COMMENT ON TABLE stimuli.stimuli_base IS 'Spice Lovers Challenge campaign targeted at Spice Enthusiasts cohort';
COMMENT ON TABLE outcomes.outcomes IS 'Campaign conversion outcome showing Sarah used the discount offer';
COMMENT ON TABLE ai.functions IS 'Core system functions registered for signal processing, belief updates, and clustering';
COMMENT ON TABLE core.system_parameters IS 'System configuration parameters for clustering and learning';
