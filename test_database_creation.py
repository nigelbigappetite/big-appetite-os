#!/usr/bin/env python3
"""
Test database table creation for clustering
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

def main():
    print("🔧 Testing Database Table Creation")
    print("="*50)
    
    db = DatabaseManager()
    
    # Read the SQL file
    with open('create_clustering_tables.sql', 'r') as f:
        sql_content = f.read()
    
    print("📄 SQL file loaded successfully")
    print(f"   File size: {len(sql_content)} characters")
    
    # Split into individual statements
    statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
    print(f"   Found {len(statements)} SQL statements")
    
    print("\n🚀 Attempting to create tables...")
    
    success_count = 0
    error_count = 0
    
    for i, statement in enumerate(statements[:10]):  # Test first 10 statements
        if not statement:
            continue
            
        try:
            print(f"   Executing statement {i+1}...")
            # Try to execute via RPC
            result = db.supabase.rpc('exec_sql', {'sql': statement + ';'}).execute()
            print(f"   ✅ Statement {i+1} executed successfully")
            success_count += 1
        except Exception as e:
            print(f"   ❌ Statement {i+1} failed: {str(e)[:100]}...")
            error_count += 1
    
    print(f"\n📊 Results:")
    print(f"   ✅ Successful: {success_count}")
    print(f"   ❌ Failed: {error_count}")
    
    if success_count > 0:
        print("\n🎉 Some tables were created successfully!")
        print("   You can now run clustering and save to database")
    else:
        print("\n⚠️  Manual setup required")
        print("   Please run the SQL file in Supabase SQL Editor")
        print("   File: create_clustering_tables.sql")

if __name__ == "__main__":
    main()
