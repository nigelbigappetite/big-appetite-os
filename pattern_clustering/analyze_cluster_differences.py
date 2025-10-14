#!/usr/bin/env python3
"""
Analyze differences between similar clusters
"""

import os
import sys
import numpy as np
from pathlib import Path

# Add pattern_clustering to path
ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.append(ROOT)

from pattern_analysis import get_actor_profiles
from clustering import prepare_feature_matrix, cluster_kmeans, characterize_clusters

def main():
    print("🔍 Analyzing Cluster Differences")
    print("="*60)
    
    # Load data
    actors = get_actor_profiles(min_signals=1, include_quantum=True)
    features, actor_ids, feature_names = prepare_feature_matrix(actors, {
        "include_drivers": True,
        "include_contradiction": True,
        "include_quantum": True,
        "normalize": True
    })
    
    # Run clustering
    result = cluster_kmeans(features, n_clusters=5)
    cohorts = characterize_clusters(actors, result["labels"], features)
    
    print("\n📊 DETAILED CLUSTER ANALYSIS")
    print("="*60)
    
    # Analyze each cluster in detail
    for i, cohort in enumerate(cohorts):
        print(f"\n🎯 CLUSTER {i+1}: {cohort['cohort_name']}")
        print("-" * 50)
        
        # Get actors in this cluster
        cluster_mask = result["labels"] == i
        cluster_actors = [actors[j] for j in range(len(actors)) if cluster_mask[j]]
        cluster_features = features[cluster_mask]
        
        # Driver profile analysis
        driver_profile = cohort['driver_profile']
        print(f"📈 Driver Profile:")
        for driver, value in driver_profile.items():
            print(f"   {driver}: {value:.3f}")
        
        # Find the second highest driver
        sorted_drivers = sorted(driver_profile.items(), key=lambda x: x[1], reverse=True)
        dominant = sorted_drivers[0]
        secondary = sorted_drivers[1] if len(sorted_drivers) > 1 else None
        
        print(f"   🥇 Dominant: {dominant[0]} ({dominant[1]:.3f})")
        if secondary:
            print(f"   🥈 Secondary: {secondary[0]} ({secondary[1]:.3f})")
        
        # Contradiction analysis
        contradiction_scores = [actor['contradiction_score'] for actor in cluster_actors]
        print(f"\n⚡ Contradiction Analysis:")
        print(f"   Average: {np.mean(contradiction_scores):.3f}")
        print(f"   Range: {np.min(contradiction_scores):.3f} - {np.max(contradiction_scores):.3f}")
        print(f"   Std Dev: {np.std(contradiction_scores):.3f}")
        
        # Quantum state analysis
        if 'superposition_detected' in cluster_actors[0]:
            superposition_count = sum(1 for actor in cluster_actors if actor.get('superposition_detected', False))
            coherence_scores = [actor.get('coherence', 0.0) for actor in cluster_actors]
            print(f"\n🌌 Quantum States:")
            print(f"   Superposition: {superposition_count}/{len(cluster_actors)} ({superposition_count/len(cluster_actors)*100:.1f}%)")
            print(f"   Avg Coherence: {np.mean(coherence_scores):.3f}")
        
        # Signal count analysis
        signal_counts = [actor['signal_count'] for actor in cluster_actors]
        print(f"\n📊 Signal Analysis:")
        print(f"   Avg Signals: {np.mean(signal_counts):.2f}")
        print(f"   Range: {np.min(signal_counts)} - {np.max(signal_counts)}")
        
        # Identity markers
        all_identities = []
        for actor in cluster_actors:
            identities = actor.get('identity_markers', [])
            if isinstance(identities, list):
                all_identities.extend(identities)
        
        if all_identities:
            from collections import Counter
            identity_counts = Counter(all_identities)
            print(f"\n🏷️  Top Identity Markers:")
            for identity, count in identity_counts.most_common(3):
                print(f"   {identity}: {count} ({count/len(cluster_actors)*100:.1f}%)")
        
        # Cluster centroid analysis
        centroid = np.mean(cluster_features, axis=0)
        print(f"\n🎯 Cluster Centroid (normalized features):")
        for j, feature_name in enumerate(feature_names):
            print(f"   {feature_name}: {centroid[j]:.3f}")
    
    print("\n" + "="*60)
    print("🔍 KEY DIFFERENCES SUMMARY")
    print("="*60)
    
    # Compare similar clusters
    print("\n📊 Connection Clusters (1 vs 2):")
    conn1 = cohorts[0]
    conn2 = cohorts[1]
    
    print(f"   Cluster 1: {conn1['size']} actors, Contradiction: {conn1['characteristics']['avg_contradiction']:.3f}")
    print(f"   Cluster 2: {conn2['size']} actors, Contradiction: {conn2['characteristics']['avg_contradiction']:.3f}")
    
    # Compare driver profiles
    print(f"   Driver Profile Differences:")
    for driver in ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']:
        diff = conn1['driver_profile'][driver] - conn2['driver_profile'][driver]
        print(f"     {driver}: {diff:+.3f} ({conn1['driver_profile'][driver]:.3f} vs {conn2['driver_profile'][driver]:.3f})")
    
    print("\n📊 Safety Clusters (3 vs 4):")
    safety1 = cohorts[2]
    safety2 = cohorts[3]
    
    print(f"   Cluster 3: {safety1['size']} actors, Contradiction: {safety1['characteristics']['avg_contradiction']:.3f}")
    print(f"   Cluster 4: {safety2['size']} actors, Contradiction: {safety2['characteristics']['avg_contradiction']:.3f}")
    
    # Compare driver profiles
    print(f"   Driver Profile Differences:")
    for driver in ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']:
        diff = safety1['driver_profile'][driver] - safety2['driver_profile'][driver]
        print(f"     {driver}: {diff:+.3f} ({safety1['driver_profile'][driver]:.3f} vs {safety2['driver_profile'][driver]:.3f})")

if __name__ == "__main__":
    main()
