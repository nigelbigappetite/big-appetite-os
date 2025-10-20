/**
 * Simple Observation Agent (JavaScript version)
 * Monitors brand state and creates observations
 */

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

export async function runObservationAgent(brandId) {
  console.log('👁️ Running Simple Observation Agent...');
  
  try {
    // Get recent feedback
    const { data: recentFeedback, error: feedbackError } = await supabase
      .from('stimuli_feedback')
      .select('*')
      .eq('brand_id', brandId)
      .gte('created_at', new Date(Date.now() - 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: false });

    if (feedbackError) {
      throw new Error(`Failed to fetch feedback: ${feedbackError.message}`);
    }

    // Create simple observation
    const observation = {
      brand_id: brandId,
      observation_type: 'feedback_analysis',
      observation_data: {
        total_feedback: recentFeedback?.length || 0,
        time_window: '1_hour',
        sentiment_trend: 'neutral'
      },
      insight: recentFeedback?.length > 0 
        ? `Received ${recentFeedback.length} feedback items in the last hour`
        : 'No recent feedback activity',
      confidence_score: 0.7,
      created_at: new Date().toISOString()
    };

    // Save observation
    const { data: insertedObservation, error: insertError } = await supabase
      .from('stimuli_observations')
      .insert(observation)
      .select();

    if (insertError) {
      throw new Error(`Failed to save observation: ${insertError.message}`);
    }

    console.log('✅ Observation created successfully');
    return {
      success: true,
      observationId: insertedObservation[0].id,
      insight: observation.insight
    };

  } catch (error) {
    console.error('❌ Observation Agent failed:', error.message);
    return { success: false, error: error.message };
  }
}

export default { runObservationAgent };
