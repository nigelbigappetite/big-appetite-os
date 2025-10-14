#!/usr/bin/env node

/**
 * Stage 1: Actor Identification
 * Analyze WhatsApp data structure and extract identifiers
 */

const { createClient } = require('@supabase/supabase-js');

// You'll need to set these environment variables
const supabaseUrl = process.env.SUPABASE_URL || 'your_supabase_url_here';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'your_service_role_key_here';

const supabase = createClient(supabaseUrl, supabaseKey);

async function analyzeWhatsAppData() {
  console.log('🔍 Analyzing WhatsApp data structure...\n');
  
  try {
    // Get sample of WhatsApp messages
    const { data: messages, error } = await supabase
      .from('signals.whatsapp_messages')
      .select('sender_phone, message_text, message_timestamp, raw_content')
      .limit(10);
    
    if (error) {
      console.error('❌ Error fetching messages:', error);
      return;
    }
    
    console.log('📱 Sample WhatsApp Messages:');
    messages.forEach((msg, i) => {
      console.log(`${i+1}. Phone: ${msg.sender_phone}`);
      console.log(`   Text: ${msg.message_text.substring(0, 100)}...`);
      console.log(`   Time: ${msg.message_timestamp}`);
      console.log('');
    });
    
    // Get unique phone numbers count
    const { data: phoneStats, error: phoneError } = await supabase
      .from('signals.whatsapp_messages')
      .select('sender_phone')
      .not('sender_phone', 'is', null);
    
    if (!phoneError) {
      const uniquePhones = new Set(phoneStats.map(m => m.sender_phone));
      console.log(`📊 Total unique phone numbers: ${uniquePhones.size}`);
      
      // Show phone number distribution
      const phoneCounts = {};
      phoneStats.forEach(msg => {
        phoneCounts[msg.sender_phone] = (phoneCounts[msg.sender_phone] || 0) + 1;
      });
      
      console.log('\n📈 Top 10 most active phone numbers:');
      Object.entries(phoneCounts)
        .sort(([,a], [,b]) => b - a)
        .slice(0, 10)
        .forEach(([phone, count]) => {
          console.log(`   ${phone}: ${count} messages`);
        });
    }
    
    // Check for other identifiers in raw_content
    console.log('\n🔍 Checking for other identifiers in raw_content...');
    const { data: rawData, error: rawError } = await supabase
      .from('signals.whatsapp_messages')
      .select('raw_content')
      .not('raw_content', 'is', null)
      .limit(5);
    
    if (!rawError && rawData.length > 0) {
      console.log('Raw content samples:');
      rawData.forEach((msg, i) => {
        console.log(`${i+1}. ${JSON.stringify(msg.raw_content, null, 2)}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

// Run the analysis
if (require.main === module) {
  analyzeWhatsAppData();
}

module.exports = { analyzeWhatsAppData };
