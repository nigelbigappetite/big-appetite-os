import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM';

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

/**
 * Unified Context Access Layer
 * Merges brand identity from Supabase storage with live state from brand_markov_blankets
 */
export async function loadBrandContext(brandId) {
  console.log(`🔍 Loading unified brand context for ${brandId}...`);

  try {
    // Step 1: Fetch brand card JSON from Supabase Storage
    console.log('📋 Fetching brand card from storage...');
    const { data: brandCardData, error: storageError } = await supabase.storage
      .from('brand cards')
      .download(`${brandId}.json`);

    if (storageError) {
      console.warn(`⚠️ Could not fetch brand card: ${storageError.message}`);
    }

    let brandIdentity = {};
    if (brandCardData) {
      const brandCardText = await brandCardData.text();
      brandIdentity = JSON.parse(brandCardText);
      console.log('✅ Brand card loaded successfully');
    } else {
      // Fallback brand identity if no card exists - using real data
      brandIdentity = {
        brand_name: "Wing Shack Co",
        voice_tone: "casual, authentic, conversational",
        currency: "£",
        channel_bias: {
          instagram: 0.8,
          tiktok: 0.6,
          facebook: 0.4
        },
        offers: {
          hero: "Buy 1 Get 1 Half Price"
        },
        brand_values: ["quality", "community", "authenticity", "consistency"]
      };
      console.log('📝 Using fallback brand identity');
    }

    // Step 2: Fetch real offers from copy_generator table
    console.log('🎯 Fetching real offers from database...');
    const { data: offersData, error: offersError } = await supabase
      .from('copy_generator')
      .select('offer, hook, caption, cta, creative_type')
      .eq('brand_id', brandId)
      .not('offer', 'is', null)
      .order('created_at', { ascending: false })
      .limit(5);

    let realOffers = [];
    if (!offersError && offersData && offersData.length > 0) {
      realOffers = offersData.map(item => ({
        offer: item.offer,
        hook: item.hook,
        caption: item.caption,
        cta: item.cta,
        type: item.creative_type
      }));
      console.log(`✅ Found ${realOffers.length} real offers`);
    } else {
      console.log('⚠️ No real offers found, using fallback');
    }

    // Step 3: Fetch latest Markov Blanket from database
    console.log('🧠 Fetching latest Markov Blanket...');
    const { data: markovData, error: markovError } = await supabase
      .from('brand_markov_blankets')
      .select('*')
      .eq('brand_id', brandId)
      .order('last_updated', { ascending: false })
      .limit(1)
      .single();

    if (markovError) {
      console.warn(`⚠️ Could not fetch Markov Blanket: ${markovError.message}`);
    }

    let brandState = {};
    if (markovData) {
      brandState = {
        collapse_vectors: markovData.stimuli_clusters || {},
        emotional_state: markovData.emotional_state || {},
        stimuli_feedback: markovData.stimuli_clusters || {},
        signal_weights: markovData.signal_weights || {},
        content_performance: markovData.recent_insights || {},
        next_content_focus: markovData.next_content_focus || "general content"
      };
      console.log('✅ Markov Blanket loaded successfully');
    } else {
      // Fallback brand state if no Markov Blanket exists
      brandState = {
        collapse_vectors: { belief_clusters: [] },
        emotional_state: { joy: 0.5, anger: 0.1, surprise: 0.3, anticipation: 0.4 },
        stimuli_feedback: { belief_clusters: [] },
        signal_weights: { trust: 0.25, desire: 0.25, belonging: 0.25, certainty: 0.25 },
        content_performance: { summary: "No recent data available" },
        next_content_focus: "general content"
      };
      console.log('📝 Using fallback brand state');
    }

    // Step 4: Merge contexts into unified object
    const mergedContext = {
      brand_identity: {
        brand_name: brandIdentity.brand_name || "Wing Shack Co",
        voice_tone: brandIdentity.voice_tone || "casual, authentic, conversational",
        currency: brandIdentity.currency || "£",
        channel_bias: brandIdentity.channel_bias || { instagram: 0.8, tiktok: 0.6, facebook: 0.4 },
        offers: brandIdentity.offers || { hero: "Buy 1 Get 1 Half Price" },
        brand_values: brandIdentity.brand_values || ["quality", "community", "authenticity", "consistency"],
        real_offers: realOffers
      },
      brand_state: {
        collapse_vectors: brandState.collapse_vectors,
        emotional_state: brandState.emotional_state,
        stimuli_feedback: brandState.stimuli_feedback,
        signal_weights: brandState.signal_weights,
        content_performance: brandState.content_performance,
        next_content_focus: brandState.next_content_focus
      }
    };

    console.log('🎯 Brand context loaded successfully');
    console.log(`📊 Brand: ${mergedContext.brand_identity.brand_name}`);
    console.log(`💰 Currency: ${mergedContext.brand_identity.currency}`);
    console.log(`🎯 Real Offers: ${mergedContext.brand_identity.real_offers.length} found`);
    console.log(`😊 Emotional State: ${Object.keys(mergedContext.brand_state.emotional_state).join(', ')}`);
    console.log(`🎯 Next Focus: ${mergedContext.brand_state.next_content_focus}`);

    return mergedContext;

  } catch (error) {
    console.error('❌ Error loading brand context:', error.message);
    throw error;
  }
}

/**
 * Get the primary emotional state for content generation
 */
export function getPrimaryEmotionalState(brandContext) {
  const emotions = brandContext.brand_state.emotional_state;
  if (!emotions) return 'balanced';

  const sortedEmotions = Object.entries(emotions)
    .sort(([,a], [,b]) => b - a);
  
  const primaryEmotion = sortedEmotions[0][0];
  const primaryValue = sortedEmotions[0][1];
  
  // Only return the emotion if it's significantly dominant
  if (primaryValue > 0.6) {
    return primaryEmotion;
  }
  
  return 'balanced';
}

/**
 * Get the dominant signal weight for content focus
 */
export function getDominantSignalWeight(brandContext) {
  const weights = brandContext.brand_state.signal_weights;
  if (!weights) return 'belonging';

  const sortedWeights = Object.entries(weights)
    .sort(([,a], [,b]) => b - a);
  
  return sortedWeights[0][0];
}

/**
 * Get the best platform for content based on channel bias
 */
export function getBestPlatform(brandContext) {
  const channelBias = brandContext.brand_identity.channel_bias;
  if (!channelBias) return 'instagram';

  const sortedChannels = Object.entries(channelBias)
    .sort(([,a], [,b]) => b - a);
  
  return sortedChannels[0][0];
}

/**
 * Get platform-specific dimensions (DALL-E compatible)
 */
export function getPlatformDimensions(platform) {
  const dimensions = {
    instagram: { ratio: '1:1', width: 1024, height: 1024, dall_e_size: '1024x1024' },
    tiktok: { ratio: '9:16', width: 1024, height: 1792, dall_e_size: '1024x1792' },
    facebook: { ratio: '4:5', width: 1024, height: 1024, dall_e_size: '1024x1024' },
    linkedin: { ratio: '1.91:1', width: 1792, height: 1024, dall_e_size: '1792x1024' },
    email: { ratio: '3:1', width: 1792, height: 1024, dall_e_size: '1792x1024' }
  };
  
  return dimensions[platform] || dimensions.instagram;
}
