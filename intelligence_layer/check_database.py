#!/usr/bin/env python3
"""
Database Inspector - Check what tables exist in your Supabase database
"""

import os
import sys
from supabase import create_client

# Add src to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

def check_database():
    """Check what tables exist in the database"""
    print("🔍 Database Inspector")
    print("=" * 50)
    
    try:
        # Get credentials
        url = os.getenv("SUPABASE_URL")
        key = os.getenv("SUPABASE_KEY")
        
        if not url or not key:
            print("❌ Missing SUPABASE_URL or SUPABASE_KEY")
            return
        
        print(f"✅ Connected to: {url}")
        
        # Create client
        client = create_client(url, key)
        
        # Check 1: List all tables
        print("\n📋 Checking available tables...")
        try:
            # Try to get table list (this might not work with all Supabase versions)
            response = client.table("information_schema.tables").select("table_name, table_schema").eq("table_schema", "public").execute()
            if response.data:
                print("Available tables in 'public' schema:")
                for table in response.data:
                    print(f"  - {table['table_name']}")
            else:
                print("Could not list tables via information_schema")
        except Exception as e:
            print(f"Could not list tables: {e}")
        
        # Check 2: Try different table name variations
        print("\n🔍 Testing different table name variations...")
        
        table_variations = [
            "drivers",
            "actors.drivers", 
            "public.drivers",
            "public.actors.drivers",
            "actor_profiles",
            "actors.actor_profiles",
            "public.actor_profiles",
            "public.actors.actor_profiles"
        ]
        
        for table_name in table_variations:
            try:
                print(f"Testing: {table_name}")
                response = client.table(table_name).select("count").limit(1).execute()
                print(f"  ✅ {table_name} - Found! ({len(response.data)} records)")
            except Exception as e:
                error_msg = str(e)
                if "not found" in error_msg.lower() or "does not exist" in error_msg.lower():
                    print(f"  ❌ {table_name} - Not found")
                else:
                    print(f"  ⚠️  {table_name} - Error: {error_msg}")
        
        # Check 3: Try to create a simple test table
        print("\n🧪 Testing table creation...")
        try:
            # This will fail if we don't have permissions, but we can see the error
            test_data = {"test": "value"}
            response = client.table("test_table").insert(test_data).execute()
            print("✅ Can create tables")
        except Exception as e:
            if "permission" in str(e).lower():
                print("⚠️  No permission to create tables (this is normal)")
            else:
                print(f"❌ Table creation error: {e}")
        
        # Check 4: Test with a known table (if any exist)
        print("\n🔍 Looking for any existing tables...")
        common_tables = [
            "users", "profiles", "messages", "orders", "products", 
            "reviews", "whatsapp_messages", "survey_responses"
        ]
        
        found_tables = []
        for table_name in common_tables:
            try:
                response = client.table(table_name).select("count").limit(1).execute()
                found_tables.append(table_name)
                print(f"  ✅ Found: {table_name}")
            except:
                pass
        
        if not found_tables:
            print("  ❌ No common tables found")
        else:
            print(f"\n📊 Found {len(found_tables)} tables: {', '.join(found_tables)}")
        
        print("\n" + "=" * 50)
        print("🎯 Next Steps:")
        print("1. If no tables found: You need to run your migrations")
        print("2. If tables found but wrong names: Update the table names in the code")
        print("3. If permission errors: Check your API key permissions")
        
    except Exception as e:
        print(f"❌ Database check failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    check_database()
