# 🔍 GHL Webhook Connection Checklist

## Step 1: Check if Server is Running

Your webhook handler is in `tiktok_api.js`. Check if the server is running:

```bash
# Check if process is running
ps aux | grep "tiktok_api\|node.*api"

# Or check if port 3000 is listening
lsof -i :3000
```

**What you should see:**
- A node process running `tiktok_api.js`
- Port 3000 (or your configured port) is listening

## Step 2: Check Webhook Endpoint is Accessible

Your GHL webhook endpoint is: **`POST http://your-server/api/webhook/ghl`**

Test it:

```bash
# Test the webhook endpoint
curl -X POST http://localhost:3000/api/webhook/ghl/test \
  -H "Content-Type: application/json"
```

**Expected response:**
```json
{
  "status": "success",
  "eventType": "post",
  "processed": true,
  "message": "GHL webhook test completed successfully"
}
```

## Step 3: Check Database for Webhook Data

Run this script to check if webhooks have been received:

```bash
node check_webhook_data.js
```

**What you should see:**
```
🔍 Checking GHL webhook data...
✅ social_posts: X recent posts
✅ social_post_metrics: X recent metrics
✅ social_post_comments: X recent comments
```

## Step 4: Configure GHL Webhook

In GoHighLevel, configure the webhook URL:

**Webhook URL:** `https://your-domain.com/api/webhook/ghl`
**Method:** POST
**Content-Type:** application/json

**Expected Payload Structure:**
```json
{
  "locationId": "GSEYlcxpbSqmFNOQcL0s",
  "eventType": "post_published",
  "payload": {
    "id": "post_id_123",
    "locationId": "GSEYlcxpbSqmFNOQcL0s",
    "caption": "Your post caption",
    "mediaUrl": "https://...",
    "platform": "instagram",
    "status": "published",
    "publishedAt": "2024-01-01T12:00:00Z"
  }
}
```

## Step 5: Test with Sample Data

Create a test file to simulate a webhook:

```bash
cat > test_ghl_webhook.sh << 'EOF'
#!/bin/bash

curl -X POST http://localhost:3000/api/webhook/ghl \
  -H "Content-Type: application/json" \
  -d '{
    "locationId": "GSEYlcxpbSqmFNOQcL0s",
    "eventType": "post",
    "payload": {
      "id": "test_post_' $(date +%s) '",
      "locationId": "GSEYlcxpbSqmFNOQcL0s",
      "caption": "Test post from checklist #wingshack #test",
      "mediaUrl": "https://example.com/test.jpg",
      "platform": "instagram",
      "status": "published",
      "publishedAt": "' $(date -u +"%Y-%m-%dT%H:%M:%SZ") '"
    }
  }'

EOF

chmod +x test_ghl_webhook.sh
./test_ghl_webhook.sh
```

## Step 6: Check What the Quantum System Will See

After running the test webhook, check if the post appears:

```bash
# Run this to see processing stats
npm run quantum:stats
```

Or check directly in Supabase SQL Editor:

```sql
-- Check for recent posts
SELECT 
  id, 
  caption, 
  platform, 
  created_at,
  processed_by_agents
FROM social_media.social_posts
ORDER BY created_at DESC
LIMIT 5;
```

## Troubleshooting

### ❌ "Cannot connect to webhook"
- Check if server is running: `ps aux | grep tiktok_api`
- Check firewall/port configuration
- Verify the webhook URL in GHL matches your server

### ❌ "Invalid GHL location ID"
- Expected: `GSEYlcxpbSqmFNOQcL0s`
- Check GHL webhook payload includes `locationId` field

### ❌ "No posts found"
- Webhook hasn't received any data yet
- Check GHL webhook configuration
- Verify webhook is triggering on post events

### ✅ "0 posts found" but webhook works
- This is normal! The quantum system needs posts that are 24+ hours old
- Create posts in GHL, then wait 24 hours
- Or manually trigger processing for recent posts

## Quick Verification SQL

Run this in Supabase SQL Editor to check everything:

```sql
-- 1. Check if column exists
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_schema = 'social_media' 
  AND table_name = 'social_posts'
  AND column_name = 'processed_by_agents';

-- 2. Count all posts
SELECT COUNT(*) as total_posts FROM social_media.social_posts;

-- 3. See recent posts
SELECT 
  id,
  platform,
  LEFT(caption, 50) as caption_preview,
  created_at,
  processed_by_agents
FROM social_media.social_posts
ORDER BY created_at DESC
LIMIT 10;

-- 4. Check for unprocessed old posts (24+ hours)
SELECT COUNT(*) as ready_to_process
FROM social_media.social_posts
WHERE (processed_by_agents IS NULL OR processed_by_agents = FALSE)
  AND created_at < NOW() - INTERVAL '24 hours';
```
