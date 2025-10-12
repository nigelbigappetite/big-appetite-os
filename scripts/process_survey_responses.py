#!/usr/bin/env python3
import csv
import json
from datetime import datetime
import re

print("🚀 Processing Wing Shack Survey Responses...")

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

def clean_text(text):
    """Clean and normalize text data"""
    if not text or text.strip() == '':
        return None
    return text.strip()

def extract_rating(text):
    """Extract numeric rating from text"""
    if not text:
        return None
    # Look for single digit at start or end
    match = re.search(r'\b([1-5])\b', str(text))
    return int(match.group(1)) if match else None

def create_survey_response(respondent_id, survey_type, question, response, rating=None, timestamp=None):
    """Create a survey response record"""
    
    # Parse timestamp
    survey_timestamp = None
    if timestamp:
        try:
            # Handle different timestamp formats
            if '/' in timestamp:
                survey_timestamp = datetime.strptime(timestamp, '%m/%d/%Y %H:%M:%S').isoformat()
            else:
                survey_timestamp = datetime.fromisoformat(timestamp.replace('Z', '+00:00')).isoformat()
        except:
            survey_timestamp = datetime.now().isoformat()
    
    # Create raw content
    raw_content = {
        "respondent_id": respondent_id,
        "survey_type": survey_type,
        "question": question,
        "response": response,
        "rating": rating,
        "timestamp": timestamp,
        "source": "google_forms"
    }
    
    # Create raw metadata
    raw_metadata = {
        "survey_platform": "google_forms",
        "response_timestamp": timestamp,
        "question_type": "multiple_choice" if rating else "open_ended"
    }
    
    # Create intake metadata
    intake_metadata = {
        "intake_source": "csv_upload",
        "intake_timestamp": datetime.now().isoformat(),
        "survey_batch": "wing_shack_customer_insights_2024"
    }
    
    return {
        "brand_id": WING_SHACK_BRAND_ID,
        "survey_type": survey_type,
        "question": question,
        "response": response,
        "satisfaction_score": rating,
        "respondent_id": respondent_id,
        "survey_timestamp": survey_timestamp,
        "raw_content": json.dumps(raw_content),
        "raw_metadata": json.dumps(raw_metadata),
        "received_at": datetime.now().isoformat(),
        "intake_method": "survey_intake",
        "intake_metadata": json.dumps(intake_metadata)
    }

def process_survey_data():
    """Process the survey CSV data"""
    
    results = []
    question_mapping = {
        'How old are you?': 'demographics_age',
        'How often do you visit/order from Wing Shack?': 'behavior_frequency',
        'Where do you eat your chicken?': 'behavior_dining_preference',
        'Which of these describe you currently?': 'demographics_employment',
        'Which best describes the industry you work in?': 'demographics_industry',
        'What is your average spend (per person) at Wing Shack?': 'behavior_spending',
        'Who do you visit/share Wing Shack with?': 'behavior_social',
        'How did you hear about Wing Shack?': 'behavior_discovery',
        'What brings you to Wing Shack': 'motivation_primary',
        'Your beats of choice?': 'preferences_music',
        'Which social media platform do you most frequently?': 'preferences_social_media',
        'Which of these is the most interesting to you?': 'preferences_interests',
        'In a month, what do you spend the most £££ on (outside of the boring stuff!)?': 'lifestyle_spending_priorities',
        'What would you like to see more of at Wing Shack?': 'feedback_improvements',
        'Food Quality': 'rating_food_quality',
        'Food Variety': 'rating_food_variety',
        'Price': 'rating_price',
        'Speed of Service': 'rating_service_speed',
        'Atmosphere of the Restaurant': 'rating_atmosphere',
        'Healthiness of Food Options': 'rating_healthiness',
        'What are your hobbies or interests outside of dining? This can help us understand your lifestyle better.': 'lifestyle_hobbies',
        'What other brands or restaurants do you feel a strong loyalty towards, and why?': 'lifestyle_brand_loyalty',
        'Describe a memorable experience you had at Wing Shack Co. What made it memorable?': 'experience_memorable',
        'Have you ever shared your dining experience at Wing Shack Co. on social media? If so, what prompted you to do so?': 'behavior_social_sharing',
        'When choosing where to eat, what emotional factors influence your decision? (e.g., comfort, adventure, socializing, nostalgia)': 'motivation_emotional',
        'What changes or additions to Wing Shack Co. would enhance your dining experience?': 'feedback_enhancements',
        'Are there any specific dishes or flavors you\'d like to see added to our menu?': 'feedback_menu_requests',
        'If you are a part of our loyalty program, what aspects do you find most valuable? How can we improve it?': 'feedback_loyalty_program',
        'How important is it for you that a restaurant practices sustainability in its operations (e.g., sourcing locally, minimizing waste)?': 'values_sustainability',
        ' How do you feel about restaurants engaging in community services or local events? Does this influence your dining choices?': 'values_community',
        'On a scale of 1 to 10, how significant is the healthiness of food in your decision-making process when choosing a dining establishment?': 'values_health_importance',
        'How much do you value having cultural or unique dining experiences? Can you share an example of a memorable cultural dining experience you\'ve had?': 'values_cultural_experiences',
        'Beyond dining, what are your top three leisure activities? This will help us understand your lifestyle and interests better.': 'lifestyle_leisure',
        'Are you interested in trying dishes from different cultures or unusual flavor combinations? Why or why not?': 'preferences_culinary_adventure',
        'How does technology (e.g., mobile ordering, social media interactions) enhance your dining experience?': 'preferences_technology',
        'When it comes to food, do you lean more towards comfort and familiarity, or are you more adventurous? What drives your choice?': 'preferences_food_approach',
        ' How important are social interactions to you in a dining setting? Do you prefer dining out as an opportunity to meet new people, or is it more about spending time with known friends and family?': 'preferences_social_dining',
        'Can you recall a dining experience that you feel contributed to your personal growth or broadened your perspectives? Please describe it.': 'experience_personal_growth',
        'Describe a restaurant or dining experience you aspire to try. What about it appeals to you?': 'aspirations_dining',
        'Are there any chefs, food bloggers, or food influencers you follow for inspiration? What do you admire about them?': 'influences_culinary',
        'How do ethical considerations (e.g., animal welfare, fair trade) influence your food choices?': 'values_ethical_food',
        'Do you prioritize eating locally sourced food over exotic imports? Please explain your reasoning.': 'values_local_vs_global',
        'Rate your last Wing Shack Experience': 'rating_overall_experience'
    }
    
    # Rating questions (1-5 scale)
    rating_questions = [
        'Food Quality', 'Food Variety', 'Price', 'Speed of Service', 
        'Atmosphere of the Restaurant', 'Healthiness of Food Options'
    ]
    
    # 1-10 scale questions
    scale_10_questions = [
        'On a scale of 1 to 10, how significant is the healthiness of food in your decision-making process when choosing a dining establishment?'
    ]
    
    try:
        with open('data/survey_responses.csv', 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            
            for row_num, row in enumerate(reader, 1):
                print(f"Processing respondent {row_num}...")
                
                # Get respondent ID (email)
                respondent_id = clean_text(row.get('Email address', ''))
                if not respondent_id:
                    print(f"  ⚠️ Skipping row {row_num} - no email address")
                    continue
                
                # Get timestamp
                timestamp = clean_text(row.get('Timestamp', ''))
                
                # Process each question
                for question, response in row.items():
                    if question == 'Timestamp' or question == 'Email address':
                        continue
                    
                    # Clean response
                    response_text = clean_text(response)
                    if not response_text or response_text.lower() in ['none', 'n/a', 'no', '']:
                        continue
                    
                    # Determine survey type and rating
                    survey_type = question_mapping.get(question, 'general_feedback')
                    rating = None
                    
                    # Extract rating for rating questions
                    if question in rating_questions:
                        rating = extract_rating(response_text)
                    elif question in scale_10_questions:
                        rating = extract_rating(response_text)
                    elif question == 'Rate your last Wing Shack Experience':
                        rating = extract_rating(response_text)
                    
                    # Create survey response record
                    survey_record = create_survey_response(
                        respondent_id=respondent_id,
                        survey_type=survey_type,
                        question=question,
                        response=response_text,
                        rating=rating,
                        timestamp=timestamp
                    )
                    
                    results.append(survey_record)
        
        print(f"\n📊 Processing complete:")
        print(f"   - Total survey responses: {len(results)}")
        print(f"   - Unique respondents: {len(set(r['respondent_id'] for r in results))}")
        
        return results
        
    except FileNotFoundError:
        print("❌ Error: survey_responses.csv not found")
        print("Please save your Google Sheets data as 'data/survey_responses.csv'")
        return []
    except Exception as e:
        print(f"❌ Error processing survey data: {e}")
        return []

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
    
    csv_header = "brand_id,survey_type,question,response,satisfaction_score,respondent_id,survey_timestamp,raw_content,raw_metadata,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
        row = [
            escape_csv(record["brand_id"]),
            escape_csv(record["survey_type"]),
            escape_csv(record["question"]),
            escape_csv(record["response"]),
            escape_csv(record["satisfaction_score"]),
            escape_csv(record["respondent_id"]),
            escape_csv(record["survey_timestamp"]),
            escape_csv(record["raw_content"]),
            escape_csv(record["raw_metadata"]),
            escape_csv(record["received_at"]),
            escape_csv(record["intake_method"]),
            escape_csv(record["intake_metadata"])
        ]
        csv_rows.append(','.join(row))
    
    csv_content = csv_header + '\n'.join(csv_rows)
    
    filename = 'data/survey_responses_clean.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ Clean CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

def main():
    print("🎯 Big Appetite OS - Survey Response Processing")
    print("================================================\n")
    
    # Process survey data
    results = process_survey_data()
    
    if results:
        # Generate clean CSV
        csv_file = generate_clean_csv(results)
        
        if csv_file:
            print("\n🎉 Processing complete!")
            print(f"📁 Ready to upload: {csv_file}")
            print("\n📋 Next steps:")
            print("1. Upload the CSV to Supabase signals.survey_responses table")
            print("2. Verify data in the database")
            print("3. Check for any data quality issues")
    else:
        print("\n❌ No data processed. Please check your input file.")

if __name__ == "__main__":
    main()
