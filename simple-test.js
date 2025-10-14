console.log('=== SIMPLE TEST START ===');

// Test basic Node.js
console.log('Node.js version:', process.version);
console.log('Current directory:', process.cwd());

// Test require
try {
  console.log('Testing require...');
  const { createClient } = require('@supabase/supabase-js');
  console.log('✅ Supabase client loaded successfully');
  
  // Test client creation
  const supabase = createClient(
    'https://phjawqphehkzfaezhzzf.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
  );
  console.log('✅ Supabase client created');
  
  // Test a simple query
  console.log('Testing database query...');
  supabase.from('signals.whatsapp_messages').select('count').limit(1)
    .then(result => {
      console.log('✅ Query successful:', result);
    })
    .catch(error => {
      console.log('❌ Query failed:', error.message);
    });
    
} catch (error) {
  console.log('❌ Error:', error.message);
}

console.log('=== SIMPLE TEST END ===');
