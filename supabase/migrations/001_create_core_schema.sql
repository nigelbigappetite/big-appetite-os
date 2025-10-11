-- =====================================================
-- CORE SCHEMA - Global Configuration & Multi-tenancy
-- =====================================================
-- This schema contains the foundational tables for brands, users, 
-- and system-wide configuration that all other schemas depend on.

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS signals;
CREATE SCHEMA IF NOT EXISTS actors;
CREATE SCHEMA IF NOT EXISTS cohorts;
CREATE SCHEMA IF NOT EXISTS stimuli;
CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS outcomes;
CREATE SCHEMA IF NOT EXISTS ai;

-- =====================================================
-- BRANDS TABLE
-- =====================================================
-- Central tenant isolation - every piece of data belongs to a brand
CREATE TABLE core.brands (
    brand_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_name TEXT NOT NULL,
    brand_slug TEXT UNIQUE NOT NULL,
    description TEXT,
    
    -- Contact information
    primary_phone TEXT,
    primary_email TEXT,
    website_url TEXT,
    
    -- Business configuration
    timezone TEXT DEFAULT 'UTC',
    currency TEXT DEFAULT 'USD',
    language TEXT DEFAULT 'en',
    
    -- Brand-specific settings
    settings JSONB DEFAULT '{}',
    
    -- Status and metadata
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT valid_currency CHECK (currency ~ '^[A-Z]{3}$'),
    CONSTRAINT valid_language CHECK (language ~ '^[a-z]{2}(-[A-Z]{2})?$')
);

-- =====================================================
-- USERS TABLE
-- =====================================================
-- Brand-scoped user management
CREATE TABLE core.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- User profile
    email TEXT NOT NULL,
    full_name TEXT,
    role TEXT NOT NULL DEFAULT 'user',
    
    -- Permissions and access
    permissions JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_role CHECK (role IN ('owner', 'admin', 'manager', 'user', 'viewer')),
    CONSTRAINT unique_brand_email UNIQUE (brand_id, email)
);

-- =====================================================
-- BRAND SETTINGS TABLE
-- =====================================================
-- Flexible configuration storage per brand
CREATE TABLE core.brand_settings (
    setting_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Setting identification
    setting_key TEXT NOT NULL,
    setting_value JSONB NOT NULL,
    setting_type TEXT NOT NULL DEFAULT 'string',
    
    -- Versioning and change tracking
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    changed_by UUID REFERENCES core.users(user_id),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_setting_type CHECK (setting_type IN ('string', 'number', 'boolean', 'object', 'array')),
    CONSTRAINT unique_brand_setting UNIQUE (brand_id, setting_key, version)
);

-- =====================================================
-- SYSTEM PARAMETERS TABLE
-- =====================================================
-- Global system configuration that affects all brands
CREATE TABLE core.system_parameters (
    parameter_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Parameter identification
    parameter_key TEXT UNIQUE NOT NULL,
    parameter_value JSONB NOT NULL,
    parameter_type TEXT NOT NULL DEFAULT 'string',
    description TEXT,
    
    -- Configuration
    is_editable BOOLEAN DEFAULT true,
    requires_restart BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT valid_parameter_type CHECK (parameter_type IN ('string', 'number', 'boolean', 'object', 'array'))
);

-- =====================================================
-- BRAND INTEGRATIONS TABLE
-- =====================================================
-- External service connections per brand
CREATE TABLE core.brand_integrations (
    integration_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Integration details
    service_name TEXT NOT NULL,
    service_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'inactive',
    
    -- Configuration
    config JSONB DEFAULT '{}',
    credentials JSONB DEFAULT '{}', -- Encrypted in application layer
    
    -- Status and health
    last_sync_at TIMESTAMPTZ,
    last_error TEXT,
    error_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES core.users(user_id),
    
    -- Constraints
    CONSTRAINT valid_service_type CHECK (service_type IN ('whatsapp', 'email', 'crm', 'analytics', 'payment', 'social', 'other')),
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'error', 'pending'))
);

-- =====================================================
-- AUDIT LOG TABLE
-- =====================================================
-- System-wide audit trail for all significant changes
CREATE TABLE core.audit_log (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID REFERENCES core.brands(brand_id) ON DELETE SET NULL,
    
    -- Action details
    table_name TEXT NOT NULL,
    record_id UUID,
    action TEXT NOT NULL,
    old_values JSONB,
    new_values JSONB,
    
    -- Actor information
    user_id UUID REFERENCES core.users(user_id),
    ip_address INET,
    user_agent TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_action CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT'))
);

-- =====================================================
-- INDEXES FOR CORE SCHEMA
-- =====================================================

-- Brands indexes
CREATE INDEX IF NOT EXISTS idx_brands_slug ON core.brands(brand_slug);
CREATE INDEX IF NOT EXISTS idx_brands_active ON core.brands(is_active) WHERE is_active = true;

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_brand_id ON core.users(brand_id);
CREATE INDEX IF NOT EXISTS idx_users_auth_user_id ON core.users(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON core.users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON core.users(is_active) WHERE is_active = true;

-- Brand settings indexes
CREATE INDEX IF NOT EXISTS idx_brand_settings_brand_id ON core.brand_settings(brand_id);
CREATE INDEX IF NOT EXISTS idx_brand_settings_key ON core.brand_settings(setting_key);
CREATE INDEX IF NOT EXISTS idx_brand_settings_active ON core.brand_settings(is_active) WHERE is_active = true;

-- System parameters indexes
CREATE INDEX IF NOT EXISTS idx_system_parameters_key ON core.system_parameters(parameter_key);
CREATE INDEX IF NOT EXISTS idx_system_parameters_editable ON core.system_parameters(is_editable) WHERE is_editable = true;

-- Brand integrations indexes
CREATE INDEX IF NOT EXISTS idx_brand_integrations_brand_id ON core.brand_integrations(brand_id);
CREATE INDEX IF NOT EXISTS idx_brand_integrations_service ON core.brand_integrations(service_name);
CREATE INDEX IF NOT EXISTS idx_brand_integrations_status ON core.brand_integrations(status);

-- Audit log indexes
CREATE INDEX IF NOT EXISTS idx_audit_log_brand_id ON core.audit_log(brand_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_table_name ON core.audit_log(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON core.audit_log(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON core.audit_log(user_id);

-- =====================================================
-- TRIGGERS FOR CORE SCHEMA
-- =====================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION core.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update triggers
CREATE TRIGGER update_brands_updated_at 
    BEFORE UPDATE ON core.brands 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON core.users 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

CREATE TRIGGER update_brand_settings_updated_at 
    BEFORE UPDATE ON core.brand_settings 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

CREATE TRIGGER update_system_parameters_updated_at 
    BEFORE UPDATE ON core.system_parameters 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

CREATE TRIGGER update_brand_integrations_updated_at 
    BEFORE UPDATE ON core.brand_integrations 
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- =====================================================
-- COMMENTS FOR CORE SCHEMA
-- =====================================================

COMMENT ON SCHEMA core IS 'Core configuration and multi-tenancy schema for Big Appetite OS';
COMMENT ON TABLE core.brands IS 'Central tenant isolation - every piece of data belongs to a brand';
COMMENT ON TABLE core.users IS 'Brand-scoped user management with role-based access';
COMMENT ON TABLE core.brand_settings IS 'Flexible configuration storage per brand';
COMMENT ON TABLE core.system_parameters IS 'Global system configuration affecting all brands';
COMMENT ON TABLE core.brand_integrations IS 'External service connections and credentials per brand';
COMMENT ON TABLE core.audit_log IS 'System-wide audit trail for compliance and debugging';

COMMENT ON COLUMN core.brands.brand_slug IS 'URL-safe identifier for the brand';
COMMENT ON COLUMN core.brands.settings IS 'Brand-specific configuration as JSONB';
COMMENT ON COLUMN core.users.permissions IS 'Granular permissions as JSONB object';
COMMENT ON COLUMN core.brand_settings.setting_value IS 'Flexible value storage as JSONB';
COMMENT ON COLUMN core.brand_integrations.credentials IS 'Encrypted credentials for external services';
COMMENT ON COLUMN core.audit_log.old_values IS 'Previous state before change';
COMMENT ON COLUMN core.audit_log.new_values IS 'New state after change';
