#!/usr/bin/env python3
"""
Display a summary of the improved cohort names and characteristics
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

def show_cohort_summary():
    print("🎯 IMPROVED COHORT NAMES & CHARACTERISTICS")
    print("="*60)
    
    db = DatabaseManager()
    
    try:
        # Get unique cohorts (grouped by name)
        cohorts_result = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        cohorts = cohorts_result.data
        
        if not cohorts:
            print("❌ No cohorts found")
            return
        
        # Group by name to get unique cohorts
        unique_cohorts = {}
        for cohort in cohorts:
            name = cohort['cohort_name']
            if name not in unique_cohorts:
                unique_cohorts[name] = cohort
        
        print(f"📊 Found {len(unique_cohorts)} unique customer segments")
        print()
        
        for i, (name, cohort) in enumerate(unique_cohorts.items()):
            print(f"🎯 {i+1}. {name}")
            print(f"   Size: {cohort['size']} actors ({cohort['percentage']:.1f}%)")
            
            # Show driver profile
            driver_profile = cohort.get('driver_profile', {})
            if driver_profile:
                print(f"   Psychological Drivers:")
                drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
                for driver in drivers:
                    value = driver_profile.get(driver, 0)
                    if isinstance(value, (int, float)):
                        bar = "█" * int(value * 20)  # Visual bar
                        print(f"     {driver:10}: {value:.2f} {bar}")
            
            # Show characteristics
            characteristics = cohort.get('characteristics', {})
            if characteristics:
                print(f"   Key Characteristics:")
                dominant = characteristics.get('dominant_driver', 'Unknown')
                contradiction = characteristics.get('avg_contradiction', 0)
                print(f"     Dominant Driver: {dominant}")
                print(f"     Contradiction Score: {contradiction:.2f}")
                
                # Show messaging strategy
                messaging = cohort.get('messaging_strategy', {})
                if messaging and isinstance(messaging, dict):
                    tone = messaging.get('tone', 'Not specified')
                    print(f"     Messaging Tone: {tone}")
            
            print()
        
        print("💡 BUSINESS INSIGHTS:")
        print("="*30)
        print("• Relationship Builders (Complex) - Your largest segment (32.3%)")
        print("  - High contradiction means they have conflicting needs")
        print("  - Focus on community and connection in messaging")
        print("  - Use warm, inclusive language")
        print()
        print("• Risk-Averse Planners - Your second largest segment (17.5%)")
        print("  - Safety-focused customers who need reassurance")
        print("  - Emphasize security, guarantees, and proven results")
        print("  - Use data and testimonials to build trust")
        print()
        print("• Premium Customers - Your smallest but most valuable segment (1.3%)")
        print("  - Balanced drivers suggest they're sophisticated buyers")
        print("  - Focus on quality, exclusivity, and premium positioning")
        print("  - Use aspirational messaging and high-end imagery")
        print()
        print("🎯 NEXT STEPS:")
        print("• Develop specific messaging strategies for each segment")
        print("• Create targeted marketing campaigns")
        print("• Test different approaches with each cohort")
        print("• Monitor how new customers fit into these segments")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    show_cohort_summary()
