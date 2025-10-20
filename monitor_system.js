#!/usr/bin/env node

/**
 * System Monitor Dashboard
 * Provides real-time monitoring of the Big Appetite OS system
 */

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

class SystemMonitor {
  constructor(brandId = 'a1b2c3d4-e5f6-7890-1234-567890abcdef') {
    this.brandId = brandId;
    this.isMonitoring = false;
  }

  /**
   * Start monitoring dashboard
   */
  async start() {
    console.log('📊 Starting Big Appetite OS Monitor...');
    console.log('=' .repeat(60));
    
    this.isMonitoring = true;
    
    // Initial status
    await this.displayStatus();
    
    // Update every 30 seconds
    const interval = setInterval(async () => {
      if (!this.isMonitoring) {
        clearInterval(interval);
        return;
      }
      
      console.clear();
      await this.displayStatus();
    }, 30000);
    
    // Handle Ctrl+C
    process.on('SIGINT', () => {
      console.log('\n🛑 Stopping monitor...');
      this.isMonitoring = false;
      process.exit(0);
    });
  }

  /**
   * Display current system status
   */
  async displayStatus() {
    console.log('📊 Big Appetite OS - Real-time Monitor');
    console.log('=' .repeat(60));
    console.log(`🕐 ${new Date().toLocaleString()}`);
    console.log(`🏷️  Brand ID: ${this.brandId}`);
    console.log('');
    
    try {
      // Get recent activity
      const activity = await this.getRecentActivity();
      this.displayActivity(activity);
      
      // Get Markov Blanket status
      const markovStatus = await this.getMarkovStatus();
      this.displayMarkovStatus(markovStatus);
      
      // Get content generation status
      const contentStatus = await this.getContentStatus();
      this.displayContentStatus(contentStatus);
      
      // Get feedback status
      const feedbackStatus = await this.getFeedbackStatus();
      this.displayFeedbackStatus(feedbackStatus);
      
      // Get system health
      const health = await this.getSystemHealth();
      this.displayHealth(health);
      
    } catch (error) {
      console.error('❌ Error fetching status:', error.message);
    }
    
    console.log('');
    console.log('Press Ctrl+C to stop monitoring');
  }

  /**
   * Get recent activity across all tables
   */
  async getRecentActivity() {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    
    const [markovData, copyData, assetData, feedbackData, observationData] = await Promise.all([
      supabase.from('brand_markov_blankets').select('created_at').eq('brand_id', this.brandId).gte('created_at', oneHourAgo),
      supabase.from('copy_generator').select('created_at').eq('brand_id', this.brandId).gte('created_at', oneHourAgo),
      supabase.from('creative_assets').select('created_at').eq('brand_id', this.brandId).gte('created_at', oneHourAgo),
      supabase.from('stimuli_feedback').select('created_at').eq('brand_id', this.brandId).gte('created_at', oneHourAgo),
      supabase.from('stimuli_observations').select('created_at').eq('brand_id', this.brandId).gte('created_at', oneHourAgo)
    ]);

    return {
      markov: markovData.data?.length || 0,
      copy: copyData.data?.length || 0,
      assets: assetData.data?.length || 0,
      feedback: feedbackData.data?.length || 0,
      observations: observationData.data?.length || 0
    };
  }

  /**
   * Display activity status
   */
  displayActivity(activity) {
    console.log('📈 Recent Activity (Last Hour):');
    console.log(`   🧠 Markov Blankets: ${activity.markov}`);
    console.log(`   ✍️  Copy Generated: ${activity.copy}`);
    console.log(`   🎨 Creative Assets: ${activity.assets}`);
    console.log(`   📥 Feedback Items: ${activity.feedback}`);
    console.log(`   👁️  Observations: ${activity.observations}`);
    console.log('');
  }

  /**
   * Get Markov Blanket status
   */
  async getMarkovStatus() {
    const { data, error } = await supabase
      .from('brand_markov_blankets')
      .select('*')
      .eq('brand_id', this.brandId)
      .order('updated_at', { ascending: false })
      .limit(1)
      .single();

    if (error || !data) {
      return { status: 'no_data', message: 'No Markov Blanket found' };
    }

    const timeSinceUpdate = Date.now() - new Date(data.updated_at).getTime();
    const minutesSinceUpdate = Math.round(timeSinceUpdate / (1000 * 60));

    return {
      status: minutesSinceUpdate < 10 ? 'fresh' : minutesSinceUpdate < 30 ? 'stale' : 'outdated',
      lastUpdate: data.updated_at,
      minutesSinceUpdate,
      emotionalState: data.emotional_state,
      nextFocus: data.next_content_focus
    };
  }

  /**
   * Display Markov status
   */
  displayMarkovStatus(status) {
    console.log('🧠 Markov Blanket Status:');
    
    if (status.status === 'no_data') {
      console.log('   ❌ No data available');
      return;
    }
    
    const statusIcon = status.status === 'fresh' ? '✅' : status.status === 'stale' ? '⚠️' : '❌';
    console.log(`   ${statusIcon} Last updated: ${status.minutesSinceUpdate} minutes ago`);
    
    if (status.emotionalState) {
      const topEmotion = Object.entries(status.emotionalState)
        .sort(([,a], [,b]) => b - a)[0];
      if (topEmotion) {
        console.log(`   😊 Top emotion: ${topEmotion[0]} (${Math.round(topEmotion[1] * 100)}%)`);
      }
    }
    
    if (status.nextFocus) {
      console.log(`   🎯 Next focus: ${status.nextFocus}`);
    }
    console.log('');
  }

  /**
   * Get content generation status
   */
  async getContentStatus() {
    const { data: recentCopy, error: copyError } = await supabase
      .from('copy_generator')
      .select('created_at, creative_type, title')
      .eq('brand_id', this.brandId)
      .order('created_at', { ascending: false })
      .limit(5);

    const { data: recentAssets, error: assetError } = await supabase
      .from('creative_assets')
      .select('created_at, asset_type, visual_direction')
      .eq('brand_id', this.brandId)
      .order('created_at', { ascending: false })
      .limit(5);

    return {
      recentCopy: recentCopy || [],
      recentAssets: recentAssets || [],
      copyError: copyError,
      assetError: assetError
    };
  }

  /**
   * Display content status
   */
  displayContentStatus(status) {
    console.log('✍️ Content Generation Status:');
    
    if (status.recentCopy.length > 0) {
      console.log('   📝 Recent Copy:');
      status.recentCopy.slice(0, 3).forEach((copy, i) => {
        const timeAgo = Math.round((Date.now() - new Date(copy.created_at).getTime()) / (1000 * 60));
        console.log(`      ${i + 1}. ${copy.title} (${copy.creative_type}) - ${timeAgo}m ago`);
      });
    } else {
      console.log('   ❌ No recent copy generated');
    }
    
    if (status.recentAssets.length > 0) {
      console.log('   🎨 Recent Assets:');
      status.recentAssets.slice(0, 3).forEach((asset, i) => {
        const timeAgo = Math.round((Date.now() - new Date(asset.created_at).getTime()) / (1000 * 60));
        console.log(`      ${i + 1}. ${asset.asset_type} - ${timeAgo}m ago`);
      });
    } else {
      console.log('   ❌ No recent assets generated');
    }
    console.log('');
  }

  /**
   * Get feedback status
   */
  async getFeedbackStatus() {
    const { data, error } = await supabase
      .from('stimuli_feedback')
      .select('created_at, feedback_type, sentiment')
      .eq('brand_id', this.brandId)
      .order('created_at', { ascending: false })
      .limit(10);

    if (error || !data) {
      return { status: 'error', message: error?.message || 'No data' };
    }

    const sentimentCounts = data.reduce((acc, item) => {
      const sentiment = item.sentiment || 'neutral';
      acc[sentiment] = (acc[sentiment] || 0) + 1;
      return acc;
    }, {});

    return {
      status: 'success',
      total: data.length,
      sentimentCounts,
      recent: data.slice(0, 3)
    };
  }

  /**
   * Display feedback status
   */
  displayFeedbackStatus(status) {
    console.log('📥 Feedback Status:');
    
    if (status.status === 'error') {
      console.log(`   ❌ Error: ${status.message}`);
      return;
    }
    
    console.log(`   📊 Total recent feedback: ${status.total}`);
    
    if (Object.keys(status.sentimentCounts).length > 0) {
      console.log('   😊 Sentiment breakdown:');
      Object.entries(status.sentimentCounts).forEach(([sentiment, count]) => {
        const percentage = Math.round((count / status.total) * 100);
        console.log(`      ${sentiment}: ${count} (${percentage}%)`);
      });
    }
    console.log('');
  }

  /**
   * Get system health
   */
  async getSystemHealth() {
    // Check database connectivity
    const { error: dbError } = await supabase
      .from('brand_markov_blankets')
      .select('brand_id')
      .limit(1);

    // Check if agents are running (by looking for recent activity)
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000).toISOString();
    
    const { data: recentActivity } = await supabase
      .from('brand_markov_blankets')
      .select('updated_at')
      .eq('brand_id', this.brandId)
      .gte('updated_at', fiveMinutesAgo);

    return {
      database: dbError ? 'error' : 'healthy',
      agents: recentActivity && recentActivity.length > 0 ? 'active' : 'inactive',
      lastActivity: recentActivity?.[0]?.updated_at || null
    };
  }

  /**
   * Display health status
   */
  displayHealth(health) {
    console.log('🏥 System Health:');
    
    const dbIcon = health.database === 'healthy' ? '✅' : '❌';
    console.log(`   ${dbIcon} Database: ${health.database}`);
    
    const agentIcon = health.agents === 'active' ? '✅' : '⚠️';
    console.log(`   ${agentIcon} Agents: ${health.agents}`);
    
    if (health.lastActivity) {
      const timeSinceActivity = Math.round((Date.now() - new Date(health.lastActivity).getTime()) / (1000 * 60));
      console.log(`   🕐 Last activity: ${timeSinceActivity} minutes ago`);
    }
    console.log('');
  }
}

// Main execution
async function main() {
  const brandId = process.argv[2] || 'a1b2c3d4-e5f6-7890-1234-567890abcdef';
  const monitor = new SystemMonitor(brandId);
  
  try {
    await monitor.start();
  } catch (error) {
    console.error('❌ Monitor failed:', error.message);
    process.exit(1);
  }
}

main().catch(console.error);
