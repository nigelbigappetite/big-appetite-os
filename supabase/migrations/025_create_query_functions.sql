-- =====================================================
-- Stage 0: Product Intelligence Foundation
-- Migration 025: Create Query Functions for Belief Extraction
-- =====================================================

-- =====================================================
-- Function 1: get_sauce_by_name
-- Find sauce by name, short name, or display name
-- =====================================================
CREATE OR REPLACE FUNCTION products.get_sauce_by_name(search_name TEXT)
RETURNS TABLE (
  sauce_id UUID,
  display_name TEXT,
  primary_flavor TEXT,
  secondary_flavor TEXT,
  spice_level INTEGER,
  sweetness INTEGER,
  savory INTEGER,
  tanginess INTEGER,
  heat INTEGER,
  tags TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.sauce_id,
    s.display_name,
    s.primary_flavor,
    s.secondary_flavor,
    s.spice_level,
    s.sweetness,
    s.savory,
    s.tanginess,
    s.heat,
    s.tags
  FROM products.sauces s
  WHERE 
    LOWER(s.sauce_name) = LOWER(search_name)
    OR LOWER(s.display_name) ILIKE '%' || LOWER(search_name) || '%'
    OR LOWER(s.short_name) = LOWER(search_name)
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function 2: detect_product_mention
-- Detect product and sauce mentions in customer signals
-- =====================================================
CREATE OR REPLACE FUNCTION products.detect_product_mention(signal_text TEXT)
RETURNS TABLE (
  entity_type TEXT, -- 'product' or 'sauce'
  entity_id UUID,
  entity_name TEXT,
  confidence FLOAT,
  spice_level INTEGER,
  primary_flavor TEXT
) AS $$
BEGIN
  RETURN QUERY
  -- Check for sauce mentions via aliases
  SELECT DISTINCT
    'sauce'::TEXT as entity_type,
    s.sauce_id as entity_id,
    s.display_name as entity_name,
    CASE 
      WHEN LOWER(signal_text) ILIKE '%' || LOWER(s.display_name) || '%' THEN 0.95
      WHEN LOWER(signal_text) ILIKE '%' || LOWER(s.short_name) || '%' THEN 0.90
      WHEN LOWER(signal_text) ILIKE '%' || LOWER(a.alias_text) || '%' THEN a.confidence
      ELSE 0.5
    END as confidence,
    s.spice_level,
    s.primary_flavor
  FROM products.sauces s
  LEFT JOIN products.product_aliases a ON s.sauce_id = a.sauce_id
  WHERE 
    LOWER(signal_text) ILIKE '%' || LOWER(s.display_name) || '%'
    OR LOWER(signal_text) ILIKE '%' || LOWER(s.short_name) || '%'
    OR LOWER(signal_text) ILIKE '%' || LOWER(a.alias_text) || '%'
  
  UNION
  
  -- Check for product mentions
  SELECT DISTINCT
    'product'::TEXT as entity_type,
    p.product_id as entity_id,
    p.product_name as entity_name,
    CASE 
      WHEN LOWER(signal_text) ILIKE '%' || LOWER(p.product_name) || '%' THEN 0.95
      WHEN LOWER(signal_text) ILIKE '%' || LOWER(a.alias_text) || '%' THEN a.confidence
      ELSE 0.5
    END as confidence,
    s.spice_level,
    s.primary_flavor
  FROM products.catalog p
  LEFT JOIN products.product_aliases a ON p.product_id = a.product_id
  LEFT JOIN products.sauces s ON p.default_sauce_id = s.sauce_id
  WHERE 
    LOWER(signal_text) ILIKE '%' || LOWER(p.product_name) || '%'
    OR LOWER(signal_text) ILIKE '%' || LOWER(a.alias_text) || '%'
  
  ORDER BY confidence DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function 3: get_sauce_attributes
-- Get complete sauce attributes as JSON
-- =====================================================
CREATE OR REPLACE FUNCTION products.get_sauce_attributes(search_sauce TEXT)
RETURNS JSON AS $$
DECLARE
  sauce_data JSON;
BEGIN
  SELECT json_build_object(
    'sauce_id', sauce_id,
    'sauce_name', sauce_name,
    'display_name', display_name,
    'primary_flavor', primary_flavor,
    'secondary_flavor', secondary_flavor,
    'spice_level', spice_level,
    'spice_type', spice_type,
    'flavor_dimensions', json_build_object(
      'sweetness', sweetness,
      'savory', savory,
      'tanginess', tanginess,
      'smokiness', smokiness,
      'heat', heat
    ),
    'texture', texture,
    'base_ingredients', base_ingredients,
    'description', description,
    'tags', tags
  ) INTO sauce_data
  FROM products.sauces
  WHERE LOWER(sauce_name) = LOWER(search_sauce)
     OR LOWER(display_name) ILIKE '%' || LOWER(search_sauce) || '%'
     OR LOWER(short_name) = LOWER(search_sauce)
  LIMIT 1;
  
  RETURN sauce_data;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function 4: get_products_by_spice_level
-- Find products within a spice level range
-- =====================================================
CREATE OR REPLACE FUNCTION products.get_products_by_spice_level(
  min_level INTEGER,
  max_level INTEGER
)
RETURNS TABLE (
  product_name TEXT,
  sauce_name TEXT,
  spice_level INTEGER,
  primary_flavor TEXT,
  price NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.product_name,
    s.display_name as sauce_name,
    s.spice_level,
    s.primary_flavor,
    p.base_price
  FROM products.catalog p
  LEFT JOIN products.product_sauces ps ON p.product_id = ps.product_id
  LEFT JOIN products.sauces s ON ps.sauce_id = s.sauce_id OR p.default_sauce_id = s.sauce_id
  WHERE s.spice_level BETWEEN min_level AND max_level
  ORDER BY s.spice_level, p.product_name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function 5: get_products_by_flavor
-- Find products by primary or secondary flavor
-- =====================================================
CREATE OR REPLACE FUNCTION products.get_products_by_flavor(
  flavor_type TEXT
)
RETURNS TABLE (
  product_name TEXT,
  sauce_name TEXT,
  primary_flavor TEXT,
  spice_level INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.product_name,
    s.display_name as sauce_name,
    s.primary_flavor,
    s.spice_level
  FROM products.catalog p
  LEFT JOIN products.product_sauces ps ON p.product_id = ps.product_id
  LEFT JOIN products.sauces s ON ps.sauce_id = s.sauce_id OR p.default_sauce_id = s.sauce_id
  WHERE LOWER(s.primary_flavor) = LOWER(flavor_type)
     OR LOWER(s.secondary_flavor) = LOWER(flavor_type)
  ORDER BY p.product_name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function 6: search_sauces_by_attributes
-- Search sauces by flavor attributes
-- =====================================================
CREATE OR REPLACE FUNCTION products.search_sauces_by_attributes(
  min_sweetness INTEGER DEFAULT 0,
  max_spice INTEGER DEFAULT 10,
  required_tags TEXT[] DEFAULT NULL
)
RETURNS TABLE (
  sauce_name TEXT,
  display_name TEXT,
  spice_level INTEGER,
  sweetness INTEGER,
  tags TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.sauce_name,
    s.display_name,
    s.spice_level,
    s.sweetness,
    s.tags
  FROM products.sauces s
  WHERE 
    s.sweetness >= min_sweetness
    AND s.spice_level <= max_spice
    AND (required_tags IS NULL OR s.tags && required_tags)
  ORDER BY s.sweetness DESC, s.spice_level;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function 7: get_sauce_recommendations
-- Get sauce recommendations based on customer preferences
-- =====================================================
CREATE OR REPLACE FUNCTION products.get_sauce_recommendations(
  preferred_spice_level INTEGER,
  preferred_flavor TEXT,
  max_results INTEGER DEFAULT 5
)
RETURNS TABLE (
  sauce_name TEXT,
  display_name TEXT,
  spice_level INTEGER,
  primary_flavor TEXT,
  match_score FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.sauce_name,
    s.display_name,
    s.spice_level,
    s.primary_flavor,
    CASE 
      WHEN s.spice_level = preferred_spice_level AND LOWER(s.primary_flavor) = LOWER(preferred_flavor) THEN 1.0
      WHEN s.spice_level = preferred_spice_level OR LOWER(s.primary_flavor) = LOWER(preferred_flavor) THEN 0.7
      WHEN ABS(s.spice_level - preferred_spice_level) <= 1 THEN 0.5
      ELSE 0.3
    END as match_score
  FROM products.sauces s
  WHERE s.is_wing_sauce = true
  ORDER BY match_score DESC, s.spice_level
  LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Comments for documentation
-- =====================================================
COMMENT ON FUNCTION products.get_sauce_by_name(TEXT) IS 'Find sauce by name, short name, or display name';
COMMENT ON FUNCTION products.detect_product_mention(TEXT) IS 'Detect product and sauce mentions in customer signals for belief extraction';
COMMENT ON FUNCTION products.get_sauce_attributes(TEXT) IS 'Get complete sauce attributes as JSON for detailed analysis';
COMMENT ON FUNCTION products.get_products_by_spice_level(INTEGER, INTEGER) IS 'Find products within a spice level range';
COMMENT ON FUNCTION products.get_products_by_flavor(TEXT) IS 'Find products by primary or secondary flavor';
COMMENT ON FUNCTION products.search_sauces_by_attributes(INTEGER, INTEGER, TEXT[]) IS 'Search sauces by flavor attributes with flexible criteria';
COMMENT ON FUNCTION products.get_sauce_recommendations(INTEGER, TEXT, INTEGER) IS 'Get sauce recommendations based on customer preferences';
