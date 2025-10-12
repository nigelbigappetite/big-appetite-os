#!/usr/bin/env python3
"""
Uber Reviews Processing Script
=============================
Processes Uber Eats customer reviews for Wing Shack into signals.reviews table.

Usage:
python3 scripts/process_uber_reviews.py
"""

import csv
import json
from datetime import datetime
import os
import re

print("🚀 Processing Uber Eats Reviews for Wing Shack...")

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

def clean_review_text(text):
    """Clean and normalize review text"""
    if not text or text.strip() == '':
        return ''
    
    # Remove extra whitespace and normalize
    text = re.sub(r'\s+', ' ', text.strip())
    
    # Remove any special characters that might cause issues
    text = text.replace('\n', ' ').replace('\r', ' ')
    
    return text

def extract_rating_tags(tags_str):
    """Extract and clean rating tags"""
    if not tags_str or tags_str.strip() == '':
        return []
    
    # Split by comma and clean each tag
    tags = [tag.strip() for tag in tags_str.split(',') if tag.strip()]
    return tags

def parse_uber_reviews():
    """Process Uber reviews CSV file"""
    
    input_file = 'data/uber customer ac36db98-3b41-4c8d-8611-1634bed4e8e5_restaurant_rating_local_2025-05-01_2025-10-10.csv'
    
    if not os.path.exists(input_file):
        print(f"❌ File not found: {input_file}")
        return []
    
    print(f"📁 Processing file: {input_file}")
    
    results = []
    total_reviews = 0
    processed_reviews = 0
    
    try:
        with open(input_file, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            
            for row in reader:
                total_reviews += 1
                
                # Skip rows without rating value
                if not row.get('Rating value') or row['Rating value'] == '':
                    continue
                
                # Parse rating
                try:
                    rating = int(row['Rating value'])
                    if rating < 1 or rating > 5:
                        continue
                except (ValueError, TypeError):
                    continue
                
                # Parse dates
                rating_date = None
                if row.get('Rating date'):
                    try:
                        rating_date = datetime.strptime(row['Rating date'], '%Y-%m-%d').date()
                    except:
                        pass
                
                # Clean review text
                review_text = clean_review_text(row.get('Comment', ''))
                
                # Extract rating tags
                rating_tags = extract_rating_tags(row.get('Rating tags', ''))
                
                # Create raw content
                raw_content = {
                    "restaurant": row.get('Restaurant', ''),
                    "external_restaurant_id": row.get('External restaurant ID', ''),
                    "country": row.get('Country', ''),
                    "country_code": row.get('Country code', ''),
                    "city": row.get('City', ''),
                    "order_id": row.get('Order ID', ''),
                    "order_uuid": row.get('Order UUID', ''),
                    "date_ordered": row.get('Date ordered', ''),
                    "time_customer_ordered": row.get('Time customer ordered', ''),
                    "rating_date": row.get('Rating date', ''),
                    "rating_time": row.get('Rating time', ''),
                    "rating_type": row.get('Rating type', ''),
                    "rating_value": row.get('Rating value', ''),
                    "rating_tags": row.get('Rating tags', ''),
                    "comment": row.get('Comment', ''),
                    "fulfilment_type": row.get('Fulfilment Type', ''),
                    "order_channel": row.get('Order Channel', ''),
                    "eats_brand": row.get('Eats Brand', ''),
                    "source_file": input_file
                }
                
                # Create raw metadata
                raw_metadata = {
                    "source": "uber_eats",
                    "platform": "uber_eats",
                    "rating_type": row.get('Rating type', ''),
                    "fulfilment_type": row.get('Fulfilment Type', ''),
                    "order_channel": row.get('Order Channel', ''),
                    "city": row.get('City', ''),
                    "rating_tags": rating_tags,
                    "processing_timestamp": datetime.now().isoformat()
                }
                
                # Create intake metadata
                intake_metadata = {
                    "intake_source": "uber_eats_export",
                    "intake_timestamp": datetime.now().isoformat(),
                    "platform": "uber_eats",
                    "data_batch": "uber_reviews_2024"
                }
                
                # Create record for database (without signal_id - let Supabase generate it)
                record = {
                    "brand_id": WING_SHACK_BRAND_ID,
                    "review_text": review_text if review_text else f"Uber Eats review - Rating: {rating}",
                    "rating": rating,
                    "review_source": "uber_eats",
                    "reviewer_name": f"Uber Customer {row.get('Order ID', 'Unknown')}",
                    "review_timestamp": rating_date.isoformat() if rating_date else None,
                    "raw_content": json.dumps(raw_content),
                    "raw_metadata": json.dumps(raw_metadata),
                    "received_at": datetime.now().isoformat(),
                    "intake_method": "uber_reviews_intake",
                    "intake_metadata": json.dumps(intake_metadata)
                }
                
                results.append(record)
                processed_reviews += 1
                
    except Exception as e:
        print(f"❌ Error processing file: {e}")
        return []
    
    print(f"\n📊 Processing complete:")
    print(f"   - Total rows: {total_reviews}")
    print(f"   - Processed reviews: {processed_reviews}")
    
    if results:
        # Calculate summary statistics
        ratings = [r['rating'] for r in results]
        avg_rating = sum(ratings) / len(ratings) if ratings else 0
        
        print(f"   - Average rating: {avg_rating:.2f}")
        print(f"   - Rating distribution:")
        for i in range(1, 6):
            count = ratings.count(i)
            percentage = (count / len(ratings)) * 100 if ratings else 0
            print(f"     {i} star: {count} ({percentage:.1f}%)")
        
        # Reviews with comments
        reviews_with_comments = len([r for r in results if r['review_text'] and len(r['review_text']) > 10])
        print(f"   - Reviews with comments: {reviews_with_comments}")
    
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
    
    filename = 'data/uber_reviews_clean.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ Clean CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

def main():
    print("🎯 Big Appetite OS - Uber Reviews Processing")
    print("============================================\n")
    
    # Process Uber reviews
    results = process_uber_reviews()
    
    if results:
        # Generate clean CSV
        csv_file = generate_clean_csv(results)
        
        if csv_file:
            print("\n🎉 Processing complete!")
            print(f"📁 Ready to upload: {csv_file}")
            print("\n📋 Next steps:")
            print("1. Go to Supabase Dashboard → Table Editor")
            print("2. Select signals.reviews table")
            print("3. Click 'Import data from CSV'")
            print("4. Upload the generated CSV file")
            print("5. Verify the reviews in the database")
    else:
        print("\n❌ No reviews processed.")

if __name__ == "__main__":
    main()
