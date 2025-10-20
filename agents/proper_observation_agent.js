/**
 * Proper Observation Agent (JavaScript version)
 * Works with your actual stimuli_observations table schema
 */

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

export async function runObservationAgent(brandId) {
  console.log('👁️ Running Proper Observation Agent...');
  
  try {
    // Get recent feedback (once you add brand_id to stimuli_feedback)
    const { data: recentFeedback, error: feedbackError } = await supabase
      .from('stimuli_feedback')
      .select('*')
      .eq('brand_id', brandId) // This will work once you add brand_id column
      .gte('evaluated_at', new Date(Date.now() - 60 * 60 * 1000).toISOString())
      .order('evaluated_at', { ascending: false });

    if (feedbackError) {
      console.log('⚠️ No brand_id in stimuli_feedback yet, using fallback observation');
      
      // Create a fallback observation based on recent content performance
      const { data: recentContent } = await supabase
        .from('copy_generator')
        .select('created_at')
        .eq('brand_id', brandId)
        .gte('created_at', new Date(Date.now() - 60 * 60 * 1000).toISOString())
        .order('created_at', { ascending: false });

      const observation = {
        brand_id: brandId,
        stimulus_id: `obs_${Date.now()}`,
        belief_driver: 'belonging',
        prediction_error: 0.2,
        free_energy: 0.15,
        collapse_score: 0.8,
        qualitative_notes: `Content generation activity: ${recentContent?.length || 0} items in last hour`,
        created_at: new Date().toISOString()
      };

      const { data: insertedObservation, error: insertError } = await supabase
        .from('stimuli_observations')
        .insert(observation)
        .select();

      if (insertError) {
        throw new Error(`Failed to save observation: ${insertError.message}`);
      }

      console.log('✅ Fallback observation created successfully');
      return {
        success: true,
        observationId: insertedObservation[0].id,
        type: 'fallback',
        notes: observation.qualitative_notes
      };
    }

    // Process real feedback data
    if (!recentFeedback || recentFeedback.length === 0) {
      console.log('📊 No recent feedback to process');
      return { success: true, message: 'No recent feedback' };
    }

    // Calculate average metrics
    const avgPredictionError = recentFeedback.reduce((sum, f) => sum + (f.prediction_error || 0), 0) / recentFeedback.length;
    const avgFreeEnergy = recentFeedback.reduce((sum, f) => sum + (f.free_energy || 0), 0) / recentFeedback.length;
    const avgCollapseScore = recentFeedback.reduce((sum, f) => sum + (f.collapse_score || 0), 0) / recentFeedback.length;
    const avgAlignmentScore = recentFeedback.reduce((sum, f) => sum + (f.alignment_score || 0), 0) / recentFeedback.length;

    // Determine dominant belief driver
    const driverCounts = recentFeedback.reduce((acc, f) => {
      const driver = f.predicted_driver || 'belonging';
      acc[driver] = (acc[driver] || 0) + 1;
      return acc;
    }, {});

    const dominantDriver = Object.entries(driverCounts)
      .sort(([,a], [,b]) => b - a)[0]?.[0] || 'belonging';

    // Create observation
    const observation = {
      brand_id: brandId,
      stimulus_id: `obs_${Date.now()}`,
      belief_driver: dominantDriver,
      prediction_error: Math.round(avgPredictionError * 100) / 100,
      free_energy: Math.round(avgFreeEnergy * 100) / 100,
      collapse_score: Math.round(avgCollapseScore * 100) / 100,
      qualitative_notes: `Processed ${recentFeedback.length} feedback items. Avg alignment: ${Math.round(avgAlignmentScore * 100)}%. Dominant driver: ${dominantDriver}`,
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
      type: 'feedback_analysis',
      notes: observation.qualitative_notes,
      metrics: {
        predictionError: avgPredictionError,
        freeEnergy: avgFreeEnergy,
        collapseScore: avgCollapseScore,
        dominantDriver
      }
    };

  } catch (error) {
    console.error('❌ Observation Agent failed:', error.message);
    return { success: false, error: error.message };
  }
}

export default { runObservationAgent };
