const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function checkDatabase() {
  try {
    console.log('🔍 Checking your Supabase database...\n');
    
    // Try to get brands
    console.log('Checking core.brands...');
    const { data: brands, error: brandsError } = await supabase
      .from('core.brands')
      .select('brand_name, brand_slug')
      .limit(3);
    
    if (brandsError) {
      console.log('❌ core.brands error:', brandsError.message);
    } else {
      console.log('✅ core.brands found:', brands.length, 'brands');
      if (brands.length > 0) {
        brands.forEach(brand => console.log('  -', brand.brand_name, '(' + brand.brand_slug + ')'));
      }
    }
    
    // Try to get whatsapp messages
    console.log('\nChecking signals.whatsapp_messages...');
    const { data: whatsapp, error: whatsappError } = await supabase
      .from('signals.whatsapp_messages')
      .select('signal_id, sender_phone, message_text')
      .limit(3);
    
    if (whatsappError) {
      console.log('❌ signals.whatsapp_messages error:', whatsappError.message);
    } else {
      console.log('✅ signals.whatsapp_messages found:', whatsapp.length, 'messages');
      if (whatsapp.length > 0) {
        whatsapp.forEach(msg => console.log('  -', msg.sender_phone, ':', msg.message_text.substring(0, 50) + '...'));
      }
    }
    
    // Try to get actors
    console.log('\nChecking actors.actors...');
    const { data: actors, error: actorsError } = await supabase
      .from('actors.actors')
      .select('actor_id, primary_identifier')
      .limit(3);
    
    if (actorsError) {
      console.log('❌ actors.actors error:', actorsError.message);
    } else {
      console.log('✅ actors.actors found:', actors.length, 'actors');
      if (actors.length > 0) {
        actors.forEach(actor => console.log('  -', actor.primary_identifier));
      }
    }
    
  } catch (error) {
    console.log('❌ Error:', error.message);
  }
}

checkDatabase();
