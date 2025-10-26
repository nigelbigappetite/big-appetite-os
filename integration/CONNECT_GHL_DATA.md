# Connect Real GHL Data - Quick Start Guide

## 🎯 Overview

Your webhook handler is at: `http://localhost:3000/api/webhook/ghl`  
Your GHL Location ID: `GSEYlcxpbSqmFNOQcL0s`

---

## Step 1: Start Your Webhook Server

### Terminal 1: Webhook Server
```bash
node tiktok_api.js
```

**Expected Output:**
```
🚀 Big Appetite OS API Server started
📡 Server running on port 3000
🔗 GHL Webhook URL: http://localhost:3000/api/webhook/ghl
```

### Terminal 2: Quantum Agent Scheduler
```bash
./integration/start-quantum-service.sh
```

---

## Step 2: Configure GHL Webhook

### In GoHighLevel:
1. Go to **Settings → Webhooks**
2. Click **Add Webhook**
3. Configure:
   - **URL:** `http://your-domain.com/api/webhook/ghl` (or use ngrok for local)
   - **Method:** POST
   - **Content-Type:** application/json
   - **Events:** Select "Social Media Post Published"

### Expected Payload Format:
```json
{
  "locationId": "GSEYlcxpbSqmFNOQcL0s",
  "eventType": "post_published",
  "payload": {
    "id": "post_123",
    "caption": "Your post caption",
    "mediaUrl": "https://example.com/image.jpg",
    "platform": "instagram",
    "status": "published",
    "publishedAt": "2024-10-26T18:00:00Z"
  }
}
```

---

## Step 3: Test the Connection

### Option A: Use Test Endpoint
```bash
curl -X POST http://localhost:3000/api/webhook/ghl/test \
  -H "Content-Type: application/json"
```

### Option B: Send Real Post from GHL
1. Create a post in GHL
2. Publish it
3. Watch the server logs

---

## Step 4: Verify Data Arrival

### Check Server Logs
You should see:
```
📨 GHL Webhook received
🎯 Processing GHL event: post_published
✅ Post event processed successfully
```

### Check Database
```sql
-- In Supabase SQL Editor
SELECT * FROM social_media.social_posts 
ORDER BY created_at DESC 
LIMIT 5;
```

---

## Step 5: Wait for Processing

Posts need to be 1+ hours old before quantum processing:
- After 1 hour, scheduler will pick it up
- Or manually trigger: `npm run quantum:trigger`

---

## 🌐 For Production (Public URL)

### Option 1: ngrok (Quick Testing)
```bash
# Install ngrok
npm install -g ngrok

# Start tunnel
ngrok http 3000

# Use the URL in GHL
# Example: https://abc123.ngrok.io/api/webhook/ghl
```

### Option 2: Deploy to Server
- Deploy `tiktok_api.js` to your server
- Update GHL webhook URL to your server
- Ensure port 3000 is accessible

---

## 🧪 Testing Checklist

- [ ] Webhook server running
- [ ] Quantum scheduler running  
- [ ] GHL webhook configured
- [ ] Test post sent
- [ ] Data visible in database
- [ ] Posts being processed
- [ ] Content generated
- [ ] Assets created

---

## 📊 Monitoring

### Check Webhook Activity
```bash
tail -f output.log  # or wherever your server logs
```

### Check Processing Stats
```bash
./integration/status-quantum-service.sh
```

### Check Generated Content
```sql
-- In Supabase
SELECT * FROM public.copy_generator 
ORDER BY created_at DESC 
LIMIT 5;
```

---

## 🐛 Troubleshooting

### Server Not Running
```bash
# Check if running
ps aux | grep tiktok_api

# Start it
node tiktok_api.js
```

### Webhook Not Receiving Data
1. Check GHL webhook is enabled
2. Verify URL is correct
3. Check firewall/port 3000 accessible
4. Use ngrok for local testing

### Posts Not Processing
1. Check if posts are old enough (1+ hours)
2. Verify `processed_by_agents` column exists
3. Run: `npm run quantum:trigger` manually

### Data Not Appearing in Database
1. Check server logs for errors
2. Verify database connection in `.env`
3. Check table names are correct

---

## 🎉 Success Criteria

When working correctly, you should see:
1. ✅ Webhook logs showing received posts
2. ✅ Posts in `social_media.social_posts` table
3. ✅ Posts being processed after 1 hour
4. ✅ Content in `copy_generator` table
5. ✅ Assets in `creative_assets` table
6. ✅ Posts marked as `processed_by_agents = TRUE`

---

## 💡 Next Steps

Once connected:
1. Let system run for 24 hours
2. Review generated content
3. Adjust belief weights if needed
4. Monitor engagement metrics
5. Iterate and improve

