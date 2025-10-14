#!/usr/bin/env python3
"""
Test script to verify that outbound WhatsApp messages are properly filtered out
from signal processing.
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

from intelligence_layer.src.database import get_unprocessed_signals
from intelligence_layer.run_unified_processor import inbound_only_filter, INBOUND_VALUES

def test_outbound_filtering():
    """Test that outbound messages are filtered out correctly."""
    print("Testing outbound message filtering...")
    print(f"INBOUND_VALUES: {INBOUND_VALUES}")
    
    # Get unprocessed signals
    print("\nFetching unprocessed signals...")
    signals = get_unprocessed_signals(limit=50)
    print(f"Total signals fetched: {len(signals)}")
    
    if not signals:
        print("No signals found to test.")
        return
    
    # Show signal breakdown by type and direction
    whatsapp_signals = [s for s in signals if s.get('source_platform', '').lower() == 'whatsapp']
    other_signals = [s for s in signals if s.get('source_platform', '').lower() != 'whatsapp']
    
    print(f"\nWhatsApp signals: {len(whatsapp_signals)}")
    print(f"Other signals: {len(other_signals)}")
    
    # Show WhatsApp message directions
    if whatsapp_signals:
        print("\nWhatsApp message directions:")
        direction_counts = {}
        for signal in whatsapp_signals:
            direction = signal.get('message_direction', 'unknown')
            direction_counts[direction] = direction_counts.get(direction, 0) + 1
        
        for direction, count in direction_counts.items():
            print(f"  {direction}: {count}")
    
    # Apply filtering
    print("\nApplying inbound-only filter...")
    filtered_signals = inbound_only_filter(signals)
    print(f"Signals after filtering: {len(filtered_signals)}")
    
    # Show what was filtered out
    filtered_out = len(signals) - len(filtered_signals)
    print(f"Signals filtered out: {filtered_out}")
    
    # Show sample of filtered signals
    if filtered_signals:
        print("\nSample of filtered signals (first 3):")
        for i, signal in enumerate(filtered_signals[:3]):
            direction = signal.get('message_direction', 'N/A')
            text = (signal.get('signal_text', '') or signal.get('raw_content', ''))[:50]
            print(f"  {i+1}. [{signal.get('source_platform', 'unknown')}] {direction}: {text}...")
    
    # Check if any outbound messages made it through
    outbound_in_filtered = [s for s in filtered_signals 
                          if s.get('source_platform', '').lower() == 'whatsapp' 
                          and s.get('message_direction', '').lower() not in INBOUND_VALUES]
    
    if outbound_in_filtered:
        print(f"\n⚠️  WARNING: {len(outbound_in_filtered)} outbound messages made it through the filter!")
        for signal in outbound_in_filtered:
            direction = signal.get('message_direction', 'unknown')
            text = (signal.get('signal_text', '') or signal.get('raw_content', ''))[:50]
            print(f"  - {direction}: {text}...")
    else:
        print("\n✅ SUCCESS: No outbound messages made it through the filter!")

if __name__ == "__main__":
    test_outbound_filtering()
