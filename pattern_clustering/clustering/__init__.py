"""
Clustering Engine Module for Customer Segmentation

This module provides comprehensive clustering capabilities for discovering
natural customer segments based on psychological driver distributions.
"""

from .feature_preparation import prepare_feature_matrix, validate_feature_matrix
from .algorithms import (
    cluster_kmeans,
    cluster_kmeans_range,
    cluster_dbscan,
    cluster_hierarchical,
    cluster_gaussian_mixture
)
from .validation import (
    validate_clustering,
    compare_clustering_results,
    test_train_validation
)
from .characterization import characterize_clusters, generate_messaging_strategy
from .assignment import assign_actor_to_cluster, batch_assign_actors
from .database import (
    save_clustering_run,
    save_cohorts,
    save_actor_assignments,
    get_cohort_summary,
    get_actor_cohort
)

__all__ = [
    'prepare_feature_matrix',
    'validate_feature_matrix',
    'cluster_kmeans',
    'cluster_kmeans_range',
    'cluster_dbscan',
    'cluster_hierarchical',
    'cluster_gaussian_mixture',
    'validate_clustering',
    'compare_clustering_results',
    'test_train_validation',
    'characterize_clusters',
    'generate_messaging_strategy',
    'assign_actor_to_cluster',
    'batch_assign_actors',
    'save_clustering_run',
    'save_cohorts',
    'save_actor_assignments',
    'get_cohort_summary',
    'get_actor_cohort'
]
