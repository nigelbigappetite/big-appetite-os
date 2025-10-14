#!/usr/bin/env python3
"""
Create better cohort names and clean up duplicates
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

def create_better_cohort_names():
    print("🎯 Creating Better Cohort Names")
    print("="*50)
    
    db = DatabaseManager()
    
    try:
        # Get the most recent clustering run
        runs_result = db.supabase.table('clustering_runs').select('*').order('created_at', desc=True).limit(1).execute()
        if not runs_result.data:
            print("❌ No clustering runs found")
            return
        
        latest_run = runs_result.data[0]
        run_id = latest_run['run_id']
        print(f"📊 Using latest run: {run_id}")
        
        # Get cohorts from the latest run
        cohorts_result = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        cohorts = cohorts_result.data
        
        if not cohorts:
            print("❌ No cohorts found")
            return
        
        print(f"📊 Found {len(cohorts)} cohorts")
        
        # Group cohorts by their characteristics to identify unique ones
        unique_cohorts = {}
        
        for cohort in cohorts:
            # Create a key based on characteristics
            key = (
                cohort.get('size', 0),
                cohort.get('percentage', 0),
                str(cohort.get('driver_profile', {})),
                str(cohort.get('characteristics', {}))
            )
            
            if key not in unique_cohorts:
                unique_cohorts[key] = cohort
        
        print(f"🔍 Found {len(unique_cohorts)} unique cohorts")
        print()
        
        # Create better names for unique cohorts
        cohort_names = []
        for i, (key, cohort) in enumerate(unique_cohorts.items()):
            driver_profile = cohort.get('driver_profile', {})
            characteristics = cohort.get('characteristics', {})
            size = cohort.get('size', 0)
            
            # Generate better name
            better_name = generate_cohort_name(driver_profile, characteristics, size, i+1)
            cohort_names.append({
                'cohort_id': cohort['cohort_id'],
                'old_name': cohort['cohort_name'],
                'new_name': better_name,
                'size': size,
                'percentage': cohort.get('percentage', 0)
            })
            
            print(f"🎯 Cohort {i+1}:")
            print(f"   Old Name: {cohort['cohort_name']}")
            print(f"   New Name: {better_name}")
            print(f"   Size: {size} actors ({cohort.get('percentage', 0):.1f}%)")
            print(f"   Driver Profile: {driver_profile}")
            print("-" * 40)
        
        # Ask user if they want to update the names
        print("\n🤔 Do you want to update these cohort names in the database?")
        print("This will update the cohort_name field for all cohorts.")
        
        # For now, let's just show the suggestions
        print("\n💡 Suggested Cohort Names:")
        print("="*40)
        for i, cohort in enumerate(cohort_names):
            print(f"{i+1}. {cohort['old_name']} → {cohort['new_name']}")
        
        return cohort_names
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

def generate_cohort_name(driver_profile, characteristics, size, cohort_number):
    """Generate a better name based on cohort characteristics"""
    
    if not driver_profile or not characteristics:
        return f"Unknown Cohort {cohort_number}"
    
    # Get dominant driver
    dominant = characteristics.get('dominant_driver', 'Unknown')
    contradiction = characteristics.get('avg_contradiction', 0)
    
    # Get driver values
    safety = driver_profile.get('Safety', 0)
    connection = driver_profile.get('Connection', 0)
    status = driver_profile.get('Status', 0)
    growth = driver_profile.get('Growth', 0)
    freedom = driver_profile.get('Freedom', 0)
    purpose = driver_profile.get('Purpose', 0)
    
    # Determine if high contradiction
    is_high_contradiction = contradiction > 0.7
    
    # Create descriptive names based on patterns
    if dominant == 'Connection':
        if is_high_contradiction:
            if safety > 0.6:
                return "Community Seekers (Conflicted)"
            elif status > 0.5:
                return "Social Climbers (Torn)"
            else:
                return "Relationship Builders (Complex)"
        else:
            if safety > 0.5:
                return "Trusted Community Members"
            else:
                return "Social Connectors"
    
    elif dominant == 'Safety':
        if is_high_contradiction:
            if connection > 0.6:
                return "Security Seekers (Social)"
            elif status > 0.5:
                return "Cautious Achievers"
            else:
                return "Risk-Averse Planners"
        else:
            if connection > 0.5:
                return "Trust-Building Community"
            else:
                return "Safety-First Customers"
    
    elif dominant == 'Status':
        if is_high_contradiction:
            if connection > 0.6:
                return "Status Seekers (Social)"
            elif safety > 0.5:
                return "Elite Members (Cautious)"
            else:
                return "Achievement-Oriented (Complex)"
        else:
            if connection > 0.5:
                return "Influential Leaders"
            else:
                return "Premium Customers"
    
    elif dominant == 'Growth':
        if is_high_contradiction:
            return "Growth Seekers (Evolving)"
        else:
            return "Learning Enthusiasts"
    
    elif dominant == 'Freedom':
        if is_high_contradiction:
            return "Independence Seekers (Torn)"
        else:
            return "Autonomous Customers"
    
    elif dominant == 'Purpose':
        if is_high_contradiction:
            return "Purpose-Driven (Complex)"
        else:
            return "Mission-Aligned Customers"
    
    # Fallback based on size and contradiction
    if size < 10:
        return "Niche Segment"
    elif is_high_contradiction:
        return "Complex Personality Group"
    else:
        return "Balanced Customer Group"

def update_cohort_names(cohort_names):
    """Update cohort names in the database"""
    
    if not cohort_names:
        print("❌ No cohort names to update")
        return
    
    db = DatabaseManager()
    
    try:
        print("\n🔄 Updating cohort names in database...")
        
        for cohort in cohort_names:
            # Update the cohort name
            result = db.supabase.table('cohorts').update({
                'cohort_name': cohort['new_name']
            }).eq('cohort_id', cohort['cohort_id']).execute()
            
            if result.data:
                print(f"   ✅ Updated: {cohort['old_name']} → {cohort['new_name']}")
            else:
                print(f"   ❌ Failed to update: {cohort['old_name']}")
        
        print("\n✅ Cohort names updated successfully!")
        
    except Exception as e:
        print(f"❌ Error updating cohort names: {e}")

if __name__ == "__main__":
    cohort_names = create_better_cohort_names()
    
    if cohort_names:
        print("\n" + "="*60)
        print("🎯 FINAL COHORT NAMES:")
        print("="*60)
        for i, cohort in enumerate(cohort_names):
            print(f"{i+1}. {cohort['new_name']} ({cohort['size']} actors, {cohort['percentage']:.1f}%)")
        
        print("\n💡 These names are more descriptive and business-friendly!")
        print("   They reflect the actual psychological drivers and behaviors")
        print("   of each customer segment, making them easier to work with.")
