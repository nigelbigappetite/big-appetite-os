-- =====================================================
-- WORKING CORE SCHEMA - BIG APPETITE OS
-- =====================================================
-- This is a simplified, working foundation focused on signal intake
-- and basic actor management. Advanced features will be added later.

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS signals;
CREATE SCHEMA IF NOT EXISTS actors;

-- =====================================================
-- CORE: BRANDS (Multi-tenancy)
-- =====================================================
CREATE TABLE core.brands (
    brand_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_name TEXT NOT NULL UNIQUE,
    brand_slug TEXT UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CORE: USERS (Brand-scoped access)
-- =====================================================
CREATE TABLE core.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ACTORS: Basic Customer Registry
-- =====================================================
CREATE TABLE actors.actors (
    actor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Basic identification
    primary_identifier TEXT NOT NULL, -- Email, phone, etc.
    identifier_type TEXT NOT NULL, -- 'email', 'phone', 'social'
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    first_seen_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Basic metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SIGNALS: Raw Data Intake
-- =====================================================
CREATE TABLE signals.signals_base (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Signal identification
    signal_type TEXT NOT NULL, -- 'whatsapp', 'review', 'order', 'web_behavior'
    source_platform TEXT NOT NULL, -- 'whatsapp', 'google', 'website', etc.
    
    -- Actor connection (may be null for unknown actors)
    actor_id UUID REFERENCES actors.actors(actor_id),
    actor_identifier TEXT, -- The identifier used to match the actor
    
    -- Content
    raw_content TEXT NOT NULL, -- Raw signal content
    processed_content JSONB, -- Processed/structured data
    
    -- Metadata
    received_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    processing_status TEXT DEFAULT 'pending', -- 'pending', 'processed', 'failed'
    
    -- Source tracking
    source_id TEXT, -- External ID from the platform
    source_metadata JSONB DEFAULT '{}',
    
    -- Quality
    quality_score FLOAT DEFAULT 0.0, -- 0-1 signal quality
    is_duplicate BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SIGNALS: WhatsApp Messages
-- =====================================================
CREATE TABLE signals.whatsapp_messages (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Message details
    sender_phone TEXT NOT NULL,
    message_text TEXT NOT NULL,
    message_direction TEXT NOT NULL, -- 'inbound', 'outbound'
    
    -- Actor connection
    actor_id UUID REFERENCES actors.actors(actor_id),
    actor_identifier TEXT,
    
    -- Metadata
    received_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    processing_status TEXT DEFAULT 'pending',
    
    -- Content
    raw_content TEXT,
    processed_content JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SIGNALS: Reviews
-- =====================================================
CREATE TABLE signals.reviews (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Review details
    review_text TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_source TEXT NOT NULL, -- 'google', 'yelp', 'facebook', etc.
    
    -- Actor connection
    actor_id UUID REFERENCES actors.actors(actor_id),
    actor_identifier TEXT,
    
    -- Metadata
    received_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    processing_status TEXT DEFAULT 'pending',
    
    -- Content
    raw_content TEXT,
    processed_content JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SIGNALS: Orders
-- =====================================================
CREATE TABLE signals.orders (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Order details
    order_id TEXT NOT NULL,
    order_total DECIMAL(10,2),
    order_items JSONB, -- Array of items
    order_status TEXT NOT NULL, -- 'pending', 'completed', 'cancelled'
    
    -- Actor connection
    actor_id UUID REFERENCES actors.actors(actor_id),
    actor_identifier TEXT,
    
    -- Metadata
    received_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    processing_status TEXT DEFAULT 'pending',
    
    -- Content
    raw_content TEXT,
    processed_content JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SIGNALS: Web Behavior
-- =====================================================
CREATE TABLE signals.web_behavior (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Behavior details
    page_url TEXT NOT NULL,
    action_type TEXT NOT NULL, -- 'page_view', 'click', 'form_submit', etc.
    session_id TEXT,
    
    -- Actor connection
    actor_id UUID REFERENCES actors.actors(actor_id),
    actor_identifier TEXT,
    
    -- Metadata
    received_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    processing_status TEXT DEFAULT 'pending',
    
    -- Content
    raw_content TEXT,
    processed_content JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Brands indexes
CREATE INDEX IF NOT EXISTS idx_brands_slug ON core.brands(brand_slug);
CREATE INDEX IF NOT EXISTS idx_brands_active ON core.brands(is_active) WHERE is_active = true;

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_brand_id ON core.users(brand_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON core.users(email);

-- Actors indexes
CREATE INDEX IF NOT EXISTS idx_actors_brand_id ON actors.actors(brand_id);
CREATE INDEX IF NOT EXISTS idx_actors_identifier ON actors.actors(primary_identifier);
CREATE INDEX IF NOT EXISTS idx_actors_active ON actors.actors(is_active) WHERE is_active = true;

-- Signals base indexes
CREATE INDEX IF NOT EXISTS idx_signals_brand_id ON signals.signals_base(brand_id);
CREATE INDEX IF NOT EXISTS idx_signals_type ON signals.signals_base(signal_type);
CREATE INDEX IF NOT EXISTS idx_signals_actor_id ON signals.signals_base(actor_id);
CREATE INDEX IF NOT EXISTS idx_signals_received_at ON signals.signals_base(received_at);
CREATE INDEX IF NOT EXISTS idx_signals_status ON signals.signals_base(processing_status);

-- WhatsApp indexes
CREATE INDEX IF NOT EXISTS idx_whatsapp_brand_id ON signals.whatsapp_messages(brand_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_actor_id ON signals.whatsapp_messages(actor_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_received_at ON signals.whatsapp_messages(received_at);

-- Reviews indexes
CREATE INDEX IF NOT EXISTS idx_reviews_brand_id ON signals.reviews(brand_id);
CREATE INDEX IF NOT EXISTS idx_reviews_actor_id ON signals.reviews(actor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON signals.reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_source ON signals.reviews(review_source);

-- Orders indexes
CREATE INDEX IF NOT EXISTS idx_orders_brand_id ON signals.orders(brand_id);
CREATE INDEX IF NOT EXISTS idx_orders_actor_id ON signals.orders(actor_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_id ON signals.orders(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON signals.orders(order_status);

-- Web behavior indexes
CREATE INDEX IF NOT EXISTS idx_web_behavior_brand_id ON signals.web_behavior(brand_id);
CREATE INDEX IF NOT EXISTS idx_web_behavior_actor_id ON signals.web_behavior(actor_id);
CREATE INDEX IF NOT EXISTS idx_web_behavior_session_id ON signals.web_behavior(session_id);
CREATE INDEX IF NOT EXISTS idx_web_behavior_action_type ON signals.web_behavior(action_type);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE core.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors.actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.signals_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.whatsapp_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals.web_behavior ENABLE ROW LEVEL SECURITY;

-- Service role can do everything
CREATE POLICY "Service role full access" ON core.brands FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access" ON core.users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access" ON actors.actors FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access" ON signals.signals_base FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access" ON signals.whatsapp_messages FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access" ON signals.reviews FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access" ON signals.orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access" ON signals.web_behavior FOR ALL USING (true) WITH CHECK (true);

-- Brand-scoped access (users can only see their brand's data)
CREATE POLICY "Brand-scoped access" ON core.brands FOR SELECT USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));
CREATE POLICY "Brand-scoped access" ON core.users FOR ALL USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));
CREATE POLICY "Brand-scoped access" ON actors.actors FOR ALL USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));
CREATE POLICY "Brand-scoped access" ON signals.signals_base FOR ALL USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));
CREATE POLICY "Brand-scoped access" ON signals.whatsapp_messages FOR ALL USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));
CREATE POLICY "Brand-scoped access" ON signals.reviews FOR ALL USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));
CREATE POLICY "Brand-scoped access" ON signals.orders FOR ALL USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));
CREATE POLICY "Brand-scoped access" ON signals.web_behavior FOR ALL USING (brand_id = (SELECT brand_id FROM core.users WHERE user_id = auth.uid()));

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON SCHEMA core IS 'Core system tables for brands and users';
COMMENT ON SCHEMA actors IS 'Actor (customer) management and identification';
COMMENT ON SCHEMA signals IS 'Signal intake and processing pipeline';

COMMENT ON TABLE core.brands IS 'Multi-tenant brand management';
COMMENT ON TABLE core.users IS 'Brand-scoped user access';
COMMENT ON TABLE actors.actors IS 'Basic customer registry';
COMMENT ON TABLE signals.signals_base IS 'Central signal intake table';
COMMENT ON TABLE signals.whatsapp_messages IS 'WhatsApp message signals';
COMMENT ON TABLE signals.reviews IS 'Review and rating signals';
COMMENT ON TABLE signals.orders IS 'Order and purchase signals';
COMMENT ON TABLE signals.web_behavior IS 'Website behavior signals';
