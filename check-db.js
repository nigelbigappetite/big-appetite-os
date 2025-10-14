// Simple database check
console.log('Checking database...');

const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://phjawqphehkzfaezhzzf.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

async function checkDatabase() {
  try {
    console.log('Testing signals.whatsapp_messages...');
    const { data, error } = await supabase
      .from('signals.whatsapp_messages')
      .select('signal_id')
      .limit(1);
    
    if (error) {
      console.log('WhatsApp messages error:', error.message);
    } else {
      console.log('WhatsApp messages OK, count:', data.length);
    }
    
    console.log('Testing actors.actors...');
    const { data: actorsData, error: actorsError } = await supabase
      .from('actors.actors')
      .select('actor_id')
      .limit(1);
    
    if (actorsError) {
      console.log('Actors table error:', actorsError.message);
      console.log('You need to run migration 027 first!');
    } else {
      console.log('Actors table OK, count:', actorsData.length);
    }
    
  } catch (err) {
    console.log('General error:', err.message);
  }
}

checkDatabase();
