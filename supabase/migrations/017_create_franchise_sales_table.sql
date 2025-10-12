-- Create franchise_sales table in ops schema
-- This table stores daily sales data from franchise locations

CREATE TABLE IF NOT EXISTS ops.franchise_sales (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id),
    site_id INTEGER NOT NULL,
    site_name TEXT NOT NULL,
    platform TEXT NOT NULL,
    order_date DATE NOT NULL,
    reporting_week TEXT,
    orders_count INTEGER DEFAULT 0,
    gross_sales DECIMAL(10,2) DEFAULT 0,
    refunds DECIMAL(10,2) DEFAULT 0,
    net_sales DECIMAL(10,2) DEFAULT 0,
    avg_order_value DECIMAL(10,2) DEFAULT 0,
    avg_prep_time INTEGER,
    avg_fulfilment_time INTEGER,
    completion_rate DECIMAL(5,2),
    delivery_rating DECIMAL(3,2),
    royalty_rate DECIMAL(5,2),
    royalty_value DECIMAL(10,2),
    raw_content JSONB DEFAULT '{}'::jsonb,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    intake_method TEXT,
    intake_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_franchise_sales_brand_id ON ops.franchise_sales(brand_id);
CREATE INDEX IF NOT EXISTS idx_franchise_sales_site_id ON ops.franchise_sales(site_id);
CREATE INDEX IF NOT EXISTS idx_franchise_sales_platform ON ops.franchise_sales(platform);
CREATE INDEX IF NOT EXISTS idx_franchise_sales_order_date ON ops.franchise_sales(order_date);
CREATE INDEX IF NOT EXISTS idx_franchise_sales_reporting_week ON ops.franchise_sales(reporting_week);

-- Add comments for documentation
COMMENT ON TABLE ops.franchise_sales IS 'Daily sales data from franchise locations across multiple platforms';
COMMENT ON COLUMN ops.franchise_sales.signal_id IS 'Unique identifier for each sales record';
COMMENT ON COLUMN ops.franchise_sales.brand_id IS 'Reference to the brand this data belongs to';
COMMENT ON COLUMN ops.franchise_sales.site_id IS 'Franchise location ID (1=Loughton, 2=Maidstone, 3=Chatham, 4=Wanstead)';
COMMENT ON COLUMN ops.franchise_sales.site_name IS 'Human-readable site name';
COMMENT ON COLUMN ops.franchise_sales.platform IS 'Delivery platform (deliveroo, justeat, ubereats, wingverse)';
COMMENT ON COLUMN ops.franchise_sales.order_date IS 'Date of the sales data';
COMMENT ON COLUMN ops.franchise_sales.orders_count IS 'Number of orders for this site/platform/date';
COMMENT ON COLUMN ops.franchise_sales.gross_sales IS 'Total sales before refunds';
COMMENT ON COLUMN ops.franchise_sales.net_sales IS 'Sales after refunds';
COMMENT ON COLUMN ops.franchise_sales.avg_order_value IS 'Average order value for this site/platform/date';
COMMENT ON COLUMN ops.franchise_sales.completion_rate IS 'Percentage of orders completed successfully';
COMMENT ON COLUMN ops.franchise_sales.delivery_rating IS 'Average delivery rating for this site/platform/date';
