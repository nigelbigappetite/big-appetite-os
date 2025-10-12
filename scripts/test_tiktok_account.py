#!/usr/bin/env python3
"""
Test TikTok Account Access
=========================
Test if we can access the Wing Shack TikTok account.
"""

import os
from apify_client import ApifyClient

print("🔍 Testing TikTok Account Access...")

# Initialize Apify client
client = ApifyClient(os.getenv('APIFY_API_TOKEN'))

def test_tiktok_account():
    """Test different ways to access the TikTok account"""
    
    # Test 1: Try with @ symbol
    print("Test 1: Trying @wingshackco...")
    try:
        run_input = {
            "usernames": ["@wingshackco"],
            "resultsPerPage": 1,
            "maxItems": 1
        }
        run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
        results = list(client.dataset(run["defaultDatasetId"]).iterate_items())
        print(f"✅ @wingshackco works: {len(results)} results")
        return True
    except Exception as e:
        print(f"❌ @wingshackco failed: {e}")
    
    # Test 2: Try without @ symbol
    print("\nTest 2: Trying wingshackco...")
    try:
        run_input = {
            "usernames": ["wingshackco"],
            "resultsPerPage": 1,
            "maxItems": 1
        }
        run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
        results = list(client.dataset(run["defaultDatasetId"]).iterate_items())
        print(f"✅ wingshackco works: {len(results)} results")
        return True
    except Exception as e:
        print(f"❌ wingshackco failed: {e}")
    
    # Test 3: Try with full URL
    print("\nTest 3: Trying with URL...")
    try:
        run_input = {
            "usernames": ["https://www.tiktok.com/@wingshackco"],
            "resultsPerPage": 1,
            "maxItems": 1
        }
        run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
        results = list(client.dataset(run["defaultDatasetId"]).iterate_items())
        print(f"✅ URL works: {len(results)} results")
        return True
    except Exception as e:
        print(f"❌ URL failed: {e}")
    
    return False

def search_tiktok_accounts():
    """Search for Wing Shack related TikTok accounts"""
    
    print("\n🔍 Searching for Wing Shack TikTok accounts...")
    
    # Try different variations
    variations = [
        "wingshackco",
        "wingshack",
        "wing_shack",
        "wingshackco.uk",
        "wingshackco.london"
    ]
    
    for variation in variations:
        print(f"\nTrying: {variation}")
        try:
            run_input = {
                "usernames": [variation],
                "resultsPerPage": 1,
                "maxItems": 1
            }
            run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
            results = list(client.dataset(run["defaultDatasetId"]).iterate_items())
            if results:
                print(f"✅ Found: {variation} - {len(results)} results")
                return variation
            else:
                print(f"❌ No results for: {variation}")
        except Exception as e:
            print(f"❌ Error with {variation}: {e}")
    
    return None

if __name__ == "__main__":
    print("🎯 TikTok Account Troubleshooting")
    print("================================\n")
    
    # Check API token
    if not os.getenv('APIFY_API_TOKEN'):
        print("❌ APIFY_API_TOKEN not set")
        exit(1)
    
    # Test the account
    if test_tiktok_account():
        print("\n🎉 TikTok account is accessible!")
    else:
        print("\n🔍 Account not found, searching for alternatives...")
        found_account = search_tiktok_accounts()
        if found_account:
            print(f"\n✅ Found working account: {found_account}")
        else:
            print("\n❌ No Wing Shack TikTok accounts found")
            print("   Possible reasons:")
            print("   - Account doesn't exist")
            print("   - Account is private")
            print("   - Account name is different")
            print("   - TikTok API restrictions")
