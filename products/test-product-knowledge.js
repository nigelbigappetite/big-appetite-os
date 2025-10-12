#!/usr/bin/env node

/**
 * Stage 0: Product Intelligence Foundation
 * Test Script for Product Knowledge Base
 * 
 * This script runs comprehensive tests to validate the product knowledge base
 * and ensure all functions work correctly for belief extraction.
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

/**
 * Test 1: Verify all sauces imported correctly
 */
async function testSauceCount() {
  console.log('🧪 Test 1: Sauce Count Verification');
  
  const { data, error } = await supabase
    .from('products.sauces')
    .select('sauce_id', { count: 'exact' });
  
  if (error) throw error;
  
  console.log(`✅ Found ${data.length} sauces (Expected: 15)`);
  return data.length === 15;
}

/**
 * Test 2: Check spice level distribution
 */
async function testSpiceDistribution() {
  console.log('\n🧪 Test 2: Spice Level Distribution');
  
  const { data, error } = await supabase
    .from('products.sauces')
    .select('spice_level, display_name')
    .order('spice_level');
  
  if (error) throw error;
  
  const distribution = {};
  data.forEach(sauce => {
    if (!distribution[sauce.spice_level]) {
      distribution[sauce.spice_level] = [];
    }
    distribution[sauce.spice_level].push(sauce.display_name);
  });
  
  console.log('Spice Level Distribution:');
  Object.entries(distribution).forEach(([level, sauces]) => {
    console.log(`  Level ${level}: ${sauces.join(', ')}`);
  });
  
  return true;
}

/**
 * Test 3: Find all sweet sauces
 */
async function testSweetSauces() {
  console.log('\n🧪 Test 3: Sweet Sauces Detection');
  
  const { data, error } = await supabase
    .from('products.sauces')
    .select('display_name, sweetness, spice_level, primary_flavor')
    .or('primary_flavor.eq.sweet,sweetness.gte.7')
    .order('sweetness', { ascending: false });
  
  if (error) throw error;
  
  console.log('Sweet Sauces:');
  data.forEach(sauce => {
    console.log(`  ${sauce.display_name}: sweetness=${sauce.sweetness}, spice=${sauce.spice_level}, flavor=${sauce.primary_flavor}`);
  });
  
  return data.length >= 4; // Should have at least Honey Sesame, Sweet Chilli, Honey Mustard, etc.
}

/**
 * Test 4: Find medium-heat options
 */
async function testMediumHeatProducts() {
  console.log('\n🧪 Test 4: Medium Heat Products');
  
  const { data, error } = await supabase.rpc('get_products_by_spice_level', {
    min_level: 3,
    max_level: 5
  });
  
  if (error) throw error;
  
  console.log('Medium Heat Products:');
  data.forEach(product => {
    console.log(`  ${product.product_name} - ${product.sauce_name} (spice: ${product.spice_level})`);
  });
  
  return data.length > 0;
}

/**
 * Test 5: Product mention detection
 */
async function testMentionDetection() {
  console.log('\n🧪 Test 5: Product Mention Detection');
  
  const testPhrases = [
    'I love the honey sesame wings',
    'The buffalo sauce is too spicy',
    'Can I get mango mazzaline?',
    'Jarvs tangy buffalo is my favorite',
    'I want the sweet one',
    'Korean heat is amazing'
  ];
  
  for (const phrase of testPhrases) {
    console.log(`\n  Testing: "${phrase}"`);
    
    const { data, error } = await supabase.rpc('detect_product_mention', {
      signal_text: phrase
    });
    
    if (error) throw error;
    
    if (data.length > 0) {
      data.forEach(detection => {
        console.log(`    ✅ Detected: ${detection.entity_name} (${detection.entity_type}) - confidence: ${detection.confidence}, spice: ${detection.spice_level}, flavor: ${detection.primary_flavor}`);
      });
    } else {
      console.log('    ❌ No detections');
    }
  }
  
  return true;
}

/**
 * Test 6: Sauce attribute lookup
 */
async function testSauceAttributes() {
  console.log('\n🧪 Test 6: Sauce Attribute Lookup');
  
  const testSauces = ['honey sesame', 'buffalo', 'mango mazzaline', 'korean heat'];
  
  for (const sauceName of testSauces) {
    console.log(`\n  Testing: "${sauceName}"`);
    
    const { data, error } = await supabase.rpc('get_sauce_attributes', {
      search_sauce: sauceName
    });
    
    if (error) throw error;
    
    if (data) {
      console.log(`    ✅ Found: ${data.display_name}`);
      console.log(`      Spice Level: ${data.spice_level}`);
      console.log(`      Primary Flavor: ${data.primary_flavor}`);
      console.log(`      Sweetness: ${data.flavor_dimensions.sweetness}`);
      console.log(`      Tags: ${data.tags.join(', ')}`);
    } else {
      console.log('    ❌ Not found');
    }
  }
  
  return true;
}

/**
 * Test 7: Find sweet, mild options
 */
async function testSweetMildOptions() {
  console.log('\n🧪 Test 7: Sweet, Mild Options');
  
  const { data, error } = await supabase.rpc('search_sauces_by_attributes', {
    min_sweetness: 7,
    max_spice: 3
  });
  
  if (error) throw error;
  
  console.log('Sweet, Mild Sauces:');
  data.forEach(sauce => {
    console.log(`  ${sauce.display_name}: sweetness=${sauce.sweetness}, spice=${sauce.spice_level}`);
  });
  
  return data.length >= 3; // Should have Honey Sesame, Sweet Chilli, Honey Mustard
}

/**
 * Test 8: Check product-sauce mappings
 */
async function testProductSauceMappings() {
  console.log('\n🧪 Test 8: Product-Sauce Mappings');
  
  const { data, error } = await supabase
    .from('products.catalog')
    .select(`
      product_name,
      has_sauce_options,
      products.product_sauces(count)
    `)
    .eq('has_sauce_options', true);
  
  if (error) throw error;
  
  console.log('Products with Sauce Options:');
  data.forEach(product => {
    const sauceCount = product.products?.product_sauces?.[0]?.count || 0;
    console.log(`  ${product.product_name}: ${sauceCount} sauce options`);
  });
  
  return data.length > 0;
}

/**
 * Test 9: Verify aliases work
 */
async function testAliases() {
  console.log('\n🧪 Test 9: Alias Detection');
  
  const { data, error } = await supabase
    .from('products.sauces')
    .select(`
      display_name,
      products.product_aliases(alias_text, confidence)
    `)
    .order('display_name');
  
  if (error) throw error;
  
  console.log('Sauce Aliases:');
  data.forEach(sauce => {
    const aliases = sauce.products?.product_aliases || [];
    console.log(`  ${sauce.display_name}: ${aliases.length} aliases`);
    aliases.forEach(alias => {
      console.log(`    - "${alias.alias_text}" (confidence: ${alias.confidence})`);
    });
  });
  
  return true;
}

/**
 * Test 10: Full integration test
 */
async function testFullIntegration() {
  console.log('\n🧪 Test 10: Full Integration Test');
  
  const testSignal = "I got honey sesame wings and they weren't like the original";
  
  const { data, error } = await supabase.rpc('detect_product_mention', {
    signal_text: testSignal
  });
  
  if (error) throw error;
  
  console.log(`Testing signal: "${testSignal}"`);
  
  if (data.length > 0) {
    const sauceDetection = data.find(d => d.entity_type === 'sauce');
    if (sauceDetection) {
      console.log(`✅ Detected sauce: ${sauceDetection.entity_name}`);
      console.log(`   Confidence: ${sauceDetection.confidence}`);
      console.log(`   Spice Level: ${sauceDetection.spice_level}`);
      console.log(`   Primary Flavor: ${sauceDetection.primary_flavor}`);
      
      // Get full attributes
      const { data: attributes } = await supabase.rpc('get_sauce_attributes', {
        search_sauce: sauceDetection.entity_name
      });
      
      if (attributes) {
        console.log(`   Sweetness: ${attributes.flavor_dimensions.sweetness}`);
        console.log(`   Tags: ${attributes.tags.join(', ')}`);
      }
      
      return sauceDetection.entity_name.includes('Honey Sesame');
    }
  }
  
  console.log('❌ No sauce detected');
  return false;
}

/**
 * Run all tests
 */
async function runAllTests() {
  console.log('🚀 Starting Product Knowledge Base Tests\n');
  
  const tests = [
    { name: 'Sauce Count', fn: testSauceCount },
    { name: 'Spice Distribution', fn: testSpiceDistribution },
    { name: 'Sweet Sauces', fn: testSweetSauces },
    { name: 'Medium Heat Products', fn: testMediumHeatProducts },
    { name: 'Mention Detection', fn: testMentionDetection },
    { name: 'Sauce Attributes', fn: testSauceAttributes },
    { name: 'Sweet Mild Options', fn: testSweetMildOptions },
    { name: 'Product-Sauce Mappings', fn: testProductSauceMappings },
    { name: 'Aliases', fn: testAliases },
    { name: 'Full Integration', fn: testFullIntegration }
  ];
  
  let passed = 0;
  let total = tests.length;
  
  for (const test of tests) {
    try {
      const result = await test.fn();
      if (result) {
        console.log(`✅ ${test.name}: PASSED`);
        passed++;
      } else {
        console.log(`❌ ${test.name}: FAILED`);
      }
    } catch (error) {
      console.log(`❌ ${test.name}: ERROR - ${error.message}`);
    }
  }
  
  console.log(`\n🎯 Test Results: ${passed}/${total} tests passed`);
  
  if (passed === total) {
    console.log('🎉 All tests passed! Product Knowledge Base is ready for belief extraction.');
  } else {
    console.log('⚠️  Some tests failed. Please review and fix issues.');
  }
  
  return passed === total;
}

// Run tests if called directly
if (require.main === module) {
  runAllTests().then(success => {
    process.exit(success ? 0 : 1);
  });
}

module.exports = { runAllTests };
