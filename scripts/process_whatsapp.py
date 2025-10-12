#!/usr/bin/env python3
import csv
import json
import uuid
from datetime import datetime

def process_whatsapp_file():
    print("🚀 Processing master WhatsApp file...")
    
    messages = []
    conversations = set()
    
    # Read the CSV file
    with open('data/wing_shack_whatsapp_support_master_parsed.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            # Skip system messages
            if 'Messages and calls are end-to-end encrypted' in row['message']:
                continue
            
            # Track conversations
            if row['conversation_id']:
                conversations.add(row['conversation_id'])
            
            # Clean phone number
            phone = row['phone_number']
            if phone and not phone.startswith('+'):
                phone = '+' + phone
            
            # Clean sender name (remove ~ prefix)
            sender = row['sender']
            if sender and sender.startswith('~'):
                sender = sender[1:]
            
            # Generate UUID for signal_id
            signal_id = str(uuid.uuid4())
            
            # Create message object
            message = {
                'signal_id': signal_id,
                'brand_id': 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
                'sender_phone': phone or 'unknown',
                'message_text': row['message'],
                'message_direction': row['direction'],
                'message_timestamp': row['timestamp'] + '+00:00',
                'raw_content': json.dumps({
                    'timestamp': row['timestamp'],
                    'sender': sender,
                    'message': row['message'],
                    'phone_number': row['phone_number'],
                    'brand': row['brand'],
                    'direction': row['direction'],
                    'conversation_id': row['conversation_id']
                }),
                'raw_metadata': json.dumps({
                    'conversation_id': row['conversation_id'],
                    'sender': sender,
                    'source': 'csv_upload'
                }),
                'received_at': datetime.now().isoString() + '+00:00',
                'intake_method': 'csv_upload',
                'intake_metadata': json.dumps({
                    'uploaded_at': datetime.now().isoString() + 'Z',
                    'conversation_id': row['conversation_id']
                })
            }
            
            messages.append(message)
    
    print(f"📊 Found {len(messages)} messages across {len(conversations)} conversations")
    
    # Write to CSV file
    with open('data/master_whatsapp_for_upload.csv', 'w', newline='', encoding='utf-8') as file:
        if messages:
            writer = csv.DictWriter(file, fieldnames=messages[0].keys())
            writer.writeheader()
            writer.writerows(messages)
    
    print(f"✅ Created master_whatsapp_for_upload.csv with {len(messages)} messages")
    
    # Show sample conversations
    print("\n📋 Sample conversations:")
    sample_convs = list(conversations)[:5]
    for conv in sample_convs:
        conv_messages = [m for m in messages if conv in m['raw_metadata']]
        print(f"  - {conv}: {len(conv_messages)} messages")

if __name__ == "__main__":
    process_whatsapp_file()
