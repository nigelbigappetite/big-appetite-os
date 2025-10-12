const fs = require('fs');
const csv = require('csv-parser');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

// Generate valid UUID (only 0-9, a-f)
function generateValidUUID() {
  const chars = '0123456789abcdef';
  let uuid = '';
  for (let i = 0; i < 32; i++) {
    uuid += chars[Math.floor(Math.random() * chars.length)];
  }
  return uuid.substring(0, 8) + '-' + 
         uuid.substring(8, 12) + '-' + 
         uuid.substring(12, 16) + '-' + 
         uuid.substring(16, 20) + '-' + 
         uuid.substring(20, 32);
}

async function processAllConversations() {
  try {
    console.log('🚀 Processing ALL WhatsApp conversations...\n');
    
    const messages = [];
    const conversations = new Set();
    let messageCount = 0;
    
    // Read and parse the master CSV
    await new Promise((resolve, reject) => {
      fs.createReadStream('data/wing_shack_whatsapp_support_master_parsed.csv')
        .pipe(csv())
        .on('data', (row) => {
          // Skip system messages
          if (row.message.includes('Messages and calls are end-to-end encrypted')) {
            return;
          }
          
          // Track conversations
          if (row.conversation_id && !conversations.has(row.conversation_id)) {
            conversations.add(row.conversation_id);
          }
          
          // Clean phone number
          let phone = row.phone_number;
          if (phone && !phone.startsWith('+')) {
            phone = '+' + phone;
          }
          
          // Keep original sender name (with ~ prefix)
          const sender = row.sender;
          
          // Generate valid UUID for signal_id
          const signalId = generateValidUUID();
          
          const message = {
            signal_id: signalId,
            brand_id: 'a1b2c3d4-e5f6-7890-1234-567890abcdef', // Wing Shack brand ID
            sender_phone: phone || 'unknown',
            message_text: row.message,
            message_direction: row.direction,
            message_timestamp: row.timestamp + '+00:00',
            raw_content: JSON.stringify({
              timestamp: row.timestamp,
              sender: sender,
              message: row.message,
              phone_number: row.phone_number,
              brand: row.brand,
              direction: row.direction,
              conversation_id: row.conversation_id
            }),
            raw_metadata: JSON.stringify({
              conversation_id: row.conversation_id,
              sender: sender,
              source: 'whatsapp_intake',
              raw_timestamp: row.timestamp
            }),
            received_at: new Date().toISOString(),
            intake_method: 'whatsapp_intake',
            intake_metadata: JSON.stringify({
              intake_source: 'csv_upload',
              intake_timestamp: new Date().toISOString(),
              conversation_id: row.conversation_id
            })
          };
          
          messages.push(message);
          messageCount++;
          
          if (messageCount % 50 === 0) {
            console.log(`📊 Processed ${messageCount} messages...`);
          }
        })
        .on('end', resolve)
        .on('error', reject);
    });
    
    console.log(`\n✅ Processing complete!`);
    console.log(`📊 Total messages: ${messages.length}`);
    console.log(`📊 Total conversations: ${conversations.size}`);
    
    // Write to CSV file
    const csvContent = [
      'signal_id,brand_id,sender_phone,message_text,message_direction,message_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata'
    ];
    
    messages.forEach(msg => {
      const row = [
        msg.signal_id,
        msg.brand_id,
        `"${msg.sender_phone}"`,
        `"${msg.message_text.replace(/"/g, '""')}"`,
        msg.message_direction,
        msg.message_timestamp,
        `"${msg.raw_content.replace(/"/g, '""')}"`,
        `"${msg.raw_metadata.replace(/"/g, '""')}"`,
        msg.received_at,
        msg.intake_method,
        `"${msg.intake_metadata.replace(/"/g, '""')}"`
      ].join(',');
      csvContent.push(row);
    });
    
    fs.writeFileSync('data/all_whatsapp_conversations.csv', csvContent.join('\n'));
    
    console.log(`\n✅ Created all_whatsapp_conversations.csv`);
    console.log(`📁 File saved to: data/all_whatsapp_conversations.csv`);
    
    // Show conversation breakdown
    console.log('\n📋 Conversation breakdown:');
    const convArray = Array.from(conversations).sort();
    convArray.forEach(conv => {
      const convMessages = messages.filter(m => m.raw_metadata.includes(conv));
      console.log(`  - ${conv}: ${convMessages.length} messages`);
    });
    
    console.log(`\n🚀 Ready to upload to Supabase!`);
    
  } catch (error) {
    console.error('❌ Error processing file:', error.message);
  }
}

processAllConversations();
