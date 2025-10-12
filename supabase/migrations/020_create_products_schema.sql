-- =====================================================
-- Stage 0: Product Intelligence Foundation
-- Migration 020: Create Products Schema
-- =====================================================

-- Create products schema
CREATE SCHEMA IF NOT EXISTS products;

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Table 1: products.sauces
-- Complete sauce knowledge base with flavor profiles
-- =====================================================
CREATE TABLE products.sauces (
  sauce_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sauce_name TEXT NOT NULL UNIQUE, -- snake_case identifier
  display_name TEXT NOT NULL, -- Human-readable full name
  short_name TEXT, -- Common shortened version
  
  -- Flavor Profile
  primary_flavor TEXT NOT NULL, -- sweet, savory, spicy, tangy, smoky
  secondary_flavor TEXT, -- Optional secondary flavor
  spice_level INTEGER NOT NULL CHECK (spice_level >= 0 AND spice_level <= 10),
  spice_type TEXT NOT NULL, -- none, mild_heat, medium_heat, hot, very_hot, extreme
  
  -- Flavor Dimensions (0-10 scale each)
  sweetness INTEGER CHECK (sweetness >= 0 AND sweetness <= 10),
  savory INTEGER CHECK (savory >= 0 AND savory <= 10),
  tanginess INTEGER CHECK (tanginess >= 0 AND tanginess <= 10),
  smokiness INTEGER CHECK (smokiness >= 0 AND smokiness <= 10),
  heat INTEGER CHECK (heat >= 0 AND heat <= 10),
  
  -- Physical Characteristics
  texture TEXT, -- sticky, thick, creamy, vinegary, etc.
  base_ingredients TEXT[], -- Array of key ingredients
  
  -- Customer Intelligence
  description TEXT, -- Marketing/flavor description
  customer_descriptors TEXT[], -- How customers refer to it
  tags TEXT[], -- Searchable tags
  
  -- Metadata
  is_dip BOOLEAN DEFAULT false, -- Is this available as a dip?
  is_wing_sauce BOOLEAN DEFAULT true, -- Available for wings/bites/tenders?
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast lookups
CREATE INDEX idx_sauces_name ON products.sauces(sauce_name);
CREATE INDEX idx_sauces_spice_level ON products.sauces(spice_level);
CREATE INDEX idx_sauces_primary_flavor ON products.sauces(primary_flavor);
CREATE INDEX idx_sauces_wing_sauce ON products.sauces(is_wing_sauce) WHERE is_wing_sauce = true;

-- =====================================================
-- Table 2: products.spice_scale
-- Reference table for spice level meanings
-- =====================================================
CREATE TABLE products.spice_scale (
  level INTEGER PRIMARY KEY CHECK (level >= 0 AND level <= 10),
  name TEXT NOT NULL,
  description TEXT,
  scoville_low INTEGER,
  scoville_high INTEGER,
  customer_tolerance TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Table 3: products.categories
-- Product categories for organization
-- =====================================================
CREATE TABLE products.categories (
  category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_name TEXT NOT NULL UNIQUE,
  display_order INTEGER,
  description TEXT,
  has_sauce_options BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Table 4: products.catalog
-- Main product catalog with pricing and attributes
-- =====================================================
CREATE TABLE products.catalog (
  product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_name TEXT NOT NULL,
  category_id UUID REFERENCES products.categories(category_id),
  base_price NUMERIC(10,2),
  
  -- Product Specifics
  portion_size TEXT, -- "6 Wings", "3 Tenders", "Regular", etc.
  has_sauce_options BOOLEAN DEFAULT false, -- Can customer choose sauce?
  default_sauce_id UUID REFERENCES products.sauces(sauce_id), -- For items with fixed sauce
  
  -- Derived Attributes
  typical_spice_range TEXT, -- "0-10" for customizable items
  typical_flavor_profile TEXT, -- Derived from default sauce or "Various"
  
  -- Business Attributes
  price_tier TEXT, -- budget (<£5), standard (£5-10), premium (>£10)
  popularity_tier TEXT, -- signature, popular, standard, specialty
  
  -- Tags
  tags TEXT[],
  
  -- Dietary & Allergens
  allergens TEXT[],
  dietary_flags TEXT[], -- vegetarian, vegan, gluten_free, etc.
  
  -- Metadata
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_catalog_category ON products.catalog(category_id);
CREATE INDEX idx_catalog_price ON products.catalog(base_price);
CREATE INDEX idx_catalog_sauce_options ON products.catalog(has_sauce_options) WHERE has_sauce_options = true;

-- =====================================================
-- Table 5: products.product_sauces
-- Many-to-many mapping between products and available sauces
-- =====================================================
CREATE TABLE products.product_sauces (
  mapping_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products.catalog(product_id) ON DELETE CASCADE,
  sauce_id UUID REFERENCES products.sauces(sauce_id) ON DELETE CASCADE,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, sauce_id)
);

-- Indexes for fast sauce availability lookups
CREATE INDEX idx_product_sauces_product ON products.product_sauces(product_id);
CREATE INDEX idx_product_sauces_sauce ON products.product_sauces(sauce_id);

-- =====================================================
-- Table 6: products.product_aliases
-- Aliases for mention detection (abbreviations, misspellings, etc.)
-- =====================================================
CREATE TABLE products.product_aliases (
  alias_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products.catalog(product_id),
  sauce_id UUID REFERENCES products.sauces(sauce_id),
  alias_text TEXT NOT NULL,
  alias_type TEXT, -- abbreviation, misspelling, colloquial, short_name
  confidence FLOAT DEFAULT 1.0 CHECK (confidence >= 0 AND confidence <= 1),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (product_id IS NOT NULL OR sauce_id IS NOT NULL) -- Must reference one
);

-- Index for mention detection (case-insensitive)
CREATE INDEX idx_aliases_text ON products.product_aliases(LOWER(alias_text));

-- =====================================================
-- Comments for documentation
-- =====================================================
COMMENT ON SCHEMA products IS 'Product Intelligence Foundation - Complete knowledge base for Wing Shack menu and sauces';
COMMENT ON TABLE products.sauces IS 'Complete sauce knowledge base with flavor profiles, spice levels, and customer descriptors';
COMMENT ON TABLE products.spice_scale IS 'Reference table for spice level meanings and customer tolerance';
COMMENT ON TABLE products.categories IS 'Product categories for organization and filtering';
COMMENT ON TABLE products.catalog IS 'Main product catalog with pricing, attributes, and business intelligence';
COMMENT ON TABLE products.product_sauces IS 'Many-to-many mapping between products and available sauces';
COMMENT ON TABLE products.product_aliases IS 'Aliases for mention detection in customer signals';
