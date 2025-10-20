/**
 * Simple Feedback Retriever Agent (JavaScript version)
 * Retrieves and processes feedback from various sources
 */

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

export async function runFeedbackRetrieverAgent(brandId) {
  console.log('📥 Running Simple Feedback Retriever Agent...');
  
  try {
    // Check for new Instagram posts/comments
    const { data: recentPosts, error: postsError } = await supabase
      .from('instagram_posts')
      .select('*')
      .eq('brand_id', brandId)
      .gte('created_at', new Date(Date.now() - 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: false });

    if (postsError) {
      throw new Error(`Failed to fetch Instagram posts: ${postsError.message}`);
    }

    // Process new posts into feedback
    let processedCount = 0;
    if (recentPosts && recentPosts.length > 0) {
      for (const post of recentPosts) {
        // Check if feedback already exists for this post
        const { data: existingFeedback } = await supabase
          .from('stimuli_feedback')
          .select('id')
          .eq('brand_id', brandId)
          .eq('source_id', post.id)
          .limit(1);

        if (!existingFeedback || existingFeedback.length === 0) {
          // Create feedback entry
          const feedback = {
            brand_id: brandId,
            feedback_type: 'instagram_post',
            feedback_text: post.caption || 'Instagram post',
            sentiment: 'neutral',
            source: 'instagram',
            source_id: post.id,
            created_at: new Date().toISOString()
          };

          const { error: insertError } = await supabase
            .from('stimuli_feedback')
            .insert(feedback);

          if (!insertError) {
            processedCount++;
          }
        }
      }
    }

    console.log(`✅ Processed ${processedCount} new feedback items`);
    return {
      success: true,
      processedCount,
      message: `Retrieved and processed ${processedCount} new feedback items`
    };

  } catch (error) {
    console.error('❌ Feedback Retriever Agent failed:', error.message);
    return { success: false, error: error.message };
  }
}

export default { runFeedbackRetrieverAgent };
