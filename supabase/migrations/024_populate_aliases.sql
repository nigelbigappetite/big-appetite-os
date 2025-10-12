-- =====================================================
-- Stage 0: Product Intelligence Foundation
-- Migration 024: Populate Product and Sauce Aliases
-- =====================================================

-- Populate sauce aliases for mention detection
INSERT INTO products.product_aliases (sauce_id, alias_text, alias_type, confidence)
VALUES
-- Honey Sesame variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'changs_honey_sesame'), 'honey sesame', 'short_name', 1.0),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'changs_honey_sesame'), 'HS', 'abbreviation', 0.9),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'changs_honey_sesame'), 'honey sesh', 'colloquial', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'changs_honey_sesame'), 'sesame', 'short_name', 0.8),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'changs_honey_sesame'), 'the sweet one', 'colloquial', 0.95),

-- Buffalo variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'), 'buffalo', 'short_name', 0.9),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'), 'Jarvs', 'short_name', 0.95),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'), 'jarvs', 'short_name', 0.95),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'), 'tang buff', 'colloquial', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'jarvs_tangy_buffalo'), 'the tangy one', 'colloquial', 0.9),

-- Korean Heat variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'korean_heat'), 'korean', 'short_name', 0.9),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'korean_heat'), 'KH', 'abbreviation', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'korean_heat'), 'gochujang', 'ingredient', 0.8),

-- Mango Mazzaline variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'mango_mazzaline'), 'mango', 'short_name', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'mango_mazzaline'), 'mazzaline', 'short_name', 0.9),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'mango_mazzaline'), 'scotch bonnet', 'ingredient', 0.8),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'mango_mazzaline'), 'the mango one', 'colloquial', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'mango_mazzaline'), 'tropical heat', 'colloquial', 0.85),

-- Island BBQ variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'island_bbq'), 'island', 'short_name', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'island_bbq'), 'chipotle bbq', 'descriptor', 0.9),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'island_bbq'), 'chipotle', 'short_name', 0.8),

-- Flamin Hoisin variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'flamin_hoisin'), 'hoisin', 'short_name', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'flamin_hoisin'), 'flaming hoisin', 'misspelling', 0.95),

-- Honey Mustard variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'honey_mustard'), 'honey must', 'abbreviation', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'honey_mustard'), 'HM', 'abbreviation', 0.8),

-- Sweet Chilli variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'sweet_chilli'), 'sweet chili', 'misspelling', 0.95),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'sweet_chilli'), 'SC', 'abbreviation', 0.8),

-- Shack Sauce variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'sriracha_mayo'), 'shack sauce', 'colloquial', 1.0),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'sriracha_mayo'), 'sriracha', 'short_name', 0.85),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'sriracha_mayo'), 'spicy mayo', 'colloquial', 0.9),

-- Blue Cheese variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'blue_cheese'), 'bleu cheese', 'misspelling', 0.95),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'blue_cheese'), 'blue', 'short_name', 0.8),

-- Plain variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'plain'), 'no sauce', 'descriptor', 0.95),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'plain'), 'dry', 'descriptor', 0.9),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'plain'), 'plain wings', 'descriptor', 0.95),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'plain'), 'naked', 'colloquial', 0.85),

-- Note: 12 Wings (2 Flavors) product aliases will be added after the product is created in migration 026

-- Smokey BBQ variations
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'smokey_bbq'), 'smoky bbq', 'misspelling', 0.95),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'smokey_bbq'), 'classic bbq', 'descriptor', 0.9),
((SELECT sauce_id FROM products.sauces WHERE sauce_name = 'smokey_bbq'), 'regular bbq', 'descriptor', 0.85);

-- Verify aliases population
SELECT 
  s.display_name,
  COUNT(a.alias_id) as alias_count,
  string_agg(a.alias_text, ', ' ORDER BY a.confidence DESC) as aliases
FROM products.sauces s
LEFT JOIN products.product_aliases a ON s.sauce_id = a.sauce_id
GROUP BY s.sauce_id, s.display_name
ORDER BY alias_count DESC;

-- Count total aliases
SELECT COUNT(*) as total_aliases FROM products.product_aliases;
