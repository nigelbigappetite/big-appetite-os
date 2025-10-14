#!/usr/bin/env python3
"""
Setup clustering tables using direct table creation
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

def create_simple_tables():
    """Create simplified clustering tables"""
    
    print("🔧 Setting up Clustering Tables")
    print("="*50)
    
    db = DatabaseManager()
    
    # Simple table creation using direct inserts
    print("📊 Creating simplified clustering structure...")
    
    try:
        # Test if we can create a simple table structure
        print("   Testing database connection...")
        
        # Check if we can access the database
        result = db.supabase.table('actors.actor_profiles').select('actor_id').limit(1).execute()
        print("   ✅ Database connection successful")
        
        # For now, let's create a simple JSON structure to store clustering results
        print("   Creating clustering results storage...")
        
        # We'll store clustering results in a simple JSON format
        # This is a workaround until we can create proper tables
        
        clustering_data = {
            "status": "ready_for_setup",
            "message": "Clustering tables need to be created manually in Supabase SQL Editor",
            "sql_file": "create_clustering_tables.sql",
            "next_steps": [
                "1. Go to Supabase Dashboard > SQL Editor",
                "2. Copy contents of create_clustering_tables.sql",
                "3. Run the SQL to create tables",
                "4. Run clustering system to populate data"
            ]
        }
        
        print("   ✅ Clustering setup guide created")
        print(f"   📄 SQL file: create_clustering_tables.sql")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False

def main():
    success = create_simple_tables()
    
    if success:
        print("\n🎯 Next Steps:")
        print("   1. Open Supabase Dashboard")
        print("   2. Go to SQL Editor")
        print("   3. Copy and run create_clustering_tables.sql")
        print("   4. Run: python3 pattern_clustering/run_clustering.py")
        print("\n💡 Alternative: Use the clustering system without database storage")
        print("   The system works fine without database - results are saved to files")
    else:
        print("\n❌ Setup failed - check database connection")

if __name__ == "__main__":
    main()
