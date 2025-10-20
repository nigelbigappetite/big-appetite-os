/**
 * Proper Adjustment Agent (JavaScript version)
 * Works with your actual stimuli_adjustments table schema
 */

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

export async function runAdjustmentAgent(brandId) {
  console.log('⚙️ Running Proper Adjustment Agent...');
  
  try {
    // Get recent observations
    const { data: recentObservations, error: obsError } = await supabase
      .from('stimuli_observations')
      .select('*')
      .eq('brand_id', brandId)
      .gte('created_at', new Date(Date.now() - 30 * 60 * 1000).toISOString())
      .order('created_at', { ascending: false });

    if (obsError) {
      throw new Error(`Failed to fetch observations: ${obsError.message}`);
    }

    // Get current driver weights from Markov Blanket
    const { data: currentMarkov, error: markovError } = await supabase
      .from('brand_markov_blankets')
      .select('signal_weights')
      .eq('brand_id', brandId)
      .order('updated_at', { ascending: false })
      .limit(1)
      .single();

    if (markovError) {
      console.log('⚠️ No Markov Blanket found, using default weights');
    }

    // Default driver weights
    const defaultWeights = {
      belonging: 0.2,
      status: 0.15,
      freedom: 0.15,
      purpose: 0.15,
      growth: 0.15,
      safety: 0.2
    };

    const currentWeights = currentMarkov?.signal_weights || defaultWeights;
    const previousWeights = { ...currentWeights };

    // Calculate adjustments based on observations
    let newWeights = { ...currentWeights };
    let adjustmentReason = 'No recent observations';

    if (recentObservations && recentObservations.length > 0) {
      // Analyze observations to determine adjustments
      const avgPredictionError = recentObservations.reduce((sum, obs) => sum + (obs.prediction_error || 0), 0) / recentObservations.length;
      const avgFreeEnergy = recentObservations.reduce((sum, obs) => sum + (obs.free_energy || 0), 0) / recentObservations.length;
      const avgCollapseScore = recentObservations.reduce((sum, obs) => sum + (obs.collapse_score || 0), 0) / recentObservations.length;

      // Count belief drivers
      const driverCounts = recentObservations.reduce((acc, obs) => {
        const driver = obs.belief_driver || 'belonging';
        acc[driver] = (acc[driver] || 0) + 1;
        return acc;
      }, {});

      // Adjust weights based on performance
      const adjustmentFactor = 0.05; // Small adjustments
      
      if (avgPredictionError > 0.3) {
        // High prediction error - increase diversity
        Object.keys(newWeights).forEach(driver => {
          newWeights[driver] = Math.max(0.1, Math.min(0.4, newWeights[driver] + (Math.random() - 0.5) * adjustmentFactor));
        });
        adjustmentReason = `High prediction error (${Math.round(avgPredictionError * 100)}%) - increasing diversity`;
      } else if (avgCollapseScore > 0.7) {
        // High collapse score - focus on dominant drivers
        const dominantDriver = Object.entries(driverCounts)
          .sort(([,a], [,b]) => b - a)[0]?.[0] || 'belonging';
        
        newWeights[dominantDriver] = Math.min(0.4, newWeights[dominantDriver] + adjustmentFactor);
        Object.keys(newWeights).forEach(driver => {
          if (driver !== dominantDriver) {
            newWeights[driver] = Math.max(0.1, newWeights[driver] - adjustmentFactor / 5);
          }
        });
        adjustmentReason = `High collapse score (${Math.round(avgCollapseScore * 100)}%) - focusing on ${dominantDriver}`;
      } else {
        // Normal operation - small random adjustments
        Object.keys(newWeights).forEach(driver => {
          newWeights[driver] = Math.max(0.1, Math.min(0.4, newWeights[driver] + (Math.random() - 0.5) * adjustmentFactor / 2));
        });
        adjustmentReason = `Normal operation - fine-tuning based on ${recentObservations.length} observations`;
      }

      // Normalize weights to sum to 1
      const totalWeight = Object.values(newWeights).reduce((sum, weight) => sum + weight, 0);
      Object.keys(newWeights).forEach(driver => {
        newWeights[driver] = Math.round((newWeights[driver] / totalWeight) * 1000) / 1000;
      });
    }

    // Calculate confidence score
    const confidenceScore = recentObservations?.length > 0 
      ? Math.min(0.9, 0.5 + (recentObservations.length * 0.1))
      : 0.3;

    // Create adjustment record
    const adjustment = {
      brand_id: brandId,
      driver_weights: newWeights,
      adjustment_reason: adjustmentReason,
      previous_weights: previousWeights,
      confidence_score: Math.round(confidenceScore * 100) / 100,
      created_at: new Date().toISOString()
    };

    // Save adjustment
    const { data: insertedAdjustment, error: insertError } = await supabase
      .from('stimuli_adjustments')
      .insert(adjustment)
      .select();

    if (insertError) {
      throw new Error(`Failed to save adjustment: ${insertError.message}`);
    }

    // Update the Markov Blanket with new weights
    const { error: updateError } = await supabase
      .from('brand_markov_blankets')
      .update({ 
        signal_weights: newWeights,
        updated_at: new Date().toISOString()
      })
      .eq('brand_id', brandId);

    if (updateError) {
      console.warn('⚠️ Failed to update Markov Blanket with new weights:', updateError.message);
    }

    console.log('✅ Adjustment created successfully');
    console.log(`📊 New weights:`, newWeights);
    console.log(`💭 Reason: ${adjustmentReason}`);

    return {
      success: true,
      adjustmentId: insertedAdjustment[0].id,
      newWeights,
      previousWeights,
      reason: adjustmentReason,
      confidence: confidenceScore
    };

  } catch (error) {
    console.error('❌ Adjustment Agent failed:', error.message);
    return { success: false, error: error.message };
  }
}

export default { runAdjustmentAgent };
