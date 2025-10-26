# Quantum Agent Integration with GHL Webhooks

This integration connects your quantum cognitive agent system with GoHighLevel webhook data to automatically process social media posts and generate optimized content recommendations.

## 🎯 Overview

The integration system automatically:
1. **Receives** social media posts from GHL webhooks
2. **Processes** them through your quantum agents (observation, adjustment, content generation)
3. **Learns** from performance data (updates belief driver weights)
4. **Generates** new optimized content based on learnings
5. **Pushes** recommendations back to GHL as draft posts

## 📁 Files

### `agent-integration-service.ts`
Main service that routes post data through all agents. Handles:
- Calculating observation metrics (prediction error, free energy, collapse score)
- Triggering belief weight adjustments
- Generating new optimized copy and assets
- Tracking processed posts

### `quantum-agent-scheduler.ts`
Automated scheduler that runs periodic processing cycles:
- Processes posts 24-48 hours after publication
- Runs every 6 hours (configurable)
- Batch processes multiple posts
- Provides manual trigger capabilities

### `ghl-integration-service.ts`
Service for pushing results back to GoHighLevel:
- Retrieves generated content
- Formats as draft posts
- Pushes to GHL API
- Tracks recommendation usage

## 🚀 Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Run Database Migration

Run the SQL migration to add the `processed_by_agents` column in the **Supabase SQL Editor**:

```sql
-- Add column to track processed posts
ALTER TABLE social_media.social_posts
ADD COLUMN IF NOT EXISTS processed_by_agents BOOLEAN DEFAULT FALSE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_social_posts_processed 
ON social_media.social_posts(processed_by_agents);

-- Create index for filtering unprocessed posts
CREATE INDEX IF NOT EXISTS idx_social_posts_unprocessed 
ON social_media.social_posts(created_at) 
WHERE processed_by_agents IS NULL OR processed_by_agents = FALSE;

-- Add comment explaining the column
COMMENT ON COLUMN social_media.social_posts.processed_by_agents IS 
'Flag indicating whether this post has been processed by the quantum agent system. Set to true after running through observation, adjustment, and content generation agents.';

-- Verify the column was added
SELECT 
  column_name, 
  data_type, 
  column_default
FROM information_schema.columns
WHERE table_schema = 'social_media'
  AND table_name = 'social_posts'
  AND column_name = 'processed_by_agents';
```

### 3. Configure Environment

Ensure your `.env` file has:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_key
BRAND_ID=your_brand_id
OPENAI_API_KEY=your_openai_key
```

Optional for GHL integration:
```env
GHL_API_KEY=your_ghl_api_key
GHL_API_URL=https://rest.gohighlevel.com/v1
```

### 4. Start the Scheduler

```bash
npm run quantum:start
```

## 📊 Usage

### View Processing Stats

```bash
npm run quantum:stats
```

### Manually Trigger Processing

```bash
npm run quantum:trigger
```

### Process a Specific Post

```bash
npm run quantum:process <post-id>
```

## 🔄 How It Works

### 1. Post Ingestion (T = 0 hours)
GHL publishes a post → Webhook received → Stored in `social_media.social_posts`

### 2. Processing Window (T = 24-48 hours)
Scheduler detects posts in the 24-48 hour age window and triggers processing.

### 3. Agent Pipeline (5-10 minutes)

```
Observation Agent
├─ Calculate prediction error (expected vs actual engagement)
├─ Calculate free energy (cognitive dissonance metric)
└─ Calculate collapse score (belief state alignment)

Adjustment Agent
├─ Read recent observations
├─ Update belief driver weights (Bayesian learning)
└─ Store new priors in stimuli_adjustments

Copy Generator
├─ Read updated driver weights
├─ Generate optimized content (driver-biased)
└─ Store in copy_generator

Creative Asset Generator
├─ Read generated copy
├─ Generate matching visuals (DALL-E)
└─ Store in creative_assets
```

### 4. GHL Push
Generated content pushed to GHL as draft posts for review.

## 📈 Monitoring

### Check Stats
```typescript
import { getProcessingStats } from './integration/agent-integration-service';

const stats = await getProcessingStats(brandId);
console.log(stats);
// {
//   total: 150,
//   processed: 120,
//   pending: 30,
//   avgPredictionError: 0.23,
//   avgFreeEnergy: 0.15
// }
```

### View Recent Recommendations
```typescript
import { previewLatestRecommendations } from './integration/ghl-integration-service';

const recommendations = await previewLatestRecommendations(brandId, 5);
```

## ⚙️ Configuration

### Scheduler Config

```typescript
import { startScheduler } from './integration/quantum-agent-scheduler';

startScheduler({
  brandId: 'your-brand-id',
  enabled: true,
  processSchedule: '0 */6 * * *', // Every 6 hours
  batchSize: 10,
  minPostAgeHours: 24,
  maxPostAgeHours: 72
});
```

### Process Posts Manually

```typescript
import { processReadyPosts } from './integration/agent-integration-service';

const results = await processReadyPosts(brandId, {
  minAge: 24 * 60 * 60 * 1000, // 24 hours
  maxAge: 72 * 60 * 60 * 1000,  // 72 hours
  limit: 10
});
```

## 🐛 Troubleshooting

### Posts Not Processing

1. Check if posts are old enough (24-48 hours)
2. Verify `processed_by_agents` column exists
3. Check logs for errors

```sql
-- See unprocessed posts
SELECT id, caption, created_at, processed_by_agents
FROM social_media.social_posts
WHERE (processed_by_agents IS NULL OR processed_by_agents = FALSE)
  AND created_at < NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

### High Prediction Error

This is actually good! High prediction error means the system is discovering new patterns. Check what was different:

```sql
SELECT post_id, prediction_error, actual_engagement, expected_engagement
FROM analytics.stimuli_observations
WHERE prediction_error > 0.5
ORDER BY created_at DESC;
```

### Belief Weights Not Updating

Check:
1. Observations are being stored in `stimuli_observations`
2. SQL function `update_belief_driver_weights` exists
3. Recent observations exist

```sql
-- Check recent observations
SELECT * FROM analytics.stimuli_observations
ORDER BY created_at DESC LIMIT 5;
```

## 📚 Related Documentation

- [Agent System](../../README_CREATIVE_AGENTS.md)
- [Intelligence Layer](../../INTELLIGENCE_LAYER_EXECUTIVE_SUMMARY.md)
- [Schema Migration](../../big_appetite_schema_migration.sql)

## ✅ Success Metrics

After 30 days, expect to see:
- ✅ Prediction error decreasing (system learning)
- ✅ Free energy stabilizing (less confusion)
- ✅ Dominant drivers emerging (clear strategy)
- ✅ Content generation velocity increasing
- ✅ Engagement rates improving

## 🎓 Theory

This system implements concepts from:
- **Active Inference**: Karl Friston's Free Energy Principle
- **Quantum Cognition**: Busemeyer & Bruza's quantum psychology models
- **Bayesian Learning**: Belief state updates based on evidence

The combination creates a self-improving content system that minimizes cognitive free energy (uncertainty) while maximizing belief alignment with audience drivers.
