/**
 * Real-time Markov Blanket Processor
 * Processes feedback data and updates Markov Blankets continuously
 */

import { createClient } from '@supabase/supabase-js';
import { randomUUID } from 'crypto';

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

/**
 * Process real-time feedback and update Markov Blanket
 */
export async function processRealtimeMarkovBlanket(brandId) {
  console.log(`🧠 Processing real-time Markov Blanket for ${brandId}...`);
  
  try {
    // Get recent feedback data (last 2 hours)
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString();
    
    const { data: recentFeedback, error: feedbackError } = await supabase
      .from('stimuli_feedback')
      .select('*')
      .eq('brand_id', brandId)
      .gte('created_at', twoHoursAgo)
      .order('created_at', { ascending: false });

    if (feedbackError) {
      console.error('❌ Error fetching feedback:', feedbackError.message);
      return { success: false, error: feedbackError.message };
    }

    if (!recentFeedback || recentFeedback.length === 0) {
      console.log('📊 No recent feedback to process');
      return { success: true, message: 'No recent feedback' };
    }

    // Get decoder log data for sentiment analysis
    const { data: decoderData, error: decoderError } = await supabase
      .from('decoder_log')
      .select('*')
      .eq('brand_id', brandId)
      .gte('created_at', twoHoursAgo)
      .order('created_at', { ascending: false });

    // Get existing Markov Blanket
    const { data: existingBlanket, error: blanketError } = await supabase
      .from('brand_markov_blankets')
      .select('*')
      .eq('brand_id', brandId)
      .order('updated_at', { ascending: false })
      .limit(1)
      .single();

    // Process the data
    const markovData = await analyzeAndCreateMarkovBlanket(
      recentFeedback, 
      decoderData || [], 
      existingBlanket
    );

    // Save updated Markov Blanket
    const { data: insertedBlanket, error: insertError } = await supabase
      .from('brand_markov_blankets')
      .upsert({
        brand_id: brandId,
        stimuli_clusters: markovData.stimuli_clusters,
        signal_weights: markovData.signal_weights,
        emotional_state: markovData.emotional_state,
        recent_insights: markovData.recent_insights,
        next_content_focus: markovData.next_content_focus,
        collapse_vectors: markovData.collapse_vectors,
        content_performance: markovData.content_performance,
        updated_at: new Date().toISOString()
      })
      .select();

    if (insertError) {
      console.error('❌ Error saving Markov Blanket:', insertError.message);
      return { success: false, error: insertError.message };
    }

    console.log('✅ Real-time Markov Blanket updated successfully');
    return { 
      success: true, 
      data: insertedBlanket[0],
      processedFeedback: recentFeedback.length,
      processedDecoder: decoderData?.length || 0
    };

  } catch (error) {
    console.error('❌ Real-time Markov processing failed:', error.message);
    return { success: false, error: error.message };
  }
}

/**
 * Analyze feedback and create Markov Blanket data
 */
async function analyzeAndCreateMarkovBlanket(feedbackData, decoderData, existingBlanket) {
  // Extract themes and patterns from feedback
  const themes = extractThemes(feedbackData);
  const language = extractLanguage(feedbackData);
  const contradictions = identifyContradictions(feedbackData);
  
  // Calculate emotional state
  const emotionalState = calculateEmotionalState(feedbackData, decoderData);
  
  // Calculate signal weights
  const signalWeights = calculateSignalWeights(feedbackData, decoderData);
  
  // Generate insights
  const recentInsights = generateRecentInsights(feedbackData, decoderData, themes, contradictions);
  
  // Determine next content focus
  const nextContentFocus = determineNextContentFocus(themes, emotionalState, signalWeights);
  
  // Create stimuli clusters
  const stimuliClusters = identifyStimuliClusters(feedbackData, decoderData, themes);
  
  // Calculate collapse vectors
  const collapseVectors = calculateCollapseVectors(feedbackData, themes, contradictions);
  
  // Calculate content performance
  const contentPerformance = calculateContentPerformance(feedbackData);

  return {
    stimuli_clusters: stimuliClusters,
    signal_weights: signalWeights,
    emotional_state: emotionalState,
    recent_insights: recentInsights,
    next_content_focus: nextContentFocus,
    collapse_vectors: collapseVectors,
    content_performance: contentPerformance
  };
}

/**
 * Extract themes from feedback data
 */
function extractThemes(feedbackData) {
  const themes = {};
  
  feedbackData.forEach(feedback => {
    const content = (feedback.feedback_text || '').toLowerCase();
    
    // Common wing-related themes
    if (content.includes('sauce') || content.includes('flavor')) themes.sauce = (themes.sauce || 0) + 1;
    if (content.includes('spicy') || content.includes('hot')) themes.spice = (themes.spice || 0) + 1;
    if (content.includes('crispy') || content.includes('crunchy')) themes.texture = (themes.texture || 0) + 1;
    if (content.includes('price') || content.includes('expensive') || content.includes('cheap')) themes.price = (themes.price || 0) + 1;
    if (content.includes('service') || content.includes('staff')) themes.service = (themes.service || 0) + 1;
    if (content.includes('wait') || content.includes('time')) themes.speed = (themes.speed || 0) + 1;
    if (content.includes('delivery') || content.includes('takeout')) themes.delivery = (themes.delivery || 0) + 1;
  });
  
  return Object.entries(themes)
    .sort(([,a], [,b]) => b - a)
    .slice(0, 5)
    .map(([theme, count]) => ({ theme, count }));
}

/**
 * Extract language patterns
 */
function extractLanguage(feedbackData) {
  const language = {
    positive: 0,
    negative: 0,
    neutral: 0,
    emojis: 0,
    questions: 0
  };
  
  feedbackData.forEach(feedback => {
    const content = feedback.feedback_text || '';
    
    // Count emojis
    language.emojis += (content.match(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]/gu) || []).length;
    
    // Count questions
    language.questions += (content.match(/\?/g) || []).length;
    
    // Simple sentiment analysis
    const positiveWords = ['good', 'great', 'amazing', 'love', 'best', 'excellent', 'perfect', 'delicious', 'fantastic'];
    const negativeWords = ['bad', 'terrible', 'awful', 'hate', 'worst', 'disgusting', 'horrible', 'disappointed'];
    
    const contentLower = content.toLowerCase();
    const positiveCount = positiveWords.filter(word => contentLower.includes(word)).length;
    const negativeCount = negativeWords.filter(word => contentLower.includes(word)).length;
    
    if (positiveCount > negativeCount) language.positive++;
    else if (negativeCount > positiveCount) language.negative++;
    else language.neutral++;
  });
  
  return language;
}

/**
 * Identify contradictions in feedback
 */
function identifyContradictions(feedbackData) {
  const contradictions = [];
  
  // Look for conflicting opinions on the same topics
  const topics = ['sauce', 'spice', 'price', 'service', 'speed'];
  
  topics.forEach(topic => {
    const positive = feedbackData.filter(f => 
      f.feedback_text?.toLowerCase().includes(topic) && 
      ['good', 'great', 'amazing', 'love'].some(word => 
        f.feedback_text?.toLowerCase().includes(word)
      )
    ).length;
    
    const negative = feedbackData.filter(f => 
      f.feedback_text?.toLowerCase().includes(topic) && 
      ['bad', 'terrible', 'awful', 'hate'].some(word => 
        f.feedback_text?.toLowerCase().includes(word)
      )
    ).length;
    
    if (positive > 0 && negative > 0) {
      contradictions.push({
        topic,
        positive_count: positive,
        negative_count: negative,
        contradiction_strength: Math.min(positive, negative) / Math.max(positive, negative)
      });
    }
  });
  
  return contradictions;
}

/**
 * Calculate emotional state
 */
function calculateEmotionalState(feedbackData, decoderData) {
  const emotions = {
    joy: 0,
    anger: 0,
    surprise: 0,
    anticipation: 0,
    trust: 0,
    fear: 0,
    disgust: 0,
    sadness: 0
  };
  
  // Analyze feedback data
  feedbackData.forEach(feedback => {
    const content = (feedback.feedback_text || '').toLowerCase();
    
    // Joy indicators
    if (content.includes('love') || content.includes('amazing') || content.includes('best')) emotions.joy++;
    if (content.includes('wow') || content.includes('incredible')) emotions.surprise++;
    if (content.includes('can\'t wait') || content.includes('excited')) emotions.anticipation++;
    if (content.includes('trust') || content.includes('reliable')) emotions.trust++;
    
    // Negative emotions
    if (content.includes('angry') || content.includes('mad') || content.includes('furious')) emotions.anger++;
    if (content.includes('scared') || content.includes('worried')) emotions.fear++;
    if (content.includes('disgusting') || content.includes('gross')) emotions.disgust++;
    if (content.includes('sad') || content.includes('disappointed')) emotions.sadness++;
  });
  
  // Analyze decoder data for additional sentiment
  if (decoderData && decoderData.length > 0) {
    decoderData.forEach(decoder => {
      const sentiment = decoder.sentiment || 'neutral';
      if (sentiment === 'positive') emotions.joy += 0.5;
      else if (sentiment === 'negative') emotions.anger += 0.5;
    });
  }
  
  // Normalize emotions
  const total = Object.values(emotions).reduce((sum, val) => sum + val, 0);
  if (total > 0) {
    Object.keys(emotions).forEach(key => {
      emotions[key] = Math.round((emotions[key] / total) * 100) / 100;
    });
  }
  
  return emotions;
}

/**
 * Calculate signal weights
 */
function calculateSignalWeights(feedbackData, decoderData) {
  const signals = {
    belonging: 0,
    status: 0,
    freedom: 0,
    purpose: 0,
    growth: 0,
    safety: 0
  };
  
  feedbackData.forEach(feedback => {
    const content = (feedback.feedback_text || '').toLowerCase();
    
    // Belonging indicators
    if (content.includes('community') || content.includes('friends') || content.includes('together')) signals.belonging++;
    if (content.includes('exclusive') || content.includes('premium') || content.includes('vip')) signals.status++;
    if (content.includes('choice') || content.includes('freedom') || content.includes('options')) signals.freedom++;
    if (content.includes('mission') || content.includes('values') || content.includes('purpose')) signals.purpose++;
    if (content.includes('learn') || content.includes('grow') || content.includes('improve')) signals.growth++;
    if (content.includes('safe') || content.includes('secure') || content.includes('reliable')) signals.safety++;
  });
  
  // Normalize signal weights
  const total = Object.values(signals).reduce((sum, val) => sum + val, 0);
  if (total > 0) {
    Object.keys(signals).forEach(key => {
      signals[key] = Math.round((signals[key] / total) * 100) / 100;
    });
  }
  
  return signals;
}

/**
 * Generate recent insights
 */
function generateRecentInsights(feedbackData, decoderData, themes, contradictions) {
  const insights = [];
  
  // Top themes insight
  if (themes.length > 0) {
    insights.push(`Top customer focus: ${themes[0].theme} (${themes[0].count} mentions)`);
  }
  
  // Contradiction insights
  if (contradictions.length > 0) {
    const topContradiction = contradictions[0];
    insights.push(`Mixed feelings about ${topContradiction.topic}: ${topContradiction.positive_count} positive vs ${topContradiction.negative_count} negative`);
  }
  
  // Sentiment insights
  const positiveCount = feedbackData.filter(f => 
    ['good', 'great', 'amazing', 'love'].some(word => 
      f.feedback_text?.toLowerCase().includes(word)
    )
  ).length;
  
  const negativeCount = feedbackData.filter(f => 
    ['bad', 'terrible', 'awful', 'hate'].some(word => 
      f.feedback_text?.toLowerCase().includes(word)
    )
  ).length;
  
  if (positiveCount > negativeCount) {
    insights.push(`Positive sentiment trend: ${positiveCount} positive vs ${negativeCount} negative feedback`);
  } else if (negativeCount > positiveCount) {
    insights.push(`Negative sentiment trend: ${negativeCount} negative vs ${positiveCount} positive feedback`);
  }
  
  // Decoder insights
  if (decoderData && decoderData.length > 0) {
    const avgSentiment = decoderData.reduce((sum, d) => {
      const sentiment = d.sentiment || 'neutral';
      return sum + (sentiment === 'positive' ? 1 : sentiment === 'negative' ? -1 : 0);
    }, 0) / decoderData.length;
    
    if (avgSentiment > 0.3) {
      insights.push('Strong positive sentiment in recent communications');
    } else if (avgSentiment < -0.3) {
      insights.push('Negative sentiment detected in recent communications');
    }
  }
  
  return insights.slice(0, 5); // Limit to 5 insights
}

/**
 * Determine next content focus
 */
function determineNextContentFocus(themes, emotionalState, signalWeights) {
  const focusAreas = [];
  
  // Based on top themes
  if (themes.length > 0) {
    const topTheme = themes[0].theme;
    focusAreas.push(`${topTheme}-focused content`);
  }
  
  // Based on emotional state
  const topEmotion = Object.entries(emotionalState)
    .sort(([,a], [,b]) => b - a)[0];
  
  if (topEmotion && topEmotion[1] > 0.3) {
    focusAreas.push(`${topEmotion[0]}-driven messaging`);
  }
  
  // Based on signal weights
  const topSignal = Object.entries(signalWeights)
    .sort(([,a], [,b]) => b - a)[0];
  
  if (topSignal && topSignal[1] > 0.2) {
    focusAreas.push(`${topSignal[0]}-aligned content`);
  }
  
  return focusAreas.length > 0 
    ? focusAreas.join(' with ') 
    : 'Community-focused content with balanced and authentic tone';
}

/**
 * Identify stimuli clusters
 */
function identifyStimuliClusters(feedbackData, decoderData, themes) {
  const clusters = [];
  
  // Theme-based clusters
  themes.forEach(({ theme, count }) => {
    clusters.push({
      theme,
      strength: Math.min(count / 5, 1), // Normalize to 0-1
      friction_points: [],
      belief_alignment: 'positive'
    });
  });
  
  // Add general clusters if no themes
  if (clusters.length === 0) {
    clusters.push({
      theme: 'general satisfaction',
      strength: 0.5,
      friction_points: [],
      belief_alignment: 'neutral'
    });
  }
  
  return clusters;
}

/**
 * Calculate collapse vectors
 */
function calculateCollapseVectors(feedbackData, themes, contradictions) {
  return {
    belief_clusters: themes.map(({ theme, count }) => ({
      theme,
      strength: Math.min(count / 10, 1),
      friction_points: []
    })),
    contradiction_vectors: contradictions.map(c => ({
      topic: c.topic,
      strength: c.contradiction_strength,
      resolution_priority: 'medium'
    })),
    cognitive_load: Math.min(contradictions.length / 5, 1)
  };
}

/**
 * Calculate content performance
 */
function calculateContentPerformance(feedbackData) {
  const totalFeedback = feedbackData.length;
  const positiveFeedback = feedbackData.filter(f => 
    ['good', 'great', 'amazing', 'love'].some(word => 
      f.feedback_text?.toLowerCase().includes(word)
    )
  ).length;
  
  return {
    engagement_rate: totalFeedback > 0 ? positiveFeedback / totalFeedback : 0,
    total_responses: totalFeedback,
    positive_responses: positiveFeedback,
    negative_responses: totalFeedback - positiveFeedback,
    response_velocity: totalFeedback / 2 // responses per hour
  };
}

export default { processRealtimeMarkovBlanket };
