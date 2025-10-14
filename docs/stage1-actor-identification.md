# 🎯 Stage 1: Actor Identification & Matching

## Overview

Stage 1 transforms raw signals into structured actor profiles by identifying who each signal belongs to and linking signals from the same person across different sources (WhatsApp, reviews, orders, social media).

## 🎯 **The Challenge**

**Before Stage 1:**
```
Signal 1: WhatsApp from +447473880264 (George complains about delivery)
Signal 2: Google Review from "George R." (mentions Rayleigh location)  
Signal 3: Order #4GCRD3 (phone: +447473880264)
```
**Result:** 3 separate, unconnected signals

**After Stage 1:**
```
Actor: George (+447473880264)
├── WhatsApp: 12 messages (delivery complaints, quality issues)
├── Google Review: 1 review (location mention)
└── Orders: 3 orders (phone linked)
```
**Result:** 1 unified actor profile with all signals linked

## 🏗️ **Database Schema**

### **Core Tables**

#### **`actors.actors`** - Main actor profiles
- `actor_id` - Unique identifier
- `primary_phone` - Most reliable identifier
- `primary_email` - Email if available
- `primary_name` - Name if available
- `first_seen` / `last_seen` - Activity timeline
- `signal_count` - Number of linked signals
- `signal_sources` - Array of source types
- `profile_completeness` - 0-1 completeness score
- `confidence_in_identity` - 0-1 confidence score

#### **`actors.actor_identifiers`** - All known identifiers
- `actor_id` - Links to main actor
- `identifier_type` - 'phone', 'email', 'name', 'social_handle'
- `identifier_value` - The actual identifier
- `identifier_confidence` - Confidence in this identifier
- `source_signal_id` - Which signal provided this identifier
- `is_verified` - Whether identifier is verified

#### **`actors.actor_signals`** - Signal-to-actor links
- `actor_id` - Links to actor
- `signal_id` - Links to original signal
- `signal_type` - 'whatsapp_message', 'google_review', 'order'
- `link_confidence` - Confidence in the link
- `link_method` - How the link was made

#### **`actors.actor_matches`** - Matching decisions log
- `signal_id` - Signal being processed
- `matched_actor_id` - Actor it was matched to
- `match_confidence` - Confidence in match
- `match_method` - How match was made
- `decision` - 'matched', 'created_new', 'flagged_for_review'

#### **`actors.actor_merges`** - Duplicate merge log
- `primary_actor_id` - Actor that survived merge
- `merged_actor_id` - Actor that was merged
- `merge_reason` - Why they were merged
- `merge_confidence` - Confidence in merge decision

## 🔍 **Matching Logic**

### **Tier 1: High Confidence (0.95+)**
- **Exact phone match**: Same phone number across signals
- **Exact email match**: Same email address across signals
- **Order ID link**: Order linked to known actor

### **Tier 2: Medium Confidence (0.70-0.94)**
- **Name + location match**: Similar name + similar behavior
- **Name + behavior match**: Similar name + similar patterns
- **Cross-reference match**: Multiple weak signals pointing to same person

### **Tier 3: Low Confidence (0.50-0.69)**
- **Name similarity only**: Fuzzy name matching
- **Behavioral similarity**: Similar patterns but no direct identifiers
- **Flagged for review**: Human review needed

## 🛠️ **Implementation**

### **1. Identity Resolver (`scripts/identity-resolver.js`)**

**Core Class:** `IdentityResolver`

**Key Methods:**
- `extractIdentifiers(signal)` - Extract phone, email, name from signal
- `findExistingActor(identifiers)` - Find matching actor
- `createNewActor(identifiers, signal)` - Create new actor profile
- `linkSignalToActor(actorId, signal, confidence, method)` - Link signal to actor

**Example Usage:**
```javascript
const resolver = new IdentityResolver();

const signal = {
  signal_id: 'whatsapp_123',
  sender_phone: '+447473880264',
  message_text: 'I love honey sesame wings!',
  message_timestamp: '2025-09-29T01:17:18Z'
};

const result = await resolver.processSignal(signal);
// Returns: { action: 'matched', actor_id: 'uuid', confidence: 0.98, method: 'exact_phone' }
```

### **2. WhatsApp Processor (`scripts/process-whatsapp-actors.js`)**

**Core Class:** `WhatsAppActorProcessor`

**Key Methods:**
- `processAllWhatsAppMessages()` - Process all WhatsApp messages in batches
- `processMessage(message)` - Process single message
- `showFinalResults()` - Show processing statistics

**Example Usage:**
```javascript
const processor = new WhatsAppActorProcessor();
await processor.processAllWhatsAppMessages();
```

### **3. Validation (`scripts/validate-actor-matching.js`)**

**Core Class:** `ActorMatchingValidator`

**Key Methods:**
- `runValidation()` - Run all validation checks
- `validateActorCounts()` - Check actor and signal counts
- `validateSignalLinking()` - Check for orphaned signals
- `validateIdentifierMatching()` - Check identifier quality
- `validateConfidenceScores()` - Check confidence distribution

**Example Usage:**
```javascript
const validator = new ActorMatchingValidator();
await validator.runValidation();
```

## 📊 **Expected Results**

### **WhatsApp Processing (1,540+ messages)**
- **~100-200 unique actors** identified
- **95%+ success rate** for phone number matches
- **80%+ success rate** for name matches
- **Complete audit trail** of all matching decisions

### **Actor Profile Quality**
- **High confidence actors**: 60-70% (exact phone/email matches)
- **Medium confidence actors**: 20-30% (fuzzy name matches)
- **Low confidence actors**: 10-20% (behavioral matches)

### **Signal Linking**
- **All WhatsApp messages** linked to actors
- **Google reviews** linked where possible
- **Orders** linked via phone/email
- **No orphaned signals** (all signals have actors)

## 🚀 **Execution Steps**

### **Step 1: Set Up Database**
```sql
-- Run migration 027
-- Creates actors schema and all tables
```

### **Step 2: Configure Environment**
```bash
# Set environment variables
export SUPABASE_URL="your_supabase_url"
export SUPABASE_SERVICE_ROLE_KEY="your_service_role_key"
```

### **Step 3: Process WhatsApp Messages**
```bash
# Run WhatsApp actor processing
node scripts/process-whatsapp-actors.js
```

### **Step 4: Validate Results**
```bash
# Run validation
node scripts/validate-actor-matching.js
```

### **Step 5: Review Results**
```sql
-- Check actor counts
SELECT COUNT(*) FROM actors.actors;

-- Check signal linking
SELECT COUNT(*) FROM actors.actor_signals;

-- Check top actors
SELECT 
  primary_name,
  primary_phone,
  signal_count,
  profile_completeness,
  confidence_in_identity
FROM actors.actors 
ORDER BY signal_count DESC 
LIMIT 10;
```

## 🎯 **Success Criteria**

### **Quantitative Metrics**
- ✅ All 1,540+ WhatsApp messages processed
- ✅ 95%+ success rate for phone number matches
- ✅ 80%+ success rate for name matches
- ✅ <5% false positive rate
- ✅ Complete audit trail of all matches

### **Qualitative Metrics**
- ✅ Actor profiles are useful and accurate
- ✅ Signal linking is logical and consistent
- ✅ Confidence scores correlate with accuracy
- ✅ System ready for Stage 2 (Belief Extraction)

## 🔄 **Next Steps**

After Stage 1 completion:
- **Stage 2**: Belief Extraction Engine
- **Stage 3**: Bayesian Profile Builder
- **Stage 4**: Contradiction Detector
- **Stage 5**: Actor Intelligence Dashboard

## 🐛 **Troubleshooting**

### **Common Issues**

**1. Low Success Rate**
- Check phone number normalization
- Verify identifier extraction logic
- Review confidence scoring

**2. Duplicate Actors**
- Check fuzzy matching logic
- Review name similarity algorithm
- Implement duplicate detection

**3. Orphaned Signals**
- Check signal linking logic
- Verify signal type mapping
- Review error handling

### **Debug Queries**

```sql
-- Find actors with low confidence
SELECT * FROM actors.actors WHERE confidence_in_identity < 0.5;

-- Find potential duplicates
SELECT 
  identifier_value,
  COUNT(*) as count,
  ARRAY_AGG(actor_id) as actor_ids
FROM actors.actor_identifiers 
WHERE identifier_type = 'phone'
GROUP BY identifier_value 
HAVING COUNT(*) > 1;

-- Find orphaned signals
SELECT 
  w.signal_id,
  w.sender_phone,
  w.message_timestamp
FROM signals.whatsapp_messages w
LEFT JOIN actors.actor_signals a ON w.signal_id = a.signal_id
WHERE a.signal_id IS NULL;
```

## 📈 **Performance Optimization**

### **Batch Processing**
- Process signals in batches of 100
- Use database transactions for consistency
- Implement retry logic for failed signals

### **Caching**
- Cache actor lookups for performance
- Use Map for identifier matching
- Implement connection pooling

### **Monitoring**
- Track processing statistics
- Monitor error rates
- Log performance metrics

## 🎉 **Stage 1 Complete!**

When Stage 1 is complete, you'll have:
- ✅ **100-200 unique actor profiles** with complete identity information
- ✅ **All signals linked** to appropriate actors
- ✅ **Confidence scores** for all matches
- ✅ **Complete audit trail** of matching decisions
- ✅ **Foundation ready** for Stage 2 (Belief Extraction)

**Ready to extract beliefs from these actor profiles!** 🚀
