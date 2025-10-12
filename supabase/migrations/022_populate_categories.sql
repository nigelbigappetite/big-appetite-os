-- =====================================================
-- Stage 0: Product Intelligence Foundation
-- Migration 022: Populate Product Categories
-- =====================================================

-- Populate product categories
INSERT INTO products.categories (category_name, display_order, description, has_sauce_options)
VALUES
('Bundles', 1, 'Meal deals and combo packages', false),
('Sandwiches', 2, 'Chicken sandwiches with fixed sauces', false),
('Wraps', 3, 'Chicken wraps with fixed sauces', false),
('Wings', 4, 'Bone-in chicken wings with sauce choice', true),
('Boneless Bites', 5, 'Boneless chicken bites with sauce choice', true),
('Tenders', 6, 'Chicken tenders with sauce choice', true),
('Loaded Fries', 7, 'Fries topped with chicken and sauce', false),
('Sides', 8, 'Side dishes and accompaniments', false),
('Kids Meals', 9, 'Child-sized portions', true),
('Dips', 10, 'Extra sauce portions', false),
('Drinks', 11, 'Beverages', false);

-- Verify categories population
SELECT 
  category_name, 
  display_order, 
  description,
  has_sauce_options
FROM products.categories 
ORDER BY display_order;
