# Data Contamination Recovery Plan

## Problem Summary
The previous signal processing runs included **outbound WhatsApp messages** (your responses to customers) in the customer sentiment analysis, which heavily skews the data. This happened because the `signals_unified` view was missing the `message_direction` field needed for proper filtering.

## Impact Assessment
- **Contaminated Data**: All previous analysis runs included outbound messages
- **Skewed Results**: Customer sentiment analysis includes your own responses
- **Invalid Insights**: Driver analysis, quantum effects, and identity detection are based on mixed data

## Recovery Steps

### Step 1: Assess Contamination
```bash
python assess_data_contamination.py
```
This will show you exactly how much outbound data was processed.

### Step 2: Clean Contaminated Data
```bash
# First, do a dry run to see what would be cleaned
python clean_contaminated_data.py

# Then actually clean the data
python clean_contaminated_data.py --live
```
This will:
- Remove contaminated processing state records
- Delete contaminated decoder outputs
- Reset signals for reprocessing

### Step 3: Apply the Fix
Run the migration in your Supabase SQL editor:
```sql
-- Run the contents of: supabase/migrations/039_fix_unified_view_message_direction.sql
```

### Step 4: Test the Fix
```bash
python test_outbound_filtering.py
```
This verifies that outbound messages are now properly filtered out.

### Step 5: Reprocess Clean Data
```bash
# Run the signal processor on clean, inbound-only data
cd intelligence_layer
python run_unified_processor.py
```

## What Gets Cleaned

### Contaminated Records to Remove:
1. **Processing State**: Records marking outbound messages as "processed"
2. **Decoder Outputs**: Analysis results from outbound messages
3. **API Usage Logs**: Cost tracking for outbound message processing

### What Stays:
1. **Inbound Messages**: Customer messages (these are valid)
2. **Reviews**: Customer reviews (these are valid)
3. **Other Signals**: Non-WhatsApp signals (these are valid)

## Prevention
After recovery, the system will:
- ✅ Only process inbound WhatsApp messages
- ✅ Include `message_direction` field in unified view
- ✅ Properly filter out outbound messages
- ✅ Maintain clean customer sentiment analysis

## Expected Results After Recovery
- **Accurate Customer Sentiment**: Only based on customer messages
- **Valid Driver Analysis**: Only customer motivations, not your responses
- **Clean Identity Detection**: Only customer identity fragments
- **Proper Quantum Effects**: Only customer psychological states

## Rollback Plan
If something goes wrong during cleanup:
1. The original signal data in `whatsapp_messages` table is untouched
2. Only analysis/processing tables are cleaned
3. You can always reprocess from the original data

## Timeline
- **Assessment**: 2-3 minutes
- **Cleanup**: 1-2 minutes  
- **Migration**: 30 seconds
- **Testing**: 1 minute
- **Reprocessing**: Depends on data volume

**Total Recovery Time**: ~5-10 minutes
