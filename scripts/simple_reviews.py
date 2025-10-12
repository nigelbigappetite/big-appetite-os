#!/usr/bin/env python3
import json
from datetime import datetime, timedelta
import re

print("🚀 Processing Google Reviews...")

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

def parse_time_ago(time_str):
    """Convert 'X days ago', 'X weeks ago', etc. to actual date"""
    now = datetime.now()
    
    if 'day' in time_str:
        days = int(re.search(r'(\d+)', time_str).group(1))
        return (now - timedelta(days=days)).isoformat()
    elif 'week' in time_str:
        weeks = int(re.search(r'(\d+)', time_str).group(1))
        return (now - timedelta(weeks=weeks)).isoformat()
    elif 'month' in time_str:
        months = int(re.search(r'(\d+)', time_str).group(1))
        return (now - timedelta(days=months*30)).isoformat()
    elif 'year' in time_str:
        years = int(re.search(r'(\d+)', time_str).group(1))
        return (now - timedelta(days=years*365)).isoformat()
    else:
        return now.isoformat()

# Sample reviews data
reviews = [
    {
        "reviewer_name": "Mummy Meech",
        "review_text": "Used to be one of my faves! It's been years since I last visited 😢 but what happened to the food ? It's not the same items and it's no way near as nice anymore, so dissatisfied and disappointed",
        "time_ago": "2 days ago",
        "rating": 2
    },
    {
        "reviewer_name": "Lewis Brooman",
        "review_text": "Lovely food, Great chicken and greta selection of dips.",
        "time_ago": "a month ago",
        "rating": 5
    },
    {
        "reviewer_name": "Ahmed Al-hashimi",
        "review_text": "Great service and delicious food",
        "time_ago": "3 months ago",
        "rating": 5
    }
]

results = []

for review in reviews:
    print(f"Processing: {review['reviewer_name']}")
    
    # Parse timestamp
    review_timestamp = parse_time_ago(review['time_ago'])
    
    # Create record
    record = {
        "brand_id": WING_SHACK_BRAND_ID,
        "review_text": review['review_text'],
        "rating": review['rating'],
        "review_source": "google",
        "reviewer_name": review['reviewer_name'],
        "review_timestamp": review_timestamp,
        "raw_content": json.dumps({
            "reviewer_name": review['reviewer_name'],
            "review_text": review['review_text'],
            "time_ago": review['time_ago'],
            "rating": review['rating'],
            "source": "google"
        }),
        "raw_metadata": json.dumps({
            "review_platform": "google_business",
            "review_timestamp_original": review['time_ago'],
            "review_length": len(review['review_text'])
        }),
        "received_at": datetime.now().isoformat(),
        "intake_method": "review_intake",
        "intake_metadata": json.dumps({
            "intake_source": "manual_google_reviews",
            "intake_timestamp": datetime.now().isoformat()
        })
    }
    
    results.append(record)

print(f"\nProcessed {len(results)} reviews")

# Generate CSV
csv_content = "brand_id,review_text,rating,review_source,reviewer_name,review_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"

for record in results:
    row = [
        record["brand_id"],
        f'"{record["review_text"]}"',
        str(record["rating"]),
        record["review_source"],
        f'"{record["reviewer_name"]}"',
        record["review_timestamp"],
        f'"{record["raw_content"]}"',
        f'"{record["raw_metadata"]}"',
        record["received_at"],
        record["intake_method"],
        f'"{record["intake_metadata"]}"'
    ]
    csv_content += ",".join(row) + "\n"

# Save to file
with open('data/google_reviews_clean.csv', 'w', encoding='utf-8') as f:
    f.write(csv_content)

print("✅ CSV created: data/google_reviews_clean.csv")
print(f"File size: {len(csv_content)} bytes")
