#!/usr/bin/env node

/**
 * Stage 1: Actor Identification
 * Validate actor matching accuracy and results
 */

const { createClient } = require('@supabase/supabase-js');

// You'll need to set these environment variables
const supabaseUrl = process.env.SUPABASE_URL || 'your_supabase_url_here';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'your_service_role_key_here';

const supabase = createClient(supabaseUrl, supabaseKey);

class ActorMatchingValidator {
  constructor() {
    this.validationResults = {
      totalActors: 0,
      totalSignals: 0,
      averageSignalsPerActor: 0,
      actorsWithMultipleSignals: 0,
      actorsWithSingleSignal: 0,
      phoneMatches: 0,
      emailMatches: 0,
      nameMatches: 0,
      highConfidenceMatches: 0,
      mediumConfidenceMatches: 0,
      lowConfidenceMatches: 0,
      potentialDuplicates: 0,
      errors: []
    };
  }

  /**
   * Run all validation checks
   */
  async runValidation() {
    console.log('🔍 Starting Actor Matching Validation...\n');

    try {
      await this.validateActorCounts();
      await this.validateSignalLinking();
      await this.validateIdentifierMatching();
      await this.validateConfidenceScores();
      await this.validatePotentialDuplicates();
      await this.validateDataQuality();

      this.showValidationResults();

    } catch (error) {
      console.error('❌ Validation failed:', error);
      this.validationResults.errors.push(error.message);
    }
  }

  /**
   * Validate actor and signal counts
   */
  async validateActorCounts() {
    console.log('📊 Validating actor and signal counts...');

    // Get total actors
    const { count: totalActors } = await supabase
      .from('actors.actors')
      .select('*', { count: 'exact', head: true });

    // Get total signals linked
    const { count: totalSignals } = await supabase
      .from('actors.actor_signals')
      .select('*', { count: 'exact', head: true });

    // Get actors with multiple signals
    const { data: multiSignalActors } = await supabase
      .from('actors.actors')
      .select('actor_id, signal_count')
      .gt('signal_count', 1);

    // Get actors with single signal
    const { data: singleSignalActors } = await supabase
      .from('actors.actors')
      .select('actor_id, signal_count')
      .eq('signal_count', 1);

    this.validationResults.totalActors = totalActors || 0;
    this.validationResults.totalSignals = totalSignals || 0;
    this.validationResults.averageSignalsPerActor = totalActors > 0 ? (totalSignals / totalActors).toFixed(2) : 0;
    this.validationResults.actorsWithMultipleSignals = multiSignalActors?.length || 0;
    this.validationResults.actorsWithSingleSignal = singleSignalActors?.length || 0;

    console.log(`   ✅ Total actors: ${this.validationResults.totalActors}`);
    console.log(`   ✅ Total signals linked: ${this.validationResults.totalSignals}`);
    console.log(`   ✅ Average signals per actor: ${this.validationResults.averageSignalsPerActor}`);
    console.log(`   ✅ Actors with multiple signals: ${this.validationResults.actorsWithMultipleSignals}`);
    console.log(`   ✅ Actors with single signal: ${this.validationResults.actorsWithSingleSignal}\n`);
  }

  /**
   * Validate signal linking
   */
  async validateSignalLinking() {
    console.log('🔗 Validating signal linking...');

    // Check for orphaned signals (signals without actors)
    const { data: orphanedSignals } = await supabase
      .from('signals.whatsapp_messages')
      .select('signal_id')
      .not('signal_id', 'in', `(SELECT signal_id FROM actors.actor_signals WHERE signal_type = 'whatsapp_message')`);

    // Check for duplicate signal links
    const { data: duplicateLinks } = await supabase
      .from('actors.actor_signals')
      .select('signal_id, signal_type, COUNT(*) as link_count')
      .eq('signal_type', 'whatsapp_message')
      .group('signal_id, signal_type')
      .having('COUNT(*) > 1');

    console.log(`   ✅ Orphaned signals: ${orphanedSignals?.length || 0}`);
    console.log(`   ✅ Duplicate signal links: ${duplicateLinks?.length || 0}\n`);

    if (orphanedSignals && orphanedSignals.length > 0) {
      this.validationResults.errors.push(`${orphanedSignals.length} orphaned signals found`);
    }

    if (duplicateLinks && duplicateLinks.length > 0) {
      this.validationResults.errors.push(`${duplicateLinks.length} duplicate signal links found`);
    }
  }

  /**
   * Validate identifier matching
   */
  async validateIdentifierMatching() {
    console.log('🆔 Validating identifier matching...');

    // Count identifier types
    const { data: identifierCounts } = await supabase
      .from('actors.actor_identifiers')
      .select('identifier_type, COUNT(*) as count')
      .group('identifier_type');

    // Count phone matches
    const { count: phoneMatches } = await supabase
      .from('actors.actor_identifiers')
      .select('*', { count: 'exact', head: true })
      .eq('identifier_type', 'phone');

    // Count email matches
    const { count: emailMatches } = await supabase
      .from('actors.actor_identifiers')
      .select('*', { count: 'exact', head: true })
      .eq('identifier_type', 'email');

    // Count name matches
    const { count: nameMatches } = await supabase
      .from('actors.actor_identifiers')
      .select('*', { count: 'exact', head: true })
      .eq('identifier_type', 'name');

    this.validationResults.phoneMatches = phoneMatches || 0;
    this.validationResults.emailMatches = emailMatches || 0;
    this.validationResults.nameMatches = nameMatches || 0;

    console.log(`   ✅ Phone identifiers: ${this.validationResults.phoneMatches}`);
    console.log(`   ✅ Email identifiers: ${this.validationResults.emailMatches}`);
    console.log(`   ✅ Name identifiers: ${this.validationResults.nameMatches}`);

    if (identifierCounts) {
      identifierCounts.forEach(type => {
        console.log(`   ✅ ${type.identifier_type}: ${type.count}`);
      });
    }
    console.log('');
  }

  /**
   * Validate confidence scores
   */
  async validateConfidenceScores() {
    console.log('📈 Validating confidence scores...');

    // Get confidence distribution
    const { data: confidenceData } = await supabase
      .from('actors.actor_signals')
      .select('link_confidence')
      .eq('signal_type', 'whatsapp_message');

    if (confidenceData) {
      const highConfidence = confidenceData.filter(c => c.link_confidence >= 0.8).length;
      const mediumConfidence = confidenceData.filter(c => c.link_confidence >= 0.5 && c.link_confidence < 0.8).length;
      const lowConfidence = confidenceData.filter(c => c.link_confidence < 0.5).length;

      this.validationResults.highConfidenceMatches = highConfidence;
      this.validationResults.mediumConfidenceMatches = mediumConfidence;
      this.validationResults.lowConfidenceMatches = lowConfidence;

      console.log(`   ✅ High confidence (≥0.8): ${highConfidence}`);
      console.log(`   ✅ Medium confidence (0.5-0.8): ${mediumConfidence}`);
      console.log(`   ✅ Low confidence (<0.5): ${lowConfidence}`);

      const avgConfidence = confidenceData.reduce((sum, c) => sum + c.link_confidence, 0) / confidenceData.length;
      console.log(`   ✅ Average confidence: ${avgConfidence.toFixed(3)}\n`);
    }
  }

  /**
   * Validate potential duplicates
   */
  async validatePotentialDuplicates() {
    console.log('🔍 Checking for potential duplicates...');

    // Find actors with similar phone numbers
    const { data: similarPhones } = await supabase
      .from('actors.actor_identifiers')
      .select('actor_id, identifier_value')
      .eq('identifier_type', 'phone');

    if (similarPhones) {
      const phoneGroups = {};
      similarPhones.forEach(phone => {
        const normalized = phone.identifier_value.replace(/\D/g, '');
        if (!phoneGroups[normalized]) {
          phoneGroups[normalized] = [];
        }
        phoneGroups[normalized].push(phone);
      });

      const duplicates = Object.values(phoneGroups).filter(group => group.length > 1);
      this.validationResults.potentialDuplicates = duplicates.length;

      console.log(`   ✅ Potential phone duplicates: ${duplicates.length}`);
      
      if (duplicates.length > 0) {
        console.log('   📋 Duplicate groups:');
        duplicates.forEach((group, i) => {
          console.log(`      Group ${i + 1}: ${group.map(p => p.actor_id).join(', ')}`);
        });
      }
    }

    console.log('');
  }

  /**
   * Validate data quality
   */
  async validateDataQuality() {
    console.log('🎯 Validating data quality...');

    // Check for actors with no identifiers
    const { data: actorsNoIds } = await supabase
      .from('actors.actors')
      .select('actor_id')
      .not('actor_id', 'in', `(SELECT DISTINCT actor_id FROM actors.actor_identifiers)`);

    // Check for actors with low confidence
    const { data: lowConfidenceActors } = await supabase
      .from('actors.actors')
      .select('actor_id, confidence_in_identity')
      .lt('confidence_in_identity', 0.5);

    // Check for actors with low completeness
    const { data: lowCompletenessActors } = await supabase
      .from('actors.actors')
      .select('actor_id, profile_completeness')
      .lt('profile_completeness', 0.3);

    console.log(`   ✅ Actors with no identifiers: ${actorsNoIds?.length || 0}`);
    console.log(`   ✅ Actors with low confidence (<0.5): ${lowConfidenceActors?.length || 0}`);
    console.log(`   ✅ Actors with low completeness (<0.3): ${lowCompletenessActors?.length || 0}\n`);

    if (actorsNoIds && actorsNoIds.length > 0) {
      this.validationResults.errors.push(`${actorsNoIds.length} actors have no identifiers`);
    }
  }

  /**
   * Show validation results
   */
  showValidationResults() {
    console.log('🎉 Validation Complete!\n');
    console.log('📊 Summary Results:');
    console.log(`   Total actors created: ${this.validationResults.totalActors}`);
    console.log(`   Total signals linked: ${this.validationResults.totalSignals}`);
    console.log(`   Average signals per actor: ${this.validationResults.averageSignalsPerActor}`);
    console.log(`   Actors with multiple signals: ${this.validationResults.actorsWithMultipleSignals}`);
    console.log(`   High confidence matches: ${this.validationResults.highConfidenceMatches}`);
    console.log(`   Potential duplicates: ${this.validationResults.potentialDuplicates}`);

    if (this.validationResults.errors.length > 0) {
      console.log('\n❌ Issues Found:');
      this.validationResults.errors.forEach(error => {
        console.log(`   - ${error}`);
      });
    } else {
      console.log('\n✅ No issues found!');
    }

    // Overall assessment
    const successRate = this.validationResults.totalActors > 0 ? 
      ((this.validationResults.actorsWithMultipleSignals + this.validationResults.actorsWithSingleSignal) / this.validationResults.totalActors * 100).toFixed(1) : 0;
    
    console.log(`\n🎯 Overall Success Rate: ${successRate}%`);
    
    if (successRate >= 90) {
      console.log('🌟 Excellent! Actor matching is working very well.');
    } else if (successRate >= 70) {
      console.log('👍 Good! Actor matching is working well with room for improvement.');
    } else {
      console.log('⚠️  Needs improvement. Consider reviewing matching logic.');
    }
  }
}

// Run if called directly
if (require.main === module) {
  const validator = new ActorMatchingValidator();
  
  validator.runValidation()
    .then(() => {
      console.log('✅ Validation complete!');
      process.exit(0);
    })
    .catch(error => {
      console.error('❌ Validation failed:', error);
      process.exit(1);
    });
}

module.exports = { ActorMatchingValidator };
