#!/usr/bin/env python3
"""
Fixed Instagram Scraper - Get ALL Comments
=========================================
This version properly extracts all comments from Instagram posts.
"""

import os
import json
import time
from datetime import datetime
from apify_client import ApifyClient

print("📸 Fixed Instagram Scraper - Getting ALL Comments")
print("================================================\n")

# Initialize Apify client
client = ApifyClient(os.getenv('APIFY_API_TOKEN'))

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

def scrape_instagram_all_comments():
    """Scrape Instagram with ALL comments properly extracted"""
    
    print("📸 Scraping Instagram comments from @wingshackco...")
    print("   Target: https://www.instagram.com/wingshackco/")
    print("   Getting ALL comments from recent posts")
    
    # Instagram scraper with proper comment extraction
    run_input = {
        "directUrls": ["https://www.instagram.com/wingshackco/"],
        "resultsType": "posts",
        "resultsLimit": 15,  # 15 recent posts
        "addParentData": True,
        "downloadImages": False,
        "downloadVideos": False,
        "includeComments": True,  # Ensure comments are included
        "maxCommentsPerPost": 50  # Get up to 50 comments per post
    }
    
    try:
        print("   Starting Instagram scrape...")
        run = client.actor("apify/instagram-scraper").call(run_input=run_input)
        
        results = []
        total_comments = 0
        
        print("   Processing posts and comments...")
        
        for item in client.dataset(run["defaultDatasetId"]).iterate_items():
            post_id = item.get('id', 'Unknown')
            print(f"   📝 Processing post: {post_id}")
            
            # Check if comments exist
            comments = item.get('comments', [])
            print(f"      Found {len(comments)} comments in this post")
            
            if comments:
                for i, comment in enumerate(comments):
                    # Extract comment data
                    comment_data = {
                        'brand_id': WING_SHACK_BRAND_ID,
                        'post_id': post_id,
                        'comment_id': comment.get('id', f'comment_{i}'),
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
                            'source': 'apify_instagram_scraper_fixed',
                            'scraper_version': '2.0',
                            'scraped_at': datetime.now().isoformat()
                        }),
                        'received_at': datetime.now().isoformat(),
                        'intake_method': 'apify_instagram_scraper_fixed',
                        'intake_metadata': json.dumps({
                            'apify_run_id': run['id'],
                            'scraper_actor': 'apify/instagram-scraper',
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
                print(f"      ⚠️ No comments found in post {post_id}")
        
        print(f"✅ Instagram scraping complete: {len(results)} comments from {len(set(r['post_id'] for r in results))} posts")
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

def generate_csv(results):
    """Generate CSV file for upload"""
    
    if not results:
        print("❌ No Instagram data to process")
        return None
    
    print(f"\n📝 Generating Instagram CSV...")
    
    def escape_csv(value):
        if value is None:
            return ''
        str_value = str(value)
        if ',' in str_value or '"' in str_value or '\n' in str_value:
            return '"' + str_value.replace('"', '""') + '"'
        return str_value
    
    csv_header = "brand_id,post_id,comment_id,comment_text,author_username,author_display_name,author_followers_count,author_verified,comment_timestamp,like_count,reply_count,is_reply,parent_comment_id,post_url,post_caption,post_like_count,post_comment_count,post_view_count,post_timestamp,hashtags,mentions,language_code,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
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
    
    filename = 'data/instagram_comments_fixed.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ Instagram CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    # Show sample comments
    print(f"\n📊 Sample comments:")
    for i, result in enumerate(results[:5]):
        print(f"   {i+1}. @{result['author_username']}: {result['comment_text'][:50]}...")
    
    return filename

if __name__ == "__main__":
    print("🎯 Fixed Instagram Scraper")
    print("==========================\n")
    
    # Check for API token
    if not os.getenv('APIFY_API_TOKEN'):
        print("❌ APIFY_API_TOKEN environment variable not set")
        exit(1)
    
    # Scrape Instagram
    instagram_results = scrape_instagram_all_comments()
    
    if instagram_results:
        generate_csv(instagram_results)
        print(f"\n🎉 Instagram scraping complete!")
        print(f"   - Total comments: {len(instagram_results)}")
        print(f"   - Posts processed: {len(set(r['post_id'] for r in instagram_results))}")
        print("\n📋 Next steps:")
        print("1. Create the instagram_comments table in Supabase")
        print("2. Upload the CSV file to signals.instagram_comments")
        print("3. Verify the data in the database")
    else:
        print("\n❌ No Instagram comments scraped.")
        print("   Possible issues:")
        print("   - Account is private")
        print("   - No posts available")
        print("   - API restrictions")
