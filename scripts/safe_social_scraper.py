#!/usr/bin/env python3
"""
Safe Social Media Scraper for Wing Shack
========================================
Conservative scraping to avoid rate limits while getting substantial data.

Targets:
- Instagram: @wingshackco
- TikTok: @wingshackco

Safe limits:
- 20-30 recent posts per platform
- 10-20 comments per post
- Total: ~400-600 comments
"""

import os
import json
import time
from datetime import datetime
from apify_client import ApifyClient

print("🛡️ Safe Social Media Scraper for Wing Shack")
print("===========================================\n")

# Initialize Apify client
client = ApifyClient(os.getenv('APIFY_API_TOKEN'))

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

# Wing Shack social media handles (confirmed)
WING_SHACK_HANDLES = {
    'tiktok': '@wingshackco',
    'instagram': '@wingshackco'
}

def safe_scrape_tiktok():
    """Safely scrape TikTok comments with conservative limits"""
    
    print("📱 Safely scraping TikTok comments...")
    print("   Target: @wingshackco")
    print("   Limit: 20 recent videos, 15 comments each")
    
    # Conservative TikTok scraper settings
    run_input = {
        "usernames": [WING_SHACK_HANDLES['tiktok']],
        "resultsPerPage": 20,  # Only 20 recent videos
        "shouldDownloadVideos": False,  # No video downloads to save bandwidth
        "shouldDownloadCovers": False,  # No thumbnails to save bandwidth
        "shouldDownloadSlideshowImages": False,
        "maxItems": 20,  # Conservative limit
        "maxCommentsPerVideo": 15  # Limit comments per video
    }
    
    try:
        print("   Starting TikTok scrape...")
        run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
        
        results = []
        comment_count = 0
        
        for item in client.dataset(run["defaultDatasetId"]).iterate_items():
            if 'comments' in item and comment_count < 300:  # Hard limit
                for comment in item['comments'][:15]:  # Max 15 comments per video
                    if comment_count >= 300:  # Safety break
                        break
                        
                    comment_data = {
                        'brand_id': WING_SHACK_BRAND_ID,
                        'video_id': item.get('id', ''),
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
                        'video_url': item.get('webVideoUrl', ''),
                        'video_caption': item.get('desc', ''),
                        'video_like_count': item.get('stats', {}).get('diggCount', 0),
                        'video_comment_count': item.get('stats', {}).get('commentCount', 0),
                        'video_view_count': item.get('stats', {}).get('playCount', 0),
                        'video_timestamp': item.get('createTime', ''),
                        'hashtags': extract_hashtags(item.get('desc', '')),
                        'mentions': extract_mentions(comment.get('text', '')),
                        'language_code': 'en',
                        'raw_content': json.dumps({
                            'video_data': {
                                'id': item.get('id'),
                                'desc': item.get('desc'),
                                'stats': item.get('stats'),
                                'createTime': item.get('createTime')
                            },
                            'comment_data': comment,
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'raw_metadata': json.dumps({
                            'source': 'apify_tiktok_scraper_safe',
                            'scraper_version': '1.0',
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'received_at': datetime.now().isoformat(),
                        'intake_method': 'apify_tiktok_scraper_safe',
                        'intake_metadata': json.dumps({
                            'apify_run_id': run['id'],
                            'scraper_actor': 'apify/tiktok-scraper',
                            'scraped_at': datetime.now().isoformat()
                        })
                    }
                    
                    results.append(comment_data)
                    comment_count += 1
                    
                    # Rate limiting - small delay
                    if comment_count % 50 == 0:
                        print(f"   Processed {comment_count} comments...")
                        time.sleep(1)  # 1 second delay every 50 comments
        
        print(f"✅ TikTok scraping complete: {len(results)} comments")
        return results
        
    except Exception as e:
        print(f"❌ Error scraping TikTok: {e}")
        return []

def safe_scrape_instagram():
    """Safely scrape Instagram comments with conservative limits"""
    
    print("📸 Safely scraping Instagram comments...")
    print("   Target: @wingshackco")
    print("   Limit: 25 recent posts, 12 comments each")
    
    # Conservative Instagram scraper settings
    run_input = {
        "directUrls": [f"https://www.instagram.com/{WING_SHACK_HANDLES['instagram'].replace('@', '')}/"],
        "resultsType": "posts",
        "resultsLimit": 25,  # Only 25 recent posts
        "addParentData": True,
        "downloadImages": False,  # No image downloads to save bandwidth
        "downloadVideos": False   # No video downloads to save bandwidth
    }
    
    try:
        print("   Starting Instagram scrape...")
        run = client.actor("apify/instagram-scraper").call(run_input=run_input)
        
        results = []
        comment_count = 0
        
        for item in client.dataset(run["defaultDatasetId"]).iterate_items():
            if 'comments' in item and comment_count < 300:  # Hard limit
                for comment in item['comments'][:12]:  # Max 12 comments per post
                    if comment_count >= 300:  # Safety break
                        break
                        
                    comment_data = {
                        'brand_id': WING_SHACK_BRAND_ID,
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
                        'language_code': 'en',
                        'raw_content': json.dumps({
                            'post_data': {
                                'id': item.get('id'),
                                'caption': item.get('caption'),
                                'likesCount': item.get('likesCount'),
                                'commentsCount': item.get('commentsCount'),
                                'timestamp': item.get('timestamp')
                            },
                            'comment_data': comment,
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'raw_metadata': json.dumps({
                            'source': 'apify_instagram_scraper_safe',
                            'scraper_version': '1.0',
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'received_at': datetime.now().isoformat(),
                        'intake_method': 'apify_instagram_scraper_safe',
                        'intake_metadata': json.dumps({
                            'apify_run_id': run['id'],
                            'scraper_actor': 'apify/instagram-scraper',
                            'scraped_at': datetime.now().isoformat()
                        })
                    }
                    
                    results.append(comment_data)
                    comment_count += 1
                    
                    # Rate limiting - small delay
                    if comment_count % 50 == 0:
                        print(f"   Processed {comment_count} comments...")
                        time.sleep(1)  # 1 second delay every 50 comments
        
        print(f"✅ Instagram scraping complete: {len(results)} comments")
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
    
    # Platform-specific headers
    if platform == 'tiktok':
        csv_header = "brand_id,video_id,comment_id,comment_text,author_username,author_display_name,author_followers_count,author_verified,comment_timestamp,like_count,reply_count,is_reply,parent_comment_id,video_url,video_caption,video_like_count,video_comment_count,video_view_count,video_timestamp,hashtags,mentions,language_code,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    else:  # instagram
        csv_header = "brand_id,post_id,comment_id,comment_text,author_username,author_display_name,author_followers_count,author_verified,comment_timestamp,like_count,reply_count,is_reply,parent_comment_id,post_url,post_caption,post_like_count,post_comment_count,post_view_count,post_timestamp,hashtags,mentions,language_code,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
        if platform == 'tiktok':
            row = [
                escape_csv(record["brand_id"]),
                escape_csv(record["video_id"]),
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
                escape_csv(record["video_url"]),
                escape_csv(record["video_caption"]),
                escape_csv(record["video_like_count"]),
                escape_csv(record["video_comment_count"]),
                escape_csv(record["video_view_count"]),
                escape_csv(record["video_timestamp"]),
                escape_csv(record["hashtags"]),
                escape_csv(record["mentions"]),
                escape_csv(record["language_code"]),
                escape_csv(record["raw_content"]),
                escape_csv(record["raw_metadata"]),
                escape_csv(record["received_at"]),
                escape_csv(record["intake_method"]),
                escape_csv(record["intake_metadata"])
            ]
        else:  # instagram
            row = [
                escape_csv(record["brand_id"]),
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
                escape_csv(record["language_code"]),
                escape_csv(record["raw_content"]),
                escape_csv(record["raw_metadata"]),
                escape_csv(record["received_at"]),
                escape_csv(record["intake_method"]),
                escape_csv(record["intake_metadata"])
            ]
        csv_rows.append(','.join(row))
    
    csv_content = csv_header + '\n'.join(csv_rows)
    
    filename = f'data/{platform}_comments_safe.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ {platform.title()} CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

def main():
    print("🎯 Big Appetite OS - Safe Social Media Scraper")
    print("==============================================\n")
    
    # Check for API token
    if not os.getenv('APIFY_API_TOKEN'):
        print("❌ APIFY_API_TOKEN environment variable not set")
        print("   Get your token from: https://console.apify.com/account/integrations")
        return
    
    all_results = []
    
    # Scrape TikTok safely
    tiktok_results = safe_scrape_tiktok()
    if tiktok_results:
        generate_csv(tiktok_results, 'tiktok')
        all_results.extend(tiktok_results)
    
    # Small delay between platforms
    print("\n⏳ Waiting 30 seconds between platforms...")
    time.sleep(30)
    
    # Scrape Instagram safely
    instagram_results = safe_scrape_instagram()
    if instagram_results:
        generate_csv(instagram_results, 'instagram')
        all_results.extend(instagram_results)
    
    if all_results:
        print(f"\n🎉 Safe scraping complete!")
        print(f"   - Total comments: {len(all_results)}")
        print(f"   - TikTok: {len(tiktok_results)}")
        print(f"   - Instagram: {len(instagram_results)}")
        print("\n📋 Next steps:")
        print("1. Create the social tables in Supabase")
        print("2. Upload the CSV files to respective tables")
        print("3. Verify the data in the database")
    else:
        print("\n❌ No comments scraped.")

if __name__ == "__main__":
    main()
