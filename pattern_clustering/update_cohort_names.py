#!/usr/bin/env python3
"""
Update cohort names in the database with better, more descriptive names
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

def update_cohort_names():
    print("🎯 Updating Cohort Names with Better Descriptions")
    print("="*60)
    
    db = DatabaseManager()
    
    try:
        # Get all cohorts
        cohorts_result = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        cohorts = cohorts_result.data
        
        if not cohorts:
            print("❌ No cohorts found")
            return
        
        print(f"📊 Found {len(cohorts)} cohorts to update")
        
        # Define the new names based on the analysis
        new_names = {
            "High-Contradiction Connection": "Relationship Builders (Complex)",
            "High-Contradiction Safety": "Risk-Averse Planners", 
            "Balanced Status": "Premium Customers"
        }
        
        updated_count = 0
        
        for cohort in cohorts:
            old_name = cohort['cohort_name']
            new_name = new_names.get(old_name, old_name)
            
            if old_name != new_name:
                # Update the cohort name
                result = db.supabase.table('cohorts').update({
                    'cohort_name': new_name
                }).eq('cohort_id', cohort['cohort_id']).execute()
                
                if result.data:
                    print(f"   ✅ Updated: {old_name} → {new_name}")
                    updated_count += 1
                else:
                    print(f"   ❌ Failed to update: {old_name}")
            else:
                print(f"   ⏭️  Skipped: {old_name} (already correct)")
        
        print(f"\n✅ Updated {updated_count} cohort names successfully!")
        
        # Show the final cohort summary
        print("\n🎯 Final Cohort Summary:")
        print("="*40)
        
        # Get updated cohorts
        updated_cohorts = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        
        # Group by name to show unique cohorts
        unique_cohorts = {}
        for cohort in updated_cohorts.data:
            name = cohort['cohort_name']
            if name not in unique_cohorts:
                unique_cohorts[name] = {
                    'name': name,
                    'size': cohort['size'],
                    'percentage': cohort['percentage'],
                    'count': 1
                }
            else:
                unique_cohorts[name]['count'] += 1
        
        for i, (name, info) in enumerate(unique_cohorts.items()):
            print(f"{i+1}. {info['name']}")
            print(f"   Size: {info['size']} actors ({info['percentage']:.1f}%)")
            print(f"   Instances: {info['count']}")
            print()
        
        print("💡 These names are now more descriptive and business-friendly!")
        print("   They reflect the actual psychological drivers and behaviors")
        print("   of each customer segment, making them easier to work with.")
        
    except Exception as e:
        print(f"❌ Error updating cohort names: {e}")

if __name__ == "__main__":
    update_cohort_names()
