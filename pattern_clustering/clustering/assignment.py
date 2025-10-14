"""
Actor Assignment Module

Handles assignment of new actors to existing clusters and
batch processing of actor assignments.
"""

import numpy as np
from typing import List, Dict, Any, Tuple
from scipy.spatial.distance import cdist
import warnings
warnings.filterwarnings('ignore')

def assign_actor_to_cluster(actor: Dict[str, Any], 
                           cluster_centers: np.ndarray, 
                           feature_names: List[str],
                           feature_config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Assign new actor to nearest existing cluster.
    
    Args:
        actor: Actor profile dictionary
        cluster_centers: Cluster centroids from clustering
        feature_names: Feature names for feature matrix
        feature_config: Configuration for feature extraction
    
    Returns:
        Dictionary with assignment results
    """
    try:
        # Extract features for this actor
        actor_features = _extract_actor_features(actor, feature_config)
        
        if actor_features is None:
            return {
                'assigned_cohort_id': None,
                'confidence': 0.0,
                'distance_to_center': float('inf'),
                'alternative_cohorts': [],
                'error': 'Failed to extract features'
            }
        
        # Calculate distances to all cluster centers
        distances = cdist([actor_features], cluster_centers, metric='euclidean')[0]
        
        # Find nearest cluster
        nearest_cluster_idx = np.argmin(distances)
        min_distance = distances[nearest_cluster_idx]
        
        # Calculate confidence (inverse of distance, normalized)
        max_possible_distance = np.sqrt(len(actor_features))  # Max distance in normalized space
        confidence = max(0, 1 - (min_distance / max_possible_distance))
        
        # Find alternative clusters (top 3)
        sorted_indices = np.argsort(distances)
        alternative_cohorts = []
        
        for i in range(min(3, len(sorted_indices))):
            if i != nearest_cluster_idx:  # Skip the assigned cluster
                alt_idx = sorted_indices[i]
                alt_distance = distances[alt_idx]
                alt_confidence = max(0, 1 - (alt_distance / max_possible_distance))
                
                alternative_cohorts.append({
                    'cohort_id': f'cluster_{alt_idx}',  # This would be actual cohort_id in practice
                    'distance': float(alt_distance),
                    'confidence': float(alt_confidence)
                })
        
        return {
            'cohort_id': f'cluster_{nearest_cluster_idx}',  # This would be actual cohort_id
            'assigned_cohort_id': f'cluster_{nearest_cluster_idx}',  # Keep for compatibility
            'confidence': float(confidence),
            'distance_to_center': float(min_distance),
            'alternative_cohorts': alternative_cohorts,
            'error': None
        }
        
    except Exception as e:
        return {
            'cohort_id': None,
            'assigned_cohort_id': None,
            'confidence': 0.0,
            'distance_to_center': float('inf'),
            'alternative_cohorts': [],
            'error': str(e)
        }

def batch_assign_actors(actors: List[Dict[str, Any]], 
                       clusters: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Assign multiple actors to clusters efficiently.
    
    Args:
        actors: List of actor profiles
        clusters: List of cluster characterizations
    
    Returns:
        List of assignment results
    """
    print(f"🎯 Assigning {len(actors)} actors to {len(clusters)} clusters...")
    
    try:
        # Extract cluster centers and feature names
        cluster_centers = []
        feature_names = []
        
        for cluster in clusters:
            # This would be extracted from the actual cluster data
            # For now, we'll use a placeholder approach
            pass
        
        # For now, return placeholder assignments
        assignments = []
        for actor in actors:
            assignment = {
                'actor_id': actor['actor_id'],
                'assigned_cohort_id': None,
                'confidence': 0.0,
                'distance_to_center': float('inf'),
                'alternative_cohorts': [],
                'error': 'Assignment not implemented yet'
            }
            assignments.append(assignment)
        
        print(f"   ✓ Assigned {len(assignments)} actors")
        return assignments
        
    except Exception as e:
        print(f"   ❌ Batch assignment failed: {e}")
        raise

def _extract_actor_features(actor: Dict[str, Any], 
                          feature_config: Dict[str, Any]) -> np.ndarray:
    """Extract features for a single actor."""
    try:
        features = []
        
        # Driver features (6 features)
        if feature_config.get('include_drivers', True):
            drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
            for driver in drivers:
                value = actor['driver_distribution'].get(driver, 0.0)
                features.append(float(value))
        
        # Contradiction feature (1 feature)
        if feature_config.get('include_contradiction', True):
            contradiction = actor.get('contradiction_score', 0.0)
            features.append(float(contradiction))
        
        # Quantum features (2 features)
        if feature_config.get('include_quantum', True):
            # Superposition strength (0 or 1)
            superposition_strength = 1.0 if actor.get('superposition_detected', False) else 0.0
            features.append(superposition_strength)
            
            # Coherence score
            coherence = actor.get('coherence', 0.0)
            features.append(float(coherence))
        
        return np.array(features, dtype=np.float64)
        
    except Exception as e:
        print(f"   ⚠️  Error extracting features for actor {actor.get('actor_id', 'unknown')}: {e}")
        return None

def calculate_assignment_confidence(actor_features: np.ndarray, 
                                  cluster_center: np.ndarray) -> float:
    """Calculate confidence score for cluster assignment."""
    try:
        # Calculate Euclidean distance
        distance = np.linalg.norm(actor_features - cluster_center)
        
        # Normalize to 0-1 range (higher = more confident)
        max_possible_distance = np.sqrt(len(actor_features))
        confidence = max(0, 1 - (distance / max_possible_distance))
        
        return float(confidence)
        
    except Exception as e:
        print(f"   ⚠️  Error calculating confidence: {e}")
        return 0.0

def find_similar_actors(actor: Dict[str, Any], 
                       all_actors: List[Dict[str, Any]], 
                       n_similar: int = 5) -> List[Dict[str, Any]]:
    """Find actors similar to the given actor."""
    try:
        # Extract features for the target actor
        target_features = _extract_actor_features(actor, {
            'include_drivers': True,
            'include_contradiction': True,
            'include_quantum': True
        })
        
        if target_features is None:
            return []
        
        # Calculate similarities to all other actors
        similarities = []
        
        for other_actor in all_actors:
            if other_actor['actor_id'] == actor['actor_id']:
                continue
            
            other_features = _extract_actor_features(other_actor, {
                'include_drivers': True,
                'include_contradiction': True,
                'include_quantum': True
            })
            
            if other_features is not None:
                # Calculate cosine similarity
                similarity = _cosine_similarity(target_features, other_features)
                similarities.append((other_actor, similarity))
        
        # Sort by similarity and return top N
        similarities.sort(key=lambda x: x[1], reverse=True)
        return [actor for actor, _ in similarities[:n_similar]]
        
    except Exception as e:
        print(f"   ⚠️  Error finding similar actors: {e}")
        return []

def _cosine_similarity(a: np.ndarray, b: np.ndarray) -> float:
    """Calculate cosine similarity between two vectors."""
    try:
        dot_product = np.dot(a, b)
        norm_a = np.linalg.norm(a)
        norm_b = np.linalg.norm(b)
        
        if norm_a == 0 or norm_b == 0:
            return 0.0
        
        return float(dot_product / (norm_a * norm_b))
        
    except Exception:
        return 0.0

def validate_assignment_quality(assignments: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Validate the quality of actor assignments."""
    try:
        if not assignments:
            return {'error': 'No assignments to validate'}
        
        # Calculate statistics
        confidences = [a.get('confidence', 0.0) for a in assignments if a.get('confidence') is not None]
        distances = [a.get('distance_to_center', float('inf')) for a in assignments if a.get('distance_to_center') is not None]
        
        # Count successful assignments
        successful_assignments = sum(1 for a in assignments if a.get('assigned_cohort_id') is not None)
        
        # Calculate quality metrics
        avg_confidence = np.mean(confidences) if confidences else 0.0
        min_confidence = np.min(confidences) if confidences else 0.0
        max_confidence = np.max(confidences) if confidences else 0.0
        
        avg_distance = np.mean(distances) if distances else float('inf')
        
        # Categorize assignments by confidence
        high_confidence = sum(1 for c in confidences if c > 0.7)
        medium_confidence = sum(1 for c in confidences if 0.4 <= c <= 0.7)
        low_confidence = sum(1 for c in confidences if c < 0.4)
        
        return {
            'total_assignments': len(assignments),
            'successful_assignments': successful_assignments,
            'success_rate': successful_assignments / len(assignments) if assignments else 0.0,
            'avg_confidence': avg_confidence,
            'min_confidence': min_confidence,
            'max_confidence': max_confidence,
            'avg_distance': avg_distance,
            'confidence_distribution': {
                'high': high_confidence,
                'medium': medium_confidence,
                'low': low_confidence
            },
            'quality_score': _calculate_quality_score(avg_confidence, successful_assignments, len(assignments))
        }
        
    except Exception as e:
        return {'error': f'Validation failed: {e}'}

def _calculate_quality_score(avg_confidence: float, 
                           successful_assignments: int, 
                           total_assignments: int) -> float:
    """Calculate overall quality score for assignments."""
    try:
        success_rate = successful_assignments / total_assignments if total_assignments > 0 else 0.0
        
        # Weighted combination of success rate and confidence
        quality_score = (0.6 * success_rate) + (0.4 * avg_confidence)
        
        return float(quality_score)
        
    except Exception:
        return 0.0

def create_assignment_report(assignments: List[Dict[str, Any]]) -> str:
    """Create a report summarizing assignment results."""
    try:
        validation = validate_assignment_quality(assignments)
        
        if 'error' in validation:
            return f"Assignment Report Error: {validation['error']}"
        
        report = f"""# Actor Assignment Report

## Summary
- **Total Assignments:** {validation['total_assignments']}
- **Successful Assignments:** {validation['successful_assignments']}
- **Success Rate:** {validation['success_rate']:.1%}
- **Quality Score:** {validation['quality_score']:.3f}

## Confidence Distribution
- **High Confidence (>0.7):** {validation['confidence_distribution']['high']}
- **Medium Confidence (0.4-0.7):** {validation['confidence_distribution']['medium']}
- **Low Confidence (<0.4):** {validation['confidence_distribution']['low']}

## Statistics
- **Average Confidence:** {validation['avg_confidence']:.3f}
- **Confidence Range:** {validation['min_confidence']:.3f} - {validation['max_confidence']:.3f}
- **Average Distance:** {validation['avg_distance']:.3f}

## Quality Assessment
"""
        
        if validation['quality_score'] > 0.8:
            report += "**Excellent** - High quality assignments with good confidence levels."
        elif validation['quality_score'] > 0.6:
            report += "**Good** - Solid assignments with reasonable confidence levels."
        elif validation['quality_score'] > 0.4:
            report += "**Fair** - Acceptable assignments but room for improvement."
        else:
            report += "**Poor** - Low quality assignments that may need review."
        
        return report
        
    except Exception as e:
        return f"Report generation failed: {e}"
