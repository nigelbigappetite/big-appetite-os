#!/usr/bin/env python3
"""
Apify Social Media Scraper
==========================
Scrapes TikTok and Instagram comments for Wing Shack using Apify actors.

Requirements:
- pip install apify-client
- Set APIFY_API_TOKEN environment variable

Usage:
python3 scripts/apify_social_scraper.py
"""

import os
import json
import time
from datetime import datetime
from apify_client import ApifyClient

print("🚀 Apify Social Media Scraper for Wing Shack")
print("============================================\n")

# Initialize Apify client
client = ApifyClient(os.getenv('APIFY_API_TOKEN'))

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

# Wing Shack social media handles
WING_SHACK_HANDLES = {
    'tiktok': '@wingshackco',
    'instagram': '@wingshackco'
}

def scrape_tiktok_comments():
    """Scrape TikTok comments for Wing Shack"""
    
    print("📱 Scraping TikTok comments...")
    
    # TikTok Comments Scraper actor
    run_input = {
        "usernames": [WING_SHACK_HANDLES['tiktok']],
        "resultsPerPage": 50,
        "shouldDownloadVideos": False,
        "shouldDownloadCovers": False,
        "shouldDownloadSlideshowImages": False,
        "maxItems": 1000
    }
    
    try:
        # Run the TikTok scraper
        run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
        
        results = []
        for item in client.dataset(run["defaultDatasetId"]).iterate_items():
            # Process each video and its comments
            if 'comments' in item:
                for comment in item['comments']:
                    # Extract comment data
                    comment_data = {
                        'brand_id': WING_SHACK_BRAND_ID,
                        'platform': 'tiktok',
                        'post_id': item.get('id', ''),
                        'comment_id': comment.get('id', ''),
                        'comment_text': comment.get('text', ''),
                        'author_username': comment.get('author', {}).get('uniqueId', ''),
                        'author_display_name': comment.get('author', {}).get('nickname', ''),
                        'author_followers_count': comment.get('author', {}).get('stats', {}).get('followerCount', 0),
                        'author_verified': comment.get('author', {}).get('verified', False),
                        'comment_timestamp': comment.get('createTime', ''),
                        'like_count': comment.get('diggCount', 0),
                        'reply_count': comment.get('replyCount', 0),
                        'is_reply': comment.get('replyToCommentId') is not None,
                        'parent_comment_id': comment.get('replyToCommentId', ''),
                        'post_url': item.get('webVideoUrl', ''),
                        'post_caption': item.get('desc', ''),
                        'post_like_count': item.get('stats', {}).get('diggCount', 0),
                        'post_comment_count': item.get('stats', {}).get('commentCount', 0),
                        'post_view_count': item.get('stats', {}).get('playCount', 0),
                        'post_timestamp': item.get('createTime', ''),
                        'hashtags': extract_hashtags(item.get('desc', '')),
                        'mentions': extract_mentions(comment.get('text', '')),
                        'raw_content': json.dumps({
                            'video_data': item,
                            'comment_data': comment,
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'raw_metadata': json.dumps({
                            'source': 'apify_tiktok_scraper',
                            'scraper_version': '1.0',
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'received_at': datetime.now().isoformat(),
                        'intake_method': 'apify_tiktok_scraper',
                        'intake_metadata': json.dumps({
                            'apify_run_id': run['id'],
                            'scraper_actor': 'apify/tiktok-scraper',
                            'scraped_at': datetime.now().isoformat()
                        })
                    }
                    
                    results.append(comment_data)
        
        print(f"✅ Scraped {len(results)} TikTok comments")
        return results
        
    except Exception as e:
        print(f"❌ Error scraping TikTok: {e}")
        return []

def scrape_instagram_comments():
    """Scrape Instagram comments for Wing Shack"""
    
    print("📸 Scraping Instagram comments...")
    
    # Instagram Comments Scraper actor
    run_input = {
        "directUrls": [f"https://www.instagram.com/{WING_SHACK_HANDLES['instagram'].replace('@', '')}/"],
        "resultsType": "posts",
        "resultsLimit": 100,
        "addParentData": True
    }
    
    try:
        # Run the Instagram scraper
        run = client.actor("apify/instagram-scraper").call(run_input=run_input)
        
        results = []
        for item in client.dataset(run["defaultDatasetId"]).iterate_items():
            # Process each post and its comments
            if 'comments' in item:
                for comment in item['comments']:
                    # Extract comment data
                    comment_data = {
                        'brand_id': WING_SHACK_BRAND_ID,
                        'platform': 'instagram',
                        'post_id': item.get('id', ''),
                        'comment_id': comment.get('id', ''),
                        'comment_text': comment.get('text', ''),
                        'author_username': comment.get('owner', {}).get('username', ''),
                        'author_display_name': comment.get('owner', {}).get('fullName', ''),
                        'author_followers_count': comment.get('owner', {}).get('followersCount', 0),
                        'author_verified': comment.get('owner', {}).get('isVerified', False),
                        'comment_timestamp': comment.get('timestamp', ''),
                        'like_count': comment.get('likesCount', 0),
                        'reply_count': comment.get('repliesCount', 0),
                        'is_reply': comment.get('parentCommentId') is not None,
                        'parent_comment_id': comment.get('parentCommentId', ''),
                        'post_url': item.get('url', ''),
                        'post_caption': item.get('caption', ''),
                        'post_like_count': item.get('likesCount', 0),
                        'post_comment_count': item.get('commentsCount', 0),
                        'post_view_count': item.get('videoViewCount', 0),
                        'post_timestamp': item.get('timestamp', ''),
                        'hashtags': extract_hashtags(item.get('caption', '')),
                        'mentions': extract_mentions(comment.get('text', '')),
                        'raw_content': json.dumps({
                            'post_data': item,
                            'comment_data': comment,
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'raw_metadata': json.dumps({
                            'source': 'apify_instagram_scraper',
                            'scraper_version': '1.0',
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'received_at': datetime.now().isoformat(),
                        'intake_method': 'apify_instagram_scraper',
                        'intake_metadata': json.dumps({
                            'apify_run_id': run['id'],
                            'scraper_actor': 'apify/instagram-scraper',
                            'scraped_at': datetime.now().isoformat()
                        })
                    }
                    
                    results.append(comment_data)
        
        print(f"✅ Scraped {len(results)} Instagram comments")
        return results
        
    except Exception as e:
        print(f"❌ Error scraping Instagram: {e}")
        return []

def extract_hashtags(text):
    """Extract hashtags from text"""
    import re
    hashtags = re.findall(r'#\w+', text)
    return [tag.replace('#', '') for tag in hashtags]

def extract_mentions(text):
    """Extract mentions from text"""
    import re
    mentions = re.findall(r'@\w+', text)
    return [mention.replace('@', '') for mention in mentions]

def generate_csv(results, platform):
    """Generate CSV file for upload"""
    
    if not results:
        print(f"❌ No {platform} data to process")
        return None
    
    print(f"\n📝 Generating {platform} CSV...")
    
    def escape_csv(value):
        if value is None:
            return ''
        str_value = str(value)
        if ',' in str_value or '"' in str_value or '\n' in str_value:
            return '"' + str_value.replace('"', '""') + '"'
        return str_value
    
    csv_header = "brand_id,platform,post_id,comment_id,comment_text,author_username,author_display_name,author_followers_count,author_verified,comment_timestamp,like_count,reply_count,is_reply,parent_comment_id,post_url,post_caption,post_like_count,post_comment_count,post_view_count,post_timestamp,hashtags,mentions,sentiment_score,sentiment_label,language_code,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
        row = [
            escape_csv(record["brand_id"]),
            escape_csv(record["platform"]),
            escape_csv(record["post_id"]),
            escape_csv(record["comment_id"]),
            escape_csv(record["comment_text"]),
            escape_csv(record["author_username"]),
            escape_csv(record["author_display_name"]),
            escape_csv(record["author_followers_count"]),
            escape_csv(record["author_verified"]),
            escape_csv(record["comment_timestamp"]),
            escape_csv(record["like_count"]),
            escape_csv(record["reply_count"]),
            escape_csv(record["is_reply"]),
            escape_csv(record["parent_comment_id"]),
            escape_csv(record["post_url"]),
            escape_csv(record["post_caption"]),
            escape_csv(record["post_like_count"]),
            escape_csv(record["post_comment_count"]),
            escape_csv(record["post_view_count"]),
            escape_csv(record["post_timestamp"]),
            escape_csv(record["hashtags"]),
            escape_csv(record["mentions"]),
            escape_csv(record.get("sentiment_score", "")),
            escape_csv(record.get("sentiment_label", "")),
            escape_csv(record.get("language_code", "")),
            escape_csv(record["raw_content"]),
            escape_csv(record["raw_metadata"]),
            escape_csv(record["received_at"]),
            escape_csv(record["intake_method"]),
            escape_csv(record["intake_metadata"])
        ]
        csv_rows.append(','.join(row))
    
    csv_content = csv_header + '\n'.join(csv_rows)
    
    filename = f'data/{platform}_comments_clean.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ {platform.title()} CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

def main():
    print("🎯 Big Appetite OS - Apify Social Media Scraper")
    print("===============================================\n")
    
    # Check for API token
    if not os.getenv('APIFY_API_TOKEN'):
        print("❌ APIFY_API_TOKEN environment variable not set")
        print("   Get your token from: https://console.apify.com/account/integrations")
        return
    
    all_results = []
    
    # Scrape TikTok
    tiktok_results = scrape_tiktok_comments()
    if tiktok_results:
        generate_csv(tiktok_results, 'tiktok')
        all_results.extend(tiktok_results)
    
    # Scrape Instagram
    instagram_results = scrape_instagram_comments()
    if instagram_results:
        generate_csv(instagram_results, 'instagram')
        all_results.extend(instagram_results)
    
    if all_results:
        print(f"\n🎉 Scraping complete!")
        print(f"   - Total comments: {len(all_results)}")
        print(f"   - TikTok: {len(tiktok_results)}")
        print(f"   - Instagram: {len(instagram_results)}")
        print("\n📋 Next steps:")
        print("1. Create the social_comments table in Supabase")
        print("2. Upload the CSV files to signals.social_comments")
        print("3. Verify the data in the database")
    else:
        print("\n❌ No comments scraped.")

if __name__ == "__main__":
    main()
