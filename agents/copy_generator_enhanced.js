import { createClient } from '@supabase/supabase-js';
import { loadBrandContext, getPrimaryEmotionalState, getDominantSignalWeight, getBestPlatform } from '../shared_context_loader.js';
import { randomUUID } from 'crypto';
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
 * Enhanced Copy Generator Agent with Brand Context Integration
 * 
 * This agent reads both static brand identity and dynamic brand state
 * to generate emotionally resonant, belief-collapsing copy.
 */
export async function runCopyGeneratorEnhanced(brandId) {
  console.log('✍️ Running Enhanced Copy Generator Agent with Brand Context...')

  try {
    // Load unified brand context
    const brandContext = await loadBrandContext(brandId)
    
    // Extract key context elements
    const primaryEmotion = getPrimaryEmotionalState(brandContext)
    const dominantSignal = getDominantSignalWeight(brandContext)
    const bestPlatform = getBestPlatform(brandContext)
    
    // Get belief clusters for collapse vectors
    const beliefClusters = brandContext.brand_state.collapse_vectors?.belief_clusters || []
    const topCluster = beliefClusters[0] || { theme: 'general', friction_points: [] }
    
    // Create context-aware prompt with authentic Wing Shack Co tone
    // Add variety - not every post needs to be about offers or the same theme
    const contentThemes = [
      'food appreciation', 'wing cravings', 'sauce love', 'kitchen vibes', 
      'comfort food', 'flavor explosion', 'midweek treat', 'weekend vibes',
      'sauce obsession', 'wing ritual', 'food mood', 'kitchen magic'
    ];
    
    const randomTheme = contentThemes[Math.floor(Math.random() * contentThemes.length)];
    const shouldUseOffer = Math.random() > 0.3; // 70% chance to use offer, 30% general content
    
    const prompt = `
    You are the copy generator for Wing Shack Co - a casual, authentic wing restaurant.

    Your brand voice is:
    - Short, punchy, conversational
    - Casual and relatable (like talking to a friend)
    - Uses emojis naturally
    - Direct and to the point
    - No corporate speak or overly polished language

    Examples of your style:
    "midweek fix? 2-4-1 wings all day 🍗"
    "a moment for me to eat it all please 😍😍😍"
    "nothing hits like that first bite 🍗✨"
    "it's not payday without extra sauce 😍😍😍"

    Brand Context:
    - Name: ${brandContext.brand_identity.brand_name}
    - Currency: ${brandContext.brand_identity.currency}
    - Platform: ${bestPlatform}
    - Real Offers Available: ${brandContext.brand_identity.real_offers.map(o => o.offer).join(', ')}
    - Content Theme: ${randomTheme}
    - Use Offer: ${shouldUseOffer ? 'Yes' : 'No - focus on general food/appreciation content'}

    Create Instagram copy that:
    1. Starts with a short, punchy hook (1-2 lines max)
    2. Follows with a brief caption (2-3 lines max) 
    3. Ends with a simple CTA
    4. Uses emojis naturally
    5. Feels like a friend posting about great food
    6. Matches the casual, authentic tone of the examples
    7. ${shouldUseOffer ? 'Uses ONLY the real offers provided above - do not create new offers' : 'Focus on food appreciation, cravings, or general wing love - NO offers needed'}
    8. Uses the correct currency (£) for any prices mentioned
    9. Varies the content - not always about the same thing

    Structure your response as:
    HOOK: [short, punchy opener]
    CAPTION: [brief, casual caption]
    CTA: [simple call to action]

    Keep it short, punchy, and conversational. No corporate language.
    `

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 300,
        temperature: 0.7
      }),
    })

    const result = await response.json()
    const content = result.choices?.[0]?.message?.content || ''

    // Parse the structured response
    const lines = content.split('\n').filter(line => line.trim())
    let hook = ''
    let caption = ''
    let cta = ''

    for (const line of lines) {
      if (line.startsWith('HOOK:')) {
        hook = line.replace('HOOK:', '').trim()
      } else if (line.startsWith('CAPTION:')) {
        caption = line.replace('CAPTION:', '').trim()
      } else if (line.startsWith('CTA:')) {
        cta = line.replace('CTA:', '').trim()
      }
    }

    // Fallback parsing if structured format wasn't followed
    if (!hook || !caption || !cta) {
      const parts = content.split('\n\n')
      hook = parts[0] || `midweek fix? 🍗`
      caption = parts[1] || `fresh wings, fresh vibes`
      cta = parts[2] || `order now at wingshackco.com`
    }

    // Save to copy_generator table
    // Create more descriptive and varied titles and types
    const contentTypes = ['post', 'story', 'reel', 'carousel'];
    const randomType = contentTypes[Math.floor(Math.random() * contentTypes.length)];
    const creativeType = `${bestPlatform}_${randomType}`;
    
    // Create descriptive title based on content
    const titleWords = hook.split(' ').slice(0, 3).join(' ');
    const title = `${titleWords} - ${randomTheme} - ${bestPlatform}`;
    
    const copyRecord = {
      stimulus_id: randomUUID(), // Generate unique stimulus_id
      brand_id: brandId,
      creative_type: creativeType,
      title: title,
      hook: hook,
      caption: caption,
      cta: cta,
      belief_driver_target: [dominantSignal],
      created_by_agent: true,
      status: 'active',
      created_at: new Date().toISOString()
    }

    const { data: insertedCopy, error: insertError } = await supabase
      .from('copy_generator')
      .insert(copyRecord)
      .select()

    if (insertError) {
      throw new Error(`Failed to save copy: ${insertError.message}`)
    }

    console.log('✅ Enhanced Copy Generator complete with brand context integration')
    console.log(`📝 Generated: ${hook}`)
    console.log(`🎯 Platform: ${bestPlatform}, Emotion: ${primaryEmotion}, Signal: ${dominantSignal}`)
    console.log(`🎨 Brand: ${brandContext.brand_identity.brand_name}, Values: ${brandContext.brand_identity.brand_values.join(', ')}`)
    
    // Now trigger creative asset generation with this specific copy
    console.log('🎨 Triggering creative asset generation for this copy...')
    try {
      const { runCreativeAssetsEnhanced } = await import('./creative_assets_enhanced.js');
      const assetResult = await runCreativeAssetsEnhanced(brandId);
      
      console.log('✅ Creative asset generated successfully!')
      console.log(`🖼️ Image URL: ${assetResult.imageUrl}`)
      
      return {
        success: true,
        copyId: insertedCopy[0].id,
        generatedContent: {
          title: title,
          creativeType: creativeType,
          hook,
          caption,
          cta,
          beliefAlignmentTag: dominantSignal
        },
        brandContext: {
          primaryEmotion,
          dominantSignal,
          bestPlatform,
          brandName: brandContext.brand_identity.brand_name
        },
        creativeAsset: {
          assetId: assetResult.assetId,
          imageUrl: assetResult.imageUrl,
          platform: assetResult.brandContext.bestPlatform,
          dimensions: assetResult.visualPrompt.metadata.ratio,
          assetType: assetResult.assetType || 'image'
        }
      }
    } catch (assetError) {
      console.warn('⚠️ Creative asset generation failed:', assetError.message)
      return {
        success: true,
        copyId: insertedCopy[0].id,
        generatedContent: {
          hook,
          caption,
          cta,
          beliefAlignmentTag: dominantSignal
        },
        brandContext: {
          primaryEmotion,
          dominantSignal,
          bestPlatform,
          brandName: brandContext.brand_identity.brand_name
        },
        creativeAsset: null
      }
    }

  } catch (error) {
    console.error('❌ Enhanced Copy Generator failed:', error.message)
    throw error
  }
}

/**
 * Generate multiple variations with different emotional focuses
 */
export async function generateCopyVariationsEnhanced(brandId, count = 3) {
  console.log(`🎭 Generating ${count} copy variations with brand context...`)
  
  const results = []
  
  for (let i = 0; i < count; i++) {
    try {
      const result = await runCopyGeneratorEnhanced(brandId)
      results.push(result)
      console.log(`✅ Variation ${i + 1}/${count} generated`)
    } catch (error) {
      console.error(`❌ Failed to generate variation ${i + 1}:`, error.message)
    }
  }
  
  return results
}

/**
 * Test the enhanced copy generator
 */
export async function testEnhancedCopyGenerator() {
  const brandId = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'
  
  try {
    console.log('🧪 Testing Enhanced Copy Generator...')
    const result = await runCopyGeneratorEnhanced(brandId)
    console.log('🎉 Test successful!')
    return result
  } catch (error) {
    console.error('❌ Test failed:', error.message)
    throw error
  }
}
