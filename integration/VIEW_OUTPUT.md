# Where to See Output / Results

## 📊 Real-Time Processing Output

When processing runs, you'll see output in these places:

### 1. Terminal Output (Manual Trigger)
```bash
./node_modules/.bin/tsx integration/quantum-agent-scheduler.ts trigger
```
Shows: Processing steps, agent results, success/failure

### 2. Background Service Logs
```bash
tail -f quantum-agent.log
```
Shows: Automatic processing logs from scheduler

### 3. Server Logs
```bash
tail -f /tmp/tiktok_api.log
# or check the terminal where you ran: node tiktok_api.js
```
Shows: Incoming webhook data

### 4. Database Results
Run in **Supabase SQL Editor**:

```sql
-- Check processed posts
SELECT id, caption, processed_by_agents 
FROM social_media.social_posts 
ORDER BY created_at DESC 
LIMIT 10;

-- Check generated content
SELECT hook, caption, cta, belief_alignment_tag
FROM public.copy_generator 
ORDER BY created_at DESC 
LIMIT 5;

-- Check generated assets  
SELECT asset_id, creative_type, media_url
FROM public.creative_assets
ORDER BY created_at DESC
LIMIT 5;
```

### 5. Verification Script
```bash
./node_modules/.bin/tsx integration/verify_results.ts
```
Shows: Complete summary of all processing activity

## 🎯 Current Post Status

**Post ID:** test_final_1761505491  
**Status:** Waiting to be processed (1+ hour old)  
**Action:** Will be processed automatically by scheduler

## 🚀 Quick Commands

```bash
# 1. Check what's in the database
./node_modules/.bin/tsx integration/verify_results.ts

# 2. View scheduler logs
tail -f quantum-agent.log

# 3. View webhook server logs  
tail -f /tmp/tiktok_api.log

# 4. Check scheduler status
./integration/status-quantum-service.sh
```

