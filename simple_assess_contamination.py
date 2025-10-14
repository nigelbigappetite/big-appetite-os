#!/usr/bin/env python3
"""
Simple assessment of data contamination from outbound messages.
Uses standard Supabase client methods instead of custom SQL functions.
"""
import os
import sys
from dotenv import load_dotenv

# Add intelligence_layer to path
ROOT = os.getcwd()
PKG_PATH = os.path.join(ROOT, 'intelligence_layer')
if PKG_PATH not in sys.path:
    sys.path.append(PKG_PATH)

load_dotenv()

from intelligence_layer.src.database import DatabaseManager

def simple_assess_contamination():
    """Simple assessment using standard Supabase methods."""
    db = DatabaseManager()
    
    print("=== SIMPLE CONTAMINATION ASSESSMENT ===\n")
    
    # 1. Check processing state table
    print("1. Checking processing state...")
    try:
        result = db.supabase.table('signal_processing_state').select('*').execute()
        processed_signals = result.data or []
        print(f"   Total processed signals: {len(processed_signals)}")
        
        if processed_signals:
            # Show recent processing activity
            recent = sorted(processed_signals, key=lambda x: x.get('processed_at', ''), reverse=True)[:10]
            print(f"\n   Recent processing activity:")
            for i, signal in enumerate(recent):
                status = signal.get('status', 'unknown')
                processed_at = signal.get('processed_at', 'unknown')
                signal_id = signal.get('signal_id', 'unknown')[:8]
                print(f"     {i+1}. [{status}] {signal_id} at {processed_at}")
        
    except Exception as e:
        print(f"   Error checking processing state: {e}")
    
    # 2. Check decoder output table
    print(f"\n2. Checking decoder output...")
    try:
        result = db.supabase.table('signal_decoder_output').select('*').execute()
        decoder_outputs = result.data or []
        print(f"   Total decoder outputs: {len(decoder_outputs)}")
        
        if decoder_outputs:
            # Show recent decoder outputs
            recent = sorted(decoder_outputs, key=lambda x: x.get('processing_timestamp', ''), reverse=True)[:5]
            print(f"\n   Recent decoder outputs:")
            for i, output in enumerate(recent):
                signal_id = output.get('signal_id', 'unknown')[:8]
                timestamp = output.get('processing_timestamp', 'unknown')
                print(f"     {i+1}. {signal_id} at {timestamp}")
        
    except Exception as e:
        print(f"   Error checking decoder output: {e}")
    
    # 3. Check WhatsApp messages to see direction distribution
    print(f"\n3. Checking WhatsApp message directions...")
    try:
        result = db.supabase.table('whatsapp_messages').select('message_direction').execute()
        whatsapp_messages = result.data or []
        
        if whatsapp_messages:
            direction_counts = {}
            for msg in whatsapp_messages:
                direction = msg.get('message_direction', 'unknown')
                direction_counts[direction] = direction_counts.get(direction, 0) + 1
            
            print(f"   Total WhatsApp messages: {len(whatsapp_messages)}")
            print(f"   Direction distribution:")
            for direction, count in direction_counts.items():
                print(f"     {direction}: {count}")
            
            # Calculate potential contamination
            outbound_count = direction_counts.get('outbound', 0) + direction_counts.get('sent', 0)
            inbound_count = direction_counts.get('inbound', 0) + direction_counts.get('received', 0)
            
            print(f"\n   Potential contamination analysis:")
            print(f"     Inbound messages: {inbound_count}")
            print(f"     Outbound messages: {outbound_count}")
            
            if outbound_count > 0:
                print(f"     ⚠️  {outbound_count} outbound messages could have been processed!")
                print(f"     This represents {outbound_count/(inbound_count + outbound_count)*100:.1f}% of WhatsApp messages")
            else:
                print(f"     ✅ No outbound messages found")
        
    except Exception as e:
        print(f"   Error checking WhatsApp messages: {e}")
    
    # 4. Check if unified view exists and has message_direction
    print(f"\n4. Checking unified view...")
    try:
        # Try to select from unified view with message_direction
        result = db.supabase.table('signals_unified').select('message_direction').limit(1).execute()
        if result.data:
            print(f"   ✅ Unified view exists and has message_direction field")
        else:
            print(f"   ⚠️  Unified view may not exist or be accessible")
    except Exception as e:
        print(f"   ❌ Unified view issue: {e}")
        print(f"   This explains why outbound filtering wasn't working!")
    
    print(f"\n=== SUMMARY ===")
    print(f"1. Check the processing state and decoder output counts above")
    print(f"2. If you see outbound messages in WhatsApp data, they were likely processed")
    print(f"3. The unified view needs the migration to be applied")
    print(f"4. Run the migration, then test filtering, then clean contaminated data")

if __name__ == "__main__":
    simple_assess_contamination()
