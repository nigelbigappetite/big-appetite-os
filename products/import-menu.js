#!/usr/bin/env node

/**
 * Stage 0: Product Intelligence Foundation
 * Menu Import Script
 * 
 * This script parses the Wing Shack menu JSON and populates the products.catalog table
 * with proper product-sauce mappings and business intelligence attributes.
 */

const fs = require('fs');
const path = require('path');

// Load environment variables
require('dotenv').config();

// Supabase client setup
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Load menu data
const menuPath = path.join(__dirname, 'menu.json');
const menuData = JSON.parse(fs.readFileSync(menuPath, 'utf8'));

/**
 * Determine price tier based on price
 */
function getPriceTier(price) {
  if (price < 5) return 'budget';
  if (price <= 10) return 'standard';
  return 'premium';
}

/**
 * Determine popularity tier based on product characteristics
 */
function getPopularityTier(productName, categoryName) {
  const name = productName.toLowerCase();
  
  // Signature items
  if (name.includes('jarv') || name.includes('buffalo')) return 'signature';
  
  // Popular items
  if (name.includes('honey sesame') || name.includes('island bbq')) return 'popular';
  if (categoryName === 'Wings' && name.includes('6 wings')) return 'popular';
  if (categoryName === 'Boneless Bites' && name.includes('8 bites')) return 'popular';
  
  // Specialty items
  if (name.includes('mango') || name.includes('korean')) return 'specialty';
  
  return 'standard';
}

/**
 * Get category ID by name
 */
async function getCategoryId(categoryName) {
  const { data, error } = await supabase
    .from('products.categories')
    .select('category_id')
    .eq('category_name', categoryName)
    .single();
  
  if (error) throw new Error(`Category not found: ${categoryName}`);
  return data.category_id;
}

/**
 * Get sauce ID by name
 */
async function getSauceId(sauceName) {
  const { data, error } = await supabase
    .from('products.sauces')
    .select('sauce_id')
    .eq('sauce_name', sauceName)
    .single();
  
  if (error) throw new Error(`Sauce not found: ${sauceName}`);
  return data.sauce_id;
}

/**
 * Get all wing sauce IDs (for "all" sauce options)
 */
async function getAllWingSauceIds() {
  const { data, error } = await supabase
    .from('products.sauces')
    .select('sauce_id')
    .eq('is_wing_sauce', true);
  
  if (error) throw error;
  return data.map(s => s.sauce_id);
}

/**
 * Process a single product item
 */
async function processProduct(item, categoryName, categoryId) {
  const product = {
    product_name: item.item,
    category_id: categoryId,
    base_price: item.price,
    portion_size: item.item.includes('Wings') || item.item.includes('Bites') || item.item.includes('Tenders') 
      ? item.item 
      : null,
    has_sauce_options: item.has_sauce_options || false,
    price_tier: getPriceTier(item.price),
    popularity_tier: getPopularityTier(item.item, categoryName),
    is_active: true
  };

  // Handle default sauce for sandwiches/wraps
  if (item.default_sauce) {
    const sauceId = await getSauceId(item.default_sauce);
    product.default_sauce_id = sauceId;
  }

  // Insert product
  const { data: productData, error: productError } = await supabase
    .from('products.catalog')
    .insert(product)
    .select()
    .single();

  if (productError) {
    console.error(`Error inserting product ${item.item}:`, productError);
    return null;
  }

  console.log(`✅ Inserted: ${item.item}`);
  return { productData, availableSauces: item.available_sauces };
}

/**
 * Create product-sauce mappings
 */
async function createProductSauceMappings(productId, availableSauces) {
  if (!availableSauces) return;

  let sauceIds = [];

  if (availableSauces === 'all') {
    sauceIds = await getAllWingSauceIds();
  } else if (Array.isArray(availableSauces)) {
    sauceIds = await Promise.all(
      availableSauces.map(sauceName => getSauceId(sauceName))
    );
  }

  // Create mappings
  const mappings = sauceIds.map(sauceId => ({
    product_id: productId,
    sauce_id: sauceId
  }));

  if (mappings.length > 0) {
    const { error } = await supabase
      .from('products.product_sauces')
      .insert(mappings);

    if (error) {
      console.error(`Error creating sauce mappings for product ${productId}:`, error);
    } else {
      console.log(`  📎 Created ${mappings.length} sauce mappings`);
    }
  }
}

/**
 * Main import function
 */
async function importMenu() {
  console.log('🚀 Starting Wing Shack menu import...\n');

  try {
    // Process each category
    for (const [categoryName, items] of Object.entries(menuData)) {
      console.log(`\n📂 Processing category: ${categoryName}`);
      
      const categoryId = await getCategoryId(categoryName);

      if (Array.isArray(items)) {
        // Simple array of items
        for (const item of items) {
          const result = await processProduct(item, categoryName, categoryId);
          if (result) {
            await createProductSauceMappings(result.productData.product_id, result.availableSauces);
          }
        }
      } else {
        // Object with nested items (Wings, Boneless Bites, Tenders)
        for (const [itemName, itemData] of Object.entries(items)) {
          const item = {
            item: itemName,
            ...itemData
          };
          
          const result = await processProduct(item, categoryName, categoryId);
          if (result) {
            await createProductSauceMappings(result.productData.product_id, result.availableSauces);
          }
        }
      }
    }

    console.log('\n🎉 Menu import completed successfully!');
    
    // Show summary
    const { data: summary } = await supabase
      .from('products.catalog')
      .select('category_id, products.categories(category_name)', { count: 'exact' })
      .eq('is_active', true);

    console.log('\n📊 Import Summary:');
    const categoryCounts = {};
    summary.forEach(item => {
      const catName = item.categories.category_name;
      categoryCounts[catName] = (categoryCounts[catName] || 0) + 1;
    });
    
    Object.entries(categoryCounts).forEach(([category, count]) => {
      console.log(`  ${category}: ${count} products`);
    });

  } catch (error) {
    console.error('❌ Import failed:', error);
    process.exit(1);
  }
}

// Run the import
if (require.main === module) {
  importMenu();
}

module.exports = { importMenu };
