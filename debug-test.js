console.log('Starting debug test...');

const SUPABASE_URL = 'https://phjawqphehkzfaezhzzf.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM';

console.log('URL:', SUPABASE_URL);
console.log('Key length:', SUPABASE_SERVICE_ROLE_KEY.length);

try {
  const { createClient } = require('@supabase/supabase-js');
  console.log('Supabase client loaded');
  
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  console.log('Supabase client created');
  
  console.log('Testing connection...');
  
  supabase.from('signals.whatsapp_messages').select('signal_id').limit(1)
    .then(({ data, error }) => {
      console.log('Response received');
      if (error) {
        console.log('Error:', error);
      } else {
        console.log('Success! Data:', data);
      }
    })
    .catch(err => {
      console.log('Promise catch error:', err);
    });
    
} catch (error) {
  console.log('Try-catch error:', error);
}
