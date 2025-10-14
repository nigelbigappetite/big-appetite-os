#!/bin/bash

# Big Appetite OS - Stage 1 Runner
# This script sets environment variables and runs Stage 1

echo "🚀 Big Appetite OS - Stage 1: Actor Identification"
echo "=================================================="
echo ""

# Check if .env file exists
if [ -f ".env" ]; then
    echo "📁 Loading .env file..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  No .env file found"
    echo "Please set your Supabase credentials:"
    echo ""
    read -p "Supabase URL: " SUPABASE_URL
    read -p "Supabase Service Role Key: " SUPABASE_SERVICE_ROLE_KEY
    read -p "Supabase Anon Key (optional): " SUPABASE_ANON_KEY
    
    export SUPABASE_URL
    export SUPABASE_SERVICE_ROLE_KEY
    export SUPABASE_ANON_KEY
fi

echo ""
echo "🔧 Environment variables set"
echo "📡 Supabase URL: ${SUPABASE_URL:0:30}..."
echo "🔑 Service Key: ${SUPABASE_SERVICE_ROLE_KEY:0:20}..."
echo ""

# Test connection first
echo "🔌 Testing connection..."
node scripts/test-connection.js

if [ $? -eq 0 ]; then
    echo ""
    echo "🚀 Starting Stage 1..."
    node scripts/run-stage1.js
else
    echo ""
    echo "❌ Connection test failed. Please check your credentials."
    exit 1
fi
