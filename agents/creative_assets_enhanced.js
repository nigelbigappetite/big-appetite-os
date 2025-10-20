import { createClient } from '@supabase/supabase-js';
import { loadBrandContext, getPrimaryEmotionalState, getDominantSignalWeight, getBestPlatform, getPlatformDimensions } from '../shared_context_loader.js';
import OpenAI from 'openai';
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

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * Enhanced Creative Assets Agent with Brand Context Integration
 * 
 * This agent combines static brand identity with dynamic brand state
 * to generate platform-ready AI image prompts and create visual assets.
 */
export async function runCreativeAssetsEnhanced(brandId) {
  console.log('🎨 Running Enhanced Creative Assets Agent with Brand Context...')

  try {
    // Load unified brand context
    const brandContext = await loadBrandContext(brandId)
    
    // Extract key context elements
    const primaryEmotion = getPrimaryEmotionalState(brandContext)
    const dominantSignal = getDominantSignalWeight(brandContext)
    const bestPlatform = getBestPlatform(brandContext)
    const platformDims = getPlatformDimensions(bestPlatform)
    
    // Get belief clusters for collapse vectors
    const beliefClusters = brandContext.brand_state.collapse_vectors?.belief_clusters || []
    const topCluster = beliefClusters[0] || { theme: 'general', friction_points: [] }
    
    // Get latest copy for context
    const { data: latestCopy } = await supabase
      .from('copy_generator')
      .select('*')
      .eq('brand_id', brandId)
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    if (latestCopy) {
      console.log(`📝 Using latest copy: "${latestCopy.hook}"`)
    }

    // Add variety to visual generation - not always dependent on Markov Blanket
    const visualThemes = [
      'close-up food photography', 'kitchen action shots', 'sauce dripping', 'wing texture details',
      'plating presentation', 'ingredient focus', 'cooking process', 'food styling',
      'casual dining vibe', 'comfort food mood', 'flavor explosion', 'authentic kitchen'
    ];
    
    const randomVisualTheme = visualThemes[Math.floor(Math.random() * visualThemes.length)];
    const shouldUseMarkovContext = Math.random() > 0.4; // 60% chance to use Markov context, 40% general
    
    // Create context-aware visual prompt
    const visualPrompt = await generateVisualPrompt(brandContext, {
      primaryEmotion: shouldUseMarkovContext ? primaryEmotion : 'appetizing',
      dominantSignal: shouldUseMarkovContext ? dominantSignal : 'desire',
      bestPlatform,
      platformDims,
      topCluster: shouldUseMarkovContext ? topCluster : { theme: randomVisualTheme, friction_points: [] },
      latestCopy,
      visualTheme: randomVisualTheme,
      useMarkovContext: shouldUseMarkovContext
    })

    // Generate the actual image using DALL-E
    const imageResult = await generateImage(visualPrompt, platformDims)

    // Create varied asset types and better titles
    const assetTypes = ['image', 'video', 'gif', 'carousel'];
    const randomAssetType = assetTypes[Math.floor(Math.random() * assetTypes.length)];
    
    // Create descriptive visual direction
    const visualDirections = [
      `Food photography for ${randomVisualTheme}`,
      `Authentic ${bestPlatform} content`,
      `Wing appreciation visual`,
      `Sauce-focused imagery`,
      `Kitchen vibes content`,
      `Comfort food photography`
    ];
    const randomVisualDirection = visualDirections[Math.floor(Math.random() * visualDirections.length)];
    
    // Save to creative_assets table
    const assetRecord = {
      stimulus_id: '23cc0b24-8250-46c5-a622-af71eff2104b', // Use existing stimulus_id
      asset_type: randomAssetType,
      visual_direction: `${randomVisualDirection}: ${latestCopy?.hook || 'Brand visual'}`,
      generation_prompt: visualPrompt.visual_prompt,
      asset_url: imageResult.url,
      version: 1,
      created_at: new Date().toISOString()
    }

    const { data: insertedAsset, error: insertError } = await supabase
      .from('creative_assets')
      .insert(assetRecord)
      .select()

    if (insertError) {
      throw new Error(`Failed to save asset: ${insertError.message}`)
    }

    console.log('✅ Enhanced Creative Assets Agent complete with brand context integration')
    console.log(`🎨 Generated: ${platformDims.ratio} image for ${bestPlatform}`)
    console.log(`🎯 Emotion: ${primaryEmotion}, Signal: ${dominantSignal}`)
    console.log(`🎨 Brand: ${brandContext.brand_identity.brand_name}, Values: ${brandContext.brand_identity.brand_values.join(', ')}`)
    console.log(`🖼️ Image URL: ${imageResult.url}`)
    
    return {
      success: true,
      assetId: insertedAsset[0].id,
      imageUrl: imageResult.url,
      assetType: randomAssetType,
      visualPrompt: visualPrompt,
      brandContext: {
        primaryEmotion,
        dominantSignal,
        bestPlatform,
        brandName: brandContext.brand_identity.brand_name,
        values: brandContext.brand_identity.brand_values
      }
    }

  } catch (error) {
    console.error('❌ Enhanced Creative Assets Agent failed:', error.message)
    throw error
  }
}

/**
 * Generate context-aware visual prompt
 */
async function generateVisualPrompt(brandContext, context) {
  const { primaryEmotion, dominantSignal, bestPlatform, platformDims, topCluster, latestCopy, visualTheme, useMarkovContext } = context

  const prompt = `
  You are the creative assets agent for Big Appetite Co brands.

  ${useMarkovContext ? 
    `Combine data from:
    - brand_cards: static brand identity (channel_bias, typography style, hero offer)
    - markov_blankets: live brand cognition (collapse_vectors, emotional_state, stimuli_feedback)
    
    Brand State:
    - Primary Emotional State: ${primaryEmotion}
    - Dominant Signal Weight: ${dominantSignal}
    - Top Belief Cluster: ${topCluster.theme}
    - Current Focus: ${brandContext.brand_state.next_content_focus}` :
    `Focus on authentic food photography with variety:
    - Visual Theme: ${visualTheme}
    - General food appreciation and craving appeal
    - Natural, casual food photography style`
  }

  Use this to generate a platform-ready AI image prompt (not a mock social post).

  Brand Identity:
  - Name: ${brandContext.brand_identity.brand_name}
  - Hero Offer: ${brandContext.brand_identity.offers.hero}

  Platform Context:
  - Target Platform: ${bestPlatform}
  - Dimensions: ${platformDims.width}x${platformDims.height} (${platformDims.ratio})
  - Copy Hook: ${latestCopy?.hook || 'Brand visual'}

  Steps:
  1. Identify the target platform: ${bestPlatform}
  2. ${useMarkovContext ? 
    `Use emotional tone: ${primaryEmotion} and focus: ${topCluster.theme}` : 
    `Focus on visual theme: ${visualTheme} for variety and appeal`}
  3. Create authentic, casual food photography style
  4. ${latestCopy?.hook?.includes('Buy 1 Get 1') ? 'Include the BOGO offer context in the visual' : 'Focus on general food appeal and craving'}
  5. Define correct ratio per platform: ${platformDims.ratio}
  6. Exclude social UI elements, text boxes, or feed mockups
  7. Vary the visual approach - not always the same type of shot

  Return a JSON object with:
  {
    "visual_prompt": "Final AI prompt text ready for image_gen",
    "metadata": {
      "ratio": "${platformDims.ratio}",
      "tone": "${primaryEmotion}",
      "theme": "${useMarkovContext ? topCluster.theme : visualTheme}",
      "belief_cluster": "${dominantSignal}",
      "channel": "${bestPlatform}",
      "brand_colours": "authentic food colors",
      "offer_used": "${latestCopy?.hook?.includes('Buy 1 Get 1') ? 'BOGO' : 'general'}",
      "variety_approach": "${useMarkovContext ? 'markov_context' : 'general_food'}"
    }
  }
  `

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 500,
      temperature: 0.7
    })

    const content = response.choices?.[0]?.message?.content || ''
    
    // Try to parse JSON response
    try {
      const parsed = JSON.parse(content)
      return parsed
    } catch (parseError) {
      // Fallback if JSON parsing fails
      return {
        visual_prompt: content || `A ${primaryEmotion} visual for ${brandContext.brand_identity.brand_name} featuring ${brandContext.brand_identity.colour_palette[0]} and ${brandContext.brand_identity.colour_palette[1]} colors, ${platformDims.ratio} aspect ratio, modern clean design, no text overlays`,
        metadata: {
          ratio: platformDims.ratio,
          tone: primaryEmotion,
          collapse_trigger: topCluster.theme,
          belief_cluster: dominantSignal,
          channel: bestPlatform,
          brand_colours: brandContext.brand_identity.colour_palette,
          offer_used: brandContext.brand_identity.offers.hero
        }
      }
    }

  } catch (error) {
    console.error('Error generating visual prompt:', error.message)
    
      // Fallback visual prompt
      return {
        visual_prompt: `Authentic casual food photography of wings, ${platformDims.ratio} aspect ratio, natural lighting, appetizing, no text overlays`,
        metadata: {
          ratio: platformDims.ratio,
          tone: primaryEmotion,
          collapse_trigger: topCluster.theme,
          belief_cluster: dominantSignal,
          channel: bestPlatform,
          brand_colours: "authentic food colors",
          offer_used: brandContext.brand_identity.offers.hero
        }
      }
  }
}

/**
 * Generate image using DALL-E
 */
async function generateImage(visualPrompt, platformDims) {
  try {
    console.log('🤖 Generating image with DALL-E...')
    
    const image = await openai.images.generate({
      model: 'dall-e-3',
      prompt: visualPrompt.visual_prompt,
      n: 1,
      size: platformDims.dall_e_size,
    })

    const imageUrl = image.data[0].url
    if (!imageUrl) {
      throw new Error('No image URL returned from DALL-E')
    }

    console.log('🖼️ Generated image URL:', imageUrl)
    return { url: imageUrl }

  } catch (error) {
    console.error('❌ Error generating image:', error.message)
    throw error
  }
}

/**
 * Generate multiple visual variations
 */
export async function generateAssetVariationsEnhanced(brandId, count = 3) {
  console.log(`🎭 Generating ${count} asset variations with brand context...`)
  
  const results = []
  
  for (let i = 0; i < count; i++) {
    try {
      const result = await runCreativeAssetsEnhanced(brandId)
      results.push(result)
      console.log(`✅ Variation ${i + 1}/${count} generated`)
    } catch (error) {
      console.error(`❌ Failed to generate variation ${i + 1}:`, error.message)
    }
  }
  
  return results
}

/**
 * Test the enhanced creative assets agent
 */
export async function testEnhancedCreativeAssets() {
  const brandId = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'
  
  try {
    console.log('🧪 Testing Enhanced Creative Assets Agent...')
    const result = await runCreativeAssetsEnhanced(brandId)
    console.log('🎉 Test successful!')
    return result
  } catch (error) {
    console.error('❌ Test failed:', error.message)
    throw error
  }
}
