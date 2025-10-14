#!/usr/bin/env python3
"""
Analyze cohort characteristics and suggest better names
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

def analyze_cohorts():
    print("🎯 Analyzing Current Cohorts for Better Names")
    print("="*60)
    
    db = DatabaseManager()
    
    try:
        # Get cohorts from database
        result = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        cohorts = result.data
        
        if not cohorts:
            print("❌ No cohorts found in database")
            return
        
        print(f"📊 Found {len(cohorts)} cohorts in database")
        print()
        
        for i, cohort in enumerate(cohorts):
            print(f"🔍 Cohort {i+1}: {cohort['cohort_name']}")
            print(f"   Size: {cohort['size']} actors ({cohort['percentage']:.1f}%)")
            
            # Analyze driver profile
            driver_profile = cohort.get('driver_profile', {})
            if driver_profile:
                print(f"   Driver Profile:")
                drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
                for driver in drivers:
                    value = driver_profile.get(driver, 0)
                    if isinstance(value, (int, float)):
                        print(f"     {driver}: {value:.2f}")
            
            # Analyze characteristics
            characteristics = cohort.get('characteristics', {})
            if characteristics:
                print(f"   Key Characteristics:")
                dominant = characteristics.get('dominant_driver', 'Unknown')
                contradiction = characteristics.get('avg_contradiction', 0)
                print(f"     Dominant Driver: {dominant}")
                print(f"     Contradiction Score: {contradiction:.2f}")
                
                # Suggest better name based on characteristics
                suggested_name = suggest_cohort_name(driver_profile, characteristics, cohort['size'])
                print(f"   💡 Suggested Name: {suggested_name}")
            
            print("-" * 50)
        
        print("\n🎯 Summary of Suggested Names:")
        print("="*40)
        for i, cohort in enumerate(cohorts):
            driver_profile = cohort.get('driver_profile', {})
            characteristics = cohort.get('characteristics', {})
            suggested_name = suggest_cohort_name(driver_profile, characteristics, cohort['size'])
            print(f"{i+1}. {cohort['cohort_name']} → {suggested_name}")
        
    except Exception as e:
        print(f"❌ Error analyzing cohorts: {e}")

def suggest_cohort_name(driver_profile, characteristics, size):
    """Suggest a better name based on cohort characteristics"""
    
    if not driver_profile or not characteristics:
        return "Unknown Cohort"
    
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

if __name__ == "__main__":
    analyze_cohorts()
