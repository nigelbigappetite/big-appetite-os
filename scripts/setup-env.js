#!/usr/bin/env node

/**
 * Environment Setup Script
 * Sets up environment variables for Big Appetite OS
 */

const fs = require('fs');
const path = require('path');

console.log('🔧 Setting up environment variables...\n');

// Get Supabase credentials from user
const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

async function setupEnvironment() {
  try {
    console.log('Please provide your Supabase credentials:\n');
    
    const supabaseUrl = await askQuestion('Supabase URL: ');
    const supabaseServiceKey = await askQuestion('Supabase Service Role Key: ');
    const supabaseAnonKey = await askQuestion('Supabase Anon Key (optional): ');
    
    // Create .env file
    const envContent = `# Big Appetite OS Environment Variables
SUPABASE_URL=${supabaseUrl}
SUPABASE_SERVICE_ROLE_KEY=${supabaseServiceKey}
SUPABASE_ANON_KEY=${supabaseAnonKey || 'not_provided'}

# Database URL (if different from Supabase)
DATABASE_URL=${supabaseUrl.replace('https://', 'postgresql://postgres:')}
`;

    // Write .env file
    fs.writeFileSync('.env', envContent);
    console.log('\n✅ .env file created successfully!');
    
    // Test the connection
    console.log('\n🔌 Testing database connection...');
    
    // Load environment variables
    require('dotenv').config();
    
    const { createClient } = require('@supabase/supabase-js');
    const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
    
    // Test connection
    const { data, error } = await supabase
      .from('signals.whatsapp_messages')
      .select('signal_id')
      .limit(1);
    
    if (error) {
      console.log('❌ Connection test failed:', error.message);
      console.log('Please check your credentials and try again.');
    } else {
      console.log('✅ Database connection successful!');
      console.log('\n🎉 Environment setup complete!');
      console.log('You can now run: node scripts/run-stage1.js');
    }
    
  } catch (error) {
    console.error('❌ Setup failed:', error.message);
  } finally {
    rl.close();
  }
}

// Run setup
if (require.main === module) {
  setupEnvironment();
}

module.exports = { setupEnvironment };
