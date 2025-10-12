#!/usr/bin/env python3
import csv
import json
from datetime import datetime

print("🚀 Processing master WhatsApp file...")

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

results = []
missing_phones = set()
conversation_count = 0
message_count = 0
processed_conversations = set()

with open('data/wing_shack_whatsapp_support_master_parsed.csv', 'r', encoding='utf-8') as file:
    reader = csv.DictReader(file)
    
    for row in reader:
        message_count += 1
        
        # Extract conversation ID
        conversation_id = row.get('conversation_id', 'unknown')
        
        # Check for missing phone numbers
        phone_number = row.get('phone_number', '').strip()
        if not phone_number:
            missing_phones.add(conversation_id)
            continue  # Skip messages without phone numbers
        
        # Clean phone number
        if not phone_number.startswith('+'):
            phone_number = '+' + phone_number
        
        # Parse timestamp
        message_timestamp = None
        if row.get('timestamp'):
            try:
                message_timestamp = datetime.fromisoformat(row['timestamp'].replace('Z', '+00:00')).isoformat()
            except:
                pass  # Keep as None if invalid
        
        # Create raw content JSON
        raw_content = {
            "timestamp": row.get('timestamp', ''),
            "sender": row.get('sender', ''),
            "message": row.get('message', ''),
            "phone_number": phone_number,
            "brand": "wing_shack",
            "direction": row.get('direction', 'inbound'),
            "conversation_id": conversation_id
        }
        
        # Create raw metadata JSON
        raw_metadata = {
            "conversation_id": conversation_id,
            "sender": row.get('sender', ''),
            "source": "whatsapp_intake",
            "raw_timestamp": row.get('timestamp', '')
        }
        
        # Create intake metadata JSON
        intake_metadata = {
            "intake_source": "csv_upload",
            "intake_timestamp": datetime.now().isoformat(),
            "conversation_id": conversation_id
        }
        
        # Create record for database (without signal_id - let Supabase generate it)
        record = {
            "brand_id": WING_SHACK_BRAND_ID,
            "sender_phone": phone_number,
            "message_text": row.get('message', ''),
            "message_direction": row.get('direction', 'inbound'),
            "message_timestamp": message_timestamp,
            "raw_content": json.dumps(raw_content),
            "raw_metadata": json.dumps(raw_metadata),
            "received_at": datetime.now().isoformat(),
            "intake_method": "whatsapp_intake",
            "intake_metadata": json.dumps(intake_metadata)
        }
        
        results.append(record)
        
        # Track unique conversations
        if conversation_id not in processed_conversations:
            processed_conversations.add(conversation_id)
            conversation_count += 1

print(f"📊 Processing complete:")
print(f"   - Total messages processed: {message_count}")
print(f"   - Messages with phone numbers: {len(results)}")
print(f"   - Conversations: {conversation_count}")
print(f"   - Missing phone conversations: {len(missing_phones)}")

if missing_phones:
    print(f"\n⚠️  Conversations with missing phone numbers:")
    for conv in sorted(missing_phones):
        print(f"   - {conv}")

# Generate CSV
print("\n📝 Generating clean CSV...")

def escape_csv(value):
    if value is None:
        return ''
    str_value = str(value)
    if ',' in str_value or '"' in str_value or '\n' in str_value:
        return '"' + str_value.replace('"', '""') + '"'
    return str_value

csv_header = "brand_id,sender_phone,message_text,message_direction,message_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"

csv_rows = []
for record in results:
    row = [
        escape_csv(record["brand_id"]),
        escape_csv(record["sender_phone"]),
        escape_csv(record["message_text"]),
        escape_csv(record["message_direction"]),
        escape_csv(record["message_timestamp"]),
        escape_csv(record["raw_content"]),
        escape_csv(record["raw_metadata"]),
        escape_csv(record["received_at"]),
        escape_csv(record["intake_method"]),
        escape_csv(record["intake_metadata"])
    ]
    csv_rows.append(','.join(row))

csv_content = csv_header + '\n'.join(csv_rows)

filename = 'data/master_whatsapp_clean.csv'
with open(filename, 'w', encoding='utf-8') as file:
    file.write(csv_content)

print(f"✅ Clean CSV generated: {filename}")
print(f"   - Records: {len(results)}")
print(f"   - File size: {len(csv_content) / 1024:.1f} KB")

print("\n🎉 Processing complete!")
print(f"📁 Ready to upload: {filename}")
