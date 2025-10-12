-- =====================================================
-- Stage 0: Product Intelligence Foundation
-- Migration 026: Import Menu Data via SQL
-- =====================================================

-- Import all menu items from the Wing Shack menu
-- This replaces the need for the Node.js import script

-- =====================================================
-- BUNDLES
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, price_tier, popularity_tier, is_active)
SELECT 
  'Deluxe Bundle for 1',
  (SELECT category_id FROM products.categories WHERE category_name = 'Bundles'),
  19.95,
  'premium',
  'signature',
  true
UNION ALL
SELECT 
  'Snuggle Bundle for 2',
  (SELECT category_id FROM products.categories WHERE category_name = 'Bundles'),
  34.95,
  'premium',
  'signature',
  true
UNION ALL
SELECT 
  'Family Feast (for 3–4)',
  (SELECT category_id FROM products.categories WHERE category_name = 'Bundles'),
  54.95,
  'premium',
  'signature',
  true;

-- =====================================================
-- SANDWICHES
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, default_sauce_id, price_tier, popularity_tier, is_active)
SELECT 
  'Jarv''s Banging Buffalo Chicken Sandwich',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sandwiches'),
  8.95,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'),
  'standard',
  'signature',
  true
UNION ALL
SELECT 
  'Island BBQ Chicken Sandwich',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sandwiches'),
  8.95,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'island_bbq'),
  'standard',
  'popular',
  true
UNION ALL
SELECT 
  'Original Chicken Sandwich',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sandwiches'),
  8.95,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'plain'),
  'standard',
  'standard',
  true
UNION ALL
SELECT 
  'Banging Buffalo Chicken Sandwich',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sandwiches'),
  8.95,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'),
  'standard',
  'signature',
  true;

-- =====================================================
-- WRAPS
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, default_sauce_id, price_tier, popularity_tier, is_active)
SELECT 
  'Original Chicken Wrap',
  (SELECT category_id FROM products.categories WHERE category_name = 'Wraps'),
  7.95,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'plain'),
  'standard',
  'standard',
  true
UNION ALL
SELECT 
  'Jarv''s Tangy Buffalo Wrap',
  (SELECT category_id FROM products.categories WHERE category_name = 'Wraps'),
  7.95,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'),
  'standard',
  'signature',
  true
UNION ALL
SELECT 
  'Smokey BBQ Wrap',
  (SELECT category_id FROM products.categories WHERE category_name = 'Wraps'),
  7.95,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'smokey_bbq'),
  'standard',
  'popular',
  true;

-- =====================================================
-- WINGS (with sauce options)
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, portion_size, has_sauce_options, price_tier, popularity_tier, is_active)
SELECT 
  '6 Wings',
  (SELECT category_id FROM products.categories WHERE category_name = 'Wings'),
  7.75,
  '6 Wings',
  true,
  'standard',
  'popular',
  true
UNION ALL
SELECT 
  '8 Wings',
  (SELECT category_id FROM products.categories WHERE category_name = 'Wings'),
  9.50,
  '8 Wings',
  true,
  'standard',
  'popular',
  true
UNION ALL
SELECT 
  '12 Wings',
  (SELECT category_id FROM products.categories WHERE category_name = 'Wings'),
  12.75,
  '12 Wings',
  true,
  'premium',
  'signature',
  true;

-- =====================================================
-- BONELESS BITES (with sauce options)
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, portion_size, has_sauce_options, price_tier, popularity_tier, is_active)
SELECT 
  '8 Bites',
  (SELECT category_id FROM products.categories WHERE category_name = 'Boneless Bites'),
  9.75,
  '8 Bites',
  true,
  'standard',
  'popular',
  true
UNION ALL
SELECT 
  '10 Bites',
  (SELECT category_id FROM products.categories WHERE category_name = 'Boneless Bites'),
  11.75,
  '10 Bites',
  true,
  'premium',
  'popular',
  true
UNION ALL
SELECT 
  '12 Bites',
  (SELECT category_id FROM products.categories WHERE category_name = 'Boneless Bites'),
  13.75,
  '12 Bites',
  true,
  'premium',
  'signature',
  true;

-- =====================================================
-- TENDERS (with sauce options)
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, portion_size, has_sauce_options, price_tier, popularity_tier, is_active)
SELECT 
  '3 Tenders',
  (SELECT category_id FROM products.categories WHERE category_name = 'Tenders'),
  6.25,
  '3 Tenders',
  true,
  'standard',
  'standard',
  true
UNION ALL
SELECT 
  '5 Tenders',
  (SELECT category_id FROM products.categories WHERE category_name = 'Tenders'),
  8.50,
  '5 Tenders',
  true,
  'standard',
  'popular',
  true;

-- =====================================================
-- LOADED FRIES
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, default_sauce_id, price_tier, popularity_tier, is_active)
SELECT 
  'Banging Buffalo Loaded Fries',
  (SELECT category_id FROM products.categories WHERE category_name = 'Loaded Fries'),
  7.50,
  (SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'),
  'standard',
  'signature',
  true
UNION ALL
SELECT 
  'Cali Loaded Fries',
  (SELECT category_id FROM products.categories WHERE category_name = 'Loaded Fries'),
  7.50,
  NULL,
  'standard',
  'popular',
  true;

-- =====================================================
-- SIDES
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, price_tier, popularity_tier, is_active)
SELECT 
  'Fries',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sides'),
  3.50,
  'budget',
  'standard',
  true
UNION ALL
SELECT 
  'Cajun Fries',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sides'),
  4.00,
  'budget',
  'popular',
  true
UNION ALL
SELECT 
  'Sweet Potato Fries',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sides'),
  4.25,
  'budget',
  'popular',
  true
UNION ALL
SELECT 
  'Mac n Cheese Bites',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sides'),
  5.75,
  'standard',
  'popular',
  true
UNION ALL
SELECT 
  'Plantain',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sides'),
  3.20,
  'budget',
  'specialty',
  true
UNION ALL
SELECT 
  'Slaw',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sides'),
  3.20,
  'budget',
  'standard',
  true
UNION ALL
SELECT 
  'Jalapeno Hush Puppies',
  (SELECT category_id FROM products.categories WHERE category_name = 'Sides'),
  5.75,
  'standard',
  'specialty',
  true;

-- =====================================================
-- KIDS MEALS (with sauce options)
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, has_sauce_options, price_tier, popularity_tier, is_active)
SELECT 
  'Kids Wing Meal',
  (SELECT category_id FROM products.categories WHERE category_name = 'Kids Meals'),
  6.50,
  true,
  'standard',
  'standard',
  true
UNION ALL
SELECT 
  'Kids Boneless Meal',
  (SELECT category_id FROM products.categories WHERE category_name = 'Kids Meals'),
  6.50,
  true,
  'standard',
  'standard',
  true;

-- =====================================================
-- DRINKS
-- =====================================================
INSERT INTO products.catalog (product_name, category_id, base_price, price_tier, popularity_tier, is_active)
SELECT 
  'Sprite',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'standard',
  true
UNION ALL
SELECT 
  'Coke',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'popular',
  true
UNION ALL
SELECT 
  'Diet Coke',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'standard',
  true
UNION ALL
SELECT 
  'Fanta Orange',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'standard',
  true
UNION ALL
SELECT 
  'Fanta Fruit Twist',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'standard',
  true
UNION ALL
SELECT 
  'Ting',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'specialty',
  true
UNION ALL
SELECT 
  'Sparkling Water',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'standard',
  true
UNION ALL
SELECT 
  'Still Water',
  (SELECT category_id FROM products.categories WHERE category_name = 'Drinks'),
  2.50,
  'budget',
  'standard',
  true;

-- =====================================================
-- CREATE PRODUCT-SAUCE MAPPINGS
-- =====================================================

-- Wings: 6 Wings (specific sauces)
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  (SELECT product_id FROM products.catalog WHERE product_name = '6 Wings'),
  sauce_id
FROM products.sauces
WHERE sauce_name IN (
  'island_bbq', 'smokey_bbq', 'changs_honey_sesame', 'korean_heat', 
  'flamin_hoisin', 'jarvs_tangy_buffalo', 'honey_mustard', 'mango_mazzaline', 'plain'
);

-- Wings: 8 Wings (all wing sauces)
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  (SELECT product_id FROM products.catalog WHERE product_name = '8 Wings'),
  sauce_id
FROM products.sauces
WHERE is_wing_sauce = true;

-- Wings: 12 Wings (all wing sauces)
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  (SELECT product_id FROM products.catalog WHERE product_name = '12 Wings'),
  sauce_id
FROM products.sauces
WHERE is_wing_sauce = true;

-- Wings: 12 Wings (2 Flavors) - Special offering where customer chooses 2 flavors of 6 each
INSERT INTO products.catalog (product_name, category_id, base_price, portion_size, has_sauce_options, price_tier, popularity_tier, is_active, tags)
SELECT 
  '12 Wings (2 Flavors)',
  (SELECT category_id FROM products.categories WHERE category_name = 'Wings'),
  12.75,
  '12 Wings (6 of each flavor)',
  true,
  'premium',
  'signature',
  true,
  ARRAY['combo', 'two-flavor', 'popular'];

-- Wings: 12 Wings (2 Flavors) - All wing sauces available
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  (SELECT product_id FROM products.catalog WHERE product_name = '12 Wings (2 Flavors)'),
  sauce_id
FROM products.sauces
WHERE is_wing_sauce = true;

-- Boneless Bites: All sizes (all wing sauces)
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  p.product_id,
  s.sauce_id
FROM products.catalog p
CROSS JOIN products.sauces s
WHERE p.product_name IN ('8 Bites', '10 Bites', '12 Bites')
  AND s.is_wing_sauce = true;

-- Tenders: 3 Tenders (specific sauces)
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  (SELECT product_id FROM products.catalog WHERE product_name = '3 Tenders'),
  sauce_id
FROM products.sauces
WHERE sauce_name IN (
  'jarvs_tangy_buffalo', 'changs_honey_sesame', 'smokey_bbq', 'island_bbq', 
  'honey_mustard', 'mango_mazzaline', 'flamin_hoisin', 'korean_heat', 'plain'
);

-- Tenders: 5 Tenders (specific sauces)
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  (SELECT product_id FROM products.catalog WHERE product_name = '5 Tenders'),
  sauce_id
FROM products.sauces
WHERE sauce_name IN (
  'jarvs_tangy_buffalo', 'changs_honey_sesame', 'smokey_bbq', 'island_bbq', 
  'honey_mustard', 'mango_mazzaline', 'flamin_hoisin', 'korean_heat', 'plain'
);

-- Kids Meals: All kids meals (all wing sauces)
INSERT INTO products.product_sauces (product_id, sauce_id)
SELECT 
  p.product_id,
  s.sauce_id
FROM products.catalog p
CROSS JOIN products.sauces s
WHERE p.product_name IN ('Kids Wing Meal', 'Kids Boneless Meal')
  AND s.is_wing_sauce = true;

-- =====================================================
-- ADD PRODUCT ALIASES FOR 12 WINGS (2 FLAVORS)
-- =====================================================

-- 12 Wings (2 Flavors) product aliases
INSERT INTO products.product_aliases (product_id, alias_text, alias_type, confidence)
VALUES
((SELECT product_id FROM products.catalog WHERE product_name = '12 Wings (2 Flavors)'), '12 wings 2 flavors', 'short_name', 0.95),
((SELECT product_id FROM products.catalog WHERE product_name = '12 Wings (2 Flavors)'), '12 wings two flavors', 'misspelling', 0.95),
((SELECT product_id FROM products.catalog WHERE product_name = '12 Wings (2 Flavors)'), '12 wings combo', 'colloquial', 0.9),
((SELECT product_id FROM products.catalog WHERE product_name = '12 Wings (2 Flavors)'), '12 wings mixed', 'colloquial', 0.85),
((SELECT product_id FROM products.catalog WHERE product_name = '12 Wings (2 Flavors)'), '12 wings split', 'colloquial', 0.8);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Show import summary
SELECT 
  c.category_name,
  COUNT(p.product_id) as product_count
FROM products.catalog p
JOIN products.categories c ON p.category_id = c.category_id
WHERE p.is_active = true
GROUP BY c.category_name, c.display_order
ORDER BY c.display_order;

-- Show products with sauce options
SELECT 
  p.product_name,
  COUNT(ps.sauce_id) as available_sauces
FROM products.catalog p
LEFT JOIN products.product_sauces ps ON p.product_id = ps.product_id
WHERE p.has_sauce_options = true
GROUP BY p.product_name
ORDER BY p.product_name;

-- Show 12 Wings options specifically
SELECT 
  p.product_name,
  p.portion_size,
  COUNT(ps.sauce_id) as available_sauces
FROM products.catalog p
LEFT JOIN products.product_sauces ps ON p.product_id = ps.product_id
WHERE p.product_name LIKE '%12 Wings%'
GROUP BY p.product_id, p.product_name, p.portion_size
ORDER BY p.product_name;

-- Show total counts
SELECT 
  'Total Products' as metric,
  COUNT(*) as count
FROM products.catalog
WHERE is_active = true
UNION ALL
SELECT 
  'Products with Sauce Options',
  COUNT(*)
FROM products.catalog
WHERE has_sauce_options = true
UNION ALL
SELECT 
  'Product-Sauce Mappings',
  COUNT(*)
FROM products.product_sauces;
