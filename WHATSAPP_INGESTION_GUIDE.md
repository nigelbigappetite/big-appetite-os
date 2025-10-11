# 🚀 WhatsApp CSV Ingestion - Quick Start Guide

## What You Have

✅ **Working database schema** (Phase 1 complete)  
✅ **CSV ingestion script** (Phase 2A complete)  
✅ **Sample data** ready to test  

## Quick Start (3 Steps)

### 1. Set Up Environment
```bash
# Copy environment template
cp env.example .env

# Edit .env with your Supabase keys
# SUPABASE_URL=https://phjawqphehkzfaezhzzf.supabase.co
# SUPABASE_SERVICE_ROLE_KEY=your_key_here
```

### 2. Test Connection
```bash
# Test database connection
node scripts/test-connection.js
```

### 3. Ingest CSV Data
```bash
# Place your CSV in data/ folder
# Then run:
node scripts/ingest-whatsapp.js
```

## CSV Format

Your CSV must have these exact headers:
```
timestamp,sender,message,phone_number,brand,direction,conversation_id
```

**Example data:**
```
2025-09-29 01:17:18,~George,Hi ordered through your Rayleigh shop...,447473880264,wing_shack,inbound,conv_001
2025-09-29 01:19:14,Wingverse,Hi there I'll have a look...,447473880264,wing_shack,outbound,conv_001
```

## What the Script Does

1. **Reads CSV** from `data/whatsapp_messages.csv`
2. **Cleans data:**
   - Adds `+` prefix to phone numbers (`447473880264` → `+447473880264`)
   - Removes `~` prefix from sender names (`~George` → `George`)
   - Filters out system messages
3. **Looks up brand** in database (uses `wing_shack` by default)
4. **Checks for duplicates** (skips if already exists)
5. **Inserts messages** into both tables:
   - `signals.whatsapp_messages` (individual messages)
   - `signals.signals` (central signal log)
6. **Shows summary** of what was processed

## Expected Output

```
🚀 WhatsApp CSV Ingestion Tool
================================

Reading CSV: data/whatsapp_messages.csv
Found 10 messages
Using brand ID: a1b2c3d4-e5f6-7890-1234-567890abcdef

Processing... 10/10 (8 inserted, 2 skipped)

✅ Processing Complete!
========================
Total rows in CSV: 10
Messages inserted: 8
System messages skipped: 0
Duplicates skipped: 2
Errors: 0
```

## File Structure

```
big-appetite-os/
├── scripts/
│   ├── ingest-whatsapp.js      # Main ingestion script
│   ├── test-connection.js      # Test database connection
│   └── README.md               # Detailed documentation
├── data/
│   ├── whatsapp_messages.csv   # Your CSV file goes here
│   └── sample_whatsapp_messages.csv  # Example CSV
├── logs/
│   └── ingestion.log           # Error logs
├── config/
│   └── supabase.config.js      # Database configuration
└── package.json                # Dependencies
```

## Troubleshooting

### "CSV file not found"
- Make sure your CSV is in `data/whatsapp_messages.csv`
- Or set `CSV_FILE` environment variable

### "Brand not found"
- Make sure `wing_shack` brand exists in database
- Run the seed data first if needed

### "Database connection failed"
- Check your Supabase keys in `.env`
- Run `node scripts/test-connection.js` to diagnose

### "Missing required headers"
- Check your CSV has exact headers: `timestamp,sender,message,phone_number,brand,direction,conversation_id`

## Next Steps

Once CSV ingestion is working:

1. **Verify data** in Supabase dashboard
2. **Test with real WhatsApp data**
3. **Build Phase 2B** (WPPConnect automation)
4. **Add Phase 3** (Signal processing and actor profiles)

## Success Criteria

✅ Script reads CSV automatically  
✅ Data cleaned (phone prefix, remove ~, filter system messages)  
✅ Brand_id looked up  
✅ Duplicates skipped  
✅ Messages inserted into database  
✅ Summary shown  
✅ Errors logged  
✅ Can run repeatedly with new CSV files  

**You now have a working signal intake pipeline!** 🎉
