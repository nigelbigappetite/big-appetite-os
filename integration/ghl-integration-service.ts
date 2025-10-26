/**
 * GHL Integration Service
 * Pushes generated content recommendations back to GoHighLevel
 * 
 * This service:
 * - Retrieves generated content from the database
 * - Formats it as draft posts for GHL
 * - Pushes recommendations to the GHL API
 */

import { supabase } from '../supabaseClient'
import { getRecentCopy } from '../agents/copy_generator_agent'
import { getAssetsForCopy } from '../agents/creative_asset_generator'

export interface GHLRecommendation {
  id: string
  brandId: string
  locationId: string
  platform: string
  content: {
    caption: string
    mediaUrl?: string
    hashtags?: string[]
  }
  strategy: string
  recommendationReason: string
  predictedPerformance: {
    expectedLikes: number
    expectedComments: number
    engagementRate: number
  }
  createdAt: string
}

/**
 * Push recommendations to GHL
 */
export async function pushRecommendationsToGHL(
  brandId: string,
  locationId: string,
  options = {
    limit: 5,
    platforms: ['instagram', 'facebook', 'tiktok']
  }
): Promise<GHLRecommendation[]> {
  console.log(`📤 Pushing recommendations to GHL (Location: ${locationId})...`)

  try {
    // Get latest generated content
    const { data: recentCopy, error: copyError } = await supabase
      .from('copy_generator')
      .select('*, creative_assets (*)')
      .eq('brand_id', brandId)
      .order('created_at', { ascending: false })
      .limit(options.limit)

    if (copyError || !recentCopy) {
      throw new Error(`Failed to fetch content: ${copyError?.message}`)
    }

    console.log(`   Found ${recentCopy.length} pieces of generated content`)

    const recommendations: GHLRecommendation[] = []

    for (const copy of recentCopy) {
      // Get assets for this copy
      const assets = copy.creative_assets || []
      const mainAsset = assets[0]?.media_url

      // Create recommendation
      const recommendation: GHLRecommendation = {
        id: copy.id,
        brandId,
        locationId,
        platform: 'instagram', // Default platform
        content: {
          caption: `${copy.hook}\n\n${copy.caption}\n\n${copy.cta}`,
          mediaUrl: mainAsset,
          hashtags: extractHashtags(copy.caption)
        },
        strategy: copy.belief_alignment_tag || 'moderate',
        recommendationReason: createRecommendationReason(copy),
        predictedPerformance: {
          expectedLikes: 150, // Simplified prediction
          expectedComments: 15,
          engagementRate: 0.08
        },
        createdAt: copy.created_at || new Date().toISOString()
      }

      recommendations.push(recommendation)

      // Push to GHL API (mock implementation)
      await pushToGHLAPI(recommendation)
    }

    console.log(`✅ Pushed ${recommendations.length} recommendations to GHL`)
    return recommendations

  } catch (error: any) {
    console.error('❌ Failed to push recommendations:', error.message)
    throw error
  }
}

/**
 * Push a single recommendation to GHL API
 */
async function pushToGHLAPI(recommendation: GHLRecommendation): Promise<void> {
  // This is a mock implementation
  // Replace with actual GHL API integration
  
  const ghlApiKey = process.env.GHL_API_KEY
  const ghlApiUrl = process.env.GHL_API_URL || 'https://rest.gohighlevel.com/v1'

  if (!ghlApiKey) {
    console.warn('⚠️ GHL_API_KEY not configured, skipping API call')
    return
  }

  try {
    // Format as draft post for GHL
    const postData = {
      locationId: recommendation.locationId,
      platform: recommendation.platform,
      caption: recommendation.content.caption,
      mediaUrl: recommendation.content.mediaUrl,
      status: 'draft', // Create as draft for review
      scheduledFor: null, // Not scheduled yet
      metadata: {
        strategy: recommendation.strategy,
        reason: recommendation.recommendationReason,
        predictedPerformance: recommendation.predictedPerformance,
        generatedBy: 'big-appetite-os',
        generatedAt: recommendation.createdAt
      }
    }

    // Push to GHL (mock implementation)
    const response = await fetch(`${ghlApiUrl}/social-media/posts`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${ghlApiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(postData)
    })

    if (!response.ok) {
      throw new Error(`GHL API error: ${response.status} ${response.statusText}`)
    }

    console.log(`   ✓ Posted to GHL: ${recommendation.id}`)

  } catch (error: any) {
    console.warn(`   ⚠️ Failed to push to GHL API: ${error.message}`)
    // Don't throw, just log the error
  }
}

/**
 * Extract hashtags from text
 */
function extractHashtags(text: string): string[] {
  const hashtagRegex = /#[\w]+/g
  const matches = text.match(hashtagRegex)
  return matches || []
}

/**
 * Create a recommendation reason based on copy metadata
 */
function createRecommendationReason(copy: any): string {
  const strategy = copy.belief_alignment_tag || 'moderate'
  const driverKeywords = {
    status: 'Exclusive and premium positioning',
    freedom: 'Flexibility and choice messaging',
    connection: 'Community and togetherness focus',
    purpose: 'Meaningful and authentic communication',
    growth: 'Innovation and improvement emphasis',
    safety: 'Reliability and consistency messaging'
  }

  const keyword = driverKeywords[strategy as keyof typeof driverKeywords] || 'Moderate messaging'

  return `Content optimized for ${strategy} driver strategy - ${keyword}`
}

/**
 * Get recommendations ready to push
 */
export async function getPendingRecommendations(brandId: string): Promise<any[]> {
  const { data, error } = await supabase
    .from('copy_generator')
    .select(`
      *,
      creative_assets (*)
    `)
    .eq('brand_id', brandId)
    .order('created_at', { ascending: false })
    .limit(10)

  if (error) {
    throw new Error(`Failed to fetch recommendations: ${error.message}`)
  }

  return data || []
}

/**
 * Mark a recommendation as used
 */
export async function markRecommendationUsed(copyId: string): Promise<void> {
  const { error } = await supabase
    .from('copy_generator')
    .update({ 
      used_at: new Date().toISOString(),
      status: 'used'
    })
    .eq('id', copyId)

  if (error) {
    throw new Error(`Failed to mark as used: ${error.message}`)
  }

  console.log(`✓ Marked recommendation ${copyId} as used`)
}

/**
 * Get latest recommendations for preview
 */
export async function previewLatestRecommendations(
  brandId: string,
  limit: number = 5
): Promise<any[]> {
  const { data, error } = await supabase
    .from('copy_generator')
    .select(`
      *,
      creative_assets (*)
    `)
    .eq('brand_id', brandId)
    .is('used_at', null)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) {
    throw new Error(`Failed to fetch recommendations: ${error.message}`)
  }

  return data || []
}
