import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

// Load environment variables
dotenv.config()

const supabaseUrl = process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co'
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'

// Default brand ID from your existing database
export const DEFAULT_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

export const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

// Types for our database tables
export interface StimuliFeedback {
  id?: string
  brand_id: string
  stimulus_id: string
  platform: string
  post_id?: string
  likes: number
  comments: number
  shares: number
  saves: number
  views: number
  engagement_rate: number
  sentiment_score: number
  primary_driver: string
  expected_engagement: number
  actual_engagement: number
  entropy_shift: number
  alignment_score: number
  behavioural_score: number
  emotional_score: number
  qualitative_summary?: string
  created_at?: string
}

export interface StimuliObservation {
  id?: string
  brand_id: string
  stimulus_id: string
  belief_driver: string
  prediction_error: number
  free_energy: number
  collapse_score: number
  qualitative_notes?: string
  created_at?: string
}

export interface StimuliAdjustment {
  id?: string
  brand_id: string
  driver_weights: Record<string, number>
  adjustment_reason: string
  created_at?: string
}

export interface CopyGenerator {
  id?: string
  brand_id: string
  creative_type: string
  title: string
  hook: string
  caption: string
  cta: string
  belief_alignment_tag: string
  iteration_parent_id?: string
  created_at?: string
}

export interface CreativeAsset {
  id?: string
  brand_id: string
  copy_id: string
  media_url: string
  creative_type: string
  generation_prompt: string
  created_at?: string
}

export interface BeliefDriverWeights {
  status: number
  freedom: number
  connection: number
  purpose: number
  growth: number
  safety: number
}

// Types for social media posts from GHL webhooks
export interface SocialPost {
  id: string
  brand_id: string
  ghl_location_id: string
  platform: string
  post_id: string
  caption: string
  media_url?: string
  status: string
  published_at?: string
  created_at?: string
  updated_at?: string
  processed_by_agents?: boolean
  raw_payload?: any
}

export interface SocialPostComment {
  id: string
  post_id: string
  comment_id: string
  comment_text: string
  author_username?: string
  created_at?: string
  sentiment_score?: number
  sentiment_label?: string
}

export interface SocialPostMetrics {
  id: string
  post_id: string
  likes: number
  comments: number
  shares: number
  saves: number
  views: number
  engagement_rate: number
  measured_at: string
  created_at?: string
}

