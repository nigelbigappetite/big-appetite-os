/**
 * Real-time Agent Orchestrator
 * Manages all agents in a continuous loop with intelligent scheduling
 */

import { processRealtimeMarkovBlanket } from './realtime_markov_processor.js';
import { runCopyGeneratorEnhanced } from './copy_generator_enhanced.js';
import { runCreativeAssetsEnhanced } from './creative_assets_enhanced.js';
import { runObservationAgent } from './proper_observation_agent.js';
import { runAdjustmentAgent } from './proper_adjustment_agent.js';
import { runFeedbackRetrieverAgent } from './proper_feedback_retriever.js';

class RealtimeOrchestrator {
  constructor(brandId, config = {}) {
    this.brandId = brandId;
    this.config = {
      markovInterval: 5 * 60 * 1000, // 5 minutes
      contentInterval: 15 * 60 * 1000, // 15 minutes
      observationInterval: 2 * 60 * 1000, // 2 minutes
      adjustmentInterval: 10 * 60 * 1000, // 10 minutes
      feedbackInterval: 3 * 60 * 1000, // 3 minutes
      maxRetries: 3,
      retryDelay: 30 * 1000, // 30 seconds
      ...config
    };
    
    this.isRunning = false;
    this.intervals = {};
    this.lastRun = {};
    this.errorCount = {};
    this.stats = {
      markovRuns: 0,
      contentRuns: 0,
      observationRuns: 0,
      adjustmentRuns: 0,
      feedbackRuns: 0,
      errors: 0,
      startTime: null
    };
  }

  /**
   * Start the real-time orchestrator
   */
  async start() {
    if (this.isRunning) {
      console.log('⚠️ Orchestrator is already running');
      return;
    }

    console.log('🚀 Starting Real-time Agent Orchestrator...');
    console.log(`📊 Brand ID: ${this.brandId}`);
    console.log('⏰ Intervals:');
    console.log(`   Markov Blanket: ${this.config.markovInterval / 1000}s`);
    console.log(`   Content Generation: ${this.config.contentInterval / 1000}s`);
    console.log(`   Observations: ${this.config.observationInterval / 1000}s`);
    console.log(`   Adjustments: ${this.config.adjustmentInterval / 1000}s`);
    console.log(`   Feedback Retrieval: ${this.config.feedbackInterval / 1000}s`);

    this.isRunning = true;
    this.stats.startTime = new Date();

    // Start all agents with their respective intervals
    this.startMarkovProcessor();
    this.startContentGenerator();
    this.startObservationAgent();
    this.startAdjustmentAgent();
    this.startFeedbackRetriever();

    console.log('✅ Real-time Orchestrator started successfully!');
    console.log('📈 Monitoring all agents...');
  }

  /**
   * Stop the real-time orchestrator
   */
  stop() {
    if (!this.isRunning) {
      console.log('⚠️ Orchestrator is not running');
      return;
    }

    console.log('🛑 Stopping Real-time Orchestrator...');
    
    // Clear all intervals
    Object.values(this.intervals).forEach(interval => clearInterval(interval));
    this.intervals = {};
    
    this.isRunning = false;
    
    const runtime = this.stats.startTime ? 
      Math.round((Date.now() - this.stats.startTime.getTime()) / 1000) : 0;
    
    console.log('📊 Final Statistics:');
    console.log(`   Runtime: ${runtime}s`);
    console.log(`   Markov Runs: ${this.stats.markovRuns}`);
    console.log(`   Content Runs: ${this.stats.contentRuns}`);
    console.log(`   Observation Runs: ${this.stats.observationRuns}`);
    console.log(`   Adjustment Runs: ${this.stats.adjustmentRuns}`);
    console.log(`   Feedback Runs: ${this.stats.feedbackRuns}`);
    console.log(`   Total Errors: ${this.stats.errors}`);
    
    console.log('✅ Real-time Orchestrator stopped');
  }

  /**
   * Start Markov Blanket processor
   */
  startMarkovProcessor() {
    this.intervals.markov = setInterval(async () => {
      try {
        console.log('🧠 Running Markov Blanket processor...');
        const result = await this.runWithRetry(() => 
          processRealtimeMarkovBlanket(this.brandId)
        );
        
        if (result.success) {
          this.stats.markovRuns++;
          this.lastRun.markov = new Date();
          this.errorCount.markov = 0;
          console.log(`✅ Markov Blanket updated (${this.stats.markovRuns} runs)`);
        }
      } catch (error) {
        this.handleError('markov', error);
      }
    }, this.config.markovInterval);
  }

  /**
   * Start content generator (copy + creative assets)
   */
  startContentGenerator() {
    this.intervals.content = setInterval(async () => {
      try {
        console.log('✍️ Running content generator...');
        const result = await this.runWithRetry(() => 
          runCopyGeneratorEnhanced(this.brandId)
        );
        
        if (result.success) {
          this.stats.contentRuns++;
          this.lastRun.content = new Date();
          this.errorCount.content = 0;
          console.log(`✅ Content generated (${this.stats.contentRuns} runs)`);
          if (result.creativeAsset) {
            console.log(`🎨 Creative asset: ${result.creativeAsset.assetType}`);
          }
        }
      } catch (error) {
        this.handleError('content', error);
      }
    }, this.config.contentInterval);
  }

  /**
   * Start observation agent
   */
  startObservationAgent() {
    this.intervals.observation = setInterval(async () => {
      try {
        console.log('👁️ Running observation agent...');
        const result = await this.runWithRetry(() => 
          runObservationAgent(this.brandId)
        );
        
        if (result.success) {
          this.stats.observationRuns++;
          this.lastRun.observation = new Date();
          this.errorCount.observation = 0;
          console.log(`✅ Observations processed (${this.stats.observationRuns} runs)`);
        }
      } catch (error) {
        this.handleError('observation', error);
      }
    }, this.config.observationInterval);
  }

  /**
   * Start adjustment agent
   */
  startAdjustmentAgent() {
    this.intervals.adjustment = setInterval(async () => {
      try {
        console.log('⚙️ Running adjustment agent...');
        const result = await this.runWithRetry(() => 
          runAdjustmentAgent(this.brandId)
        );
        
        if (result.success) {
          this.stats.adjustmentRuns++;
          this.lastRun.adjustment = new Date();
          this.errorCount.adjustment = 0;
          console.log(`✅ Adjustments processed (${this.stats.adjustmentRuns} runs)`);
        }
      } catch (error) {
        this.handleError('adjustment', error);
      }
    }, this.config.adjustmentInterval);
  }

  /**
   * Start feedback retriever agent
   */
  startFeedbackRetriever() {
    this.intervals.feedback = setInterval(async () => {
      try {
        console.log('📥 Running feedback retriever...');
        const result = await this.runWithRetry(() => 
          runFeedbackRetrieverAgent(this.brandId)
        );
        
        if (result.success) {
          this.stats.feedbackRuns++;
          this.lastRun.feedback = new Date();
          this.errorCount.feedback = 0;
          console.log(`✅ Feedback retrieved (${this.stats.feedbackRuns} runs)`);
        }
      } catch (error) {
        this.handleError('feedback', error);
      }
    }, this.config.feedbackInterval);
  }

  /**
   * Run function with retry logic
   */
  async runWithRetry(fn, retries = this.config.maxRetries) {
    try {
      return await fn();
    } catch (error) {
      if (retries > 0) {
        console.log(`⚠️ Retrying in ${this.config.retryDelay / 1000}s... (${retries} retries left)`);
        await new Promise(resolve => setTimeout(resolve, this.config.retryDelay));
        return this.runWithRetry(fn, retries - 1);
      }
      throw error;
    }
  }

  /**
   * Handle errors with exponential backoff
   */
  handleError(agent, error) {
    this.stats.errors++;
    this.errorCount[agent] = (this.errorCount[agent] || 0) + 1;
    
    console.error(`❌ ${agent} agent error:`, error.message);
    
    // If too many errors, temporarily disable the agent
    if (this.errorCount[agent] >= 5) {
      console.log(`🚫 Temporarily disabling ${agent} agent due to repeated errors`);
      if (this.intervals[agent]) {
        clearInterval(this.intervals[agent]);
        delete this.intervals[agent];
        
        // Re-enable after 10 minutes
        setTimeout(() => {
          console.log(`🔄 Re-enabling ${agent} agent`);
          this.errorCount[agent] = 0;
          if (agent === 'markov') this.startMarkovProcessor();
          else if (agent === 'content') this.startContentGenerator();
          else if (agent === 'observation') this.startObservationAgent();
          else if (agent === 'adjustment') this.startAdjustmentAgent();
          else if (agent === 'feedback') this.startFeedbackRetriever();
        }, 10 * 60 * 1000);
      }
    }
  }

  /**
   * Get current status
   */
  getStatus() {
    return {
      isRunning: this.isRunning,
      stats: this.stats,
      lastRun: this.lastRun,
      errorCount: this.errorCount,
      uptime: this.stats.startTime ? 
        Math.round((Date.now() - this.stats.startTime.getTime()) / 1000) : 0
    };
  }

  /**
   * Get health check
   */
  getHealthCheck() {
    const now = Date.now();
    const health = {
      status: 'healthy',
      agents: {},
      issues: []
    };

    // Check each agent
    const agents = ['markov', 'content', 'observation', 'adjustment', 'feedback'];
    agents.forEach(agent => {
      const lastRun = this.lastRun[agent];
      const errorCount = this.errorCount[agent] || 0;
      
      if (!lastRun) {
        health.agents[agent] = 'not_started';
        health.issues.push(`${agent} agent has not run yet`);
      } else {
        const timeSinceLastRun = now - lastRun.getTime();
        const expectedInterval = this.config[`${agent}Interval`] || 60000;
        
        if (timeSinceLastRun > expectedInterval * 2) {
          health.agents[agent] = 'stale';
          health.issues.push(`${agent} agent hasn't run in ${Math.round(timeSinceLastRun / 1000)}s`);
        } else if (errorCount > 3) {
          health.agents[agent] = 'error_prone';
          health.issues.push(`${agent} agent has ${errorCount} recent errors`);
        } else {
          health.agents[agent] = 'healthy';
        }
      }
    });

    if (health.issues.length > 0) {
      health.status = 'degraded';
    }

    return health;
  }
}

export default RealtimeOrchestrator;
