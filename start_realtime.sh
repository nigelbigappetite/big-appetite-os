#!/bin/bash

# Big Appetite OS - Real-time System Startup Script
# This script starts the entire system in real-time mode

echo "🚀 Starting Big Appetite OS Real-time System..."
echo "=============================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Created .env file from example"
        echo "📝 Please edit .env file with your API keys before continuing"
        exit 1
    else
        echo "❌ No .env.example file found. Please create .env file manually"
        exit 1
    fi
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if OpenAI API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OPENAI_API_KEY not found in environment"
    echo "📝 Please set your OpenAI API key in the .env file"
    exit 1
fi

# Get brand ID from command line or use default
BRAND_ID=${1:-"a1b2c3d4-e5f6-7890-1234-567890abcdef"}

echo "🏷️  Brand ID: $BRAND_ID"
echo ""

# Start the real-time system
echo "🚀 Launching real-time system..."
node start_realtime_system.js "$BRAND_ID"
