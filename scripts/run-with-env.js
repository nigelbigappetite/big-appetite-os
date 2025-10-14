#!/usr/bin/env node

/**
 * Run Stage 1 with inline environment variables
 * This bypasses .env file issues
 */

// Set your Supabase credentials here
const SUPABASE_URL = 'https://phjawqphehkzfaezhzzf.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM';

// Set environment variables
process.env.SUPABASE_URL = SUPABASE_URL;
process.env.SUPABASE_SERVICE_ROLE_KEY = SUPABASE_SERVICE_ROLE_KEY;

console.log('🔧 Environment variables set inline');
console.log('📡 Supabase URL:', SUPABASE_URL.substring(0, 30) + '...');
console.log('🔑 Service Key:', SUPABASE_SERVICE_ROLE_KEY.substring(0, 20) + '...\n');

// Import and run Stage 1
const { Stage1Executor } = require('./run-stage1');

async function runWithInlineEnv() {
  const executor = new Stage1Executor();
  await executor.runStage1();
}

// Run if called directly
if (require.main === module) {
  runWithInlineEnv()
    .then(() => {
      console.log('✅ Stage 1 complete!');
      process.exit(0);
    })
    .catch(error => {
      console.error('❌ Stage 1 failed:', error);
      process.exit(1);
    });
}

module.exports = { runWithInlineEnv };
