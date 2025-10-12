# 🚀 Apify Social Media Scraping Guide

## 🎯 **Overview**
This guide shows you how to scrape TikTok and Instagram comments for Wing Shack using Apify's powerful social media scrapers.

## 🔧 **Setup Steps**

### **1. Get Apify API Token**
1. **Sign up** at [console.apify.com](https://console.apify.com)
2. **Go to** Account → Integrations
3. **Copy** your API token
4. **Set environment variable**:
   ```bash
   export APIFY_API_TOKEN="your_token_here"
   ```

### **2. Install Dependencies**
```bash
pip install apify-client
```

### **3. Create Social Comments Table**
Run this SQL in Supabase:
```sql
-- Copy content from supabase/migrations/018_create_social_comments_table.sql
```

### **4. Run the Scraper**
```bash
python3 scripts/apify_social_scraper.py
```

## 📊 **What Gets Scraped**

### **TikTok Data:**
- **Comments** from @wingshackco videos
- **Author info** (username, followers, verified status)
- **Engagement** (likes, replies)
- **Post details** (caption, views, likes)
- **Hashtags** and mentions

### **Instagram Data:**
- **Comments** from @wingshackco posts
- **Author info** (username, followers, verified status)
- **Engagement** (likes, replies)
- **Post details** (caption, likes, comments)
- **Hashtags** and mentions

## 🎯 **Apify Actors Used**

### **TikTok Scraper:**
- **Actor**: `apify/tiktok-scraper`
- **Features**: Comments, user data, video metadata
- **Rate limits**: Handled automatically
- **Anti-bot**: Residential proxies included

### **Instagram Scraper:**
- **Actor**: `apify/instagram-scraper`
- **Features**: Comments, user data, post metadata
- **Rate limits**: Handled automatically
- **Anti-bot**: Residential proxies included

## 💰 **Costs**

### **Apify Pricing:**
- **Free tier**: 1,000 compute units/month
- **TikTok scraper**: ~0.1 units per comment
- **Instagram scraper**: ~0.05 units per comment
- **Estimated cost**: $0.10-0.50 per 1,000 comments

### **Wing Shack Estimate:**
- **TikTok**: ~500 comments = $0.05
- **Instagram**: ~300 comments = $0.02
- **Total**: ~$0.07 per scrape

## 🔄 **Automation Options**

### **Manual Scraping:**
- Run script when needed
- Full control over timing
- Cost-effective

### **Scheduled Scraping:**
- Set up cron job
- Daily/weekly scraping
- Consistent data collection

### **Apify Schedules:**
- Use Apify's built-in scheduling
- Automatic runs
- Webhook notifications

## 📈 **Business Value**

### **Customer Insights:**
- **Sentiment analysis** of comments
- **Influencer identification** (high follower counts)
- **Trending topics** (hashtags, mentions)
- **Engagement patterns** (likes, replies)

### **Content Strategy:**
- **Popular posts** identification
- **Comment themes** analysis
- **Customer feedback** collection
- **Competitor mentions** tracking

## 🛠️ **Advanced Features**

### **Sentiment Analysis:**
```python
# Add to processing pipeline
from textblob import TextBlob

def analyze_sentiment(text):
    blob = TextBlob(text)
    return {
        'sentiment_score': blob.sentiment.polarity,
        'sentiment_label': 'positive' if blob.sentiment.polarity > 0.1 else 'negative' if blob.sentiment.polarity < -0.1 else 'neutral'
    }
```

### **Influencer Detection:**
```sql
-- Find potential influencers
SELECT 
    author_username,
    author_followers_count,
    COUNT(*) as comment_count,
    AVG(like_count) as avg_likes
FROM signals.social_comments 
WHERE author_followers_count > 10000
GROUP BY author_username, author_followers_count
ORDER BY author_followers_count DESC;
```

### **Trend Analysis:**
```sql
-- Analyze trending hashtags
SELECT 
    unnest(hashtags) as hashtag,
    COUNT(*) as usage_count
FROM signals.social_comments 
WHERE hashtags IS NOT NULL
GROUP BY hashtag
ORDER BY usage_count DESC
LIMIT 20;
```

## 🚨 **Important Notes**

### **Rate Limits:**
- Apify handles rate limits automatically
- Residential proxies prevent IP blocks
- Scraping is done responsibly

### **Data Privacy:**
- Only public comments are scraped
- No private account data accessed
- Compliant with platform ToS

### **Cost Management:**
- Monitor Apify usage dashboard
- Set spending limits
- Use free tier when possible

## 🔧 **Troubleshooting**

### **Common Issues:**
- **API token error**: Check token is set correctly
- **No data returned**: Check if account exists and is public
- **Rate limit hit**: Wait and retry, or upgrade plan

### **Getting Help:**
- **Apify docs**: [docs.apify.com](https://docs.apify.com)
- **Community**: [Apify Discord](https://discord.gg/apify)
- **Support**: [help.apify.com](https://help.apify.com)

---

**Ready to start scraping social media data? 🚀**
