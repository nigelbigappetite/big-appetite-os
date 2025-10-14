// Simple actor processing script
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://phjawqphehkzfaezhzzf.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

async function processActors() {
  console.log('Starting actor processing...');
  
  try {
    // Get all WhatsApp messages
    const { data: messages, error } = await supabase
      .from('signals.whatsapp_messages')
      .select('*')
      .order('message_timestamp', { ascending: true });
    
    if (error) {
      console.log('Error fetching messages:', error.message);
      return;
    }
    
    console.log(`Found ${messages.length} WhatsApp messages`);
    
    // Group by phone number
    const phoneGroups = {};
    messages.forEach(msg => {
      if (msg.sender_phone) {
        if (!phoneGroups[msg.sender_phone]) {
          phoneGroups[msg.sender_phone] = [];
        }
        phoneGroups[msg.sender_phone].push(msg);
      }
    });
    
    console.log(`Found ${Object.keys(phoneGroups).length} unique phone numbers`);
    
    // Create actors for each phone number
    let createdCount = 0;
    for (const [phone, phoneMessages] of Object.entries(phoneGroups)) {
      try {
        // Check if actor already exists
        const { data: existingActor } = await supabase
          .from('actors.actors')
          .select('actor_id')
          .eq('primary_phone', phone)
          .single();
        
        if (existingActor) {
          console.log(`Actor already exists for ${phone}`);
          continue;
        }
        
        // Create new actor
        const firstMessage = phoneMessages[0];
        const lastMessage = phoneMessages[phoneMessages.length - 1];
        
        const { data: newActor, error: actorError } = await supabase
          .from('actors.actors')
          .insert({
            primary_phone: phone,
            first_seen: firstMessage.message_timestamp,
            last_seen: lastMessage.message_timestamp,
            signal_count: phoneMessages.length,
            signal_sources: ['whatsapp'],
            profile_completeness: 0.3, // Basic phone + messages
            confidence_in_identity: 0.8, // High confidence for phone
            identity_quality: 'high',
            created_from: 'whatsapp_message'
          })
          .select()
          .single();
        
        if (actorError) {
          console.log(`Error creating actor for ${phone}:`, actorError.message);
          continue;
        }
        
        // Link all messages to this actor
        const linkData = phoneMessages.map(msg => ({
          actor_id: newActor.actor_id,
          signal_id: msg.signal_id,
          signal_type: 'whatsapp_message',
          signal_table: 'signals.whatsapp_messages',
          link_confidence: 1.0,
          link_method: 'exact_phone',
          link_identifier: 'phone'
        }));
        
        const { error: linkError } = await supabase
          .from('actors.actor_signals')
          .insert(linkData);
        
        if (linkError) {
          console.log(`Error linking messages for ${phone}:`, linkError.message);
        } else {
          createdCount++;
          console.log(`Created actor for ${phone} with ${phoneMessages.length} messages`);
        }
        
      } catch (err) {
        console.log(`Error processing ${phone}:`, err.message);
      }
    }
    
    console.log(`\nCompleted! Created ${createdCount} actors`);
    
    // Show summary
    const { data: finalActors } = await supabase
      .from('actors.actors')
      .select('actor_id, primary_phone, signal_count')
      .order('signal_count', { ascending: false })
      .limit(10);
    
    console.log('\nTop 10 most active actors:');
    finalActors.forEach(actor => {
      console.log(`${actor.primary_phone}: ${actor.signal_count} messages`);
    });
    
  } catch (error) {
    console.log('General error:', error.message);
  }
}

processActors();
