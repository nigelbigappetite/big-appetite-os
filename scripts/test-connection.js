#!/usr/bin/env node

/**
 * Test Supabase Connection
 * Simple script to test if your credentials work
 */

// Method 1: Try to load from .env file
try {
  require('dotenv').config();
  console.log('📁 Loaded .env file');
} catch (error) {
  console.log('⚠️  No .env file found, using inline variables');
}

// Method 2: Set inline (replace with your actual credentials)
const SUPABASE_URL = process.env.SUPABASE_URL || 'your_supabase_url_here';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || 'your_service_role_key_here';

console.log('🔧 Testing Supabase connection...\n');

// Check if credentials are set
if (SUPABASE_URL === 'your_supabase_url_here' || SUPABASE_SERVICE_ROLE_KEY === 'your_service_role_key_here') {
  console.log('❌ Please set your Supabase credentials first!');
  console.log('\nOption 1: Edit scripts/run-with-env.js and replace the placeholder values');
  console.log('Option 2: Create a .env file with your credentials');
  console.log('Option 3: Run: node scripts/setup-env.js');
  process.exit(1);
}

// Test connection
async function testConnection() {
  try {
    const { createClient } = require('@supabase/supabase-js');
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    
    console.log('📡 Supabase URL:', SUPABASE_URL);
    console.log('🔑 Service Key:', SUPABASE_SERVICE_ROLE_KEY.substring(0, 20) + '...');
    console.log('\n🔌 Testing connection...');
    
    // Test basic connection
    const { data, error } = await supabase
      .from('signals.whatsapp_messages')
      .select('signal_id')
      .limit(1);
    
    if (error) {
      console.log('❌ Connection failed:', error.message);
      console.log('\n🔍 Troubleshooting:');
      console.log('1. Check your Supabase URL is correct');
      console.log('2. Check your Service Role Key is correct');
      console.log('3. Make sure your Supabase project is active');
      console.log('4. Check if RLS policies allow service role access');
      return false;
    }
    
    console.log('✅ Connection successful!');
    console.log('📊 Sample data:', data);
    
    // Test actors schema
    console.log('\n🏗️  Testing actors schema...');
    const { data: actorsData, error: actorsError } = await supabase
      .from('actors.actors')
      .select('actor_id')
      .limit(1);
    
    if (actorsError) {
      console.log('⚠️  Actors schema not found. Please run migration 027 first.');
      console.log('   Error:', actorsError.message);
    } else {
      console.log('✅ Actors schema exists');
    }
    
    return true;
    
  } catch (error) {
    console.log('❌ Connection test failed:', error.message);
    return false;
  }
}

// Run test
if (require.main === module) {
  testConnection()
    .then(success => {
      if (success) {
        console.log('\n🎉 Ready to run Stage 1!');
        console.log('Run: node scripts/run-with-env.js');
      } else {
        console.log('\n❌ Please fix the connection issues first');
      }
      process.exit(success ? 0 : 1);
    });
}

module.exports = { testConnection };