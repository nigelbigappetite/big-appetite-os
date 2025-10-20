# 🚀 Big Appetite OS - Real-time System

A fully automated, real-time version of the Big Appetite OS that runs all agents continuously with intelligent scheduling and monitoring.

## 🎯 What This Does

The real-time system automatically:
- **Processes feedback** every 3 minutes
- **Updates Markov Blankets** every 5 minutes (instead of weekly)
- **Generates content** every 15 minutes
- **Makes observations** every 2 minutes
- **Applies adjustments** every 10 minutes
- **Monitors system health** continuously

## 🚀 Quick Start

### Option 1: Using the startup script (Recommended)
```bash
./start_realtime.sh [brand_id]
```

### Option 2: Using npm scripts
```bash
# Start the real-time system
npm run realtime

# Monitor the system (in another terminal)
npm run monitor
```

### Option 3: Direct execution
```bash
# Start the system
node start_realtime_system.js [brand_id]

# Monitor the system (in another terminal)
node monitor_system.js [brand_id]
```

## 📊 System Components

### 1. Real-time Markov Processor (`agents/realtime_markov_processor.js`)
- Processes feedback data every 5 minutes
- Updates Markov Blankets in real-time
- Analyzes sentiment, themes, and patterns
- Replaces the weekly batch process

### 2. Agent Orchestrator (`agents/realtime_orchestrator.js`)
- Manages all agents with intelligent scheduling
- Handles retries and error recovery
- Provides health monitoring
- Automatically disables problematic agents

### 3. System Monitor (`monitor_system.js`)
- Real-time dashboard showing system status
- Activity metrics and health checks
- Sentiment analysis and content generation stats
- Updates every 30 seconds

### 4. Startup Manager (`start_realtime_system.js`)
- Validates environment and dependencies
- Handles graceful shutdown
- Provides comprehensive logging
- Error handling and recovery

## ⚙️ Configuration

### Environment Variables
Create a `.env` file with:
```env
OPENAI_API_KEY=your_openai_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Optional: Customize intervals (in milliseconds)
MARKOV_INTERVAL=300000      # 5 minutes
CONTENT_INTERVAL=900000     # 15 minutes
OBSERVATION_INTERVAL=120000 # 2 minutes
ADJUSTMENT_INTERVAL=600000  # 10 minutes
FEEDBACK_INTERVAL=180000    # 3 minutes
```

### Agent Intervals
- **Markov Blanket**: 5 minutes (processes recent feedback)
- **Content Generation**: 15 minutes (copy + creative assets)
- **Observations**: 2 minutes (monitors brand state)
- **Adjustments**: 10 minutes (updates belief drivers)
- **Feedback Retrieval**: 3 minutes (collects new feedback)

## 📈 Monitoring

### Real-time Dashboard
The monitor shows:
- Recent activity counts
- Markov Blanket freshness
- Content generation status
- Feedback sentiment analysis
- System health indicators

### Health Checks
- Database connectivity
- Agent activity status
- Error rates and recovery
- Last activity timestamps

### Logs
The system provides detailed logging:
- Agent execution status
- Error messages and retries
- Performance metrics
- Health check results

## 🔧 Troubleshooting

### Common Issues

1. **"No recent feedback to process"**
   - Normal when starting fresh
   - System will process data as it becomes available

2. **"Agent temporarily disabled"**
   - Happens after 5 consecutive errors
   - Agent re-enables after 10 minutes
   - Check logs for specific error details

3. **"Database connection failed"**
   - Check your Supabase credentials
   - Verify network connectivity
   - Ensure database is accessible

4. **"Missing environment variables"**
   - Create `.env` file with required variables
   - Restart the system after adding variables

### Debug Mode
Run with debug logging:
```bash
LOG_LEVEL=debug node start_realtime_system.js
```

## 🛑 Stopping the System

### Graceful Shutdown
- Press `Ctrl+C` to stop gracefully
- System will complete current operations
- All agents will be stopped cleanly

### Force Stop
- Press `Ctrl+C` twice for immediate stop
- May leave some operations incomplete

## 📊 Performance

### Expected Performance
- **Markov Updates**: Every 5 minutes
- **Content Generation**: Every 15 minutes
- **System Response**: < 2 seconds per operation
- **Memory Usage**: ~50-100MB
- **CPU Usage**: Low (mostly I/O bound)

### Scaling
- Can run multiple brand IDs simultaneously
- Each brand runs independently
- Database handles concurrent operations

## 🔄 Migration from Weekly to Real-time

### What Changes
1. **Markov Blankets**: Now update every 5 minutes instead of weekly
2. **Content Generation**: Automatic every 15 minutes
3. **Feedback Processing**: Continuous instead of batch
4. **System Monitoring**: Real-time health checks

### Data Compatibility
- All existing data remains compatible
- No migration required
- Can switch back to weekly mode anytime

## 🚨 Important Notes

1. **API Costs**: Real-time processing uses more OpenAI API calls
2. **Database Load**: More frequent database operations
3. **Monitoring**: Keep an eye on system health
4. **Backup**: Regular database backups recommended

## 📞 Support

If you encounter issues:
1. Check the logs for error messages
2. Verify environment variables
3. Test database connectivity
4. Check OpenAI API key validity

## 🎉 Success!

Once running, your Big Appetite OS will:
- ✅ Process feedback in real-time
- ✅ Update brand understanding continuously
- ✅ Generate content automatically
- ✅ Adapt to customer behavior
- ✅ Provide real-time insights

The system is now fully autonomous and learning! 🧠✨
