#!/bin/bash
# Start Quantum Agent Service in Background
# This script runs the scheduler as a background service

echo "🚀 Starting Quantum Agent Service..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if already running
if pgrep -f "quantum-agent-scheduler" > /dev/null; then
    echo "⚠️ Quantum Agent Service is already running"
    echo "   PID: $(pgrep -f 'quantum-agent-scheduler')"
    echo "   Use: ./integration/stop-quantum-service.sh to stop"
    exit 1
fi

# Start the service in background
nohup ./node_modules/.bin/tsx integration/quantum-agent-scheduler.ts > quantum-agent.log 2>&1 &

# Get the PID
PID=$!

echo "✅ Quantum Agent Service started"
echo "   PID: $PID"
echo "   Log file: quantum-agent.log"
echo "   To stop: ./integration/stop-quantum-service.sh"
echo ""
echo "Monitor logs: tail -f quantum-agent.log"

# Save PID to file
echo $PID > .quantum-agent.pid
