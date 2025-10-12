const fs = require('fs');
const csv = require('csv-parser');

console.log('🚀 Processing master WhatsApp file...');

const results = [];
const missingPhones = new Set();
let conversationCount = 0;
let messageCount = 0;

// Brand ID for Wing Shack
const WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef';

fs.createReadStream('data/wing_shack_whatsapp_support_master_parsed.csv')
    .pipe(csv())
    .on('data', (row) => {
        messageCount++;
        
        // Extract conversation ID
        const conversationId = row.conversation_id || 'unknown';
        
        // Check for missing phone numbers
        if (!row.phone_number || row.phone_number.trim() === '') {
            missingPhones.add(conversationId);
            return; // Skip messages without phone numbers
        }
        
        // Clean phone number
        let phoneNumber = row.phone_number.trim();
        if (!phoneNumber.startsWith('+')) {
            phoneNumber = '+' + phoneNumber;
        }
        
        // Parse timestamp
        let messageTimestamp = null;
        if (row.timestamp) {
            try {
                messageTimestamp = new Date(row.timestamp).toISOString();
            } catch (e) {
                // Keep as null if invalid
            }
        }
        
        // Create raw content JSON
        const rawContent = {
            timestamp: row.timestamp || '',
            sender: row.sender || '',
            message: row.message || '',
            phone_number: phoneNumber,
            brand: 'wing_shack',
            direction: row.direction || 'inbound',
            conversation_id: conversationId
        };
        
        // Create raw metadata JSON
        const rawMetadata = {
            conversation_id: conversationId,
            sender: row.sender || '',
            source: 'whatsapp_intake',
            raw_timestamp: row.timestamp || ''
        };
        
        // Create intake metadata JSON
        const intakeMetadata = {
            intake_source: 'csv_upload',
            intake_timestamp: new Date().toISOString(),
            conversation_id: conversationId
        };
        
        // Create record for database (without signal_id - let Supabase generate it)
        const record = {
            brand_id: WING_SHACK_BRAND_ID,
            sender_phone: phoneNumber,
            message_text: row.message || '',
            message_direction: row.direction || 'inbound',
            message_timestamp: messageTimestamp,
            raw_content: JSON.stringify(rawContent),
            raw_metadata: JSON.stringify(rawMetadata),
            received_at: new Date().toISOString(),
            intake_method: 'whatsapp_intake',
            intake_metadata: JSON.stringify(intakeMetadata)
        };
        
        results.push(record);
    })
    .on('end', () => {
        console.log(`📊 Processing complete:`);
        console.log(`   - Total messages processed: ${messageCount}`);
        console.log(`   - Messages with phone numbers: ${results.length}`);
        console.log(`   - Missing phone conversations: ${missingPhones.size}`);
        
        if (missingPhones.size > 0) {
            console.log(`\n⚠️  Conversations with missing phone numbers:`);
            Array.from(missingPhones).forEach(conv => console.log(`   - ${conv}`));
        }
        
        // Generate CSV
        console.log('\n📝 Generating clean CSV...');
        
        const csvHeader = 'brand_id,sender_phone,message_text,message_direction,message_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n';
        
        const csvRows = results.map(record => {
            // Escape CSV values properly
            const escapeCsv = (value) => {
                if (value === null || value === undefined) return '';
                const str = String(value);
                if (str.includes(',') || str.includes('"') || str.includes('\n')) {
                    return '"' + str.replace(/"/g, '""') + '"';
                }
                return str;
            };
            
            return [
                escapeCsv(record.brand_id),
                escapeCsv(record.sender_phone),
                escapeCsv(record.message_text),
                escapeCsv(record.message_direction),
                escapeCsv(record.message_timestamp),
                escapeCsv(record.raw_content),
                escapeCsv(record.raw_metadata),
                escapeCsv(record.received_at),
                escapeCsv(record.intake_method),
                escapeCsv(record.intake_metadata)
            ].join(',');
        });
        
        const csvContent = csvHeader + csvRows.join('\n');
        
        const filename = 'data/master_whatsapp_clean.csv';
        fs.writeFileSync(filename, csvContent);
        
        console.log(`✅ Clean CSV generated: ${filename}`);
        console.log(`   - Records: ${results.length}`);
        console.log(`   - File size: ${(csvContent.length / 1024).toFixed(1)} KB`);
        
        console.log('\n🎉 Processing complete!');
        console.log(`📁 Ready to upload: ${filename}`);
    })
    .on('error', (error) => {
        console.error('❌ Error reading CSV file:', error);
    });
