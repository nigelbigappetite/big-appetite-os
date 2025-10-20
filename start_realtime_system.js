#!/usr/bin/env node

/**
 * Real-time System Startup Script
 * Launches the entire Big Appetite OS in real-time mode
 */

import RealtimeOrchestrator from './agents/realtime_orchestrator.js';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
  process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoamF3cXBoZWhremZhZXpoenpmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDE3Mjc0MSwiZXhwIjoyMDc1NzQ4NzQxfQ.zzKfrvGSrQImX7rm1yeifued3yeXzRI11E6UvMWURYM'
);

// Default brand ID - you can change this
const DEFAULT_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef';

class RealtimeSystemManager {
  constructor() {
    this.orchestrator = null;
    this.brandId = process.argv[2] || DEFAULT_BRAND_ID;
    this.config = this.loadConfig();
  }

  /**
   * Load configuration from environment or defaults
   */
  loadConfig() {
    return {
      markovInterval: parseInt(process.env.MARKOV_INTERVAL) || 5 * 60 * 1000, // 5 minutes
      contentInterval: parseInt(process.env.CONTENT_INTERVAL) || 15 * 60 * 1000, // 15 minutes
      observationInterval: parseInt(process.env.OBSERVATION_INTERVAL) || 2 * 60 * 1000, // 2 minutes
      adjustmentInterval: parseInt(process.env.ADJUSTMENT_INTERVAL) || 10 * 60 * 1000, // 10 minutes
      feedbackInterval: parseInt(process.env.FEEDBACK_INTERVAL) || 3 * 60 * 1000, // 3 minutes
      maxRetries: parseInt(process.env.MAX_RETRIES) || 3,
      retryDelay: parseInt(process.env.RETRY_DELAY) || 30 * 1000,
      healthCheckInterval: parseInt(process.env.HEALTH_CHECK_INTERVAL) || 60 * 1000, // 1 minute
      logLevel: process.env.LOG_LEVEL || 'info'
    };
  }

  /**
   * Start the real-time system
   */
  async start() {
    console.log('🚀 Starting Big Appetite OS Real-time System...');
    console.log('=' .repeat(60));
    
    // Validate environment
    await this.validateEnvironment();
    
    // Initialize orchestrator
    this.orchestrator = new RealtimeOrchestrator(this.brandId, this.config);
    
    // Start the orchestrator
    await this.orchestrator.start();
    
    // Start health monitoring
    this.startHealthMonitoring();
    
    // Start status reporting
    this.startStatusReporting();
    
    // Handle graceful shutdown
    this.setupGracefulShutdown();
    
    console.log('✅ Real-time system started successfully!');
    console.log('📊 System is now running continuously...');
    console.log('🛑 Press Ctrl+C to stop');
  }

  /**
   * Validate environment and dependencies
   */
  async validateEnvironment() {
    console.log('🔍 Validating environment...');
    
    // Check required environment variables
    const required = ['OPENAI_API_KEY'];
    const missing = required.filter(key => !process.env[key]);
    
    if (missing.length > 0) {
      console.error('❌ Missing required environment variables:', missing.join(', '));
      process.exit(1);
    }
    
    // Test database connection
    try {
      const { data, error } = await supabase
        .from('brand_markov_blankets')
        .select('brand_id')
        .limit(1);
      
      if (error) {
        console.error('❌ Database connection failed:', error.message);
        process.exit(1);
      }
      
      console.log('✅ Database connection successful');
    } catch (error) {
      console.error('❌ Database validation failed:', error.message);
      process.exit(1);
    }
    
    // Check if brand exists
    try {
      const { data, error } = await supabase
        .from('brand_markov_blankets')
        .select('brand_id')
        .eq('brand_id', this.brandId)
        .limit(1);
      
      if (error) {
        console.error('❌ Brand validation failed:', error.message);
        process.exit(1);
      }
      
      if (!data || data.length === 0) {
        console.log('⚠️ Brand not found in Markov Blankets, will create on first run');
      } else {
        console.log('✅ Brand validation successful');
      }
    } catch (error) {
      console.error('❌ Brand validation failed:', error.message);
      process.exit(1);
    }
    
    console.log('✅ Environment validation complete');
  }

  /**
   * Start health monitoring
   */
  startHealthMonitoring() {
    setInterval(() => {
      const health = this.orchestrator.getHealthCheck();
      
      if (health.status !== 'healthy') {
        console.log('⚠️ Health Check Alert:');
        health.issues.forEach(issue => console.log(`   - ${issue}`));
      }
    }, this.config.healthCheckInterval);
  }

  /**
   * Start status reporting
   */
  startStatusReporting() {
    setInterval(() => {
      const status = this.orchestrator.getStatus();
      const uptime = Math.round(status.uptime / 60); // minutes
      
      console.log('📊 System Status:');
      console.log(`   Uptime: ${uptime} minutes`);
      console.log(`   Markov Runs: ${status.stats.markovRuns}`);
      console.log(`   Content Runs: ${status.stats.contentRuns}`);
      console.log(`   Observation Runs: ${status.stats.observationRuns}`);
      console.log(`   Adjustment Runs: ${status.stats.adjustmentRuns}`);
      console.log(`   Feedback Runs: ${status.stats.feedbackRuns}`);
      console.log(`   Total Errors: ${status.stats.errors}`);
      console.log('---');
    }, 5 * 60 * 1000); // Every 5 minutes
  }

  /**
   * Setup graceful shutdown
   */
  setupGracefulShutdown() {
    const shutdown = (signal) => {
      console.log(`\n🛑 Received ${signal}, shutting down gracefully...`);
      
      if (this.orchestrator) {
        this.orchestrator.stop();
      }
      
      console.log('✅ Shutdown complete');
      process.exit(0);
    };
    
    process.on('SIGINT', () => shutdown('SIGINT'));
    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGUSR2', () => shutdown('SIGUSR2')); // For nodemon
  }

  /**
   * Get system status
   */
  getStatus() {
    if (!this.orchestrator) {
      return { status: 'not_started' };
    }
    
    return this.orchestrator.getStatus();
  }

  /**
   * Get health check
   */
  getHealthCheck() {
    if (!this.orchestrator) {
      return { status: 'not_started', issues: ['System not started'] };
    }
    
    return this.orchestrator.getHealthCheck();
  }
}

// Main execution
async function main() {
  const systemManager = new RealtimeSystemManager();
  
  try {
    await systemManager.start();
  } catch (error) {
    console.error('❌ Failed to start real-time system:', error.message);
    process.exit(1);
  }
}

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Start the system
main().catch(console.error);
