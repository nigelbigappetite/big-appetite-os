#!/usr/bin/env python3
import asyncio
import json
import re
from datetime import datetime
from playwright.async_api import async_playwright
import csv

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

class GoogleReviewsScraper:
    def __init__(self, place_id=None, business_name="Wing Shack", location=""):
        self.place_id = place_id
        self.business_name = business_name
        self.location = location
        self.reviews = []
        
    async def scrape_reviews(self, max_reviews=50):
        """Scrape Google Reviews for the business"""
        print(f"🚀 Starting Google Reviews scrape for {self.business_name}...")
        
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            page = await browser.new_page()
            
            try:
                # Search for the business
                search_query = f"{self.business_name} {self.location} reviews"
                await page.goto(f"https://www.google.com/search?q={search_query}")
                
                # Wait for results to load
                await page.wait_for_timeout(3000)
                
                # Look for Google Business Profile link
                business_link = await page.query_selector('a[href*="google.com/maps/place"]')
                if business_link:
                    await business_link.click()
                    await page.wait_for_timeout(3000)
                    
                    # Scroll to reviews section
                    await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
                    await page.wait_for_timeout(2000)
                    
                    # Look for "Show all reviews" button
                    show_all_button = await page.query_selector('button:has-text("Show all reviews")')
                    if show_all_button:
                        await show_all_button.click()
                        await page.wait_for_timeout(3000)
                    
                    # Extract reviews
                    await self.extract_reviews(page, max_reviews)
                else:
                    print("❌ Could not find Google Business Profile")
                    
            except Exception as e:
                print(f"❌ Error scraping reviews: {e}")
            finally:
                await browser.close()
                
        return self.reviews
    
    async def extract_reviews(self, page, max_reviews):
        """Extract review data from the page"""
        print("📊 Extracting reviews...")
        
        # Scroll to load more reviews
        for i in range(5):  # Scroll 5 times to load more reviews
            await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            await page.wait_for_timeout(2000)
        
        # Find review elements
        review_elements = await page.query_selector_all('[data-review-id]')
        
        for i, element in enumerate(review_elements[:max_reviews]):
            try:
                # Extract review text
                review_text_elem = await element.query_selector('[data-review-text]')
                review_text = await review_text_elem.inner_text() if review_text_elem else ""
                
                # Extract rating
                rating_elem = await element.query_selector('[aria-label*="star"]')
                rating = 0
                if rating_elem:
                    rating_text = await rating_elem.get_attribute('aria-label')
                    rating_match = re.search(r'(\d+)', rating_text)
                    if rating_match:
                        rating = int(rating_match.group(1))
                
                # Extract reviewer name
                name_elem = await element.query_selector('[data-review-name]')
                reviewer_name = await name_elem.inner_text() if name_elem else "Anonymous"
                
                # Extract date
                date_elem = await element.query_selector('[data-review-date]')
                review_date = await date_elem.inner_text() if date_elem else ""
                
                if review_text and rating > 0:
                    review_data = {
                        'review_text': review_text.strip(),
                        'rating': rating,
                        'reviewer_name': reviewer_name.strip(),
                        'review_date': review_date.strip(),
                        'review_source': 'google',
                        'scraped_at': datetime.now().isoformat()
                    }
                    
                    self.reviews.append(review_data)
                    print(f"  ✅ Review {i+1}: {rating} stars - {review_text[:50]}...")
                
            except Exception as e:
                print(f"  ⚠️ Error extracting review {i+1}: {e}")
                continue
        
        print(f"📊 Extracted {len(self.reviews)} reviews")

def create_review_records(reviews):
    """Convert scraped reviews to database format"""
    records = []
    
    for review in reviews:
        # Parse date (Google format varies)
        review_timestamp = None
        try:
            # Try different date formats
            date_str = review['review_date']
            if 'ago' in date_str.lower():
                # Relative date - use current time as approximation
                review_timestamp = datetime.now().isoformat()
            else:
                # Try to parse actual date
                review_timestamp = datetime.now().isoformat()  # Fallback
        except:
            review_timestamp = datetime.now().isoformat()
        
        # Create raw content
        raw_content = {
            "review_text": review['review_text'],
            "rating": review['rating'],
            "reviewer_name": review['reviewer_name'],
            "review_date": review['review_date'],
            "source": "google",
            "scraped_at": review['scraped_at']
        }
        
        # Create raw metadata
        raw_metadata = {
            "scraping_method": "playwright",
            "scraped_at": review['scraped_at'],
            "review_source": "google"
        }
        
        # Create intake metadata
        intake_metadata = {
            "intake_source": "automated_scraping",
            "intake_timestamp": datetime.now().isoformat(),
            "scraping_batch": "google_reviews_automation"
        }
        
        record = {
            "brand_id": WING_SHACK_BRAND_ID,
            "review_text": review['review_text'],
            "rating": review['rating'],
            "review_source": review['review_source'],
            "reviewer_name": review['reviewer_name'],
            "review_timestamp": review_timestamp,
            "raw_content": json.dumps(raw_content),
            "raw_metadata": json.dumps(raw_metadata),
            "received_at": datetime.now().isoformat(),
            "intake_method": "automated_scraping",
            "intake_metadata": json.dumps(intake_metadata)
        }
        
        records.append(record)
    
    return records

def generate_csv(records, filename="data/google_reviews_clean.csv"):
    """Generate CSV file for upload"""
    if not records:
        print("❌ No records to export")
        return None
    
    def escape_csv(value):
        if value is None:
            return ''
        str_value = str(value)
        if ',' in str_value or '"' in str_value or '\n' in str_value:
            return '"' + str_value.replace('"', '""') + '"'
        return str_value
    
    csv_header = "brand_id,review_text,rating,review_source,reviewer_name,review_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in records:
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
    
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ CSV generated: {filename}")
    print(f"   - Records: {len(records)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

async def main():
    print("🎯 Big Appetite OS - Google Reviews Automation")
    print("==============================================\n")
    
    # Initialize scraper
    scraper = GoogleReviewsScraper(
        business_name="Wing Shack",
        location="London"  # Adjust as needed
    )
    
    # Scrape reviews
    reviews = await scraper.scrape_reviews(max_reviews=30)
    
    if reviews:
        # Convert to database format
        records = create_review_records(reviews)
        
        # Generate CSV
        csv_file = generate_csv(records)
        
        if csv_file:
            print("\n🎉 Scraping complete!")
            print(f"📁 Ready to upload: {csv_file}")
            print("\n📋 Next steps:")
            print("1. Upload the CSV to Supabase signals.reviews table")
            print("2. Set up automated scheduling (cron job)")
            print("3. Monitor for new reviews")
    else:
        print("\n❌ No reviews scraped. Check your business name and location.")

if __name__ == "__main__":
    asyncio.run(main())
