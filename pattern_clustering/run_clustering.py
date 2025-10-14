#!/usr/bin/env python3
"""
Clustering Main Script

Discovers customer segments through multiple clustering algorithms.
This script runs clustering, validates results, and saves to database.

Usage:
    python run_clustering.py [--algorithm kmeans] [--n-clusters 7]

Options:
    --algorithm: Clustering algorithm (kmeans, dbscan, hierarchical, gmm, all)
    --n-clusters: Number of clusters for k-means (default: 7)

Outputs:
    - Discovered cohorts
    - Cluster validation metrics
    - Actor assignments
    - Results saved to database
"""

import os
import sys
import argparse
from pathlib import Path

# Add pattern_clustering to path
ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.append(ROOT)

from pattern_analysis import get_actor_profiles, export_to_dataframe
from clustering import (
    prepare_feature_matrix,
    cluster_kmeans,
    cluster_kmeans_range,
    cluster_dbscan,
    cluster_hierarchical,
    cluster_gaussian_mixture,
    validate_clustering,
    compare_clustering_results,
    characterize_clusters,
    batch_assign_actors,
    save_clustering_run,
    save_cohorts,
    save_actor_assignments
)

def main(args):
    """Main function to run clustering analysis."""
    print("🧩 Starting Clustering Analysis...")
    print("="*60)
    
    try:
        # Load data
        print("\n1. Loading actor profiles...")
        actors = get_actor_profiles(min_signals=1, include_quantum=True)
        print(f"   ✓ Loaded {len(actors)} actors")
        
        if len(actors) < 10:
            print("   ⚠️  Warning: Very few actors available for clustering")
            return
        
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
        print(f"   ✓ Features: {', '.join(feature_names)}")
        
        # Run clustering
        print("\n3. Running clustering algorithms...")
        
        if args.algorithm == "all":
            # Try multiple approaches
            results = []
            
            print("   - K-Means (k=3,5,7,10)...")
            kmeans_results = cluster_kmeans_range(features, k_range=[3, 5, 7, 10])
            results.extend(kmeans_results)
            
            print("   - DBSCAN...")
            try:
                dbscan_result = cluster_dbscan(features, eps=0.3, min_samples=10)
                results.append(dbscan_result)
            except Exception as e:
                print(f"   ⚠️  DBSCAN failed: {e}")
            
            print("   - Hierarchical (k=5,7)...")
            try:
                hierarchical_result = cluster_hierarchical(features, n_clusters=5)
                results.append(hierarchical_result)
            except Exception as e:
                print(f"   ⚠️  Hierarchical failed: {e}")
            
            try:
                hierarchical_result = cluster_hierarchical(features, n_clusters=7)
                results.append(hierarchical_result)
            except Exception as e:
                print(f"   ⚠️  Hierarchical failed: {e}")
            
            # Compare and select best
            print("\n4. Comparing results...")
            comparison = compare_clustering_results(results)
            best_result = comparison['best_result']
            
        elif args.algorithm == "kmeans":
            print(f"   - K-Means (k={args.n_clusters})...")
            best_result = cluster_kmeans(features, n_clusters=args.n_clusters)
            
        elif args.algorithm == "dbscan":
            print(f"   - DBSCAN...")
            best_result = cluster_dbscan(features, eps=0.3, min_samples=10)
            
        elif args.algorithm == "hierarchical":
            print(f"   - Hierarchical (k={args.n_clusters})...")
            best_result = cluster_hierarchical(features, n_clusters=args.n_clusters)
            
        elif args.algorithm == "gmm":
            print(f"   - Gaussian Mixture Model (k={args.n_clusters})...")
            best_result = cluster_gaussian_mixture(features, n_components=args.n_clusters)
        
        else:
            raise ValueError(f"Unknown algorithm: {args.algorithm}")
        
        # Validate clustering
        print("\n5. Validating clustering quality...")
        validation = validate_clustering(features, best_result["labels"])
        print(f"   ✓ Silhouette Score: {validation['silhouette_score']:.3f} ({validation['interpretation']})")
        print(f"   ✓ Number of clusters: {validation['n_clusters']}")
        print(f"   ✓ Cluster sizes: {validation['cluster_sizes']}")
        
        # Characterize clusters
        print("\n6. Characterizing cohorts...")
        cohorts = characterize_clusters(actors, best_result["labels"], features)
        for i, cohort in enumerate(cohorts):
            print(f"   Cohort {i+1}: {cohort['cohort_name']}")
            print(f"      Size: {cohort['size']} actors ({cohort['percentage']:.1f}%)")
            print(f"      Dominant: {cohort['characteristics']['dominant_driver']}")
            print(f"      Contradiction: {cohort['characteristics']['avg_contradiction']:.2f}")
        
        # Assign actors
        print("\n7. Assigning actors to cohorts...")
        assignments = batch_assign_actors(actors, cohorts)
        print(f"   ✓ Assigned {len(assignments)} actors")
        
        # Save to database
        print("\n8. Saving results to database...")
        run_id = save_clustering_run(
            algorithm=best_result["algorithm"],
            parameters=best_result["parameters"],
            n_actors=len(actors),
            n_clusters=len(cohorts),
            silhouette_score=validation["silhouette_score"],
            feature_config=feature_config,
            validation_metrics=validation
        )
        print(f"   ✓ Clustering run ID: {run_id}")
        
        cohort_ids = save_cohorts(cohorts, run_id)
        print(f"   ✓ Saved {len(cohort_ids)} cohorts")
        
        saved_assignments = save_actor_assignments(assignments)
        print(f"   ✓ Saved {saved_assignments} actor assignments")
        
        # Print summary
        print("\n" + "="*60)
        print("✅ Clustering Complete!")
        print(f"\n🎯 Discovered {len(cohorts)} customer segments:")
        for i, cohort in enumerate(cohorts, 1):
            print(f"  {i}. {cohort['cohort_name']}: {cohort['size']} actors ({cohort['percentage']:.1f}%)")
        
        print(f"\n📊 Quality Metrics:")
        print(f"   • Silhouette Score: {validation['silhouette_score']:.3f}")
        print(f"   • Calinski-Harabasz: {validation['calinski_harabasz_score']:.2f}")
        print(f"   • Davies-Bouldin: {validation['davies_bouldin_score']:.3f}")
        
        print(f"\n💾 Database:")
        print(f"   • Run ID: {run_id}")
        print(f"   • Cohorts: {len(cohort_ids)}")
        print(f"   • Assignments: {saved_assignments}")
        
        print("\n🔄 Next Steps:")
        print("   • Review cohort characteristics")
        print("   • Develop messaging strategies")
        print("   • Test with new actors")
        
    except Exception as e:
        print(f"\n❌ Clustering failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Run customer segmentation clustering analysis",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python run_clustering.py                    # Run all algorithms
  python run_clustering.py --algorithm kmeans --n-clusters 5
  python run_clustering.py --algorithm dbscan
  python run_clustering.py --algorithm hierarchical --n-clusters 7
        """
    )
    
    parser.add_argument(
        "--algorithm",
        default="all",
        choices=["all", "kmeans", "dbscan", "hierarchical", "gmm"],
        help="Clustering algorithm to use (default: all)"
    )
    
    parser.add_argument(
        "--n-clusters",
        type=int,
        default=7,
        help="Number of clusters for k-means, hierarchical, and GMM (default: 7)"
    )
    
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    main(args)
