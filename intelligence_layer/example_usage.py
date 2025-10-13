#!/usr/bin/env python3
"""
Example usage of the Big Appetite OS Intelligence Layer
Demonstrates all four core functions
"""

import os
import sys
from datetime import datetime

# Add src to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from src import (
    analyze_signal, 
    detect_quantum_effects, 
    detect_identity_fragments,
    process_signal_complete,
    get_cost_summary
)

def example_signal_analysis():
    """Example 1: Basic signal analysis"""
    print("=" * 60)
    print("EXAMPLE 1: Basic Signal Analysis")
    print("=" * 60)
    
    signal_text = "I love the premium wings, they are so exclusive and everyone is talking about them!"
    
    result = analyze_signal(
        signal_text=signal_text,
        actor_id=None,
        signal_context={"context": "social", "audience": "friends"}
    )
    
    print(f"Signal: {signal_text}")
    print(f"Dominant Driver: {max(result['driver_distribution'], key=result['driver_distribution'].get)}")
    print(f"Confidence: {result['confidence']:.2f}")
    print(f"Reasoning: {result['reasoning']}")
    print(f"Model Used: {result.get('model_used', 'Unknown')}")
    print(f"API Cost: ${result.get('api_cost', 0):.4f}")
    print()

def example_quantum_detection():
    """Example 2: Quantum effects detection"""
    print("=" * 60)
    print("EXAMPLE 2: Quantum Effects Detection")
    print("=" * 60)
    
    # Simulate conflicting driver distribution
    driver_distribution = {
        "Safety": 0.4,
        "Connection": 0.1,
        "Status": 0.35,
        "Growth": 0.05,
        "Freedom": 0.05,
        "Purpose": 0.05
    }
    
    result = detect_quantum_effects(
        driver_distribution=driver_distribution,
        signal_context={"context": "social", "audience": "friends"}
    )
    
    print(f"Driver Distribution: {driver_distribution}")
    print(f"Superposition Detected: {result['superposition_detected']}")
    print(f"Interfering Drivers: {result['interfering_drivers']}")
    print(f"Interference Strength: {result['interference_strength']:.2f}")
    print(f"Coherence: {result['coherence']:.2f}")
    print(f"Model Used: {result.get('model_used', 'None')}")
    print(f"API Cost: ${result.get('api_cost', 0):.4f}")
    print()

def example_identity_detection():
    """Example 3: Identity fragment detection"""
    print("=" * 60)
    print("EXAMPLE 3: Identity Fragment Detection")
    print("=" * 60)
    
    signal_text = "I always order for my family, making sure everyone gets what they like. Today I'm trying something new to impress my friends."
    
    result = detect_identity_fragments(
        signal_text=signal_text,
        behavioral_history=None,
        existing_identities=None
    )
    
    print(f"Signal: {signal_text}")
    print(f"Primary Identity: {result.get('primary_identity', {}).get('label', 'None')}")
    print(f"Secondary Identity: {result.get('secondary_identity', {}).get('label', 'None')}")
    print(f"Identity Coherence: {result.get('identity_coherence', 0):.2f}")
    print(f"Fragmentation Detected: {result.get('fragmentation_detected', False)}")
    print(f"Model Used: {result.get('model_used', 'None')}")
    print(f"API Cost: ${result.get('api_cost', 0):.4f}")
    print()

def example_complete_processing():
    """Example 4: Complete signal processing (requires database)"""
    print("=" * 60)
    print("EXAMPLE 4: Complete Signal Processing")
    print("=" * 60)
    
    print("Note: This example requires a valid signal_id from your database")
    print("To test this, you would run:")
    print()
    print("result = process_signal_complete(")
    print("    signal_id='your-signal-id-here',")
    print("    actor_id='your-actor-id-here'")
    print(")")
    print()
    print("This would:")
    print("1. Read signal from database")
    print("2. Analyze drivers, quantum effects, and identity")
    print("3. Update actor profile")
    print("4. Log decoder output")
    print("5. Return 7-column analysis")
    print()

def example_batch_processing():
    """Example 5: Batch processing"""
    print("=" * 60)
    print("EXAMPLE 5: Batch Processing")
    print("=" * 60)
    
    # Example signals for batch processing
    signals = [
        {
            "signal_text": "I always get the same thing, it's reliable",
            "actor_id": None,  # Will be generated automatically
            "signal_context": {"context": "private"}
        },
        {
            "signal_text": "I love trying new flavors, what's the spiciest?",
            "actor_id": None,  # Will be generated automatically
            "signal_context": {"context": "social"}
        },
        {
            "signal_text": "The premium wings are worth every penny",
            "actor_id": None,  # Will be generated automatically
            "signal_context": {"context": "social"}
        }
    ]
    
    from src import analyze_signal_batch
    
    print("Processing batch of signals...")
    results = analyze_signal_batch(signals)
    
    print(f"Processed {len(results)} signals")
    for i, result in enumerate(results):
        dominant = max(result['driver_distribution'], key=result['driver_distribution'].get)
        print(f"  Signal {i+1}: {dominant} driver (confidence: {result['confidence']:.2f})")
    
    total_cost = sum(r.get('api_cost', 0) for r in results)
    print(f"Total API Cost: ${total_cost:.4f}")
    print()

def example_cost_tracking():
    """Example 6: Cost tracking"""
    print("=" * 60)
    print("EXAMPLE 6: Cost Tracking")
    print("=" * 60)
    
    try:
        summary = get_cost_summary("today")
        print(f"Today's Usage Summary:")
        print(f"  Signals Processed: {summary.get('signal_count', 0)}")
        print(f"  gpt-4o-mini Calls: {summary.get('mini_calls', 0)}")
        print(f"  gpt-4o Calls: {summary.get('gpt4_calls', 0)}")
        print(f"  Total Cost: ${summary.get('total_cost', 0):.2f}")
    except Exception as e:
        print(f"Cost tracking not available: {e}")
    print()

def example_model_selection():
    """Example 7: Model selection strategy"""
    print("=" * 60)
    print("EXAMPLE 7: Model Selection Strategy")
    print("=" * 60)
    
    from src.llm_client import llm_client
    
    # Test different signal complexities
    test_signals = [
        ("my usual please", "Simple signal"),
        ("I love the premium wings, they are so exclusive and everyone is talking about them!", "Complex signal"),
        ("I usually order mild but today I'm feeling adventurous and want to try something completely different that will impress my friends", "Contradictory signal")
    ]
    
    for signal_text, description in test_signals:
        complexity = llm_client.calculate_complexity(signal_text)
        model = llm_client.select_model(signal_text)
        
        print(f"{description}:")
        print(f"  Signal: {signal_text}")
        print(f"  Complexity: {complexity:.2f}")
        print(f"  Selected Model: {model}")
        print()

def main():
    """Run all examples"""
    print("Big Appetite OS - Intelligence Layer Examples")
    print("=" * 60)
    print()
    
    # Check if environment variables are set
    required_vars = ["OPENAI_API_KEY", "SUPABASE_URL", "SUPABASE_KEY"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print("⚠️  WARNING: Missing environment variables:")
        for var in missing_vars:
            print(f"   - {var}")
        print()
        print("Set these variables to run the examples:")
        print("export OPENAI_API_KEY='your-key'")
        print("export SUPABASE_URL='your-url'")
        print("export SUPABASE_KEY='your-key'")
        print()
        print("Continuing with examples that don't require API calls...")
        print()
    
    # Run examples
    example_signal_analysis()
    example_quantum_detection()
    example_identity_detection()
    example_complete_processing()
    example_batch_processing()
    example_cost_tracking()
    example_model_selection()
    
    print("=" * 60)
    print("Examples completed!")
    print("=" * 60)

if __name__ == "__main__":
    main()
