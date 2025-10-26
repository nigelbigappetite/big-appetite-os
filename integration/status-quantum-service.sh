#!/bin/bash
# Check status of Quantum Agent Service

PID_FILE=".quantum-agent.pid"

echo "📊 Quantum Agent Service Status"
echo "================================"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ Status: Running"
        echo "   PID: $PID"
        echo "   Started: $(ps -p $PID -o lstart=)"
        echo ""
        echo "📝 Recent logs:"
        tail -n 20 quantum-agent.log 2>/dev/null || echo "   No log file found"
    else
        echo "⚠️ Status: Not running (stale PID file)"
        rm "$PID_FILE"
    fi
else
    if pgrep -f "quantum-agent-scheduler" > /dev/null; then
        echo "⚠️ Status: Running (no PID file)"
        echo "   PID: $(pgrep -f 'quantum-agent-scheduler')"
    else
        echo "❌ Status: Not running"
    fi
fi

echo ""
echo "📋 Commands:"
echo "   Start: ./integration/start-quantum-service.sh"
echo "   Stop: ./integration/stop-quantum-service.sh"
echo "   Logs: tail -f quantum-agent.log"
