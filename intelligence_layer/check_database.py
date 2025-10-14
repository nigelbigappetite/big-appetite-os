#!/usr/bin/env python3
"""
Database Inspector - Check what signals are available
"""

import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables
load_dotenv()

def check_database():
    """Check database connection and available signals"""
    print("🔍 Database Inspector")
    print("=" * 50)
    
    # Get credentials
    url = os.getenv('SUPABASE_URL')
    key = os.getenv('SUPABASE_KEY')
    
    if not url or not key:
        print("❌ Missing SUPABASE_URL or SUPABASE_KEY")
        return
    
    print(f"✅ URL: {url}")
    print(f"✅ KEY: {key[:20]}...")
    
    try:
        # Create client
        client = create_client(url, key)
        print("✅ Supabase client created")
        
        # Check drivers table
        print("\n📊 Checking drivers table...")
        drivers = client.table('drivers').select('driver_name').execute()
        print(f"✅ Found {len(drivers.data)} drivers: {[d['driver_name'] for d in drivers.data]}")
        
        # Prefer unified view if present
        print("\n📊 Checking unified signals view...")
        try:
            unified = client.table('signals_unified').select('signal_id, signal_text, signal_type, source_platform').limit(5).execute()
            if unified.data:
                print(f"✅ signals_unified: {len(unified.data)} sample rows")
                for row in unified.data:
                    preview = (row.get('signal_text') or '')[:50]
                    print(f"   {row.get('signal_id')} [{row.get('signal_type')}/{row.get('source_platform')}]: {preview}...")
            else:
                print("❌ signals_unified: No rows (view empty)")
        except Exception as e:
            print(f"❌ signals_unified: Error - {str(e)}")

        print("\n📊 Checking raw signal tables...")
        raw_checks = [
            ('whatsapp_messages', 'message_text'),
            ('reviews', 'review_text'),
            ('signals', 'raw_content')
        ]
        for table, col in raw_checks:
            try:
                result = client.table(table).select(f'signal_id, {col}').limit(5).execute()
                if result.data:
                    print(f"✅ {table}: {len(result.data)} signals found")
                    first = result.data[0]
                    content = first.get(col) or ''
                    print(f"   Example: {first.get('signal_id')} - {str(content)[:50]}...")
                else:
                    print(f"❌ {table}: No signals found")
            except Exception as e:
                print(f"❌ {table}: Error - {str(e)}")
        
        # Check actor tables
        print("\n📊 Checking actor tables...")
        try:
            actors = client.table('actor_profiles').select('actor_id').limit(5).execute()
            print(f"✅ actor_profiles: {len(actors.data)} actors found")
        except Exception as e:
            print(f"❌ actor_profiles: Error - {str(e)}")
        
        print("\n🎯 Ready to process signals!")
        
    except Exception as e:
        print(f"❌ Database error: {str(e)}")

if __name__ == "__main__":
    check_database()
