#!/bin/bash
# Stop Quantum Agent Service

PID_FILE=".quantum-agent.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "🛑 Stopping Quantum Agent Service (PID: $PID)..."
        kill $PID
        rm "$PID_FILE"
        echo "✅ Quantum Agent Service stopped"
    else
        echo "⚠️ Process not running (stale PID file)"
        rm "$PID_FILE"
    fi
else
    echo "⚠️ No PID file found"
    echo "   Attempting to find and kill by process name..."
    pkill -f "quantum-agent-scheduler"
    if [ $? -eq 0 ]; then
        echo "✅ Quantum Agent Service stopped"
    else
        echo "❌ No running process found"
    fi
fi
