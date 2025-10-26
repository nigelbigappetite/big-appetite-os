# Alternative GHL Integration Methods

Since GHL doesn't support webhooks for social media posts, here are alternative ways to get your data into the system:

## Option 1: Manual Post Creation 🖐️

Create posts manually when you publish on GHL:

```bash
# Use this script to manually add a post
cat > integration/add_ghl_post.sh << 'EOF'
#!/bin/bash

curl -X POST http://localhost:3001/api/webhook/ghl \
  -H "Content-Type: application/json" \
  -d '{
    "locationId": "GSEYlcxpbSqmFNOQcL0s",
    "eventType": "post",
    "payload": {
      "id": "ghl_post_'$(date +%s)'",
      "locationId": "GSEYlcxpbSqmFNOQcL0s",
      "caption": "'"$1"'",
      "mediaUrl": "'"$2"'",
      "platform": "instagram",
      "status": "published",
      "publishedAt": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
    }
  }'
EOF

chmod +x integration/add_ghl_post.sh
```

**Usage:**
```bash
./integration/add_ghl_post.sh "Your post caption" "https://image-url.com"
```

## Option 2: Periodic Polling 🔄

Set up a script to check GHL for new posts periodically:

```bash
# Check for new posts every hour
cat > integration/poll_ghl.sh << 'EOF'
#!/bin/bash
# Poll GHL API for new posts and sync to database
# Run via cron: 0 * * * * /path/to/poll_ghl.sh

GHL_TOKEN="pit-db7f50c2-2e31-457b-adf2-1ad049705b56"
LOCATION_ID="GSEYlcxpbSqmFNOQcL0s"

# Get recent posts from GHL API
curl -X GET "https://rest.gohighlevel.com/v1/posts/" \
  -H "Authorization: Bearer $GHL_TOKEN" \
  -H "LocationId: $LOCATION_ID" \
  | jq -r '.posts[]' \
  | while read post; do
    # Forward to your webhook
    curl -X POST http://localhost:3001/api/webhook/ghl \
      -H "Content-Type: application/json" \
      -d "$post"
  done
EOF

chmod +x integration/poll_ghl.sh
```

## Option 3: Browser Extension 📝

Create a simple bookmarklet to quickly add posts:
1. Bookmark this JavaScript:
```javascript
javascript:(function(){
  fetch('http://localhost:3001/api/webhook/ghl',{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({
      locationId:'GSEYlcxpbSqmFNOQcL0s',
      eventType:'post',
      payload:{
        id:'manual_'+Date.now(),
        caption:prompt('Enter caption:'),
        platform:prompt('Platform (instagram):')||'instagram',
        status:'published',
        publishedAt:new Date().toISOString()
      }
    })
  }).then(r=>r.json()).then(alert('Posted!'));
})();
```

## Option 4: Test the System First 🧪

For now, let's test with manual data:

```bash
# Create a test post
curl -X POST http://localhost:3001/api/webhook/ghl \
  -H "Content-Type: application/json" \
  -d '{
    "locationId": "GSEYlcxpbSqmFNOQcL0s",
    "eventType": "post",
    "payload": {
      "id": "manual_post_'$(date +%s)'",
      "caption": "Testing with Wing Shack branding! 🍗",
      "platform": "instagram",
      "status": "published",
      "publishedAt": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
    }
  }'
```

Then wait 1 hour and check:
```bash
npm run quantum:trigger
```

## Recommendation 💡

Since GHL doesn't support webhooks for social posts, use **Option 2 (Polling)**:
- Set up a cron job to check GHL hourly
- Automatically sync new posts to your database
- Full automation with minimal setup

Or use **Option 1** for now if you only post occasionally.

