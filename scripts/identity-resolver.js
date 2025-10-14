#!/usr/bin/env node

/**
 * Stage 1: Actor Identification
 * Identity Resolver - Match signals to actors across different sources
 */

const { createClient } = require('@supabase/supabase-js');

// You'll need to set these environment variables
const supabaseUrl = process.env.SUPABASE_URL || 'your_supabase_url_here';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'your_service_role_key_here';

const supabase = createClient(supabaseUrl, supabaseKey);

/**
 * Identity Resolver Class
 * Handles matching signals to actors with confidence scoring
 */
class IdentityResolver {
  constructor() {
    this.matchCache = new Map(); // Cache for performance
  }

  /**
   * Extract identifiers from a signal
   */
  extractIdentifiers(signal) {
    const identifiers = {
      phone: null,
      email: null,
      name: null,
      order_id: null
    };

    // Extract phone number
    if (signal.sender_phone) {
      identifiers.phone = this.normalizePhone(signal.sender_phone);
    }

    // Extract email
    if (signal.email) {
      identifiers.email = signal.email.toLowerCase().trim();
    }

    // Extract name
    if (signal.reviewer_name) {
      identifiers.name = this.normalizeName(signal.reviewer_name);
    }

    // Extract order ID
    if (signal.order_id) {
      identifiers.order_id = signal.order_id;
    }

    return identifiers;
  }

  /**
   * Normalize phone number for consistent matching
   */
  normalizePhone(phone) {
    if (!phone) return null;
    
    // Remove all non-digits
    const digits = phone.replace(/\D/g, '');
    
    // Handle UK numbers
    if (digits.startsWith('44')) {
      return '+' + digits;
    } else if (digits.startsWith('0')) {
      return '+44' + digits.substring(1);
    } else if (digits.length === 10) {
      return '+44' + digits;
    }
    
    return '+' + digits;
  }

  /**
   * Normalize name for fuzzy matching
   */
  normalizeName(name) {
    if (!name) return null;
    
    return name
      .toLowerCase()
      .trim()
      .replace(/[^\w\s]/g, '') // Remove special characters
      .replace(/\s+/g, ' '); // Normalize whitespace
  }

  /**
   * Find existing actor by identifiers
   */
  async findExistingActor(identifiers) {
    const matches = [];

    // Tier 1: High Confidence (0.95+)
    if (identifiers.phone) {
      const phoneMatch = await this.findByPhone(identifiers.phone);
      if (phoneMatch) {
        matches.push({
          actor_id: phoneMatch.actor_id,
          confidence: 0.98,
          method: 'exact_phone',
          identifiers: ['phone']
        });
      }
    }

    if (identifiers.email) {
      const emailMatch = await this.findByEmail(identifiers.email);
      if (emailMatch) {
        matches.push({
          actor_id: emailMatch.actor_id,
          confidence: 0.95,
          method: 'exact_email',
          identifiers: ['email']
        });
      }
    }

    // Tier 2: Medium Confidence (0.70-0.94)
    if (identifiers.name) {
      const nameMatches = await this.findByName(identifiers.name);
      nameMatches.forEach(match => {
        matches.push({
          actor_id: match.actor_id,
          confidence: match.confidence,
          method: 'fuzzy_name',
          identifiers: ['name']
        });
      });
    }

    // Return best match
    if (matches.length > 0) {
      return matches.sort((a, b) => b.confidence - a.confidence)[0];
    }

    return null;
  }

  /**
   * Find actor by exact phone match
   */
  async findByPhone(phone) {
    const { data, error } = await supabase
      .from('actors.actors')
      .select('actor_id, primary_phone')
      .eq('primary_phone', phone)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('Error finding by phone:', error);
      return null;
    }

    return data;
  }

  /**
   * Find actor by exact email match
   */
  async findByEmail(email) {
    const { data, error } = await supabase
      .from('actors.actors')
      .select('actor_id, primary_email')
      .eq('primary_email', email)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('Error finding by email:', error);
      return null;
    }

    return data;
  }

  /**
   * Find actor by fuzzy name match
   */
  async findByName(name) {
    const { data, error } = await supabase
      .from('actors.actor_identifiers')
      .select(`
        actor_id,
        identifier_value,
        identifier_confidence
      `)
      .eq('identifier_type', 'name')
      .ilike('identifier_value', `%${name}%`);

    if (error) {
      console.error('Error finding by name:', error);
      return [];
    }

    // Calculate fuzzy match confidence
    return data.map(match => ({
      actor_id: match.actor_id,
      confidence: this.calculateNameSimilarity(name, match.identifier_value) * match.identifier_confidence
    })).filter(match => match.confidence >= 0.7);
  }

  /**
   * Calculate name similarity (simple Levenshtein-based)
   */
  calculateNameSimilarity(name1, name2) {
    const s1 = name1.toLowerCase();
    const s2 = name2.toLowerCase();
    
    if (s1 === s2) return 1.0;
    if (s1.includes(s2) || s2.includes(s1)) return 0.8;
    
    // Simple similarity based on common words
    const words1 = s1.split(' ');
    const words2 = s2.split(' ');
    const commonWords = words1.filter(w => words2.includes(w));
    
    return commonWords.length / Math.max(words1.length, words2.length);
  }

  /**
   * Create new actor
   */
  async createNewActor(identifiers, signal) {
    const actorData = {
      primary_phone: identifiers.phone,
      primary_email: identifiers.email,
      primary_name: identifiers.name,
      first_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
      last_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
      signal_count: 1,
      signal_sources: [this.getSignalType(signal)],
      profile_completeness: this.calculateInitialCompleteness(identifiers),
      confidence_in_identity: this.calculateInitialConfidence(identifiers),
      identity_quality: this.calculateIdentityQuality(identifiers),
      created_from: this.getSignalType(signal),
      raw_metadata: {
        original_signal: signal
      }
    };

    const { data: actor, error } = await supabase
      .from('actors.actors')
      .insert(actorData)
      .select()
      .single();

    if (error) {
      console.error('Error creating actor:', error);
      return null;
    }

    // Add identifiers
    await this.addIdentifiers(actor.actor_id, identifiers, signal);

    return actor;
  }

  /**
   * Add identifiers to actor
   */
  async addIdentifiers(actorId, identifiers, signal) {
    const identifierData = [];

    if (identifiers.phone) {
      identifierData.push({
        actor_id: actorId,
        identifier_type: 'phone',
        identifier_value: identifiers.phone,
        identifier_confidence: 1.0,
        source_signal_id: signal.signal_id,
        source_signal_type: this.getSignalType(signal),
        first_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
        last_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
        is_verified: true,
        verification_method: 'exact_match'
      });
    }

    if (identifiers.email) {
      identifierData.push({
        actor_id: actorId,
        identifier_type: 'email',
        identifier_value: identifiers.email,
        identifier_confidence: 1.0,
        source_signal_id: signal.signal_id,
        source_signal_type: this.getSignalType(signal),
        first_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
        last_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
        is_verified: true,
        verification_method: 'exact_match'
      });
    }

    if (identifiers.name) {
      identifierData.push({
        actor_id: actorId,
        identifier_type: 'name',
        identifier_value: identifiers.name,
        identifier_confidence: 0.8,
        source_signal_id: signal.signal_id,
        source_signal_type: this.getSignalType(signal),
        first_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
        last_seen: signal.message_timestamp || signal.review_timestamp || signal.order_timestamp || new Date().toISOString(),
        is_verified: false,
        verification_method: 'fuzzy_match'
      });
    }

    if (identifierData.length > 0) {
      const { error } = await supabase
        .from('actors.actor_identifiers')
        .insert(identifierData);

      if (error) {
        console.error('Error adding identifiers:', error);
      }
    }
  }

  /**
   * Link signal to actor
   */
  async linkSignalToActor(actorId, signal, confidence, method, identifier) {
    const linkData = {
      actor_id: actorId,
      signal_id: signal.signal_id,
      signal_type: this.getSignalType(signal),
      signal_table: this.getSignalTable(signal),
      link_confidence: confidence,
      link_method: method,
      link_identifier: identifier
    };

    const { error } = await supabase
      .from('actors.actor_signals')
      .insert(linkData);

    if (error) {
      console.error('Error linking signal to actor:', error);
      return false;
    }

    // Update actor stats
    await supabase.rpc('update_actor_stats', { actor_uuid: actorId });

    return true;
  }

  /**
   * Get signal type from signal object
   */
  getSignalType(signal) {
    if (signal.sender_phone) return 'whatsapp_message';
    if (signal.reviewer_name) return 'google_review';
    if (signal.order_id) return 'order';
    return 'unknown';
  }

  /**
   * Get signal table from signal object
   */
  getSignalTable(signal) {
    if (signal.sender_phone) return 'signals.whatsapp_messages';
    if (signal.reviewer_name) return 'signals.reviews';
    if (signal.order_id) return 'signals.orders';
    return 'unknown';
  }

  /**
   * Calculate initial profile completeness
   */
  calculateInitialCompleteness(identifiers) {
    let completeness = 0.0;
    if (identifiers.phone) completeness += 0.3;
    if (identifiers.email) completeness += 0.2;
    if (identifiers.name) completeness += 0.2;
    completeness += 0.3; // First signal
    return Math.min(completeness, 1.0);
  }

  /**
   * Calculate initial confidence
   */
  calculateInitialConfidence(identifiers) {
    let confidence = 0.0;
    if (identifiers.phone) confidence += 0.4;
    if (identifiers.email) confidence += 0.3;
    if (identifiers.name) confidence += 0.2;
    confidence += 0.1; // Base confidence
    return Math.min(confidence, 1.0);
  }

  /**
   * Calculate identity quality
   */
  calculateIdentityQuality(identifiers) {
    if (identifiers.phone && identifiers.email) return 'high';
    if (identifiers.phone || identifiers.email) return 'medium';
    if (identifiers.name) return 'low';
    return 'unknown';
  }

  /**
   * Process a single signal
   */
  async processSignal(signal) {
    console.log(`🔍 Processing signal: ${signal.signal_id}`);
    
    // Extract identifiers
    const identifiers = this.extractIdentifiers(signal);
    console.log(`   Identifiers:`, identifiers);

    // Find existing actor
    const existingActor = await this.findExistingActor(identifiers);
    
    if (existingActor) {
      console.log(`   ✅ Found existing actor: ${existingActor.actor_id} (confidence: ${existingActor.confidence})`);
      
      // Link signal to existing actor
      await this.linkSignalToActor(
        existingActor.actor_id,
        signal,
        existingActor.confidence,
        existingActor.method,
        existingActor.identifiers[0]
      );
      
      return {
        action: 'matched',
        actor_id: existingActor.actor_id,
        confidence: existingActor.confidence,
        method: existingActor.method
      };
    } else {
      console.log(`   ➕ Creating new actor`);
      
      // Create new actor
      const newActor = await this.createNewActor(identifiers, signal);
      
      if (newActor) {
        // Link signal to new actor
        await this.linkSignalToActor(
          newActor.actor_id,
          signal,
          1.0,
          'created_new',
          'new_actor'
        );
        
        return {
          action: 'created',
          actor_id: newActor.actor_id,
          confidence: 1.0,
          method: 'created_new'
        };
      }
    }

    return {
      action: 'failed',
      actor_id: null,
      confidence: 0.0,
      method: 'failed'
    };
  }
}

// Export for use in other scripts
module.exports = { IdentityResolver };

// Run if called directly
if (require.main === module) {
  const resolver = new IdentityResolver();
  
  // Test with a sample signal
  const testSignal = {
    signal_id: 'test-123',
    sender_phone: '+447473880264',
    message_text: 'Test message',
    message_timestamp: new Date().toISOString()
  };
  
  resolver.processSignal(testSignal)
    .then(result => {
      console.log('Test result:', result);
    })
    .catch(error => {
      console.error('Test error:', error);
    });
}
