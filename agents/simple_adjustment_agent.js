/**
 * Simple Adjustment Agent (JavaScript version)
 * Makes adjustments to belief drivers based on observations
 */

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

export async function runAdjustmentAgent(brandId) {
  console.log('⚙️ Running Simple Adjustment Agent...');
  
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

    // Create simple adjustment
    const adjustment = {
      brand_id: brandId,
      adjustment_type: 'belief_driver_update',
      adjustment_data: {
        driver: 'belonging',
        adjustment: 0.1,
        reason: 'Based on recent observations'
      },
      description: recentObservations?.length > 0 
        ? `Adjusting belief drivers based on ${recentObservations.length} recent observations`
        : 'No recent observations to base adjustments on',
      confidence_score: 0.6,
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

    console.log('✅ Adjustment created successfully');
    return {
      success: true,
      adjustmentId: insertedAdjustment[0].id,
      description: adjustment.description
    };

  } catch (error) {
    console.error('❌ Adjustment Agent failed:', error.message);
    return { success: false, error: error.message };
  }
}

export default { runAdjustmentAgent };
