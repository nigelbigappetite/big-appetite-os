#!/usr/bin/env python3
"""
Test Apify Connection
====================
Simple script to test Apify API connection and available actors.
"""

import os
from apify_client import ApifyClient

print("🔧 Testing Apify Connection...")

# Check for API token
if not os.getenv('APIFY_API_TOKEN'):
    print("❌ APIFY_API_TOKEN environment variable not set")
    print("   Get your token from: https://console.apify.com/account/integrations")
    exit(1)

try:
    # Initialize Apify client
    client = ApifyClient(os.getenv('APIFY_API_TOKEN'))
    
    # Test connection by getting user info
    user_info = client.user().get()
    print(f"✅ Connected to Apify as: {user_info.get('username', 'Unknown')}")
    
    # Check available actors
    print("\n📋 Available Social Media Actors:")
    
    # TikTok scraper
    try:
        tiktok_actor = client.actor("apify/tiktok-scraper").get()
        print(f"✅ TikTok Scraper: {tiktok_actor.get('name', 'Unknown')}")
        print(f"   - Description: {tiktok_actor.get('description', 'No description')[:100]}...")
    except Exception as e:
        print(f"❌ TikTok Scraper: {e}")
    
    # Instagram scraper
    try:
        instagram_actor = client.actor("apify/instagram-scraper").get()
        print(f"✅ Instagram Scraper: {instagram_actor.get('name', 'Unknown')}")
        print(f"   - Description: {instagram_actor.get('description', 'No description')[:100]}...")
    except Exception as e:
        print(f"❌ Instagram Scraper: {e}")
    
    print("\n🎉 Apify connection test successful!")
    print("   Ready to run social media scraper")
    
except Exception as e:
    print(f"❌ Error connecting to Apify: {e}")
    print("   Check your API token and internet connection")
