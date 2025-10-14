"""
Clustering Validation Module

Provides comprehensive validation metrics and quality assessment
for clustering results including silhouette score, Calinski-Harabasz,
Davies-Bouldin, and other clustering quality measures.
"""

import numpy as np
from typing import List, Dict, Any, Tuple
from sklearn.metrics import (
    silhouette_score, 
    calinski_harabasz_score, 
    davies_bouldin_score,
    adjusted_rand_score,
    normalized_mutual_info_score
)
import warnings
warnings.filterwarnings('ignore')

def validate_clustering(features: np.ndarray, 
                       labels: np.ndarray) -> Dict[str, Any]:
    """
    Calculate comprehensive clustering quality metrics.
    
    Args:
        features: Feature matrix (n_samples, n_features)
        labels: Cluster labels (n_samples,)
    
    Returns:
        Dictionary with validation metrics and interpretation
    """
    print("📊 Validating clustering quality...")
    
    try:
        # Basic validation
        n_samples, n_features = features.shape
        n_clusters = len(np.unique(labels))
        n_outliers = np.sum(labels == -1) if -1 in labels else 0
        
        # Calculate cluster sizes
        cluster_sizes = [np.sum(labels == i) for i in range(n_clusters)]
        
        # Calculate within-cluster variance
        within_cluster_variance = _calculate_within_cluster_variance(features, labels)
        
        # Calculate between-cluster distances
        between_cluster_distances = _calculate_between_cluster_distances(features, labels)
        
        # Calculate quality metrics
        metrics = {}
        
        # Silhouette score
        if n_clusters > 1 and n_samples > n_clusters:
            try:
                silhouette = silhouette_score(features, labels)
                metrics['silhouette_score'] = float(silhouette)
            except Exception:
                metrics['silhouette_score'] = -1.0
        else:
            metrics['silhouette_score'] = -1.0
        
        # Calinski-Harabasz score
        if n_clusters > 1 and n_samples > n_clusters:
            try:
                ch_score = calinski_harabasz_score(features, labels)
                metrics['calinski_harabasz_score'] = float(ch_score)
            except Exception:
                metrics['calinski_harabasz_score'] = 0.0
        else:
            metrics['calinski_harabasz_score'] = 0.0
        
        # Davies-Bouldin score
        if n_clusters > 1 and n_samples > n_clusters:
            try:
                db_score = davies_bouldin_score(features, labels)
                metrics['davies_bouldin_score'] = float(db_score)
            except Exception:
                metrics['davies_bouldin_score'] = float('inf')
        else:
            metrics['davies_bouldin_score'] = float('inf')
        
        # Additional metrics
        metrics['within_cluster_variance'] = within_cluster_variance
        metrics['between_cluster_distances'] = between_cluster_distances
        metrics['cluster_sizes'] = cluster_sizes
        metrics['n_clusters'] = n_clusters
        metrics['n_outliers'] = n_outliers
        
        # Calculate interpretation
        interpretation = _interpret_clustering_quality(metrics)
        metrics['interpretation'] = interpretation
        
        # Print results
        print(f"   ✓ Silhouette Score: {metrics['silhouette_score']:.3f} ({interpretation})")
        print(f"   ✓ Calinski-Harabasz: {metrics['calinski_harabasz_score']:.2f}")
        print(f"   ✓ Davies-Bouldin: {metrics['davies_bouldin_score']:.3f}")
        print(f"   ✓ Clusters: {n_clusters}, Outliers: {n_outliers}")
        
        return metrics
        
    except Exception as e:
        print(f"   ❌ Clustering validation failed: {e}")
        raise

def _calculate_within_cluster_variance(features: np.ndarray, 
                                     labels: np.ndarray) -> List[float]:
    """Calculate within-cluster variance for each cluster."""
    n_clusters = len(np.unique(labels))
    within_cluster_variance = []
    
    for i in range(n_clusters):
        cluster_mask = labels == i
        if np.sum(cluster_mask) > 1:
            cluster_features = features[cluster_mask]
            variance = np.var(cluster_features, axis=0).mean()
            within_cluster_variance.append(float(variance))
        else:
            within_cluster_variance.append(0.0)
    
    return within_cluster_variance

def _calculate_between_cluster_distances(features: np.ndarray, 
                                       labels: np.ndarray) -> np.ndarray:
    """Calculate distances between cluster centroids."""
    n_clusters = len(np.unique(labels))
    centroids = []
    
    # Calculate centroids
    for i in range(n_clusters):
        cluster_mask = labels == i
        if np.sum(cluster_mask) > 0:
            centroid = np.mean(features[cluster_mask], axis=0)
            centroids.append(centroid)
        else:
            centroids.append(np.zeros(features.shape[1]))
    
    centroids = np.array(centroids)
    
    # Calculate pairwise distances
    distances = np.zeros((n_clusters, n_clusters))
    for i in range(n_clusters):
        for j in range(n_clusters):
            if i != j:
                distances[i, j] = np.linalg.norm(centroids[i] - centroids[j])
    
    return distances

def _interpret_clustering_quality(metrics: Dict[str, Any]) -> str:
    """Interpret clustering quality based on metrics."""
    silhouette = metrics.get('silhouette_score', -1)
    
    if silhouette > 0.5:
        return "excellent"
    elif silhouette > 0.3:
        return "good"
    elif silhouette > 0.2:
        return "fair"
    else:
        return "poor"

def compare_clustering_results(results_list: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Compare multiple clustering results and recommend the best one.
    
    Args:
        results_list: List of clustering results from different algorithms
    
    Returns:
        Dictionary with comparison results and recommendation
    """
    print("🔍 Comparing clustering results...")
    
    if not results_list:
        raise Exception("No clustering results provided for comparison")
    
    # Calculate validation metrics for each result
    validated_results = []
    
    for i, result in enumerate(results_list):
        try:
            features = result.get('features')
            labels = result.get('labels')
            
            if features is None or labels is None:
                print(f"   ⚠️  Result {i} missing features or labels")
                continue
            
            # Validate clustering
            validation = validate_clustering(features, labels)
            
            # Add validation to result
            result['validation'] = validation
            validated_results.append(result)
            
        except Exception as e:
            print(f"   ⚠️  Validation failed for result {i}: {e}")
            continue
    
    if not validated_results:
        raise Exception("No valid clustering results found")
    
    # Compare results
    comparison = {
        'n_results': len(validated_results),
        'results': validated_results,
        'rankings': {}
    }
    
    # Rank by silhouette score
    silhouette_scores = []
    for i, result in enumerate(validated_results):
        silhouette = result['validation'].get('silhouette_score', -1)
        silhouette_scores.append((i, silhouette))
    
    silhouette_scores.sort(key=lambda x: x[1], reverse=True)
    comparison['rankings']['silhouette'] = [i for i, _ in silhouette_scores]
    
    # Rank by Calinski-Harabasz score
    ch_scores = []
    for i, result in enumerate(validated_results):
        ch_score = result['validation'].get('calinski_harabasz_score', 0)
        ch_scores.append((i, ch_score))
    
    ch_scores.sort(key=lambda x: x[1], reverse=True)
    comparison['rankings']['calinski_harabasz'] = [i for i, _ in ch_scores]
    
    # Rank by Davies-Bouldin score (lower is better)
    db_scores = []
    for i, result in enumerate(validated_results):
        db_score = result['validation'].get('davies_bouldin_score', float('inf'))
        db_scores.append((i, db_score))
    
    db_scores.sort(key=lambda x: x[1])
    comparison['rankings']['davies_bouldin'] = [i for i, _ in db_scores]
    
    # Overall ranking (weighted combination)
    overall_scores = []
    for i, result in enumerate(validated_results):
        validation = result['validation']
        
        # Normalize scores
        silhouette = max(0, validation.get('silhouette_score', -1))
        ch_score = validation.get('calinski_harabasz_score', 0)
        db_score = validation.get('davies_bouldin_score', float('inf'))
        
        # Weighted combination (silhouette is most important)
        overall_score = (
            0.5 * silhouette +
            0.3 * min(1.0, ch_score / 1000) +  # Normalize CH score
            0.2 * max(0, 1.0 - min(1.0, db_score / 10))  # Normalize DB score
        )
        
        overall_scores.append((i, overall_score))
    
    overall_scores.sort(key=lambda x: x[1], reverse=True)
    comparison['rankings']['overall'] = [i for i, _ in overall_scores]
    
    # Get best result
    best_idx = overall_scores[0][0]
    best_result = validated_results[best_idx]
    
    comparison['best_result'] = best_result
    comparison['best_algorithm'] = best_result.get('algorithm', 'unknown')
    comparison['best_silhouette'] = best_result['validation'].get('silhouette_score', -1)
    
    # Print comparison results
    print(f"   ✓ Compared {len(validated_results)} clustering results")
    print(f"   ✓ Best algorithm: {comparison['best_algorithm']}")
    print(f"   ✓ Best silhouette score: {comparison['best_silhouette']:.3f}")
    
    return comparison

def test_train_validation(features: np.ndarray, 
                         labels: np.ndarray, 
                         test_size: float = 0.2) -> Dict[str, Any]:
    """
    Validate clustering generalization using train-test split.
    
    Args:
        features: Feature matrix
        labels: Cluster labels
        test_size: Fraction of data to use for testing
    
    Returns:
        Dictionary with validation results
    """
    print("🔄 Testing clustering generalization...")
    
    try:
        from sklearn.model_selection import train_test_split
        from sklearn.cluster import KMeans
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            features, labels, test_size=test_size, random_state=42
        )
        
        # Get number of clusters from training data
        n_clusters = len(np.unique(y_train))
        
        # Train K-Means on training data
        kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        kmeans.fit(X_train)
        
        # Predict on test data
        test_labels = kmeans.predict(X_test)
        
        # Calculate metrics
        train_silhouette = silhouette_score(X_train, y_train)
        test_silhouette = silhouette_score(X_test, test_labels)
        
        # Calculate consistency (how well test data fits discovered clusters)
        consistency = _calculate_cluster_consistency(X_test, test_labels, kmeans.cluster_centers_)
        
        results = {
            'train_silhouette': float(train_silhouette),
            'test_silhouette': float(test_silhouette),
            'consistency': float(consistency),
            'n_train_samples': len(X_train),
            'n_test_samples': len(X_test),
            'n_clusters': n_clusters
        }
        
        print(f"   ✓ Train silhouette: {train_silhouette:.3f}")
        print(f"   ✓ Test silhouette: {test_silhouette:.3f}")
        print(f"   ✓ Consistency: {consistency:.3f}")
        
        return results
        
    except Exception as e:
        print(f"   ❌ Train-test validation failed: {e}")
        raise

def _calculate_cluster_consistency(features: np.ndarray, 
                                 labels: np.ndarray, 
                                 centers: np.ndarray) -> float:
    """Calculate how well test data fits discovered cluster centers."""
    if len(centers) == 0:
        return 0.0
    
    # Calculate distances to assigned cluster centers
    distances = []
    for i, feature in enumerate(features):
        assigned_cluster = labels[i]
        if assigned_cluster < len(centers):
            distance = np.linalg.norm(feature - centers[assigned_cluster])
            distances.append(distance)
    
    if not distances:
        return 0.0
    
    # Calculate consistency as inverse of average distance
    avg_distance = np.mean(distances)
    max_possible_distance = np.sqrt(features.shape[1])  # Maximum distance in normalized space
    consistency = max(0, 1 - (avg_distance / max_possible_distance))
    
    return consistency

def calculate_cluster_stability(features: np.ndarray, 
                              labels: np.ndarray, 
                              n_iterations: int = 10) -> Dict[str, Any]:
    """
    Calculate cluster stability across multiple runs.
    
    Args:
        features: Feature matrix
        labels: Cluster labels
        n_iterations: Number of iterations for stability test
    
    Returns:
        Dictionary with stability metrics
    """
    print(f"🔄 Calculating cluster stability ({n_iterations} iterations)...")
    
    try:
        from sklearn.cluster import KMeans
        from sklearn.metrics import adjusted_rand_score
        
        n_clusters = len(np.unique(labels))
        stability_scores = []
        
        for i in range(n_iterations):
            # Run K-Means with different random seeds
            kmeans = KMeans(n_clusters=n_clusters, random_state=i, n_init=10)
            new_labels = kmeans.fit_predict(features)
            
            # Calculate similarity with original labels
            ari = adjusted_rand_score(labels, new_labels)
            stability_scores.append(ari)
        
        # Calculate stability metrics
        mean_stability = np.mean(stability_scores)
        std_stability = np.std(stability_scores)
        min_stability = np.min(stability_scores)
        max_stability = np.max(stability_scores)
        
        results = {
            'mean_stability': float(mean_stability),
            'std_stability': float(std_stability),
            'min_stability': float(min_stability),
            'max_stability': float(max_stability),
            'stability_scores': stability_scores,
            'n_iterations': n_iterations
        }
        
        print(f"   ✓ Mean stability: {mean_stability:.3f} ± {std_stability:.3f}")
        print(f"   ✓ Stability range: {min_stability:.3f} - {max_stability:.3f}")
        
        return results
        
    except Exception as e:
        print(f"   ❌ Cluster stability calculation failed: {e}")
        raise

def generate_validation_report(validation_results: List[Dict[str, Any]]) -> str:
    """
    Generate a comprehensive validation report.
    
    Args:
        validation_results: List of validation results from different algorithms
    
    Returns:
        Markdown report string
    """
    if not validation_results:
        return "No validation results available."
    
    report = "# Clustering Validation Report\n\n"
    
    # Summary table
    report += "## Summary\n\n"
    report += "| Algorithm | Silhouette | CH Score | DB Score | Clusters | Quality |\n"
    report += "|-----------|------------|----------|----------|----------|----------|\n"
    
    for result in validation_results:
        algorithm = result.get('algorithm', 'Unknown')
        validation = result.get('validation', {})
        silhouette = validation.get('silhouette_score', -1)
        ch_score = validation.get('calinski_harabasz_score', 0)
        db_score = validation.get('davies_bouldin_score', float('inf'))
        n_clusters = validation.get('n_clusters', 0)
        quality = validation.get('interpretation', 'unknown')
        
        report += f"| {algorithm} | {silhouette:.3f} | {ch_score:.1f} | {db_score:.3f} | {n_clusters} | {quality} |\n"
    
    # Best result
    best_result = max(validation_results, 
                     key=lambda x: x.get('validation', {}).get('silhouette_score', -1))
    
    report += f"\n## Best Result\n\n"
    report += f"**Algorithm:** {best_result.get('algorithm', 'Unknown')}\n"
    report += f"**Silhouette Score:** {best_result['validation'].get('silhouette_score', -1):.3f}\n"
    report += f"**Quality:** {best_result['validation'].get('interpretation', 'unknown')}\n"
    
    return report
