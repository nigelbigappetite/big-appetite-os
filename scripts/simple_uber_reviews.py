#!/usr/bin/env python3
import csv
import json
from datetime import datetime

print("🚀 Processing Uber Reviews...")

# Brand ID
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

# Input file
input_file = 'data/uber customer ac36db98-3b41-4c8d-8611-1634bed4e8e5_restaurant_rating_local_2025-05-01_2025-10-10.csv'

results = []
total = 0
processed = 0

try:
    with open(input_file, 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            total += 1
            
            # Get rating
            try:
                rating = int(row['Rating value'])
                if rating < 1 or rating > 5:
                    continue
            except:
                continue
            
            # Get review text
            review_text = row.get('Comment', '').strip()
            if not review_text:
                review_text = f"Uber Eats review - Rating: {rating}"
            
            # Get date
            rating_date = None
            if row.get('Rating date'):
                try:
                    rating_date = datetime.strptime(row['Rating date'], '%Y-%m-%d').date()
                except:
                    pass
            
            # Create raw content
            raw_content = {
                "restaurant": row.get('Restaurant', ''),
                "order_id": row.get('Order ID', ''),
                "order_uuid": row.get('Order UUID', ''),
                "date_ordered": row.get('Date ordered', ''),
                "rating_date": row.get('Rating date', ''),
                "rating_type": row.get('Rating type', ''),
                "rating_tags": row.get('Rating tags', ''),
                "fulfilment_type": row.get('Fulfilment Type', ''),
                "order_channel": row.get('Order Channel', ''),
                "city": row.get('City', ''),
                "source_file": input_file
            }
            
            # Create record
            record = {
                "brand_id": WING_SHACK_BRAND_ID,
                "review_text": review_text,
                "rating": rating,
                "review_source": "uber_eats",
                "reviewer_name": f"Uber Customer {row.get('Order ID', 'Unknown')}",
                "review_timestamp": rating_date.isoformat() if rating_date else None,
                "raw_content": json.dumps(raw_content),
                "raw_metadata": json.dumps({"source": "uber_eats", "platform": "uber_eats"}),
                "received_at": datetime.now().isoformat(),
                "intake_method": "uber_reviews_intake",
                "intake_metadata": json.dumps({"intake_source": "uber_eats_export"})
            }
            
            results.append(record)
            processed += 1

except Exception as e:
    print(f"Error: {e}")
    exit(1)

print(f"Processed {processed} out of {total} reviews")

# Generate CSV
if results:
    csv_header = "brand_id,review_text,rating,review_source,reviewer_name,review_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
        row = [
            record["brand_id"],
            f'"{record["review_text"].replace('"', '""')}"',
            str(record["rating"]),
            record["review_source"],
            f'"{record["reviewer_name"]}"',
            record["review_timestamp"] or "",
            f'"{record["raw_content"].replace('"', '""')}"',
            f'"{record["raw_metadata"].replace('"', '""')}"',
            record["received_at"],
            record["intake_method"],
            f'"{record["intake_metadata"].replace('"', '""')}"'
        ]
        csv_rows.append(','.join(row))
    
    csv_content = csv_header + '\n'.join(csv_rows)
    
    with open('data/uber_reviews_clean.csv', 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ Generated: data/uber_reviews_clean.csv")
    print(f"   Records: {len(results)}")
    
    # Show rating distribution
    ratings = [r['rating'] for r in results]
    avg_rating = sum(ratings) / len(ratings)
    print(f"   Average rating: {avg_rating:.2f}")
    
    for i in range(1, 6):
        count = ratings.count(i)
        print(f"   {i} star: {count} reviews")
else:
    print("No reviews processed")
