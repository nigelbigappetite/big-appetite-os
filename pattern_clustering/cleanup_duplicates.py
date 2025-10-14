#!/usr/bin/env python3
"""
Clean up duplicate cohort records and keep only unique ones
"""

import os
import sys
from dotenv import load_dotenv

# Add intelligence_layer to path
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PKG_PATH = os.path.join(ROOT, 'intelligence_layer')
if PKG_PATH not in sys.path:
    sys.path.append(PKG_PATH)

# Also add the parent directory to path for direct imports
PARENT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PARENT_DIR not in sys.path:
    sys.path.append(PARENT_DIR)

load_dotenv()

from intelligence_layer.src.database import DatabaseManager

def cleanup_duplicate_cohorts():
    print("🧹 Cleaning Up Duplicate Cohort Records")
    print("="*50)
    
    db = DatabaseManager()
    
    try:
        # Get all cohorts
        cohorts_result = db.supabase.table('cohorts').select('*').order('created_at', desc=True).execute()
        cohorts = cohorts_result.data
        
        if not cohorts:
            print("❌ No cohorts found")
            return
        
        print(f"📊 Found {len(cohorts)} total cohort records")
        
        # Group by characteristics to find unique cohorts
        unique_cohorts = {}
        duplicates_to_delete = []
        
        for cohort in cohorts:
            # Create a key based on characteristics
            key = (
                cohort.get('size', 0),
                cohort.get('percentage', 0),
                str(cohort.get('driver_profile', {})),
                str(cohort.get('characteristics', {}))
            )
            
            if key not in unique_cohorts:
                # This is a unique cohort, keep it
                unique_cohorts[key] = cohort
                print(f"✅ Keeping unique cohort: {cohort['cohort_name']} (ID: {cohort['cohort_id']})")
            else:
                # This is a duplicate, mark for deletion
                duplicates_to_delete.append(cohort['cohort_id'])
                print(f"🗑️  Marking duplicate for deletion: {cohort['cohort_name']} (ID: {cohort['cohort_id']})")
        
        print(f"\n📊 Summary:")
        print(f"   Unique cohorts: {len(unique_cohorts)}")
        print(f"   Duplicates to delete: {len(duplicates_to_delete)}")
        
        if duplicates_to_delete:
            print(f"\n🗑️  Deleting {len(duplicates_to_delete)} duplicate records...")
            
            # Delete duplicates in batches
            batch_size = 10
            for i in range(0, len(duplicates_to_delete), batch_size):
                batch = duplicates_to_delete[i:i + batch_size]
                
                # Delete batch
                result = db.supabase.table('cohorts').delete().in_('cohort_id', batch).execute()
                
                if result.data:
                    print(f"   ✅ Deleted batch {i//batch_size + 1}: {len(batch)} records")
                else:
                    print(f"   ❌ Failed to delete batch {i//batch_size + 1}")
            
            print(f"\n✅ Cleanup complete! Deleted {len(duplicates_to_delete)} duplicate records")
        else:
            print("\n✅ No duplicates found - database is already clean!")
        
        # Show final unique cohorts
        print(f"\n🎯 Final Unique Cohorts:")
        print("="*30)
        
        final_cohorts = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        
        for i, cohort in enumerate(final_cohorts.data):
            print(f"{i+1}. {cohort['cohort_name']}")
            print(f"   Size: {cohort['size']} actors ({cohort['percentage']:.1f}%)")
            print(f"   ID: {cohort['cohort_id']}")
            print()
        
        print(f"💡 Now you have {len(final_cohorts.data)} clean, unique cohort records!")
        print("   Each represents a distinct customer segment with no duplicates.")
        
    except Exception as e:
        print(f"❌ Error during cleanup: {e}")

if __name__ == "__main__":
    cleanup_duplicate_cohorts()
