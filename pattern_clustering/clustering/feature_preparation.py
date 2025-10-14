"""
Feature Preparation Module for Clustering

Handles feature extraction, preprocessing, and validation for clustering algorithms.
"""

import numpy as np
import pandas as pd
from typing import List, Dict, Any, Tuple, Optional
import warnings
warnings.filterwarnings('ignore')

def prepare_feature_matrix(actors: List[Dict[str, Any]], 
                          feature_config: Dict[str, Any]) -> Tuple[np.ndarray, List[str], List[str]]:
    """
    Convert actors to feature matrix for clustering.
    
    Args:
        actors: List of actor profiles
        feature_config: Configuration specifying which features to include
            {
                "include_drivers": True,
                "include_contradiction": True,
                "include_quantum": True,
                "normalize": True
            }
    
    Returns:
        features: numpy array (n_actors × n_features)
        actor_ids: list of actor_ids (maps rows to actors)
        feature_names: list of feature names (maps columns)
    
    Raises:
        Exception: If feature preparation fails
    """
    print("🔧 Preparing feature matrix...")
    
    if not actors:
        raise Exception("No actors provided for feature preparation")
    
    try:
        # Extract features based on configuration
        feature_data = []
        actor_ids = []
        
        for actor in actors:
            actor_id = actor['actor_id']
            actor_ids.append(actor_id)
            
            row_features = []
            
            # Driver features (6 features)
            if feature_config.get('include_drivers', True):
                drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
                for driver in drivers:
                    value = actor['driver_distribution'].get(driver, 0.0)
                    row_features.append(float(value))
            
            # Contradiction feature (1 feature)
            if feature_config.get('include_contradiction', True):
                contradiction = actor.get('contradiction_score', 0.0)
                row_features.append(float(contradiction))
            
            # Quantum features (2 features)
            if feature_config.get('include_quantum', True):
                # Superposition strength (0 or 1)
                superposition_strength = 1.0 if actor.get('superposition_detected', False) else 0.0
                row_features.append(superposition_strength)
                
                # Coherence score
                coherence = actor.get('coherence', 0.0)
                row_features.append(float(coherence))
            
            feature_data.append(row_features)
        
        # Convert to numpy array
        features = np.array(feature_data, dtype=np.float64)
        
        # Build feature names
        feature_names = []
        if feature_config.get('include_drivers', True):
            feature_names.extend(['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose'])
        if feature_config.get('include_contradiction', True):
            feature_names.append('contradiction_score')
        if feature_config.get('include_quantum', True):
            feature_names.extend(['superposition_strength', 'coherence'])
        
        # Normalize features if requested
        if feature_config.get('normalize', True):
            features = _normalize_features(features, feature_names)
            print("   ✓ Features normalized to 0-1 range")
        
        # Validate feature matrix
        validate_feature_matrix(features, min_actors=10)
        
        print(f"   ✓ Feature matrix created: {features.shape[0]} actors × {features.shape[1]} features")
        print(f"   ✓ Feature names: {', '.join(feature_names)}")
        
        return features, actor_ids, feature_names
        
    except Exception as e:
        print(f"   ❌ Error preparing feature matrix: {e}")
        raise

def _normalize_features(features: np.ndarray, feature_names: List[str]) -> np.ndarray:
    """
    Normalize features to 0-1 range using min-max scaling.
    
    Args:
        features: Feature matrix
        feature_names: List of feature names
    
    Returns:
        Normalized feature matrix
    """
    normalized_features = features.copy()
    
    for i, feature_name in enumerate(feature_names):
        feature_values = features[:, i]
        
        # Skip if all values are the same
        if np.std(feature_values) == 0:
            continue
        
        # Min-max normalization
        min_val = np.min(feature_values)
        max_val = np.max(feature_values)
        
        if max_val > min_val:  # Avoid division by zero
            normalized_features[:, i] = (feature_values - min_val) / (max_val - min_val)
        else:
            normalized_features[:, i] = 0.5  # Set to middle value if all same
    
    return normalized_features

def validate_feature_matrix(features: np.ndarray, min_actors: int = 50) -> None:
    """
    Check feature matrix quality.
    
    Args:
        features: Feature matrix
        min_actors: Minimum number of actors required
    
    Raises:
        Exception: If validation fails
    """
    print("🔍 Validating feature matrix...")
    
    # Check dimensions
    if features.ndim != 2:
        raise Exception(f"Feature matrix must be 2D, got {features.ndim}D")
    
    n_actors, n_features = features.shape
    
    if n_actors < min_actors:
        raise Exception(f"Insufficient actors: {n_actors} < {min_actors}")
    
    if n_features == 0:
        raise Exception("No features found")
    
    # Check for NaN values
    nan_count = np.isnan(features).sum()
    if nan_count > 0:
        raise Exception(f"Found {nan_count} NaN values in feature matrix")
    
    # Check for infinite values
    inf_count = np.isinf(features).sum()
    if inf_count > 0:
        raise Exception(f"Found {inf_count} infinite values in feature matrix")
    
    # Check for constant features (zero variance)
    constant_features = []
    for i in range(n_features):
        if np.std(features[:, i]) == 0:
            constant_features.append(i)
    
    if constant_features:
        print(f"   ⚠️  Warning: {len(constant_features)} constant features found (columns: {constant_features})")
    
    # Check feature ranges
    min_vals = np.min(features, axis=0)
    max_vals = np.max(features, axis=0)
    
    print(f"   ✓ Feature matrix validation passed")
    print(f"   ✓ Dimensions: {n_actors} actors × {n_features} features")
    print(f"   ✓ Value ranges: {min_vals.min():.3f} to {max_vals.max():.3f}")
    
    if len(constant_features) > 0:
        print(f"   ⚠️  Constant features: {len(constant_features)}")

def create_feature_summary(features: np.ndarray, 
                          feature_names: List[str],
                          actor_ids: List[str]) -> Dict[str, Any]:
    """
    Create summary statistics for the feature matrix.
    
    Args:
        features: Feature matrix
        feature_names: List of feature names
        actor_ids: List of actor IDs
    
    Returns:
        Dictionary with feature summary statistics
    """
    summary = {
        'n_actors': features.shape[0],
        'n_features': features.shape[1],
        'feature_names': feature_names,
        'feature_stats': {}
    }
    
    for i, feature_name in enumerate(feature_names):
        feature_values = features[:, i]
        summary['feature_stats'][feature_name] = {
            'mean': float(np.mean(feature_values)),
            'std': float(np.std(feature_values)),
            'min': float(np.min(feature_values)),
            'max': float(np.max(feature_values)),
            'median': float(np.median(feature_values)),
            'q25': float(np.percentile(feature_values, 25)),
            'q75': float(np.percentile(feature_values, 75))
        }
    
    return summary

def get_feature_importance(features: np.ndarray, 
                          feature_names: List[str]) -> Dict[str, float]:
    """
    Calculate feature importance based on variance.
    
    Args:
        features: Feature matrix
        feature_names: List of feature names
    
    Returns:
        Dictionary mapping feature names to importance scores
    """
    importance = {}
    
    for i, feature_name in enumerate(feature_names):
        feature_values = features[:, i]
        variance = np.var(feature_values)
        importance[feature_name] = float(variance)
    
    # Normalize to 0-1 range
    max_importance = max(importance.values())
    if max_importance > 0:
        importance = {k: v / max_importance for k, v in importance.items()}
    
    return importance

def detect_outliers(features: np.ndarray, 
                   feature_names: List[str],
                   threshold: float = 3.0) -> List[int]:
    """
    Detect outliers using Z-score method.
    
    Args:
        features: Feature matrix
        feature_names: List of feature names
        threshold: Z-score threshold for outlier detection
    
    Returns:
        List of actor indices that are outliers
    """
    outlier_indices = set()
    
    for i, feature_name in enumerate(feature_names):
        feature_values = features[:, i]
        
        # Calculate Z-scores
        mean_val = np.mean(feature_values)
        std_val = np.std(feature_values)
        
        if std_val > 0:  # Avoid division by zero
            z_scores = np.abs((feature_values - mean_val) / std_val)
            outlier_mask = z_scores > threshold
            
            # Add outlier indices
            outlier_indices.update(np.where(outlier_mask)[0])
    
    return list(outlier_indices)

def remove_outliers(features: np.ndarray, 
                   actor_ids: List[str],
                   outlier_indices: List[int]) -> Tuple[np.ndarray, List[str]]:
    """
    Remove outliers from feature matrix and actor IDs.
    
    Args:
        features: Feature matrix
        actor_ids: List of actor IDs
        outlier_indices: List of outlier indices to remove
    
    Returns:
        Tuple of (cleaned_features, cleaned_actor_ids)
    """
    if not outlier_indices:
        return features, actor_ids
    
    # Create mask for non-outliers
    mask = np.ones(len(actor_ids), dtype=bool)
    mask[outlier_indices] = False
    
    # Filter features and actor IDs
    cleaned_features = features[mask]
    cleaned_actor_ids = [actor_ids[i] for i in range(len(actor_ids)) if mask[i]]
    
    print(f"   ✓ Removed {len(outlier_indices)} outliers")
    print(f"   ✓ Remaining actors: {len(cleaned_actor_ids)}")
    
    return cleaned_features, cleaned_actor_ids

def create_feature_correlation_matrix(features: np.ndarray, 
                                    feature_names: List[str]) -> pd.DataFrame:
    """
    Create correlation matrix for features.
    
    Args:
        features: Feature matrix
        feature_names: List of feature names
    
    Returns:
        Correlation matrix as DataFrame
    """
    # Create DataFrame
    df = pd.DataFrame(features, columns=feature_names)
    
    # Calculate correlation matrix
    correlation_matrix = df.corr()
    
    return correlation_matrix

def suggest_feature_selection(features: np.ndarray, 
                            feature_names: List[str],
                            max_features: int = 10) -> List[str]:
    """
    Suggest features for clustering based on variance and correlation.
    
    Args:
        features: Feature matrix
        feature_names: List of feature names
        max_features: Maximum number of features to select
    
    Returns:
        List of recommended feature names
    """
    # Calculate feature importance (variance)
    importance = get_feature_importance(features, feature_names)
    
    # Calculate correlation matrix
    corr_matrix = create_feature_correlation_matrix(features, feature_names)
    
    # Select features
    selected_features = []
    remaining_features = feature_names.copy()
    
    while len(selected_features) < max_features and remaining_features:
        # Find feature with highest importance
        best_feature = max(remaining_features, key=lambda f: importance[f])
        selected_features.append(best_feature)
        remaining_features.remove(best_feature)
        
        # Remove highly correlated features
        if remaining_features:
            correlations = corr_matrix.loc[best_feature, remaining_features]
            high_corr_features = correlations[abs(correlations) > 0.8].index.tolist()
            remaining_features = [f for f in remaining_features if f not in high_corr_features]
    
    return selected_features
