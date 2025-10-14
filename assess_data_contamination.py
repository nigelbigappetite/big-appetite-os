#!/usr/bin/env python3
"""
Assess data contamination from outbound messages being processed.
This script will help identify how much outbound data was incorrectly analyzed.
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

def assess_contamination():
    """Assess how much outbound data contaminated the analysis."""
    db = DatabaseManager()
    
    print("=== DATA CONTAMINATION ASSESSMENT ===\n")
    
    # 1. Check what's in the processing state table
    print("1. Checking processed signals...")
    try:
        processed_query = """
        SELECT 
            p.signal_id,
            p.status,
            p.processed_at,
            s.signal_type,
            s.source_platform,
            s.message_direction,
            s.signal_text
        FROM signal_processing_state p
        LEFT JOIN signals_unified s ON p.signal_id = s.signal_id
        WHERE p.processed_at IS NOT NULL
        ORDER BY p.processed_at DESC
        LIMIT 100
        """
        
        result = db.supabase.rpc('exec_sql', {'sql': processed_query, 'params': []}).execute()
        processed_signals = result.data or []
        
        print(f"   Total processed signals found: {len(processed_signals)}")
        
        if processed_signals:
            # Analyze by type and direction
            whatsapp_signals = [s for s in processed_signals if s.get('source_platform') == 'whatsapp']
            other_signals = [s for s in processed_signals if s.get('source_platform') != 'whatsapp']
            
            print(f"   WhatsApp signals: {len(whatsapp_signals)}")
            print(f"   Other signals: {len(other_signals)}")
            
            if whatsapp_signals:
                # Count by direction
                direction_counts = {}
                for signal in whatsapp_signals:
                    direction = signal.get('message_direction', 'unknown')
                    direction_counts[direction] = direction_counts.get(direction, 0) + 1
                
                print(f"\n   WhatsApp message directions in processed data:")
                for direction, count in direction_counts.items():
                    print(f"     {direction}: {count}")
                
                # Show sample outbound messages that were processed
                outbound_processed = [s for s in whatsapp_signals 
                                   if s.get('message_direction', '').lower() in ['outbound', 'sent']]
                
                if outbound_processed:
                    print(f"\n   ⚠️  CONTAMINATION DETECTED:")
                    print(f"   {len(outbound_processed)} outbound messages were processed!")
                    print(f"\n   Sample outbound messages that were analyzed:")
                    for i, signal in enumerate(outbound_processed[:5]):
                        text = (signal.get('signal_text') or '')[:80]
                        processed_at = signal.get('processed_at', 'unknown')
                        print(f"     {i+1}. [{processed_at}] {text}...")
                else:
                    print(f"\n   ✅ No outbound contamination detected in sample")
        
    except Exception as e:
        print(f"   Error checking processed signals: {e}")
    
    # 2. Check decoder output table for contamination
    print(f"\n2. Checking decoder output for contamination...")
    try:
        decoder_query = """
        SELECT 
            d.signal_id,
            d.processing_timestamp,
            s.signal_type,
            s.source_platform,
            s.message_direction,
            s.signal_text
        FROM signal_decoder_output d
        LEFT JOIN signals_unified s ON d.signal_id = s.signal_id
        WHERE s.source_platform = 'whatsapp'
        ORDER BY d.processing_timestamp DESC
        LIMIT 50
        """
        
        result = db.supabase.rpc('exec_sql', {'sql': decoder_query, 'params': []}).execute()
        decoder_outputs = result.data or []
        
        if decoder_outputs:
            outbound_in_decoder = [d for d in decoder_outputs 
                                 if d.get('message_direction', '').lower() in ['outbound', 'sent']]
            
            print(f"   Decoder outputs checked: {len(decoder_outputs)}")
            print(f"   Outbound messages in decoder output: {len(outbound_in_decoder)}")
            
            if outbound_in_decoder:
                print(f"\n   ⚠️  DECODER CONTAMINATION:")
                print(f"   {len(outbound_in_decoder)} outbound messages have decoder analysis!")
                
                # Show sample contaminated decoder outputs
                print(f"\n   Sample contaminated decoder outputs:")
                for i, output in enumerate(outbound_in_decoder[:3]):
                    text = (output.get('signal_text') or '')[:60]
                    timestamp = output.get('processing_timestamp', 'unknown')
                    print(f"     {i+1}. [{timestamp}] {text}...")
        else:
            print(f"   No decoder outputs found")
            
    except Exception as e:
        print(f"   Error checking decoder output: {e}")
    
    # 3. Check actor profiles for contamination
    print(f"\n3. Checking actor profiles for contamination...")
    try:
        # This would require checking if any actor profiles were updated based on outbound messages
        # For now, just report that this needs manual investigation
        print(f"   Manual investigation needed: Check if any actor profiles were updated")
        print(f"   based on outbound message analysis")
        
    except Exception as e:
        print(f"   Error checking actor profiles: {e}")
    
    print(f"\n=== RECOMMENDATIONS ===")
    print(f"1. If contamination is found, consider:")
    print(f"   - Deleting contaminated decoder outputs")
    print(f"   - Resetting processing state for contaminated signals")
    print(f"   - Re-running analysis on clean inbound-only data")
    print(f"2. Run the migration to fix the unified view")
    print(f"3. Test the filtering before reprocessing")

if __name__ == "__main__":
    assess_contamination()
