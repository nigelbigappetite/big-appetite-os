#!/usr/bin/env python3
"""
Pattern Analysis Main Script

Analyzes patterns in 299 actor profiles to discover insights for clustering.
This script performs comprehensive statistical analysis and generates visualizations.

Usage:
    python run_pattern_analysis.py

Outputs:
    - Statistical analysis results
    - Visualizations (7 charts)
    - Comprehensive markdown report
    - Pattern insights for clustering
"""

import os
import sys
from pathlib import Path

# Add pattern_clustering to path
ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.append(ROOT)

from pattern_analysis import (
    get_actor_profiles,
    export_to_dataframe,
    analyze_driver_distributions,
    analyze_contradictions,
    analyze_quantum_states,
    calculate_correlations,
    create_all_visualizations,
    generate_pattern_report
)

def main():
    """Main function to run pattern analysis."""
    print("🔍 Starting Pattern Analysis...")
    print("="*60)
    
    try:
        # Load data
        print("\n1. Loading actor profiles from database...")
        actors = get_actor_profiles(min_signals=1, include_quantum=True)
        print(f"   ✓ Loaded {len(actors)} actor profiles")
        
        if len(actors) < 10:
            print("   ⚠️  Warning: Very few actors available for analysis")
        
        # Convert to DataFrame
        print("\n2. Converting to DataFrame...")
        df = export_to_dataframe(actors)
        print(f"   ✓ DataFrame created: {df.shape[0]} rows, {df.shape[1]} columns")
        
        # Analyze patterns
        print("\n3. Analyzing driver distributions...")
        driver_stats = analyze_driver_distributions(actors)
        print(f"   ✓ Average Safety: {driver_stats['averages']['Safety']:.3f}")
        print(f"   ✓ Dominant driver: {max(driver_stats['dominant_driver_counts'], key=driver_stats['dominant_driver_counts'].get)}")
        
        print("\n4. Analyzing contradictions...")
        contradiction_stats = analyze_contradictions(actors)
        print(f"   ✓ High contradiction actors: {len(contradiction_stats['high_contradiction_actors'])} ({len(contradiction_stats['high_contradiction_actors'])/len(actors)*100:.1f}%)")
        
        print("\n5. Analyzing quantum states...")
        quantum_stats = analyze_quantum_states(actors)
        if quantum_stats.get('quantum_data_available', False):
            print(f"   ✓ Superposition prevalence: {quantum_stats['superposition_prevalence']:.1f}%")
        else:
            print("   ⚠️  No quantum data available")
        
        print("\n6. Calculating correlations...")
        correlation_matrix, strong_positive, strong_negative = calculate_correlations(actors)
        print(f"   ✓ Strong positive correlations: {len(strong_positive)}")
        print(f"   ✓ Strong negative correlations: {len(strong_negative)}")
        
        # Create visualizations
        print("\n7. Generating visualizations...")
        create_all_visualizations(actors, driver_stats, contradiction_stats, quantum_stats)
        print(f"   ✓ Created 7 visualization files in outputs/visualizations/")
        
        # Generate report
        print("\n8. Generating pattern analysis report...")
        report = generate_pattern_report(actors, driver_stats, contradiction_stats, quantum_stats)
        print(f"   ✓ Report saved to outputs/reports/pattern_analysis_report.md")
        
        # Print summary
        print("\n" + "="*60)
        print("✅ Pattern Analysis Complete!")
        print("\n📊 Key Findings:")
        print(f"   • Total Actors: {len(actors)}")
        print(f"   • Dominant Driver: {max(driver_stats['dominant_driver_counts'], key=driver_stats['dominant_driver_counts'].get)}")
        print(f"   • High Contradiction: {len(contradiction_stats['high_contradiction_actors'])} actors")
        print(f"   • Quantum Data: {'Available' if quantum_stats.get('quantum_data_available', False) else 'Not Available'}")
        
        print("\n📁 Outputs Created:")
        print("   • outputs/visualizations/ - 7 visualization files")
        print("   • outputs/reports/pattern_analysis_report.md - Comprehensive report")
        
        print("\n🔄 Next Step:")
        print("   Run clustering analysis: python run_clustering.py")
        
    except Exception as e:
        print(f"\n❌ Pattern analysis failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
