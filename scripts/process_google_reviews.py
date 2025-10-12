#!/usr/bin/env python3
import csv
import json
from datetime import datetime, timedelta
import re

print("🚀 Processing Wing Shack Google Reviews...")

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

def extract_rating_from_text(review_text):
    """Extract star rating from review text or infer from sentiment"""
    # Look for explicit star mentions
    star_match = re.search(r'(\d+)\s*stars?', review_text.lower())
    if star_match:
        return int(star_match.group(1))
    
    # Look for rating patterns like "10/10", "5/5"
    rating_match = re.search(r'(\d+)/(\d+)', review_text)
    if rating_match:
        rating = int(rating_match.group(1))
        max_rating = int(rating_match.group(2))
        if max_rating == 10:
            return max(1, min(5, rating // 2))  # Convert 10-point to 5-point
        elif max_rating == 5:
            return rating
    
    # Infer from sentiment keywords
    positive_words = ['amazing', 'excellent', 'great', 'love', 'perfect', 'fantastic', 'delicious', 'wonderful', 'outstanding']
    negative_words = ['terrible', 'awful', 'horrible', 'disgusting', 'disappointed', 'disappointing', 'bad', 'worst', 'avoid']
    
    text_lower = review_text.lower()
    positive_count = sum(1 for word in positive_words if word in text_lower)
    negative_count = sum(1 for word in negative_words if word in text_lower)
    
    if positive_count > negative_count and positive_count > 0:
        return 5
    elif negative_count > positive_count and negative_count > 0:
        return 1
    else:
        return 3  # Neutral if unclear

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

def create_review_record(reviewer_name, review_text, time_ago, rating=None, review_source="google"):
    """Create a review record for database"""
    
    # Extract rating if not provided
    if rating is None:
        rating = extract_rating_from_text(review_text)
    
    # Parse timestamp
    review_timestamp = parse_time_ago(time_ago)
    
    # Create raw content
    raw_content = {
        "reviewer_name": reviewer_name,
        "review_text": review_text,
        "time_ago": time_ago,
        "rating": rating,
        "source": review_source,
        "platform": "google_business"
    }
    
    # Create raw metadata
    raw_metadata = {
        "review_platform": "google_business",
        "review_timestamp_original": time_ago,
        "has_owner_response": False,  # We'll detect this separately
        "review_length": len(review_text)
    }
    
    # Create intake metadata
    intake_metadata = {
        "intake_source": "manual_google_reviews",
        "intake_timestamp": datetime.now().isoformat(),
        "review_batch": "wing_shack_google_reviews_2024"
    }
    
    return {
        "brand_id": WING_SHACK_BRAND_ID,
        "review_text": review_text,
        "rating": rating,
        "review_source": review_source,
        "reviewer_name": reviewer_name,
        "review_timestamp": review_timestamp,
        "raw_content": json.dumps(raw_content),
        "raw_metadata": json.dumps(raw_metadata),
        "received_at": datetime.now().isoformat(),
        "intake_method": "review_intake",
        "intake_metadata": json.dumps(intake_metadata)
    }

def process_google_reviews():
    """Process the Google Reviews data you provided"""
    
    # Your review data - I'll parse this from the text you provided
    reviews_data = [
        {
            "reviewer_name": "Mummy Meech",
            "review_text": "Used to be one of my faves! It's been years since I last visited 😢 but what happened to the food ? It's not the same items and it's no way near as nice anymore, so dissatisfied and disappointed",
            "time_ago": "2 days ago",
            "rating": 2
        },
        {
            "reviewer_name": "Malachi Trutwein", 
            "review_text": "I used to love wing shack and went there for the first time in ages. Was looking forward to my go to tenders order however I was massively disappointed in the quality of the food.",
            "time_ago": "a week ago",
            "rating": 2
        },
        {
            "reviewer_name": "Tayaba S",
            "review_text": "Came here after ages and was really looking forward to it. Found out the main shop has now closed and they operate from T's a few doors down. Really poor quality and tastes different. Wings have changed & was hardly any meat on there.",
            "time_ago": "a week ago", 
            "rating": 2
        },
        {
            "reviewer_name": "Olivia Drew",
            "review_text": "Haven't ordered from Wingstop in a long time but always used to love it so was really looking forward to it. Was extremely disappointed- Ordered the Cali loaded fries which were a congealed, bland mess. The honey & sesame wings sauce tastes different.",
            "time_ago": "4 weeks ago",
            "rating": 2
        },
        {
            "reviewer_name": "Mieara",
            "review_text": "Really disappointed. Google said this restaurant was open, so we drove 30 minutes to get there. When we arrived, it was closed. Please fix your hours online!! no one wants to waste their time and fuel just to find out the place isn't even open.",
            "time_ago": "a month ago",
            "rating": 1
        },
        {
            "reviewer_name": "Miran Saleh",
            "review_text": "I use to dream of the wings at wingshack with last night and the quality has changed significantly. Really saddened I can no longer enjoy the amazing wings they would do a year or so ago, the quality of the wings has completely gone downhill.",
            "time_ago": "a month ago",
            "rating": 2
        },
        {
            "reviewer_name": "Danyal Abbas",
            "review_text": "They served me undercooked chicken after I had to wait more than an hour to get my food",
            "time_ago": "a month ago",
            "rating": 1
        },
        {
            "reviewer_name": "Kylia Prince",
            "review_text": "Used to be amazing. Not anymore",
            "time_ago": "a month ago",
            "rating": 2
        },
        {
            "reviewer_name": "Siddesh R Ohri",
            "review_text": "I recently ordered the Jarvs boneless tangy buffalo and I was very disappointed by the order. The food shown in the actual image looks nothing like the one I received.",
            "time_ago": "a month ago",
            "rating": 2
        },
        {
            "reviewer_name": "Lewis Brooman",
            "review_text": "Lovely food, Great chicken and greta selection of dips.",
            "time_ago": "a month ago",
            "rating": 5
        },
        {
            "reviewer_name": "Ehsan Piracha",
            "review_text": "I wish i could say otherwise but since closing the old shop its not the same. Seems to operate out the back of Tz now. Pricing was never an issue before because the quality was there, but 2025 isnt the year for this place. Based on the recent reviews, people seem to agree.",
            "time_ago": "a month ago",
            "rating": 2
        },
        {
            "reviewer_name": "aiden larking",
            "review_text": "Completely disappointed when ordering from here, I ordered 12 of the boneless just to be sent 6 chicken nuggets cut in half with zero sauce and I also ordered a wrap which was so bad and soggy I had to chuck it in the bin. The food here is terrible.",
            "time_ago": "a month ago",
            "rating": 1
        },
        {
            "reviewer_name": "Pee Jay",
            "review_text": "Great food and service",
            "time_ago": "2 months ago",
            "rating": 5
        },
        {
            "reviewer_name": "Jack Hague",
            "review_text": "Ordered for delivery and I wish I could give it no stars I was 10 minutes round the corner came stone cold and the wings looked 2 weeks old, avoid avoid avoid.",
            "time_ago": "3 months ago",
            "rating": 1
        },
        {
            "reviewer_name": "sam stokes",
            "review_text": "Used to be so good, but it seems some things have changed in the move to the new location- the bun is not as good, it's a very dry, unexciting and feels like a cost cut to before, and the chips are so much worse too.",
            "time_ago": "3 months ago",
            "rating": 2
        },
        {
            "reviewer_name": "Ahmed Al-hashimi",
            "review_text": "Great service and delicious food",
            "time_ago": "3 months ago",
            "rating": 5
        },
        {
            "reviewer_name": "Niamh Kilgannon",
            "review_text": "Buffalo burger was nice, however the blue cheese sauce tastes and smells horrible, and made the burger worse overall. The wings were very small, the buffalo sauce was nice, but again the blue cheese sauce ruined them, so strong and not tasty. The Cajun chips are really good, and the food came quickly but could have been hotter.",
            "time_ago": "4 months ago",
            "rating": 3
        },
        {
            "reviewer_name": "Krzysztof Czajka",
            "review_text": "I ordered a takeaway during bank holiday Monday. The website allowed it. Google maps said they're open. I showed up at the door... And Wing Shack was closed. I texted them and drove away only to get a message later that they do collections from a different location.",
            "time_ago": "4 months ago",
            "rating": 1
        },
        {
            "reviewer_name": "Sanj",
            "review_text": "Incorrect opening hours on Google",
            "time_ago": "4 months ago",
            "rating": 2
        },
        {
            "reviewer_name": "J W",
            "review_text": "Drove 1 hour to find out shop has shut down, cheers guys!",
            "time_ago": "4 months ago",
            "rating": 1
        }
    ]
    
    results = []
    
    for review_data in reviews_data:
        print(f"Processing review from {review_data['reviewer_name']}...")
        
        record = create_review_record(
            reviewer_name=review_data['reviewer_name'],
            review_text=review_data['review_text'],
            time_ago=review_data['time_ago'],
            rating=review_data['rating'],
            review_source="google"
        )
        
        results.append(record)
    
    print(f"\n📊 Processing complete:")
    print(f"   - Total reviews processed: {len(results)}")
    print(f"   - Average rating: {sum(r['rating'] for r in results) / len(results):.1f}")
    print(f"   - 5-star reviews: {sum(1 for r in results if r['rating'] == 5)}")
    print(f"   - 1-star reviews: {sum(1 for r in results if r['rating'] == 1)}")
    
    return results

def generate_clean_csv(results):
    """Generate clean CSV for upload"""
    
    if not results:
        print("❌ No data to process")
        return None
    
    print("\n📝 Generating clean CSV...")
    
    def escape_csv(value):
        if value is None:
            return ''
        str_value = str(value)
        if ',' in str_value or '"' in str_value or '\n' in str_value:
            return '"' + str_value.replace('"', '""') + '"'
        return str_value
    
    csv_header = "brand_id,review_text,rating,review_source,reviewer_name,review_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
        row = [
            escape_csv(record["brand_id"]),
            escape_csv(record["review_text"]),
            escape_csv(record["rating"]),
            escape_csv(record["review_source"]),
            escape_csv(record["reviewer_name"]),
            escape_csv(record["review_timestamp"]),
            escape_csv(record["raw_content"]),
            escape_csv(record["raw_metadata"]),
            escape_csv(record["received_at"]),
            escape_csv(record["intake_method"]),
            escape_csv(record["intake_metadata"])
        ]
        csv_rows.append(','.join(row))
    
    csv_content = csv_header + '\n'.join(csv_rows)
    
    filename = 'data/google_reviews_clean.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ Clean CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

def main():
    print("🎯 Big Appetite OS - Google Reviews Processing")
    print("==============================================\n")
    
    # Process review data
    results = process_google_reviews()
    
    if results:
        # Generate clean CSV
        csv_file = generate_clean_csv(results)
        
        if csv_file:
            print("\n🎉 Processing complete!")
            print(f"📁 Ready to upload: {csv_file}")
            print("\n📋 Next steps:")
            print("1. Upload the CSV to Supabase signals.reviews table")
            print("2. Verify data in the database")
            print("3. Check review sentiment analysis")
    else:
        print("\n❌ No data processed.")

if __name__ == "__main__":
    main()
