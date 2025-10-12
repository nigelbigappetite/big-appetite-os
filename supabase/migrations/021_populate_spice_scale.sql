-- =====================================================
-- Stage 0: Product Intelligence Foundation
-- Migration 021: Populate Spice Scale Reference
-- =====================================================

-- Populate spice scale reference table
INSERT INTO products.spice_scale (level, name, description, scoville_low, scoville_high, customer_tolerance)
VALUES
(0, 'None', 'No detectable heat', 0, 0, 'Everyone'),
(1, 'Mild', 'Gentle warmth (1-2)', 0, 2500, 'Everyone'),
(2, 'Mild', 'Gentle warmth (1-2)', 0, 2500, 'Everyone'),
(3, 'Medium', 'Noticeable kick (3-5)', 2500, 15000, 'Most people'),
(4, 'Medium', 'Noticeable kick (3-5)', 2500, 15000, 'Most people'),
(5, 'Medium', 'Noticeable kick (3-5)', 2500, 15000, 'Most people'),
(6, 'Hot', 'Clearly spicy but balanced (6-7)', 15000, 35000, 'Spice lovers'),
(7, 'Hot', 'Clearly spicy but balanced (6-7)', 15000, 35000, 'Spice lovers'),
(8, 'Very Hot', 'High burn – limited menu use (8-9)', 35000, 100000, 'Spice enthusiasts'),
(9, 'Very Hot', 'High burn – limited menu use (8-9)', 35000, 100000, 'Spice enthusiasts'),
(10, 'Extreme', 'Challenge heat (10)', 100000, 300000, 'Extreme only');

-- Verify spice scale population
SELECT 
  level, 
  name, 
  description,
  customer_tolerance
FROM products.spice_scale 
ORDER BY level;
