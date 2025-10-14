#!/usr/bin/env python3
"""
Simple Clustering Test

Tests the clustering system without database operations.
"""

import os
import sys
from pathlib import Path

# Add pattern_clustering to path
ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.append(ROOT)

from pattern_analysis import get_actor_profiles, export_to_dataframe
from clustering import (
    prepare_feature_matrix,
    cluster_kmeans,
    validate_clustering,
    characterize_clusters
)

def main():
    """Test clustering without database operations."""
    print("🧪 Testing Clustering System (No Database)")
    print("="*60)
    
    try:
        # Load data
        print("\n1. Loading actor profiles...")
        actors = get_actor_profiles(min_signals=1, include_quantum=True)
        print(f"   ✓ Loaded {len(actors)} actors")
        
        # Prepare features
        print("\n2. Preparing feature matrix...")
        feature_config = {
            "include_drivers": True,
            "include_contradiction": True,
            "include_quantum": True,
            "normalize": True
        }
        features, actor_ids, feature_names = prepare_feature_matrix(actors, feature_config)
        print(f"   ✓ Feature matrix: {features.shape} ({len(feature_names)}D space)")
        
        # Run clustering
        print("\n3. Running K-Means clustering...")
        result = cluster_kmeans(features, n_clusters=5)
        print(f"   ✓ K-Means completed: {result['n_clusters_found']} clusters")
        
        # Validate clustering
        print("\n4. Validating clustering quality...")
        validation = validate_clustering(features, result["labels"])
        print(f"   ✓ Silhouette Score: {validation['silhouette_score']:.3f} ({validation['interpretation']})")
        print(f"   ✓ Cluster sizes: {validation['cluster_sizes']}")
        
        # Characterize clusters
        print("\n5. Characterizing cohorts...")
        cohorts = characterize_clusters(actors, result["labels"], features)
        print(f"   ✓ Characterized {len(cohorts)} cohorts")
        
        # Print results
        print("\n" + "="*60)
        print("✅ Clustering Test Complete!")
        print(f"\n🎯 Discovered {len(cohorts)} customer segments:")
        for i, cohort in enumerate(cohorts, 1):
            print(f"  {i}. {cohort['cohort_name']}: {cohort['size']} actors ({cohort['percentage']:.1f}%)")
            print(f"     Dominant: {cohort['characteristics']['dominant_driver']}")
            print(f"     Contradiction: {cohort['characteristics']['avg_contradiction']:.2f}")
            print(f"     Messaging Tone: {cohort['messaging_strategy']['tone']}")
        
        print(f"\n📊 Quality Metrics:")
        print(f"   • Silhouette Score: {validation['silhouette_score']:.3f}")
        print(f"   • Calinski-Harabasz: {validation['calinski_harabasz_score']:.2f}")
        print(f"   • Davies-Bouldin: {validation['davies_bouldin_score']:.3f}")
        
        print(f"\n🎨 Key Insights:")
        print(f"   • Total Actors: {len(actors)}")
        print(f"   • Feature Space: {len(feature_names)}D")
        print(f"   • Clustering Quality: {validation['interpretation']}")
        
        # Save results to files
        print(f"\n💾 Saving results to files...")
        
        # Save cohort summary
        with open('outputs/cohort_summary.txt', 'w') as f:
            f.write("Customer Segmentation Results\n")
            f.write("="*40 + "\n\n")
            for i, cohort in enumerate(cohorts, 1):
                f.write(f"{i}. {cohort['cohort_name']}\n")
                f.write(f"   Size: {cohort['size']} actors ({cohort['percentage']:.1f}%)\n")
                f.write(f"   Dominant Driver: {cohort['characteristics']['dominant_driver']}\n")
                f.write(f"   Avg Contradiction: {cohort['characteristics']['avg_contradiction']:.2f}\n")
                f.write(f"   Messaging Tone: {cohort['messaging_strategy']['tone']}\n")
                f.write(f"   Key Themes: {', '.join(cohort['messaging_strategy']['themes'][:3])}\n\n")
        
        print(f"   ✓ Saved cohort summary to outputs/cohort_summary.txt")
        
        print(f"\n🎉 Test completed successfully!")
        print(f"   The clustering system is working correctly.")
        print(f"   Database integration can be added later.")
        
    except Exception as e:
        print(f"\n❌ Clustering test failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
