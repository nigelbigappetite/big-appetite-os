/**
 * Quantum Agent Scheduler
 * Automates the execution of the agent integration pipeline
 * 
 * This scheduler runs periodic jobs to:
 * - Process posts that are 24-48 hours old
 * - Maintain belief driver weights
 * - Generate new optimized content
 */

import { processReadyPosts, processPost, getProcessingStats } from './agent-integration-service'
import * as cron from 'node-cron'

export interface SchedulerConfig {
  brandId?: string
  enabled: boolean
  processIntervalMinutes: number
  processSchedule?: string // Cron expression
  batchSize: number
  minPostAgeHours: number
  maxPostAgeHours: number
}

export class QuantumAgentScheduler {
  private config: SchedulerConfig
  private taskId: string | null = null
  private isRunning: boolean = false

  constructor(config?: Partial<SchedulerConfig>) {
    this.config = {
      enabled: true,
      processIntervalMinutes: 30,
      processSchedule: '0 */6 * * *', // Every 6 hours
      batchSize: 10,
      minPostAgeHours: 1, // Changed from 24 for testing
      maxPostAgeHours: 72,
      ...config
    }
  }

  /**
   * Start the scheduler
   */
  start(): void {
    if (this.isRunning) {
      console.log('⚠️ Scheduler already running')
      return
    }

    if (!this.config.enabled) {
      console.log('⚠️ Scheduler is disabled in config')
      return
    }

    console.log('🚀 Starting Quantum Agent Scheduler...')
    console.log(`   Schedule: ${this.config.processSchedule}`)
    console.log(`   Min age: ${this.config.minPostAgeHours} hours`)
    console.log(`   Max age: ${this.config.maxPostAgeHours} hours`)

    // Schedule the main processing task
    if (this.config.processSchedule) {
      this.taskId = this.config.processSchedule
      
      cron.schedule(this.config.processSchedule, async () => {
        await this.runProcessingCycle()
      })

      console.log('✅ Scheduler started')
    } else {
      console.error('❌ No schedule configured')
    }

    this.isRunning = true
  }

  /**
   * Stop the scheduler
   */
  stop(): void {
    if (this.taskId) {
      cron.destroy()
      this.taskId = null
      this.isRunning = false
      console.log('🛑 Scheduler stopped')
    }
  }

  /**
   * Run a single processing cycle
   */
  async runProcessingCycle(): Promise<void> {
    console.log('\n⏰ Running scheduled processing cycle...')
    const startTime = Date.now()

    try {
      // Get stats before processing
      const statsBefore = await getProcessingStats(this.config.brandId)
      console.log(`📊 Stats: ${statsBefore.pending} pending, ${statsBefore.processed} processed`)

      // Process ready posts
      const results = await processReadyPosts(this.config.brandId, {
        minAge: this.config.minPostAgeHours * 60 * 60 * 1000,
        maxAge: this.config.maxPostAgeHours * 60 * 60 * 1000,
        limit: this.config.batchSize
      })

      // Get stats after processing
      const statsAfter = await getProcessingStats(this.config.brandId)
      
      const successful = results.filter(r => r.success).length
      const failed = results.filter(r => !r.success).length
      
      const duration = (Date.now() - startTime) / 1000

      console.log(`\n✅ Processing cycle complete`)
      console.log(`   Processed: ${results.length} posts`)
      console.log(`   Successful: ${successful}`)
      console.log(`   Failed: ${failed}`)
      console.log(`   Duration: ${duration.toFixed(1)}s`)
      console.log(`   Pending posts remaining: ${statsAfter.pending}`)

    } catch (error: any) {
      console.error('❌ Processing cycle failed:', error.message)
    }
  }

  /**
   * Get current status
   */
  getStatus(): {
    running: boolean
    config: SchedulerConfig
  } {
    return {
      running: this.isRunning,
      config: this.config
    }
  }

  /**
   * Update configuration
   */
  updateConfig(config: Partial<SchedulerConfig>): void {
    const wasRunning = this.isRunning

    if (wasRunning) {
      this.stop()
    }

    this.config = {
      ...this.config,
      ...config
    }

    if (wasRunning) {
      this.start()
    }

    console.log('⚙️ Configuration updated')
  }

  /**
   * Manually trigger a processing cycle (for testing)
   */
  async triggerNow(): Promise<void> {
    console.log('🔧 Manually triggering processing cycle...')
    await this.runProcessingCycle()
  }

  /**
   * Process a specific post now (bypasses age constraints)
   */
  async processPostNow(postId: string): Promise<void> {
    console.log(`🔧 Manually processing post ${postId}...`)
    const result = await processPost(postId)
    
    if (result.success) {
      console.log(`✅ Post ${postId} processed successfully`)
    } else {
      console.error(`❌ Failed to process post ${postId}`)
      console.error(`   Errors: ${result.errors.join(', ')}`)
    }
  }
}

// Global instance for convenience
let globalScheduler: QuantumAgentScheduler | null = null

/**
 * Initialize and start the global scheduler
 */
export function startScheduler(config?: Partial<SchedulerConfig>): QuantumAgentScheduler {
  if (globalScheduler) {
    console.log('⚠️ Scheduler already initialized')
    return globalScheduler
  }

  globalScheduler = new QuantumAgentScheduler(config)
  globalScheduler.start()

  return globalScheduler
}

/**
 * Stop the global scheduler
 */
export function stopScheduler(): void {
  if (globalScheduler) {
    globalScheduler.stop()
    globalScheduler = null
  }
}

/**
 * Get the global scheduler instance
 */
export function getScheduler(): QuantumAgentScheduler | null {
  return globalScheduler
}

// CLI interface for running from command line
// Check if this file is being run directly (ESM equivalent of require.main === module)
const isMainModule = import.meta.url === `file://${process.argv[1]}` || 
                      process.argv[1]?.includes('quantum-agent-scheduler.ts')

if (isMainModule) {
  import('dotenv').then(({ default: dotenv }) => {
    dotenv.config()

    const args = process.argv.slice(2)
    const command = args[0]

    const scheduler = startScheduler({
      brandId: process.env.BRAND_ID,
      processSchedule: '0 */6 * * *' // Every 6 hours
    })

    if (command === 'trigger') {
      scheduler.triggerNow()
    } else if (command === 'process' && args[1]) {
      scheduler.processPostNow(args[1])
    } else {
      console.log('Quantum Agent Scheduler running...')
      console.log('Commands:')
      console.log('  npm run quantum:trigger    - Manually trigger processing')
      console.log('  npm run quantum:process <id> - Process specific post')
    }
  })
}

