#!/usr/bin/env python3
"""
Test Different TikTok Handle Variations
=====================================
"""

import os
from apify_client import ApifyClient

print("🔍 Testing TikTok Handle Variations...")

client = ApifyClient(os.getenv('APIFY_API_TOKEN'))

# Different variations to try
variations = [
    "wingshackco",           # No @
    "@wingshackco",          # With @
    "https://www.tiktok.com/@wingshackco",  # Full URL
    "wingshack",             # Shorter version
    "wing_shack",            # With underscore
    "wingshackco.uk",        # With country
]

for variation in variations:
    print(f"\n🧪 Testing: {variation}")
    try:
        run_input = {
            "usernames": [variation],
            "resultsPerPage": 1,
            "maxItems": 1
        }
        run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
        results = list(client.dataset(run["defaultDatasetId"]).iterate_items())
        
        if results:
            print(f"✅ SUCCESS: {variation} - Found {len(results)} results")
            # Show first result details
            first_result = results[0]
            print(f"   - Video ID: {first_result.get('id', 'N/A')}")
            print(f"   - Description: {first_result.get('desc', 'N/A')[:50]}...")
            print(f"   - Author: {first_result.get('author', {}).get('uniqueId', 'N/A')}")
            break
        else:
            print(f"❌ No results for: {variation}")
            
    except Exception as e:
        print(f"❌ Error with {variation}: {str(e)[:100]}...")

print("\n🎯 Test complete!")
