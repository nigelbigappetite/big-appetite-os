#!/usr/bin/env node

/**
 * Stage 1: Actor Identification & Matching
 * Main execution script for Stage 1
 */

const { createClient } = require('@supabase/supabase-js');
const { IdentityResolver } = require('./identity-resolver');
const { WhatsAppActorProcessor } = require('./process-whatsapp-actors');
const { ActorMatchingValidator } = require('./validate-actor-matching');

// You'll need to set these environment variables
const supabaseUrl = process.env.SUPABASE_URL || 'your_supabase_url_here';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'your_service_role_key_here';

const supabase = createClient(supabaseUrl, supabaseKey);

class Stage1Executor {
  constructor() {
    this.startTime = new Date();
    this.results = {
      actorsCreated: 0,
      signalsProcessed: 0,
      successRate: 0,
      errors: []
    };
  }

  /**
   * Run complete Stage 1 process
   */
  async runStage1() {
    console.log('🚀 Starting Stage 1: Actor Identification & Matching\n');
    console.log('=' * 60);
    console.log('Stage 1: Transform raw signals into structured actor profiles');
    console.log('=' * 60);
    console.log('');

    try {
      // Step 1: Check database connection
      await this.checkDatabaseConnection();

      // Step 2: Check if actors schema exists
      await this.checkActorsSchema();

      // Step 3: Analyze WhatsApp data
      await this.analyzeWhatsAppData();

      // Step 4: Process WhatsApp messages
      await this.processWhatsAppMessages();

      // Step 5: Validate results
      await this.validateResults();

      // Step 6: Show final results
      this.showFinalResults();

    } catch (error) {
      console.error('❌ Stage 1 failed:', error);
      this.results.errors.push(error.message);
      process.exit(1);
    }
  }

  /**
   * Check database connection
   */
  async checkDatabaseConnection() {
    console.log('🔌 Checking database connection...');
    
    try {
      const { data, error } = await supabase
        .from('signals.whatsapp_messages')
        .select('signal_id')
        .limit(1);

      if (error) {
        throw new Error(`Database connection failed: ${error.message}`);
      }

      console.log('   ✅ Database connection successful\n');
    } catch (error) {
      throw new Error(`Database connection failed: ${error.message}`);
    }
  }

  /**
   * Check if actors schema exists
   */
  async checkActorsSchema() {
    console.log('🏗️  Checking actors schema...');
    
    try {
      const { data, error } = await supabase
        .from('actors.actors')
        .select('actor_id')
        .limit(1);

      if (error && error.code === 'PGRST106') {
        throw new Error('Actors schema not found. Please run migration 027 first.');
      }

      console.log('   ✅ Actors schema exists\n');
    } catch (error) {
      throw new Error(`Actors schema check failed: ${error.message}`);
    }
  }

  /**
   * Analyze WhatsApp data
   */
  async analyzeWhatsAppData() {
    console.log('📊 Analyzing WhatsApp data...');
    
    try {
      // Get total message count
      const { count: totalMessages } = await supabase
        .from('signals.whatsapp_messages')
        .select('*', { count: 'exact', head: true });

      // Get unique phone count
      const { data: phoneData } = await supabase
        .from('signals.whatsapp_messages')
        .select('sender_phone')
        .not('sender_phone', 'is', null);

      const uniquePhones = new Set(phoneData?.map(m => m.sender_phone) || []);

      console.log(`   📱 Total WhatsApp messages: ${totalMessages || 0}`);
      console.log(`   👥 Unique phone numbers: ${uniquePhones.size}`);
      console.log(`   📈 Average messages per phone: ${uniquePhones.size > 0 ? ((totalMessages || 0) / uniquePhones.size).toFixed(1) : 0}\n`);

      this.results.signalsProcessed = totalMessages || 0;
    } catch (error) {
      throw new Error(`WhatsApp data analysis failed: ${error.message}`);
    }
  }

  /**
   * Process WhatsApp messages
   */
  async processWhatsAppMessages() {
    console.log('🔄 Processing WhatsApp messages...');
    
    try {
      const processor = new WhatsAppActorProcessor();
      await processor.processAllWhatsAppMessages();
      
      // Get final actor count
      const { count: actorCount } = await supabase
        .from('actors.actors')
        .select('*', { count: 'exact', head: true });

      this.results.actorsCreated = actorCount || 0;
      console.log(`   ✅ Created ${this.results.actorsCreated} actors\n`);
    } catch (error) {
      throw new Error(`WhatsApp processing failed: ${error.message}`);
    }
  }

  /**
   * Validate results
   */
  async validateResults() {
    console.log('🔍 Validating results...');
    
    try {
      const validator = new ActorMatchingValidator();
      await validator.runValidation();
      console.log('   ✅ Validation complete\n');
    } catch (error) {
      throw new Error(`Validation failed: ${error.message}`);
    }
  }

  /**
   * Show final results
   */
  showFinalResults() {
    const endTime = new Date();
    const duration = Math.round((endTime - this.startTime) / 1000);

    console.log('🎉 Stage 1 Complete!\n');
    console.log('=' * 60);
    console.log('FINAL RESULTS');
    console.log('=' * 60);
    console.log(`⏱️  Duration: ${duration} seconds`);
    console.log(`📱 Signals processed: ${this.results.signalsProcessed}`);
    console.log(`👥 Actors created: ${this.results.actorsCreated}`);
    console.log(`📈 Success rate: ${this.results.signalsProcessed > 0 ? ((this.results.actorsCreated / this.results.signalsProcessed) * 100).toFixed(1) : 0}%`);

    if (this.results.errors.length > 0) {
      console.log(`\n❌ Errors: ${this.results.errors.length}`);
      this.results.errors.forEach(error => {
        console.log(`   - ${error}`);
      });
    } else {
      console.log('\n✅ No errors!');
    }

    console.log('\n🎯 Next Steps:');
    console.log('   1. Review actor profiles in database');
    console.log('   2. Check for any potential duplicates');
    console.log('   3. Proceed to Stage 2: Belief Extraction');
    console.log('\n🚀 Ready for Stage 2!');
  }
}

// Run if called directly
if (require.main === module) {
  const executor = new Stage1Executor();
  
  executor.runStage1()
    .then(() => {
      console.log('✅ Stage 1 execution complete!');
      process.exit(0);
    })
    .catch(error => {
      console.error('❌ Stage 1 execution failed:', error);
      process.exit(1);
    });
}

module.exports = { Stage1Executor };
