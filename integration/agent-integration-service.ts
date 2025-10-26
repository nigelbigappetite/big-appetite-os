/**
 * Agent Integration Service
 * Routes GHL webhook social post data through all quantum agents
 * 
 * This service processes social media posts from GHL webhooks by:
 * 1. Extracting post data and metrics
 * 2. Calculating observation metrics (prediction error, free energy, collapse score)
 * 3. Updating belief driver weights based on performance
 * 4. Generating new optimized content
 * 5. Creating recommendations for GHL
 */

import { supabase, SocialPost, SocialPostMetrics, SocialPostComment } from '../supabaseClient'
import { runObservationCycle } from '../agents/observation_agent'
import { runAdjustmentCycle } from '../agents/adjustment_agent'
import { runCopyGenerator } from '../agents/copy_generator_agent'
import { runCreativeAssetGenerator } from '../agents/creative_asset_generator'

export interface PostProcessingResult {
  postId: string
  success: boolean
  observations?: {
    predictionError: number
    freeEnergy: number
    collapseScore: number
  }
  updatedWeights?: any
  generatedContent?: {
    copyId: string
    assetId?: string
  }
  errors: string[]
  duration: number
}

/**
 * Process a single social media post through the agent pipeline
 */
export async function processPost(postId: string): Promise<PostProcessingResult> {
  const startTime = Date.now()
  const errors: string[] = []
  const result: PostProcessingResult = {
    postId,
    success: false,
    errors,
    duration: 0
  }

  try {
    console.log(`\n🔄 Starting agent pipeline for post ${postId}`)

    // Step 1: Fetch post data
    const { data: post, error: postError } = await supabase
      .from('social_posts')
      .select(`
        *,
        social_post_metrics (*),
        social_post_comments (*)
      `)
      .eq('id', postId)
      .single()

    if (postError || !post) {
      throw new Error(`Post not found: ${postError?.message}`)
    }

    console.log(`📝 Post: ${post.caption?.substring(0, 50)}...`)
    console.log(`📊 Platform: ${post.platform}`)

    // Step 2: Calculate observation metrics
    console.log('\n🧠 Step 1: Observation Agent - Calculating cognitive metrics...')
    
    const observationResult = await calculatePostObservations(post)
    
    result.observations = observationResult
    console.log(`   ✓ Prediction Error: ${observationResult.predictionError.toFixed(3)}`)
    console.log(`   ✓ Free Energy: ${observationResult.freeEnergy.toFixed(3)}`)
    console.log(`   ✓ Collapse Score: ${observationResult.collapseScore.toFixed(3)}`)

    // Step 3: Update belief driver weights
    console.log('\n⚖️  Step 2: Adjustment Agent - Updating belief priors...')
    const adjustmentResult = await runAdjustmentCycle(post.brand_id)
    result.updatedWeights = adjustmentResult.newWeights
    console.log(`   ✓ Updated driver weights`)

    // Step 4: Generate new optimized content
    console.log('\n✍️  Step 3: Copy Generator - Creating optimized content...')
    const copyResult = await runCopyGenerator(post.brand_id)
    result.generatedContent = { copyId: copyResult.copyId }
    console.log(`   ✓ Generated copy: ${copyResult.generatedContent.hook}`)

    // Step 5: Generate creative asset
    console.log('\n🎨 Step 4: Creative Asset Generator - Generating visuals...')
    try {
      const assetResult = await runCreativeAssetGenerator(post.brand_id)
      if (result.generatedContent) {
        result.generatedContent.assetId = assetResult.assetId
      }
      console.log(`   ✓ Generated asset`)
    } catch (error: any) {
      console.warn(`   ⚠️ Asset generation skipped: ${error.message}`)
      errors.push(`Asset generation: ${error.message}`)
    }

    // Step 6: Mark post as processed
    await supabase
      .from('social_posts')
      .update({ processed_by_agents: true })
      .eq('id', postId)

    result.success = true
    console.log('\n✅ Agent pipeline complete!')

  } catch (error: any) {
    console.error('❌ Agent pipeline failed:', error)
    result.errors.push(error.message || 'Unknown error')
    result.success = false
  }

  result.duration = Date.now() - startTime
  return result
}

/**
 * Calculate observation metrics for a post
 * This simulates what the observation agent would do with post data
 */
async function calculatePostObservations(post: SocialPost): Promise<{
  predictionError: number
  freeEnergy: number
  collapseScore: number
}> {
  // Fetch metrics if available
  const metrics = (post as any).social_post_metrics?.[0]
  
  if (!metrics) {
    console.log('   ⚠️ No metrics available yet')
    return {
      predictionError: 0.5, // High uncertainty
      freeEnergy: 0.3,
      collapseScore: 0.5
    }
  }

  // Calculate expected engagement (simplified model)
  const expectedEngagement = (metrics.views || 0) * 0.05 // 5% expected rate
  const actualEngagement = (metrics.likes || 0) + (metrics.comments || 0) + (metrics.shares || 0)
  
  // Prediction error
  const predictionError = Math.abs(expectedEngagement - actualEngagement) / Math.max(expectedEngagement, 1)
  
  // Free energy (prediction error * entropy shift)
  const entropyShift = Math.log(Math.max(actualEngagement, 1))
  const freeEnergy = predictionError * Math.log(1 + entropyShift)
  
  // Collapse score (based on engagement quality)
  const comments = post.social_post_comments?.length || 0
  const collapseScore = Math.min((actualEngagement / Math.max(expectedEngagement, 1)) * 0.5 + (comments > 0 ? 0.3 : 0), 1)

  return {
    predictionError,
    freeEnergy,
    collapseScore
  }
}

/**
 * Process posts in batch
 */
export async function processReadyPosts(brandId?: string, options = {
  minAge: 1 * 60 * 60 * 1000, // 1 hour in ms (changed from 24 for testing)
  maxAge: 72 * 60 * 60 * 1000,  // 72 hours in ms
  limit: 10
}): Promise<PostProcessingResult[]> {
  const minTime = new Date(Date.now() - options.maxAge).toISOString()
  const maxTime = new Date(Date.now() - options.minAge).toISOString()

  console.log(`\n🔄 Finding ready posts (${options.minAge / (60 * 60 * 1000)}-${options.maxAge / (60 * 60 * 1000)} hours old)...`)

  // Find unprocessed posts within age range
  let query = supabase
    .from('social_posts')
    .select('id')
    .gte('created_at', minTime)
    .lte('created_at', maxTime)
    .or('processed_by_agents.is.null,processed_by_agents.eq.false')
    .limit(options.limit)

  if (brandId) {
    query = query.eq('brand_id', brandId) as any
  }

  const { data: posts, error } = await query.order('created_at', { ascending: true })

  if (error || !posts || posts.length === 0) {
    console.log(`   ✓ No ready posts found`)
    return []
  }

  console.log(`   ✓ Found ${posts.length} ready posts`)
  
  const results: PostProcessingResult[] = []
  
  for (const post of posts) {
    try {
      const result = await processPost(post.id)
      results.push(result)
      
      // Small delay between posts to avoid overwhelming the system
      await new Promise(resolve => setTimeout(resolve, 2000))
    } catch (error: any) {
      console.error(`Failed to process post ${post.id}:`, error.message)
      results.push({
        postId: post.id,
        success: false,
        errors: [error.message],
        duration: 0
      })
    }
  }

  return results
}

/**
 * Get processing statistics
 */
export async function getProcessingStats(brandId?: string): Promise<{
  total: number
  processed: number
  pending: number
  avgPredictionError: number
  avgFreeEnergy: number
}> {
  let query = supabase
    .from('social_posts')
    .select('id, processed_by_agents')

  if (brandId) {
    query = query.eq('brand_id', brandId) as any
  }

  const { data: posts } = await query

  const stats = {
    total: posts?.length || 0,
    processed: posts?.filter(p => p.processed_by_agents).length || 0,
    pending: posts?.filter(p => !p.processed_by_agents).length || 0,
    avgPredictionError: 0,
    avgFreeEnergy: 0
  }

  return stats
}
