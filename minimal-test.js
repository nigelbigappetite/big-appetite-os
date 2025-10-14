console.log('=== MINIMAL TEST ===');

const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://phjawqphehkzfaezhzzf.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

async function test() {
  try {
    console.log('Testing WhatsApp messages...');
    const { data, error } = await supabase
      .from('signals.whatsapp_messages')
      .select('signal_id, sender_phone')
      .limit(3);
    
    if (error) {
      console.log('Error:', error.message);
    } else {
      console.log('Success! Found', data.length, 'messages');
      console.log('Sample data:', data);
    }
    
    console.log('Testing actors table...');
    const { data: actorsData, error: actorsError } = await supabase
      .from('actors.actors')
      .select('actor_id')
      .limit(1);
    
    if (actorsError) {
      console.log('Actors error:', actorsError.message);
    } else {
      console.log('Actors table OK, count:', actorsData.length);
    }
    
  } catch (err) {
    console.log('Catch error:', err.message);
  }
}

test();
