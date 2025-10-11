-- =====================================================
-- OPS SCHEMA - Internal Operations
-- =====================================================
-- This schema manages internal business operations including:
-- sites/locations, sales data, supply chain, inventory, CRM functions,
-- and business metrics that support the core system functionality.

-- =====================================================
-- SITES TABLE
-- =====================================================
-- Physical locations and virtual sites
CREATE TABLE ops.sites (
    site_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Site identification
    site_name TEXT NOT NULL,
    site_code TEXT UNIQUE NOT NULL, -- Short code for the site
    site_type TEXT NOT NULL, -- 'physical', 'virtual', 'popup', 'delivery_hub'
    
    -- Location information
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state_province TEXT,
    postal_code TEXT,
    country TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Contact information
    phone TEXT,
    email TEXT,
    website_url TEXT,
    
    -- Operational details
    timezone TEXT DEFAULT 'UTC',
    currency TEXT DEFAULT 'USD',
    language TEXT DEFAULT 'en',
    
    -- Hours of operation
    operating_hours JSONB DEFAULT '{}', -- Day-by-day hours
    special_hours JSONB DEFAULT '[]', -- Holiday and special hours
    
    -- Capacity and capabilities
    max_capacity INTEGER, -- Maximum customer capacity
    delivery_radius INTEGER, -- Delivery radius in miles/km
    pickup_available BOOLEAN DEFAULT true,
    delivery_available BOOLEAN DEFAULT true,
    dine_in_available BOOLEAN DEFAULT true,
    
    -- Status and metadata
    is_active BOOLEAN DEFAULT true,
    opening_date DATE,
    closing_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_site_type CHECK (site_type IN ('physical', 'virtual', 'popup', 'delivery_hub', 'kiosk', 'other')),
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL OR (latitude >= -90 AND latitude <= 90)) AND
        (longitude IS NULL OR (longitude >= -180 AND longitude <= 180))
    ),
    CONSTRAINT valid_capacity CHECK (max_capacity IS NULL OR max_capacity > 0),
    CONSTRAINT valid_radius CHECK (delivery_radius IS NULL OR delivery_radius > 0),
    CONSTRAINT valid_dates CHECK (opening_date IS NULL OR closing_date IS NULL OR opening_date <= closing_date)
);

-- =====================================================
-- SALES DATA TABLE
-- =====================================================
-- Sales transactions and revenue data
CREATE TABLE ops.sales_data (
    sale_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    site_id UUID REFERENCES ops.sites(site_id),
    
    -- Transaction details
    transaction_id TEXT NOT NULL, -- External transaction ID
    transaction_type TEXT NOT NULL, -- 'sale', 'refund', 'void', 'adjustment'
    transaction_date TIMESTAMPTZ NOT NULL,
    
    -- Customer information
    customer_id UUID REFERENCES actors.actors(actor_id),
    customer_identifier TEXT, -- Phone, email, or other identifier
    customer_type TEXT, -- 'new', 'returning', 'vip', 'anonymous'
    
    -- Order details
    order_number TEXT,
    order_method TEXT NOT NULL, -- 'online', 'phone', 'in_store', 'app', 'third_party'
    payment_method TEXT NOT NULL, -- 'cash', 'card', 'digital_wallet', 'online_payment'
    
    -- Financial data
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    tip_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    service_fee DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Items and services
    items JSONB NOT NULL, -- Array of items sold
    item_count INTEGER NOT NULL,
    unique_item_count INTEGER NOT NULL,
    
    -- Timing information
    order_time TIMESTAMPTZ,
    preparation_time INTEGER, -- Minutes
    total_time INTEGER, -- Total minutes from order to completion
    
    -- Status and metadata
    status TEXT NOT NULL DEFAULT 'completed', -- 'pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    
    -- Constraints
    CONSTRAINT valid_transaction_type CHECK (transaction_type IN ('sale', 'refund', 'void', 'adjustment', 'gift_card', 'loyalty_redemption')),
    CONSTRAINT valid_order_method CHECK (order_method IN ('online', 'phone', 'in_store', 'app', 'third_party', 'kiosk')),
    CONSTRAINT valid_payment_method CHECK (payment_method IN ('cash', 'card', 'digital_wallet', 'online_payment', 'gift_card', 'loyalty_points', 'other')),
    CONSTRAINT valid_customer_type CHECK (customer_type IN ('new', 'returning', 'vip', 'anonymous', 'employee')),
    CONSTRAINT valid_status CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled', 'refunded')),
    CONSTRAINT valid_amounts CHECK (
        subtotal >= 0 AND tax_amount >= 0 AND tip_amount >= 0 AND
        discount_amount >= 0 AND delivery_fee >= 0 AND service_fee >= 0 AND
        total_amount >= 0 AND item_count > 0 AND unique_item_count > 0
    )
);

-- =====================================================
-- INVENTORY TABLE
-- =====================================================
-- Product inventory and stock management
CREATE TABLE ops.inventory (
    inventory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    site_id UUID REFERENCES ops.sites(site_id),
    
    -- Product identification
    product_id TEXT NOT NULL, -- External product ID
    product_name TEXT NOT NULL,
    product_category TEXT,
    product_type TEXT, -- 'food', 'beverage', 'merchandise', 'ingredient'
    
    -- Inventory details
    current_stock INTEGER NOT NULL DEFAULT 0,
    minimum_stock INTEGER DEFAULT 0,
    maximum_stock INTEGER,
    reorder_point INTEGER DEFAULT 0,
    reorder_quantity INTEGER DEFAULT 0,
    
    -- Pricing
    unit_cost DECIMAL(10,2),
    unit_price DECIMAL(10,2),
    markup_percentage FLOAT,
    
    -- Units and measurements
    unit_of_measure TEXT NOT NULL, -- 'pieces', 'pounds', 'liters', 'each'
    unit_size TEXT, -- 'small', 'medium', 'large', 'family'
    
    -- Status and availability
    is_active BOOLEAN DEFAULT true,
    is_available BOOLEAN DEFAULT true,
    availability_reason TEXT, -- Why unavailable if not available
    
    -- Supplier information
    supplier_id TEXT,
    supplier_name TEXT,
    supplier_contact TEXT,
    
    -- Tracking
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_restocked_at TIMESTAMPTZ,
    last_sold_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT valid_product_type CHECK (product_type IN ('food', 'beverage', 'merchandise', 'ingredient', 'supply', 'other')),
    CONSTRAINT valid_stock_levels CHECK (
        current_stock >= 0 AND minimum_stock >= 0 AND
        (maximum_stock IS NULL OR maximum_stock >= current_stock) AND
        reorder_point >= 0 AND reorder_quantity >= 0
    ),
    CONSTRAINT valid_pricing CHECK (
        unit_cost IS NULL OR unit_cost >= 0 AND
        unit_price IS NULL OR unit_price >= 0 AND
        markup_percentage IS NULL OR markup_percentage >= 0
    )
);

-- =====================================================
-- SUPPLY CHAIN TABLE
-- =====================================================
-- Supply chain and vendor management
CREATE TABLE ops.supply_chain (
    supply_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Supplier information
    supplier_id TEXT NOT NULL,
    supplier_name TEXT NOT NULL,
    supplier_type TEXT NOT NULL, -- 'food', 'beverage', 'packaging', 'equipment', 'service'
    
    -- Contact details
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    website TEXT,
    
    -- Address
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state_province TEXT,
    postal_code TEXT,
    country TEXT,
    
    -- Business details
    tax_id TEXT,
    payment_terms TEXT, -- 'net_30', 'net_15', 'cod', 'prepaid'
    credit_limit DECIMAL(10,2),
    current_balance DECIMAL(10,2) DEFAULT 0,
    
    -- Performance metrics
    on_time_delivery_rate FLOAT DEFAULT 0.0, -- 0-1
    quality_score FLOAT DEFAULT 0.0, -- 0-1
    cost_competitiveness FLOAT DEFAULT 0.0, -- 0-1
    overall_rating FLOAT DEFAULT 0.0, -- 0-1
    
    -- Status and metadata
    is_active BOOLEAN DEFAULT true,
    is_preferred BOOLEAN DEFAULT false,
    relationship_start_date DATE,
    last_order_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_supplier_type CHECK (supplier_type IN ('food', 'beverage', 'packaging', 'equipment', 'service', 'logistics', 'other')),
    CONSTRAINT valid_payment_terms CHECK (payment_terms IN ('net_30', 'net_15', 'net_7', 'cod', 'prepaid', 'other')),
    CONSTRAINT valid_ratings CHECK (
        on_time_delivery_rate >= 0 AND on_time_delivery_rate <= 1 AND
        quality_score >= 0 AND quality_score <= 1 AND
        cost_competitiveness >= 0 AND cost_competitiveness <= 1 AND
        overall_rating >= 0 AND overall_rating <= 1
    ),
    CONSTRAINT valid_balances CHECK (credit_limit IS NULL OR credit_limit >= 0 AND current_balance >= 0)
);

-- =====================================================
-- CRM EVENTS TABLE
-- =====================================================
-- Customer relationship management events
CREATE TABLE ops.crm_events (
    crm_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    actor_id UUID REFERENCES actors.actors(actor_id),
    
    -- Event details
    event_type TEXT NOT NULL, -- 'interaction', 'complaint', 'compliment', 'inquiry', 'feedback'
    event_category TEXT, -- 'service', 'product', 'delivery', 'billing', 'general'
    event_description TEXT NOT NULL,
    
    -- Event context
    event_source TEXT NOT NULL, -- 'phone', 'email', 'chat', 'in_person', 'social', 'review'
    event_channel TEXT, -- Specific channel within source
    event_priority TEXT DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
    
    -- Customer information
    customer_identifier TEXT, -- Phone, email, or other identifier
    customer_sentiment TEXT, -- 'positive', 'neutral', 'negative', 'mixed'
    customer_satisfaction_score INTEGER, -- 1-5 rating
    
    -- Resolution details
    status TEXT NOT NULL DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed', 'escalated'
    assigned_to UUID REFERENCES core.users(user_id),
    resolution_notes TEXT,
    resolution_date TIMESTAMPTZ,
    
    -- Follow-up
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date TIMESTAMPTZ,
    follow_up_notes TEXT,
    
    -- Timing
    event_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    first_response_time INTEGER, -- Minutes to first response
    resolution_time INTEGER, -- Minutes to resolution
    
    -- Metadata
    tags JSONB DEFAULT '[]', -- Tags for categorization
    metadata JSONB DEFAULT '{}',
    
    -- Constraints
    CONSTRAINT valid_event_type CHECK (event_type IN ('interaction', 'complaint', 'compliment', 'inquiry', 'feedback', 'escalation', 'other')),
    CONSTRAINT valid_event_category CHECK (event_category IN ('service', 'product', 'delivery', 'billing', 'general', 'technical', 'other')),
    CONSTRAINT valid_priority CHECK (event_priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT valid_sentiment CHECK (customer_sentiment IN ('positive', 'neutral', 'negative', 'mixed')),
    CONSTRAINT valid_satisfaction CHECK (customer_satisfaction_score IS NULL OR (customer_satisfaction_score >= 1 AND customer_satisfaction_score <= 5)),
    CONSTRAINT valid_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed', 'escalated', 'cancelled'))
);

-- =====================================================
-- BUSINESS METRICS TABLE
-- =====================================================
-- Key business performance indicators
CREATE TABLE ops.business_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    site_id UUID REFERENCES ops.sites(site_id),
    
    -- Metric identification
    metric_name TEXT NOT NULL, -- 'revenue', 'orders', 'customers', 'avg_order_value', etc.
    metric_category TEXT NOT NULL, -- 'financial', 'operational', 'customer', 'marketing'
    metric_value FLOAT NOT NULL,
    metric_unit TEXT, -- 'currency', 'count', 'percentage', 'rate'
    
    -- Time period
    measurement_date DATE NOT NULL,
    measurement_period TEXT NOT NULL, -- 'daily', 'weekly', 'monthly', 'quarterly', 'yearly'
    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL,
    
    -- Context and breakdown
    breakdown_dimension TEXT, -- 'by_site', 'by_product', 'by_customer_segment', 'by_channel'
    breakdown_value TEXT, -- Specific value within the dimension
    
    -- Comparison and trends
    previous_period_value FLOAT,
    year_over_year_value FLOAT,
    target_value FLOAT,
    variance_from_target FLOAT,
    
    -- Statistical measures
    sample_size INTEGER,
    confidence_level FLOAT, -- 0-1
    margin_of_error FLOAT,
    
    -- Quality and reliability
    data_quality_score FLOAT DEFAULT 0.0, -- 0-1
    calculation_method TEXT,
    source_systems JSONB DEFAULT '[]', -- Which systems contributed data
    
    -- Metadata
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    calculated_by TEXT, -- 'system', 'user', 'import'
    
    -- Constraints
    CONSTRAINT valid_metric_category CHECK (metric_category IN ('financial', 'operational', 'customer', 'marketing', 'inventory', 'supply_chain')),
    CONSTRAINT valid_measurement_period CHECK (measurement_period IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom')),
    CONSTRAINT valid_confidence_level CHECK (confidence_level IS NULL OR (confidence_level >= 0 AND confidence_level <= 1)),
    CONSTRAINT valid_quality_score CHECK (data_quality_score >= 0 AND data_quality_score <= 1),
    CONSTRAINT valid_period CHECK (period_start < period_end)
);

-- =====================================================
-- OPERATIONAL ALERTS TABLE
-- =====================================================
-- System alerts and notifications for operations
CREATE TABLE ops.operational_alerts (
    alert_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    site_id UUID REFERENCES ops.sites(site_id),
    
    -- Alert details
    alert_type TEXT NOT NULL, -- 'inventory', 'sales', 'customer', 'system', 'financial'
    alert_severity TEXT NOT NULL, -- 'low', 'medium', 'high', 'critical'
    alert_title TEXT NOT NULL,
    alert_description TEXT NOT NULL,
    
    -- Alert conditions
    trigger_condition TEXT NOT NULL, -- What triggered this alert
    trigger_value FLOAT, -- Value that triggered the alert
    threshold_value FLOAT, -- Threshold that was exceeded
    threshold_type TEXT, -- 'above', 'below', 'equals', 'not_equals'
    
    -- Status and handling
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'acknowledged', 'resolved', 'dismissed'
    assigned_to UUID REFERENCES core.users(user_id),
    acknowledged_at TIMESTAMPTZ,
    acknowledged_by UUID REFERENCES core.users(user_id),
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES core.users(user_id),
    
    -- Resolution details
    resolution_notes TEXT,
    resolution_action TEXT,
    follow_up_required BOOLEAN DEFAULT false,
    
    -- Timing
    triggered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    
    -- Metadata
    source_system TEXT, -- Which system generated this alert
    alert_data JSONB DEFAULT '{}', -- Additional alert data
    related_entities JSONB DEFAULT '[]', -- Related entities (orders, customers, etc.)
    
    -- Constraints
    CONSTRAINT valid_alert_type CHECK (alert_type IN ('inventory', 'sales', 'customer', 'system', 'financial', 'supply_chain', 'quality', 'other')),
    CONSTRAINT valid_severity CHECK (alert_severity IN ('low', 'medium', 'high', 'critical')),
    CONSTRAINT valid_threshold_type CHECK (threshold_type IN ('above', 'below', 'equals', 'not_equals', 'changed', 'unchanged')),
    CONSTRAINT valid_status CHECK (status IN ('active', 'acknowledged', 'resolved', 'dismissed', 'expired'))
);

-- =====================================================
-- INDEXES FOR OPS SCHEMA
-- =====================================================

-- Sites indexes
CREATE INDEX IF NOT EXISTS idx_sites_brand_id ON ops.sites(brand_id);
CREATE INDEX IF NOT EXISTS idx_sites_site_code ON ops.sites(site_code);
CREATE INDEX IF NOT EXISTS idx_sites_type ON ops.sites(site_type);
CREATE INDEX IF NOT EXISTS idx_sites_active ON ops.sites(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_sites_city ON ops.sites(city);
CREATE INDEX IF NOT EXISTS idx_sites_state ON ops.sites(state_province);

-- Sales data indexes
CREATE INDEX IF NOT EXISTS idx_sales_data_brand_id ON ops.sales_data(brand_id);
CREATE INDEX IF NOT EXISTS idx_sales_data_site_id ON ops.sales_data(site_id);
CREATE INDEX IF NOT EXISTS idx_sales_data_customer_id ON ops.sales_data(customer_id) WHERE customer_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sales_data_transaction_date ON ops.sales_data(transaction_date);
CREATE INDEX IF NOT EXISTS idx_sales_data_transaction_type ON ops.sales_data(transaction_type);
CREATE INDEX IF NOT EXISTS idx_sales_data_order_method ON ops.sales_data(order_method);
CREATE INDEX IF NOT EXISTS idx_sales_data_status ON ops.sales_data(status);

-- Inventory indexes
CREATE INDEX IF NOT EXISTS idx_inventory_brand_id ON ops.inventory(brand_id);
CREATE INDEX IF NOT EXISTS idx_inventory_site_id ON ops.inventory(site_id);
CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON ops.inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_category ON ops.inventory(product_category);
CREATE INDEX IF NOT EXISTS idx_inventory_type ON ops.inventory(product_type);
CREATE INDEX IF NOT EXISTS idx_inventory_active ON ops.inventory(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_inventory_available ON ops.inventory(is_available) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_inventory_low_stock ON ops.inventory(current_stock) WHERE current_stock <= reorder_point;

-- Supply chain indexes
CREATE INDEX IF NOT EXISTS idx_supply_chain_brand_id ON ops.supply_chain(brand_id);
CREATE INDEX IF NOT EXISTS idx_supply_chain_supplier_id ON ops.supply_chain(supplier_id);
CREATE INDEX IF NOT EXISTS idx_supply_chain_type ON ops.supply_chain(supplier_type);
CREATE INDEX IF NOT EXISTS idx_supply_chain_active ON ops.supply_chain(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_supply_chain_preferred ON ops.supply_chain(is_preferred) WHERE is_preferred = true;

-- CRM events indexes
CREATE INDEX IF NOT EXISTS idx_crm_events_brand_id ON ops.crm_events(brand_id);
CREATE INDEX IF NOT EXISTS idx_crm_events_actor_id ON ops.crm_events(actor_id) WHERE actor_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_crm_events_type ON ops.crm_events(event_type);
CREATE INDEX IF NOT EXISTS idx_crm_events_category ON ops.crm_events(event_category);
CREATE INDEX IF NOT EXISTS idx_crm_events_status ON ops.crm_events(status);
CREATE INDEX IF NOT EXISTS idx_crm_events_priority ON ops.crm_events(event_priority);
CREATE INDEX IF NOT EXISTS idx_crm_events_timestamp ON ops.crm_events(event_timestamp);
CREATE INDEX IF NOT EXISTS idx_crm_events_assigned_to ON ops.crm_events(assigned_to) WHERE assigned_to IS NOT NULL;

-- Business metrics indexes
CREATE INDEX IF NOT EXISTS idx_business_metrics_brand_id ON ops.business_metrics(brand_id);
CREATE INDEX IF NOT EXISTS idx_business_metrics_site_id ON ops.business_metrics(site_id) WHERE site_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_business_metrics_name ON ops.business_metrics(metric_name);
CREATE INDEX IF NOT EXISTS idx_business_metrics_category ON ops.business_metrics(metric_category);
CREATE INDEX IF NOT EXISTS idx_business_metrics_date ON ops.business_metrics(measurement_date);
CREATE INDEX IF NOT EXISTS idx_business_metrics_period ON ops.business_metrics(measurement_period);

-- Operational alerts indexes
CREATE INDEX IF NOT EXISTS idx_operational_alerts_brand_id ON ops.operational_alerts(brand_id);
CREATE INDEX IF NOT EXISTS idx_operational_alerts_site_id ON ops.operational_alerts(site_id) WHERE site_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_operational_alerts_type ON ops.operational_alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_operational_alerts_severity ON ops.operational_alerts(alert_severity);
CREATE INDEX IF NOT EXISTS idx_operational_alerts_status ON ops.operational_alerts(status);
CREATE INDEX IF NOT EXISTS idx_operational_alerts_triggered_at ON ops.operational_alerts(triggered_at);
CREATE INDEX IF NOT EXISTS idx_operational_alerts_assigned_to ON ops.operational_alerts(assigned_to) WHERE assigned_to IS NOT NULL;

-- =====================================================
-- TRIGGERS FOR OPS SCHEMA
-- =====================================================

-- Update timestamps
CREATE TRIGGER update_sites_updated_at 
    BEFORE UPDATE ON ops.sites 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

CREATE TRIGGER update_supply_chain_updated_at 
    BEFORE UPDATE ON ops.supply_chain 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Update inventory when sales occur
CREATE OR REPLACE FUNCTION ops.update_inventory_on_sale()
RETURNS TRIGGER AS $$
DECLARE
    item JSONB;
    current_stock INTEGER;
BEGIN
    -- Only process completed sales
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        -- Loop through items in the sale
        FOR item IN SELECT * FROM jsonb_array_elements(NEW.items)
        LOOP
            -- Update inventory for this item
            UPDATE ops.inventory 
            SET 
                current_stock = current_stock - (item->>'quantity')::INTEGER,
                last_sold_at = NEW.transaction_date,
                last_updated_at = NOW()
            WHERE 
                brand_id = NEW.brand_id AND
                (site_id = NEW.site_id OR site_id IS NULL) AND
                product_id = item->>'product_id';
        END LOOP;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_inventory_on_sale_trigger
    AFTER INSERT OR UPDATE ON ops.sales_data
    FOR EACH ROW EXECUTE FUNCTION ops.update_inventory_on_sale();

-- =====================================================
-- COMMENTS FOR OPS SCHEMA
-- =====================================================

COMMENT ON SCHEMA ops IS 'Internal business operations including sites, sales, inventory, supply chain, and metrics';
COMMENT ON TABLE ops.sites IS 'Physical and virtual locations with operational details and capabilities';
COMMENT ON TABLE ops.sales_data IS 'Sales transactions with customer, financial, and timing information';
COMMENT ON TABLE ops.inventory IS 'Product inventory management with stock levels and supplier information';
COMMENT ON TABLE ops.supply_chain IS 'Supplier and vendor management with performance metrics';
COMMENT ON TABLE ops.crm_events IS 'Customer relationship management events and interactions';
COMMENT ON TABLE ops.business_metrics IS 'Key business performance indicators with time-series data';
COMMENT ON TABLE ops.operational_alerts IS 'System alerts and notifications for operational issues';

COMMENT ON COLUMN ops.sites.delivery_radius IS 'Delivery radius in miles or kilometers';
COMMENT ON COLUMN ops.sales_data.customer_type IS 'Type of customer: new, returning, vip, anonymous, employee';
COMMENT ON COLUMN ops.sales_data.items IS 'Array of items sold with quantities, prices, and details';
COMMENT ON COLUMN ops.inventory.reorder_point IS 'Stock level at which to reorder';
COMMENT ON COLUMN ops.supply_chain.overall_rating IS 'Overall supplier rating based on performance metrics';
COMMENT ON COLUMN ops.crm_events.customer_satisfaction_score IS 'Customer satisfaction rating from 1-5';
COMMENT ON COLUMN ops.business_metrics.breakdown_dimension IS 'Dimension for metric breakdown (by_site, by_product, etc.)';
COMMENT ON COLUMN ops.operational_alerts.trigger_condition IS 'Condition that triggered this alert';
