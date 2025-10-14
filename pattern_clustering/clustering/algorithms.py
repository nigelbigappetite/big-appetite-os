"""
Clustering Algorithms Module

Implements multiple clustering algorithms for customer segmentation including
K-Means, DBSCAN, Hierarchical, and Gaussian Mixture Models.
"""

import numpy as np
from typing import List, Dict, Any, Optional
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering
from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import StandardScaler
import warnings
warnings.filterwarnings('ignore')

def cluster_kmeans(features: np.ndarray, 
                  n_clusters: int = 5, 
                  random_state: int = 42) -> Dict[str, Any]:
    """
    K-Means clustering algorithm.
    
    Args:
        features: Feature matrix (n_samples, n_features)
        n_clusters: Number of clusters
        random_state: Random seed for reproducibility
    
    Returns:
        Dictionary with clustering results
    """
    print(f"🔵 Running K-Means clustering (k={n_clusters})...")
    
    try:
        # Initialize K-Means
        kmeans = KMeans(
            n_clusters=n_clusters,
            random_state=random_state,
            n_init=10,
            max_iter=300
        )
        
        # Fit and predict
        labels = kmeans.fit_predict(features)
        centers = kmeans.cluster_centers_
        inertia = kmeans.inertia_
        
        # Calculate additional metrics
        n_clusters_found = len(np.unique(labels))
        
        print(f"   ✓ K-Means completed: {n_clusters_found} clusters found")
        print(f"   ✓ Inertia: {inertia:.2f}")
        
        return {
            "labels": labels,
            "centers": centers,
            "inertia": inertia,
            "algorithm": "kmeans",
            "parameters": {
                "n_clusters": n_clusters,
                "random_state": random_state
            },
            "n_clusters_found": n_clusters_found
        }
        
    except Exception as e:
        print(f"   ❌ K-Means clustering failed: {e}")
        raise

def cluster_kmeans_range(features: np.ndarray, 
                        k_range: List[int] = [3, 5, 7, 10]) -> List[Dict[str, Any]]:
    """
    Try K-Means with multiple k values.
    
    Args:
        features: Feature matrix
        k_range: List of k values to try
    
    Returns:
        List of clustering results for each k value
    """
    print(f"🔵 Running K-Means with k values: {k_range}")
    
    results = []
    
    for k in k_range:
        try:
            result = cluster_kmeans(features, n_clusters=k)
            results.append(result)
        except Exception as e:
            print(f"   ⚠️  K-Means with k={k} failed: {e}")
            continue
    
    print(f"   ✓ Completed {len(results)} K-Means runs")
    return results

def cluster_dbscan(features: np.ndarray, 
                  eps: float = 0.3, 
                  min_samples: int = 10) -> Dict[str, Any]:
    """
    DBSCAN (density-based) clustering.
    
    Args:
        features: Feature matrix
        eps: Maximum distance between samples in same cluster
        min_samples: Minimum samples in neighborhood for core point
    
    Returns:
        Dictionary with clustering results
    """
    print(f"🟢 Running DBSCAN clustering (eps={eps}, min_samples={min_samples})...")
    
    try:
        # Initialize DBSCAN
        dbscan = DBSCAN(
            eps=eps,
            min_samples=min_samples,
            metric='euclidean'
        )
        
        # Fit and predict
        labels = dbscan.fit_predict(features)
        
        # Calculate metrics
        n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
        n_outliers = list(labels).count(-1)
        n_core_samples = len(dbscan.core_sample_indices_)
        
        print(f"   ✓ DBSCAN completed: {n_clusters} clusters, {n_outliers} outliers")
        print(f"   ✓ Core samples: {n_core_samples}")
        
        return {
            "labels": labels,
            "n_clusters": n_clusters,
            "n_outliers": n_outliers,
            "n_core_samples": n_core_samples,
            "algorithm": "dbscan",
            "parameters": {
                "eps": eps,
                "min_samples": min_samples
            },
            "core_sample_indices": dbscan.core_sample_indices_
        }
        
    except Exception as e:
        print(f"   ❌ DBSCAN clustering failed: {e}")
        raise

def cluster_hierarchical(features: np.ndarray, 
                        n_clusters: int = 5,
                        linkage: str = 'ward') -> Dict[str, Any]:
    """
    Agglomerative hierarchical clustering.
    
    Args:
        features: Feature matrix
        n_clusters: Number of clusters
        linkage: Linkage criterion ('ward', 'complete', 'average', 'single')
    
    Returns:
        Dictionary with clustering results
    """
    print(f"🟡 Running Hierarchical clustering (k={n_clusters}, linkage={linkage})...")
    
    try:
        # Initialize hierarchical clustering
        hierarchical = AgglomerativeClustering(
            n_clusters=n_clusters,
            linkage=linkage
        )
        
        # Fit and predict
        labels = hierarchical.fit_predict(features)
        
        # Calculate linkage matrix for dendrogram
        from scipy.cluster.hierarchy import linkage as scipy_linkage
        linkage_matrix = scipy_linkage(features, method=linkage)
        
        print(f"   ✓ Hierarchical clustering completed: {n_clusters} clusters")
        
        return {
            "labels": labels,
            "linkage_matrix": linkage_matrix,
            "algorithm": "hierarchical",
            "parameters": {
                "n_clusters": n_clusters,
                "linkage": linkage
            },
            "n_clusters_found": n_clusters
        }
        
    except Exception as e:
        print(f"   ❌ Hierarchical clustering failed: {e}")
        raise

def cluster_gaussian_mixture(features: np.ndarray, 
                           n_components: int = 5,
                           random_state: int = 42) -> Dict[str, Any]:
    """
    Gaussian Mixture Model (probabilistic clustering).
    
    Args:
        features: Feature matrix
        n_components: Number of mixture components
        random_state: Random seed for reproducibility
    
    Returns:
        Dictionary with clustering results
    """
    print(f"🟣 Running Gaussian Mixture Model (n_components={n_components})...")
    
    try:
        # Initialize GMM
        gmm = GaussianMixture(
            n_components=n_components,
            random_state=random_state,
            max_iter=200,
            covariance_type='full'
        )
        
        # Fit and predict
        gmm.fit(features)
        labels = gmm.predict(features)
        probabilities = gmm.predict_proba(features)
        
        # Calculate metrics
        aic = gmm.aic(features)
        bic = gmm.bic(features)
        log_likelihood = gmm.score(features)
        
        print(f"   ✓ GMM completed: {n_components} components")
        print(f"   ✓ AIC: {aic:.2f}, BIC: {bic:.2f}")
        
        return {
            "labels": labels,
            "probabilities": probabilities,
            "aic": aic,
            "bic": bic,
            "log_likelihood": log_likelihood,
            "algorithm": "gmm",
            "parameters": {
                "n_components": n_components,
                "random_state": random_state
            },
            "n_clusters_found": n_components,
            "model": gmm
        }
        
    except Exception as e:
        print(f"   ❌ Gaussian Mixture Model failed: {e}")
        raise

def cluster_spectral(features: np.ndarray, 
                    n_clusters: int = 5,
                    random_state: int = 42) -> Dict[str, Any]:
    """
    Spectral clustering algorithm.
    
    Args:
        features: Feature matrix
        n_clusters: Number of clusters
        random_state: Random seed for reproducibility
    
    Returns:
        Dictionary with clustering results
    """
    print(f"🟠 Running Spectral clustering (k={n_clusters})...")
    
    try:
        from sklearn.cluster import SpectralClustering
        
        # Initialize spectral clustering
        spectral = SpectralClustering(
            n_clusters=n_clusters,
            random_state=random_state,
            affinity='rbf',
            gamma=1.0
        )
        
        # Fit and predict
        labels = spectral.fit_predict(features)
        
        print(f"   ✓ Spectral clustering completed: {n_clusters} clusters")
        
        return {
            "labels": labels,
            "algorithm": "spectral",
            "parameters": {
                "n_clusters": n_clusters,
                "random_state": random_state
            },
            "n_clusters_found": n_clusters
        }
        
    except Exception as e:
        print(f"   ❌ Spectral clustering failed: {e}")
        raise

def cluster_optics(features: np.ndarray, 
                  min_samples: int = 10,
                  max_eps: float = 1.0) -> Dict[str, Any]:
    """
    OPTICS clustering algorithm.
    
    Args:
        features: Feature matrix
        min_samples: Minimum samples in neighborhood
        max_eps: Maximum distance for neighborhood search
    
    Returns:
        Dictionary with clustering results
    """
    print(f"🔴 Running OPTICS clustering (min_samples={min_samples})...")
    
    try:
        from sklearn.cluster import OPTICS
        
        # Initialize OPTICS
        optics = OPTICS(
            min_samples=min_samples,
            max_eps=max_eps,
            metric='euclidean'
        )
        
        # Fit and predict
        labels = optics.fit_predict(features)
        
        # Calculate metrics
        n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
        n_outliers = list(labels).count(-1)
        
        print(f"   ✓ OPTICS completed: {n_clusters} clusters, {n_outliers} outliers")
        
        return {
            "labels": labels,
            "n_clusters": n_clusters,
            "n_outliers": n_outliers,
            "algorithm": "optics",
            "parameters": {
                "min_samples": min_samples,
                "max_eps": max_eps
            },
            "reachability": optics.reachability_,
            "ordering": optics.ordering_
        }
        
    except Exception as e:
        print(f"   ❌ OPTICS clustering failed: {e}")
        raise

def run_all_algorithms(features: np.ndarray, 
                      n_clusters: int = 5,
                      k_range: List[int] = [3, 5, 7, 10]) -> List[Dict[str, Any]]:
    """
    Run all clustering algorithms and return results.
    
    Args:
        features: Feature matrix
        n_clusters: Default number of clusters
        k_range: Range of k values for K-Means
    
    Returns:
        List of clustering results from all algorithms
    """
    print("🚀 Running all clustering algorithms...")
    
    results = []
    
    # K-Means with multiple k values
    try:
        kmeans_results = cluster_kmeans_range(features, k_range)
        results.extend(kmeans_results)
    except Exception as e:
        print(f"   ⚠️  K-Means range failed: {e}")
    
    # DBSCAN
    try:
        dbscan_result = cluster_dbscan(features)
        results.append(dbscan_result)
    except Exception as e:
        print(f"   ⚠️  DBSCAN failed: {e}")
    
    # Hierarchical
    try:
        hierarchical_result = cluster_hierarchical(features, n_clusters)
        results.append(hierarchical_result)
    except Exception as e:
        print(f"   ⚠️  Hierarchical failed: {e}")
    
    # Gaussian Mixture
    try:
        gmm_result = cluster_gaussian_mixture(features, n_clusters)
        results.append(gmm_result)
    except Exception as e:
        print(f"   ⚠️  GMM failed: {e}")
    
    # Spectral (optional)
    try:
        spectral_result = cluster_spectral(features, n_clusters)
        results.append(spectral_result)
    except Exception as e:
        print(f"   ⚠️  Spectral failed: {e}")
    
    print(f"   ✓ Completed {len(results)} clustering runs")
    return results

def find_optimal_k(features: np.ndarray, 
                  max_k: int = 15,
                  method: str = 'elbow') -> int:
    """
    Find optimal number of clusters using various methods.
    
    Args:
        features: Feature matrix
        max_k: Maximum k to test
        method: Method to use ('elbow', 'silhouette', 'gap')
    
    Returns:
        Optimal number of clusters
    """
    print(f"🔍 Finding optimal k using {method} method...")
    
    k_range = range(2, max_k + 1)
    
    if method == 'elbow':
        return _find_optimal_k_elbow(features, k_range)
    elif method == 'silhouette':
        return _find_optimal_k_silhouette(features, k_range)
    elif method == 'gap':
        return _find_optimal_k_gap(features, k_range)
    else:
        raise ValueError(f"Unknown method: {method}")

def _find_optimal_k_elbow(features: np.ndarray, k_range: range) -> int:
    """Find optimal k using elbow method."""
    inertias = []
    
    for k in k_range:
        try:
            kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
            kmeans.fit(features)
            inertias.append(kmeans.inertia_)
        except Exception:
            inertias.append(float('inf'))
    
    # Find elbow point (largest decrease in inertia)
    if len(inertias) < 3:
        return k_range[0]
    
    # Calculate second derivative
    second_derivatives = []
    for i in range(1, len(inertias) - 1):
        second_deriv = inertias[i-1] - 2*inertias[i] + inertias[i+1]
        second_derivatives.append(second_deriv)
    
    # Find maximum second derivative (elbow point)
    elbow_idx = np.argmax(second_derivatives) + 1
    optimal_k = k_range[elbow_idx]
    
    print(f"   ✓ Optimal k (elbow): {optimal_k}")
    return optimal_k

def _find_optimal_k_silhouette(features: np.ndarray, k_range: range) -> int:
    """Find optimal k using silhouette method."""
    from sklearn.metrics import silhouette_score
    
    silhouette_scores = []
    
    for k in k_range:
        try:
            kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
            labels = kmeans.fit_predict(features)
            score = silhouette_score(features, labels)
            silhouette_scores.append(score)
        except Exception:
            silhouette_scores.append(-1)
    
    # Find k with maximum silhouette score
    optimal_k = k_range[np.argmax(silhouette_scores)]
    max_score = max(silhouette_scores)
    
    print(f"   ✓ Optimal k (silhouette): {optimal_k} (score: {max_score:.3f})")
    return optimal_k

def _find_optimal_k_gap(features: np.ndarray, k_range: range) -> int:
    """Find optimal k using gap statistic method."""
    # Simplified gap statistic implementation
    # In practice, you might want to use a more sophisticated implementation
    
    inertias = []
    for k in k_range:
        try:
            kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
            kmeans.fit(features)
            inertias.append(kmeans.inertia_)
        except Exception:
            inertias.append(float('inf'))
    
    # Calculate gap statistic (simplified)
    gaps = []
    for i in range(1, len(inertias)):
        gap = np.log(inertias[i-1]) - np.log(inertias[i])
        gaps.append(gap)
    
    # Find k with maximum gap
    if gaps:
        optimal_k = k_range[np.argmax(gaps) + 1]
    else:
        optimal_k = k_range[0]
    
    print(f"   ✓ Optimal k (gap): {optimal_k}")
    return optimal_k
