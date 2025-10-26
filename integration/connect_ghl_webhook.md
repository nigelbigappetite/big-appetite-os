# Connect Real GHL Data

## Your Webhook URL
```
http://your-server:3001/api/webhook/ghl
```

## How to Connect

### 1. Start Server (Already Running ✅)
```bash
node tiktok_api.js  # Running on port 3001
```

### 2. Test Connection
```bash
curl -X POST http://localhost:3001/api/webhook/ghl/test
```

**Expected:** `{"status":"success","eventType":"post","processed":true}`

### 3. Configure in GHL

In GoHighLevel Settings → Webhooks:
- **URL:** `http://your-domain.com:3001/api/webhook/ghl` (or use ngrok)
- **Location ID:** `GSEYlcxpbSqmFNOQcL0s`
- **Events:** Social Media Post Published

### 4. Start Background Scheduler
```bash
./integration/start-quantum-service.sh
```

### 5. Monitor
```bash
# Check scheduler status
./integration/status-quantum-service.sh

# View logs
tail -f quantum-agent.log

# Check for new posts
./node_modules/.bin/tsx integration/verify_results.ts
```

---

## Quick Test

After publishing a post in GHL:

1. **Check if received:**
   ```sql
   SELECT * FROM social_media.social_posts 
   ORDER BY created_at DESC LIMIT 1;
   ```

2. **Process manually:**
   ```bash
   npm run quantum:trigger
   ```

3. **Check results:**
   ```bash
   ./node_modules/.bin/tsx integration/verify_results.ts
   ```

---

## For Production

Use **ngrok** for public URL:
```bash
ngrok http 3001
# Use the ngrok URL in GHL webhook settings
```

