#!/usr/bin/env python3
"""
Test if clustering tables exist in public schema
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

def test_tables():
    print("🔍 Testing Clustering Tables in Public Schema")
    print("="*50)
    
    db = DatabaseManager()
    
    # Test each table
    tables_to_test = [
        'cohorts',
        'clustering_runs', 
        'actor_cohort_assignments',
        'cohort_history',
        'pattern_analysis'
    ]
    
    success_count = 0
    
    for table in tables_to_test:
        try:
            print(f"   Testing {table}...")
            result = db.supabase.table(table).select('*').limit(1).execute()
            print(f"   ✅ {table} - accessible")
            success_count += 1
        except Exception as e:
            print(f"   ❌ {table} - {str(e)[:60]}...")
    
    print(f"\n📊 Results: {success_count}/{len(tables_to_test)} tables accessible")
    
    if success_count == len(tables_to_test):
        print("\n🎉 All clustering tables are ready!")
        print("   You can now run: python3 pattern_clustering/run_clustering.py")
        return True
    else:
        print("\n⚠️  Some tables are missing")
        print("   Please run: move_clusters_to_public.sql in Supabase SQL Editor")
        return False

if __name__ == "__main__":
    test_tables()
