#!/usr/bin/env node

/**
 * Stage 1: Actor Identification
 * Process all WhatsApp messages to create actors
 */

const { createClient } = require('@supabase/supabase-js');
const { IdentityResolver } = require('./identity-resolver');

// You'll need to set these environment variables
const supabaseUrl = process.env.SUPABASE_URL || 'your_supabase_url_here';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'your_service_role_key_here';

const supabase = createClient(supabaseUrl, supabaseKey);

class WhatsAppActorProcessor {
  constructor() {
    this.resolver = new IdentityResolver();
    this.stats = {
      processed: 0,
      matched: 0,
      created: 0,
      failed: 0,
      errors: []
    };
  }

  /**
   * Process all WhatsApp messages in batches
   */
  async processAllWhatsAppMessages() {
    console.log('🚀 Starting WhatsApp actor processing...\n');
    
    const batchSize = 100;
    let offset = 0;
    let hasMore = true;

    while (hasMore) {
      console.log(`📦 Processing batch ${Math.floor(offset / batchSize) + 1}...`);
      
      try {
        // Get batch of WhatsApp messages
        const { data: messages, error } = await supabase
          .from('signals.whatsapp_messages')
          .select('*')
          .order('message_timestamp', { ascending: true })
          .range(offset, offset + batchSize - 1);

        if (error) {
          console.error('❌ Error fetching messages:', error);
          break;
        }

        if (!messages || messages.length === 0) {
          hasMore = false;
          break;
        }

        // Process each message
        for (const message of messages) {
          await this.processMessage(message);
        }

        offset += batchSize;
        hasMore = messages.length === batchSize;

        // Show progress
        console.log(`   ✅ Processed ${messages.length} messages`);
        console.log(`   📊 Stats: ${this.stats.processed} total, ${this.stats.matched} matched, ${this.stats.created} created, ${this.stats.failed} failed\n`);

      } catch (error) {
        console.error('❌ Error processing batch:', error);
        this.stats.errors.push(error.message);
        break;
      }
    }

    // Show final results
    this.showFinalResults();
  }

  /**
   * Process a single WhatsApp message
   */
  async processMessage(message) {
    try {
      this.stats.processed++;

      // Check if already processed
      const { data: existingLink } = await supabase
        .from('actors.actor_signals')
        .select('link_id')
        .eq('signal_id', message.signal_id)
        .eq('signal_type', 'whatsapp_message')
        .single();

      if (existingLink) {
        console.log(`   ⏭️  Already processed: ${message.signal_id}`);
        return;
      }

      // Process with identity resolver
      const result = await this.resolver.processSignal(message);

      if (result.action === 'matched') {
        this.stats.matched++;
        console.log(`   ✅ Matched to actor: ${result.actor_id}`);
      } else if (result.action === 'created') {
        this.stats.created++;
        console.log(`   ➕ Created new actor: ${result.actor_id}`);
      } else {
        this.stats.failed++;
        console.log(`   ❌ Failed to process: ${message.signal_id}`);
      }

    } catch (error) {
      console.error(`❌ Error processing message ${message.signal_id}:`, error);
      this.stats.errors.push(`${message.signal_id}: ${error.message}`);
      this.stats.failed++;
    }
  }

  /**
   * Show final processing results
   */
  showFinalResults() {
    console.log('\n🎉 WhatsApp Actor Processing Complete!\n');
    console.log('📊 Final Statistics:');
    console.log(`   Total processed: ${this.stats.processed}`);
    console.log(`   Matched to existing: ${this.stats.matched}`);
    console.log(`   Created new: ${this.stats.created}`);
    console.log(`   Failed: ${this.stats.failed}`);
    console.log(`   Success rate: ${((this.stats.matched + this.stats.created) / this.stats.processed * 100).toFixed(1)}%`);

    if (this.stats.errors.length > 0) {
      console.log(`\n❌ Errors (${this.stats.errors.length}):`);
      this.stats.errors.slice(0, 10).forEach(error => {
        console.log(`   ${error}`);
      });
      if (this.stats.errors.length > 10) {
        console.log(`   ... and ${this.stats.errors.length - 10} more`);
      }
    }

    // Show actor summary
    this.showActorSummary();
  }

  /**
   * Show summary of created actors
   */
  async showActorSummary() {
    try {
      const { data: actors, error } = await supabase
        .from('actors.actors')
        .select(`
          actor_id,
          primary_phone,
          primary_name,
          signal_count,
          signal_sources,
          profile_completeness,
          confidence_in_identity,
          first_seen,
          last_seen
        `)
        .order('signal_count', { ascending: false })
        .limit(10);

      if (error) {
        console.error('Error fetching actor summary:', error);
        return;
      }

      console.log('\n👥 Top 10 Most Active Actors:');
      actors.forEach((actor, i) => {
        console.log(`   ${i + 1}. ${actor.primary_name || 'Unknown'} (${actor.primary_phone})`);
        console.log(`      Signals: ${actor.signal_count}, Sources: ${actor.signal_sources.join(', ')}`);
        console.log(`      Completeness: ${(actor.profile_completeness * 100).toFixed(1)}%, Confidence: ${(actor.confidence_in_identity * 100).toFixed(1)}%`);
        console.log(`      First seen: ${actor.first_seen}, Last seen: ${actor.last_seen}`);
        console.log('');
      });

      // Show total actor count
      const { count: totalActors } = await supabase
        .from('actors.actors')
        .select('*', { count: 'exact', head: true });

      console.log(`📈 Total actors created: ${totalActors}`);

    } catch (error) {
      console.error('Error showing actor summary:', error);
    }
  }
}

// Run if called directly
if (require.main === module) {
  const processor = new WhatsAppActorProcessor();
  
  processor.processAllWhatsAppMessages()
    .then(() => {
      console.log('✅ Processing complete!');
      process.exit(0);
    })
    .catch(error => {
      console.error('❌ Processing failed:', error);
      process.exit(1);
    });
}

module.exports = { WhatsAppActorProcessor };
