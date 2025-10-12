const fs = require('fs');
const csv = require('csv-parser');

console.log('🚀 Starting simple test...');

let count = 0;
fs.createReadStream('data/wing_shack_whatsapp_support_master_parsed.csv')
    .pipe(csv())
    .on('data', (row) => {
        count++;
        if (count <= 3) {
            console.log(`Row ${count}:`, {
                conversation_id: row.conversation_id,
                sender: row.sender,
                phone: row.phone_number,
                message: row.message ? row.message.substring(0, 50) + '...' : 'No message'
            });
        }
    })
    .on('end', () => {
        console.log(`✅ Processed ${count} rows total`);
    })
    .on('error', (error) => {
        console.error('❌ Error:', error);
    });
