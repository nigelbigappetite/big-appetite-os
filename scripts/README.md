# WhatsApp CSV Ingestion Tool

Simple script to ingest WhatsApp messages from CSV files into Big Appetite OS database.

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp env.example .env
   # Edit .env with your Supabase keys
   ```

3. **Place your CSV file:**
   ```bash
   # Put your CSV file here:
   data/whatsapp_messages.csv
   ```

## Usage

**Basic usage:**
```bash
node scripts/ingest-whatsapp.js
```

**With custom CSV file:**
```bash
CSV_FILE=data/my_file.csv node scripts/ingest-whatsapp.js
```

## CSV Format

Your CSV must have these exact headers:
```
timestamp,sender,message,phone_number,brand,direction,conversation_id
```

**Example:**
```
2025-09-29 01:17:18,~George,Hi ordered through your Rayleigh shop...,447473880264,wing_shack,inbound,conv_001
2025-09-29 01:19:14,Wingverse,Hi there I'll have a look...,447473880264,wing_shack,outbound,conv_001
```

## What It Does

1. **Reads CSV** from `data/whatsapp_messages.csv`
2. **Cleans data:**
   - Adds `+` prefix to phone numbers
   - Removes `~` prefix from sender names
   - Filters out system messages
3. **Looks up brand** in database
4. **Checks for duplicates** (skips if already exists)
5. **Inserts messages** into both `signals.whatsapp_messages` and `signals.signals`
6. **Shows summary** of what was processed

## Output

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

## Error Handling

- **CSV not found:** Script exits with clear error message
- **Invalid CSV format:** Shows which headers are missing
- **Brand not found:** Lists available brands in database
- **Database errors:** Logs to `logs/ingestion.log`
- **Bad data:** Skips problematic rows, continues processing

## Logs

Check `logs/ingestion.log` for detailed error information.

## Requirements

- Node.js 18+
- Supabase database with `core.brands` table
- CSV file with correct format
