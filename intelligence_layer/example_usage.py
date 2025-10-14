#!/usr/bin/env python3
"""
Big Appetite OS - Intelligence Layer Examples
============================================================

This script demonstrates how to use the intelligence layer functions
for analyzing customer signals and building actor profiles.
"""

import os
import sys
from datetime import datetime

# Add the src directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from src import (
    analyze_signal,
    detect_quantum_effects, 
    detect_identity_fragments,
    process_signal_complete,
    analyze_signal_batch,
    get_cost_summary
)

def example_signal_analysis():
    """Example 1: Basic signal analysis"""
    print("=" * 60)
    print("EXAMPLE 1: Basic Signal Analysis")
    print("=" * 60)
    
    signal = "I love the premium wings, they are so exclusive and everyone is talking about them!"
    
    result = analyze_signal(
        signal_text=signal,
        context={'source': 'whatsapp', 'timestamp': datetime.now().isoformat()}
    )
    
    if result['success']:
        print(f"Signal: {signal}")
        print(f"Dominant Driver: {result['dominant_driver']}")
        print(f"Confidence: {result['confidence']:.2f}")
        print(f"Reasoning: {result['reasoning']}")
        print(f"Model Used: {result.get('model_used', 'Unknown')}")
        print(f"API Cost: ${result.get('api_cost', 0.0):.4f}")
    else:
        print(f"Signal analysis failed: {result['error']}")
        print(f"Signal: {signal}")
        print(f"Dominant Driver: {result['dominant_driver']}")
        print(f"Confidence: {result['confidence']:.2f}")
        print(f"Reasoning: {result['reasoning']}")
        print(f"Model Used: {result.get('model_used', 'Unknown')}")
        print(f"API Cost: ${result.get('api_cost', 0.0):.4f}")

def example_quantum_effects():
    """Example 2: Quantum effects detection"""
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Quantum Effects Detection")
    print("=" * 60)
    
    # Example driver distribution
    driver_distribution = {
        'Safety': 0.4,
        'Connection': 0.1, 
        'Status': 0.35,
        'Growth': 0.05,
        'Freedom': 0.05,
        'Purpose': 0.05
    }
    
    result = detect_quantum_effects(
        driver_distribution=driver_distribution,
        signal_text="I want to try something new but I'm worried about the spice level",
        context={'source': 'whatsapp'}
    )
    
    if result['success']:
        print(f"Driver Distribution: {driver_distribution}")
        print(f"Superposition Detected: {result['superposition_detected']}")
        print(f"Interfering Drivers: {result['interfering_drivers']}")
        print(f"Interference Strength: {result['interference_strength']:.2f}")
        print(f"Coherence: {result['coherence']:.2f}")
        print(f"Model Used: {result.get('model_used', 'None')}")
        print(f"API Cost: ${result.get('api_cost', 0.0):.4f}")
    else:
        print(f"Quantum effects detection failed: {result['error']}")
        print(f"Driver Distribution: {driver_distribution}")
        print(f"Superposition Detected: {result['superposition_detected']}")
        print(f"Interfering Drivers: {result['interfering_drivers']}")
        print(f"Interference Strength: {result['interference_strength']:.2f}")
        print(f"Coherence: {result['coherence']:.2f}")
        print(f"Model Used: {result.get('model_used', 'None')}")
        print(f"API Cost: ${result.get('api_cost', 0.0):.4f}")

def example_identity_detection():
    """Example 3: Identity fragment detection"""
    print("\n" + "=" * 60)
    print("EXAMPLE 3: Identity Fragment Detection")
    print("=" * 60)
    
    signal = "I always order for my family, making sure everyone gets what they like. Today I'm trying something new to impress my friends."
    
    result = detect_identity_fragments(
        signal_text=signal,
        context={'source': 'whatsapp'}
    )
    
    if result['success']:
        print(f"Signal: {signal}")
        print(f"Primary Identity: {result['primary_identity']}")
        print(f"Secondary Identity: {result['secondary_identity']}")
        print(f"Identity Coherence: {result['identity_coherence']:.2f}")
        print(f"Fragmentation Detected: {result['fragmentation_detected']}")
        print(f"Model Used: {result.get('model_used', 'Unknown')}")
        print(f"API Cost: ${result.get('api_cost', 0.0):.4f}")
    else:
        print(f"Identity detection failed: {result['error']}")
        print(f"Signal: {signal}")
        print(f"Primary Identity: {result.get('primary_identity', 'Unknown')}")
        print(f"Secondary Identity: {result.get('secondary_identity', 'Unknown')}")
        print(f"Identity Coherence: {result.get('identity_coherence', 0.0):.2f}")
        print(f"Fragmentation Detected: {result.get('fragmentation_detected', False)}")
        print(f"Model Used: {result.get('model_used', 'Unknown')}")
        print(f"API Cost: ${result.get('api_cost', 0.0):.4f}")

def example_complete_processing():
    """Example 4: Complete signal processing"""
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Complete Signal Processing")
    print("=" * 60)
    
    print("Note: This example requires a valid signal_id from your database")
    print("To test this, you would run:")
    print()
    print("result = process_signal_complete(")
    print("    signal_id='your-signal-id-here'")
    print(")")
    print()
    print("This would:")
    print("1. Read signal from database")
    print("2. Analyze drivers, quantum effects, and identity")
    print("3. Update actor profile (database generates actor_id)")
    print("4. Log decoder output")
    print("5. Return 7-column analysis")

def example_batch_processing():
    """Example 5: Batch processing"""
    print("\n" + "=" * 60)
    print("EXAMPLE 5: Batch Processing")
    print("=" * 60)
    
    # Example signals
    signals = [
        "I love the spicy wings, they're perfect!",
        "Can I get the mild wings please? I don't like spicy food.",
        "The premium wings are worth every penny!",
        "I always order the same thing, it's reliable."
    ]
    
    print("Processing batch of signals...")
    results = analyze_signal_batch(signals)
    
    print(f"Processed {len(results)} signals:")
    for i, result in enumerate(results, 1):
        if result['success']:
            print(f"  {i}. Dominant: {result['dominant_driver']} (Confidence: {result['confidence']:.2f})")
        else:
            print(f"  {i}. Failed: {result['error']}")

def main():
    """Run all examples"""
    print("Big Appetite OS - Intelligence Layer Examples")
    print("=" * 60)
    
    try:
        example_signal_analysis()
        example_quantum_effects()
        example_identity_detection()
        example_complete_processing()
        example_batch_processing()
        
        print("\n" + "=" * 60)
        print("All examples completed!")
        print("=" * 60)
        
    except Exception as e:
        print(f"\nError running examples: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
