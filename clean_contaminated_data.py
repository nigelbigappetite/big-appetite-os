#!/usr/bin/env python3
"""
Clean up contaminated data from outbound messages being processed.
This script will identify and clean up analysis records that were based on outbound messages.
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

def clean_contaminated_data(dry_run=True):
    """
    Clean up contaminated data from outbound message processing.
    
    Args:
        dry_run: If True, only show what would be cleaned without actually doing it
    """
    db = DatabaseManager()
    
    print("=== CLEANING CONTAMINATED DATA ===\n")
    print(f"Mode: {'DRY RUN (no changes made)' if dry_run else 'LIVE (changes will be made)'}\n")
    
    # 1. Find contaminated signals
    print("1. Finding contaminated signals...")
    try:
        contaminated_query = """
        SELECT 
            p.signal_id,
            p.status,
            p.processed_at,
            s.signal_text
        FROM signal_processing_state p
        LEFT JOIN signals_unified s ON p.signal_id = s.signal_id
        WHERE p.processed_at IS NOT NULL
        AND s.source_platform = 'whatsapp'
        AND s.message_direction IN ('outbound', 'sent')
        ORDER BY p.processed_at DESC
        """
        
        result = db.supabase.rpc('exec_sql', {'sql': contaminated_query, 'params': []}).execute()
        contaminated_signals = result.data or []
        
        print(f"   Found {len(contaminated_signals)} contaminated signals")
        
        if contaminated_signals:
            print(f"\n   Sample contaminated signals:")
            for i, signal in enumerate(contaminated_signals[:5]):
                text = (signal.get('signal_text') or '')[:60]
                processed_at = signal.get('processed_at', 'unknown')
                print(f"     {i+1}. [{processed_at}] {text}...")
        
    except Exception as e:
        print(f"   Error finding contaminated signals: {e}")
        return
    
    # 2. Find contaminated decoder outputs
    print(f"\n2. Finding contaminated decoder outputs...")
    try:
        contaminated_decoder_query = """
        SELECT 
            d.signal_id,
            d.processing_timestamp,
            s.signal_text
        FROM signal_decoder_output d
        LEFT JOIN signals_unified s ON d.signal_id = s.signal_id
        WHERE s.source_platform = 'whatsapp'
        AND s.message_direction IN ('outbound', 'sent')
        ORDER BY d.processing_timestamp DESC
        """
        
        result = db.supabase.rpc('exec_sql', {'sql': contaminated_decoder_query, 'params': []}).execute()
        contaminated_decoder_outputs = result.data or []
        
        print(f"   Found {len(contaminated_decoder_outputs)} contaminated decoder outputs")
        
        if contaminated_decoder_outputs:
            print(f"\n   Sample contaminated decoder outputs:")
            for i, output in enumerate(contaminated_decoder_outputs[:3]):
                text = (output.get('signal_text') or '')[:60]
                timestamp = output.get('processing_timestamp', 'unknown')
                print(f"     {i+1}. [{timestamp}] {text}...")
        
    except Exception as e:
        print(f"   Error finding contaminated decoder outputs: {e}")
        return
    
    # 3. Clean up if not dry run
    if not dry_run and (contaminated_signals or contaminated_decoder_outputs):
        print(f"\n3. Cleaning up contaminated data...")
        
        # Reset processing state for contaminated signals
        if contaminated_signals:
            print(f"   Resetting processing state for {len(contaminated_signals)} signals...")
            try:
                signal_ids = [s['signal_id'] for s in contaminated_signals]
                
                # Delete from processing state
                delete_result = db.supabase.table('signal_processing_state').delete().in_('signal_id', signal_ids).execute()
                print(f"   Deleted {len(delete_result.data or [])} processing state records")
                
            except Exception as e:
                print(f"   Error resetting processing state: {e}")
        
        # Delete contaminated decoder outputs
        if contaminated_decoder_outputs:
            print(f"   Deleting {len(contaminated_decoder_outputs)} contaminated decoder outputs...")
            try:
                decoder_signal_ids = [d['signal_id'] for d in contaminated_decoder_outputs]
                
                # Delete from decoder output
                delete_result = db.supabase.table('signal_decoder_output').delete().in_('signal_id', decoder_signal_ids).execute()
                print(f"   Deleted {len(delete_result.data or [])} decoder output records")
                
            except Exception as e:
                print(f"   Error deleting decoder outputs: {e}")
        
        print(f"\n   ✅ Cleanup completed!")
        
    elif dry_run:
        print(f"\n3. DRY RUN - No cleanup performed")
        print(f"   To actually clean the data, run with dry_run=False")
    
    else:
        print(f"\n3. No contaminated data found - no cleanup needed")
    
    # 4. Show summary
    print(f"\n=== SUMMARY ===")
    print(f"Contaminated signals: {len(contaminated_signals)}")
    print(f"Contaminated decoder outputs: {len(contaminated_decoder_outputs)}")
    
    if contaminated_signals or contaminated_decoder_outputs:
        print(f"\nNext steps:")
        print(f"1. Run the migration to fix the unified view")
        print(f"2. Test the filtering with: python test_outbound_filtering.py")
        print(f"3. Re-run the signal processor on clean data")
    else:
        print(f"\nNo contamination found - your data is clean!")

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Clean contaminated data from outbound message processing')
    parser.add_argument('--live', action='store_true', help='Actually perform the cleanup (default is dry run)')
    args = parser.parse_args()
    
    clean_contaminated_data(dry_run=not args.live)

if __name__ == "__main__":
    main()
