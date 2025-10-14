#!/usr/bin/env python3
"""
Final cleanup script for contaminated data from outbound message processing.
This works with the actual table names in your database.
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

def clean_contamination_final(dry_run=True):
    """
    Clean up contaminated data using actual table names.
    
    Args:
        dry_run: If True, only show what would be cleaned without actually doing it
    """
    db = DatabaseManager()
    
    print("=== FINAL CONTAMINATION CLEANUP ===\n")
    print(f"Mode: {'DRY RUN (no changes made)' if dry_run else 'LIVE (changes will be made)'}\n")
    
    # 1. Get all processed signals and check which are outbound
    print("1. Identifying contaminated signals...")
    try:
        # Get all processed signals
        result = db.supabase.table('signal_processing_state').select('signal_id').execute()
        processed_signal_ids = [s['signal_id'] for s in result.data or []]
        print(f"   Total processed signals: {len(processed_signal_ids)}")
        
        # Check which ones are outbound WhatsApp messages
        contaminated_ids = []
        if processed_signal_ids:
            # Get WhatsApp messages for these signal IDs
            result = db.supabase.table('whatsapp_messages').select('signal_id,message_direction').in_('signal_id', processed_signal_ids).execute()
            whatsapp_processed = result.data or []
            
            print(f"   WhatsApp messages among processed: {len(whatsapp_processed)}")
            
            # Find outbound ones
            for msg in whatsapp_processed:
                direction = msg.get('message_direction', '').lower()
                if direction in ['outbound', 'sent']:
                    contaminated_ids.append(msg['signal_id'])
            
            print(f"   Contaminated outbound signals: {len(contaminated_ids)}")
            
            if contaminated_ids:
                print(f"\n   Sample contaminated signal IDs:")
                for i, signal_id in enumerate(contaminated_ids[:5]):
                    print(f"     {i+1}. {signal_id}")
        
    except Exception as e:
        print(f"   Error identifying contaminated signals: {e}")
        return
    
    # 2. Check decoder log contamination
    print(f"\n2. Checking decoder log contamination...")
    try:
        result = db.supabase.table('decoder_log').select('signal_id').execute()
        decoder_logs = result.data or []
        print(f"   Total decoder log entries: {len(decoder_logs)}")
        
        if contaminated_ids and decoder_logs:
            # Check which decoder logs are for contaminated signals
            contaminated_decoder_ids = [log['signal_id'] for log in decoder_logs if log['signal_id'] in contaminated_ids]
            print(f"   Contaminated decoder log entries: {len(contaminated_decoder_ids)}")
        
    except Exception as e:
        print(f"   Error checking decoder log: {e}")
    
    # 3. Check API usage contamination
    print(f"\n3. Checking API usage contamination...")
    try:
        result = db.supabase.table('api_usage').select('signal_id').execute()
        api_usage = result.data or []
        print(f"   Total API usage entries: {len(api_usage)}")
        
        if contaminated_ids and api_usage:
            # Check which API usage entries are for contaminated signals
            contaminated_api_ids = [usage['signal_id'] for usage in api_usage if usage.get('signal_id') in contaminated_ids]
            print(f"   Contaminated API usage entries: {len(contaminated_api_ids)}")
        
    except Exception as e:
        print(f"   Error checking API usage: {e}")
    
    # 4. Perform cleanup if not dry run
    if not dry_run and contaminated_ids:
        print(f"\n4. Cleaning up contaminated data...")
        
        # Clean processing state
        print(f"   Cleaning processing state for {len(contaminated_ids)} signals...")
        try:
            delete_result = db.supabase.table('signal_processing_state').delete().in_('signal_id', contaminated_ids).execute()
            print(f"   Deleted {len(delete_result.data or [])} processing state records")
        except Exception as e:
            print(f"   Error cleaning processing state: {e}")
        
        # Clean decoder log
        if 'contaminated_decoder_ids' in locals() and contaminated_decoder_ids:
            print(f"   Cleaning decoder log for {len(contaminated_decoder_ids)} entries...")
            try:
                delete_result = db.supabase.table('decoder_log').delete().in_('signal_id', contaminated_decoder_ids).execute()
                print(f"   Deleted {len(delete_result.data or [])} decoder log records")
            except Exception as e:
                print(f"   Error cleaning decoder log: {e}")
        
        # Clean API usage
        if 'contaminated_api_ids' in locals() and contaminated_api_ids:
            print(f"   Cleaning API usage for {len(contaminated_api_ids)} entries...")
            try:
                delete_result = db.supabase.table('api_usage').delete().in_('signal_id', contaminated_api_ids).execute()
                print(f"   Deleted {len(delete_result.data or [])} API usage records")
            except Exception as e:
                print(f"   Error cleaning API usage: {e}")
        
        print(f"\n   ✅ Cleanup completed!")
        
    elif dry_run:
        print(f"\n4. DRY RUN - No cleanup performed")
        print(f"   To actually clean the data, run with dry_run=False")
    
    else:
        print(f"\n4. No contaminated data found - no cleanup needed")
    
    # 5. Show summary
    print(f"\n=== SUMMARY ===")
    print(f"Contaminated signals: {len(contaminated_ids)}")
    if 'contaminated_decoder_ids' in locals():
        print(f"Contaminated decoder logs: {len(contaminated_decoder_ids)}")
    if 'contaminated_api_ids' in locals():
        print(f"Contaminated API usage: {len(contaminated_api_ids)}")
    
    if contaminated_ids:
        print(f"\nNext steps:")
        print(f"1. Run the migration to fix the unified view (if not already done)")
        print(f"2. Test the filtering with: python3 test_outbound_filtering.py")
        print(f"3. Re-run the signal processor on clean data")
    else:
        print(f"\nNo contamination found - your data is clean!")

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Clean contaminated data from outbound message processing')
    parser.add_argument('--live', action='store_true', help='Actually perform the cleanup (default is dry run)')
    args = parser.parse_args()
    
    clean_contamination_final(dry_run=not args.live)

if __name__ == "__main__":
    main()
