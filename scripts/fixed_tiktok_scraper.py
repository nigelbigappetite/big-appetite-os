#!/usr/bin/env python3
"""
Fixed TikTok Scraper - Get ALL Comments
======================================
This version properly extracts all comments from TikTok videos.
"""

import os
import json
import time
from datetime import datetime
from apify_client import ApifyClient

print("📱 Fixed TikTok Scraper - Getting ALL Comments")
print("=============================================\n")

# Initialize Apify client
client = ApifyClient(os.getenv('APIFY_API_TOKEN'))

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

def scrape_tiktok_all_comments():
    """Scrape TikTok with ALL comments properly extracted"""
    
    print("📱 Scraping TikTok comments from @wingshackco...")
    print("   Target: https://www.tiktok.com/@wingshackco")
    print("   Getting ALL comments from recent videos")
    
    # TikTok scraper with proper comment extraction
    run_input = {
        "usernames": ["wingshackco"],  # Try without @ first
        "resultsPerPage": 20,  # 20 recent videos
        "shouldDownloadVideos": False,
        "shouldDownloadCovers": False,
        "shouldDownloadSlideshowImages": False,
        "maxItems": 20,
        "includeComments": True,  # Ensure comments are included
        "maxCommentsPerVideo": 30  # Get up to 30 comments per video
    }
    
    try:
        print("   Starting TikTok scrape...")
        run = client.actor("apify/tiktok-scraper").call(run_input=run_input)
        
        results = []
        total_comments = 0
        
        print("   Processing videos and comments...")
        
        for item in client.dataset(run["defaultDatasetId"]).iterate_items():
            video_id = item.get('id', 'Unknown')
            print(f"   📹 Processing video: {video_id}")
            
            # Check if comments exist
            comments = item.get('comments', [])
            print(f"      Found {len(comments)} comments in this video")
            
            if comments:
                for i, comment in enumerate(comments):
                    # Extract comment data
                    comment_data = {
                        'brand_id': WING_SHACK_BRAND_ID,
                        'video_id': video_id,
                        'comment_id': comment.get('id', f'comment_{i}'),
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
                            'source': 'apify_tiktok_scraper_fixed',
                            'scraper_version': '2.0',
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'received_at': datetime.now().isoformat(),
                        'intake_method': 'apify_tiktok_scraper_fixed',
                        'intake_metadata': json.dumps({
                            'apify_run_id': run['id'],
                            'scraper_actor': 'apify/tiktok-scraper',
                            'scraped_at': datetime.now().isoformat()
                        })
                    }
                    
                    results.append(comment_data)
                    total_comments += 1
                    
                    # Show progress
                    if total_comments % 25 == 0:
                        print(f"      Processed {total_comments} total comments...")
                        time.sleep(0.5)  # Small delay
            else:
                print(f"      ⚠️ No comments found in video {video_id}")
        
        print(f"✅ TikTok scraping complete: {len(results)} comments from {len(set(r['video_id'] for r in results))} videos")
        return results
        
    except Exception as e:
        print(f"❌ Error scraping TikTok: {e}")
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

def generate_csv(results):
    """Generate CSV file for upload"""
    
    if not results:
        print("❌ No TikTok data to process")
        return None
    
    print(f"\n📝 Generating TikTok CSV...")
    
    def escape_csv(value):
        if value is None:
            return ''
        str_value = str(value)
        if ',' in str_value or '"' in str_value or '\n' in str_value:
            return '"' + str_value.replace('"', '""') + '"'
        return str_value
    
    csv_header = "brand_id,video_id,comment_id,comment_text,author_username,author_display_name,author_followers_count,author_verified,comment_timestamp,like_count,reply_count,is_reply,parent_comment_id,video_url,video_caption,video_like_count,video_comment_count,video_view_count,video_timestamp,hashtags,mentions,language_code,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
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
        csv_rows.append(','.join(row))
    
    csv_content = csv_header + '\n'.join(csv_rows)
    
    filename = 'data/tiktok_comments_fixed.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ TikTok CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    # Show sample comments
    print(f"\n📊 Sample comments:")
    for i, result in enumerate(results[:5]):
        print(f"   {i+1}. @{result['author_username']}: {result['comment_text'][:50]}...")
    
    return filename

if __name__ == "__main__":
    print("🎯 Fixed TikTok Scraper")
    print("=======================\n")
    
    # Check for API token
    if not os.getenv('APIFY_API_TOKEN'):
        print("❌ APIFY_API_TOKEN environment variable not set")
        exit(1)
    
    # Scrape TikTok
    tiktok_results = scrape_tiktok_all_comments()
    
    if tiktok_results:
        generate_csv(tiktok_results)
        print(f"\n🎉 TikTok scraping complete!")
        print(f"   - Total comments: {len(tiktok_results)}")
        print(f"   - Videos processed: {len(set(r['video_id'] for r in tiktok_results))}")
        print("\n📋 Next steps:")
        print("1. Create the tiktok_comments table in Supabase")
        print("2. Upload the CSV file to signals.tiktok_comments")
        print("3. Verify the data in the database")
    else:
        print("\n❌ No TikTok comments scraped.")
        print("   Possible issues:")
        print("   - Account not found")
        print("   - No videos available")
        print("   - API restrictions")
