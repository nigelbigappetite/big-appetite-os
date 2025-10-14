# 🚀 Stage 1 Setup Guide

## Prerequisites

Before running Stage 1, you need to have:

1. ✅ **Supabase project set up** (you have this)
2. ✅ **Signals data imported** (WhatsApp messages, reviews, etc.)
3. ❌ **Actors schema created** (migration 027)

## Step 1: Run Database Migration

**You MUST run migration 027 first!**

1. Go to your Supabase dashboard
2. Go to SQL Editor
3. Copy and paste the contents of `supabase/migrations/027_create_actors_schema.sql`
4. Run the migration

## Step 2: Test Connection

After running the migration, test your connection:

```bash
node check-db.js
```

This should show:
- ✅ WhatsApp messages OK
- ✅ Actors table OK

## Step 3: Run Stage 1

Once the migration is complete:

```bash
node scripts/run-with-env.js
```

## Troubleshooting

### If you get "actors.actors does not exist" error:
- You need to run migration 027 first
- The actors schema hasn't been created yet

### If you get connection errors:
- Check your Supabase URL and service role key
- Make sure your Supabase project is active
- Check if RLS policies allow service role access

### If scripts run but show no output:
- This might be a terminal output issue
- Check the Supabase dashboard for any errors
- Look at the database logs

## Quick Test

Run this to test everything:

```bash
node -e "
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient('https://phjawqphehkzfaezhzzf.supabase.co', 'your_service_key');
supabase.from('signals.whatsapp_messages').select('count').then(r => console.log('WhatsApp:', r.data?.length || 'error'));
supabase.from('actors.actors').select('count').then(r => console.log('Actors:', r.data?.length || 'error'));
"
```

## Next Steps

1. Run migration 027 in Supabase SQL Editor
2. Test connection with `node check-db.js`
3. Run Stage 1 with `node scripts/run-with-env.js`
4. Check results in Supabase dashboard
