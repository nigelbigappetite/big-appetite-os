#!/usr/bin/env python3
"""
Debug assignment data structure
"""

import os
import sys
from dotenv import load_dotenv

# Add intelligence_layer to path
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PKG_PATH = os.path.join(ROOT, 'intelligence_layer')
if PKG_PATH not in sys.path:
    sys.path.append(PKG_PATH)

load_dotenv()

from pattern_analysis.data_retrieval import get_actor_profiles
from clustering.feature_preparation import prepare_feature_matrix
from clustering.algorithms import cluster_kmeans
from clustering.assignment import batch_assign_actors

def main():
    print("🔍 Debugging Assignment Data Structure")
    print("="*50)
    
    # Load data
    print("1. Loading actor profiles...")
    actors_df = get_actor_profiles(min_signals=1)
    print(f"   ✓ Loaded {len(actors_df)} actors")
    
    # Prepare features
    print("2. Preparing features...")
    feature_matrix, feature_names = prepare_feature_matrix(actors_df)
    print(f"   ✓ Feature matrix: {feature_matrix.shape}")
    
    # Run clustering
    print("3. Running clustering...")
    result = cluster_kmeans(feature_matrix, n_clusters=5)
    clusters = result['cluster_centers']
    labels = result['labels']
    print(f"   ✓ Found {len(set(labels))} clusters")
    
    # Get assignments
    print("4. Getting assignments...")
    actors_list = actors_df.to_dict('records')
    assignments = batch_assign_actors(actors_list, clusters, labels)
    print(f"   ✓ Generated {len(assignments)} assignments")
    
    # Show first few assignments
    print("\n📋 First 3 assignments:")
    for i, assignment in enumerate(assignments[:3]):
        print(f"   Assignment {i+1}:")
        print(f"     Keys: {list(assignment.keys())}")
        print(f"     Values: {assignment}")
        print()

if __name__ == "__main__":
    main()
