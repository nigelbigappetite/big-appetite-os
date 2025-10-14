"""
Cluster Characterization Module

Provides detailed characterization of discovered clusters including
driver profiles, behavioral signatures, and messaging strategies.
"""

import numpy as np
import uuid
from typing import List, Dict, Any, Tuple
from collections import Counter
import warnings
warnings.filterwarnings('ignore')

def characterize_clusters(actors: List[Dict[str, Any]], 
                         labels: np.ndarray, 
                         feature_matrix: np.ndarray) -> List[Dict[str, Any]]:
    """
    Generate detailed characterization for each cluster.
    
    Args:
        actors: List of actor profiles
        labels: Cluster labels from clustering
        feature_matrix: Feature matrix used for clustering
    
    Returns:
        List of cohort profiles with detailed characteristics
    """
    print("🎯 Characterizing clusters...")
    
    try:
        n_clusters = len(np.unique(labels))
        cohorts = []
        
        for cluster_id in range(n_clusters):
            # Get actors in this cluster
            cluster_mask = labels == cluster_id
            cluster_actors = [actors[i] for i in range(len(actors)) if cluster_mask[i]]
            cluster_features = feature_matrix[cluster_mask]
            
            if len(cluster_actors) == 0:
                continue
            
            # Characterize this cluster
            cohort = _characterize_single_cluster(
                cluster_id, cluster_actors, cluster_features, len(actors)
            )
            cohorts.append(cohort)
        
        # Sort by size (largest first)
        cohorts.sort(key=lambda x: x['size'], reverse=True)
        
        print(f"   ✓ Characterized {len(cohorts)} clusters")
        for cohort in cohorts:
            print(f"      - {cohort['cohort_name']}: {cohort['size']} actors")
        
        return cohorts
        
    except Exception as e:
        print(f"   ❌ Cluster characterization failed: {e}")
        raise

def _characterize_single_cluster(cluster_id: int, 
                               cluster_actors: List[Dict[str, Any]], 
                               cluster_features: np.ndarray,
                               total_actors: int) -> Dict[str, Any]:
    """Characterize a single cluster."""
    
    # Basic info
    cohort_id = str(uuid.uuid4())
    size = len(cluster_actors)
    percentage = (size / total_actors) * 100
    
    # Calculate driver profile (mean values)
    driver_profile = _calculate_driver_profile(cluster_actors)
    
    # Calculate characteristics
    characteristics = _calculate_cluster_characteristics(cluster_actors, cluster_features)
    
    # Generate behavioral signature
    behavioral_signature = _calculate_behavioral_signature(cluster_actors, cluster_features)
    
    # Generate messaging strategy
    messaging_strategy = generate_messaging_strategy(driver_profile, characteristics)
    
    # Find notable actors (representative examples)
    notable_actors = _find_notable_actors(cluster_actors, cluster_features)
    
    # Generate cohort name
    cohort_name = _generate_cohort_name(driver_profile, characteristics)
    
    return {
        'cohort_id': cohort_id,
        'cohort_name': cohort_name,
        'cohort_description': _generate_cohort_description(driver_profile, characteristics),
        'size': size,
        'percentage': percentage,
        'driver_profile': driver_profile,
        'characteristics': characteristics,
        'behavioral_signature': behavioral_signature,
        'messaging_strategy': messaging_strategy,
        'notable_actors': notable_actors,
        'cluster_id': cluster_id
    }

def _calculate_driver_profile(cluster_actors: List[Dict[str, Any]]) -> Dict[str, float]:
    """Calculate mean driver profile for cluster."""
    drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
    driver_profile = {}
    
    for driver in drivers:
        values = [actor['driver_distribution'][driver] for actor in cluster_actors]
        driver_profile[driver] = float(np.mean(values))
    
    return driver_profile

def _calculate_cluster_characteristics(cluster_actors: List[Dict[str, Any]], 
                                     cluster_features: np.ndarray) -> Dict[str, Any]:
    """Calculate detailed cluster characteristics."""
    
    # Dominant driver analysis
    dominant_drivers = [actor['dominant_driver'] for actor in cluster_actors]
    dominant_counts = Counter(dominant_drivers)
    dominant_driver = dominant_counts.most_common(1)[0][0]
    dominant_percentage = (dominant_counts[dominant_driver] / len(cluster_actors)) * 100
    
    # Contradiction analysis
    contradiction_scores = [actor['contradiction_score'] for actor in cluster_actors]
    avg_contradiction = np.mean(contradiction_scores)
    
    # Categorize contradiction levels
    low_contradiction = sum(1 for score in contradiction_scores if score < 0.3)
    medium_contradiction = sum(1 for score in contradiction_scores if 0.3 <= score < 0.6)
    high_contradiction = sum(1 for score in contradiction_scores if score >= 0.6)
    
    contradiction_distribution = {
        'low': (low_contradiction / len(cluster_actors)) * 100,
        'medium': (medium_contradiction / len(cluster_actors)) * 100,
        'high': (high_contradiction / len(cluster_actors)) * 100
    }
    
    # Quantum state analysis
    quantum_analysis = _analyze_quantum_states(cluster_actors)
    
    # Identity markers analysis
    all_identities = []
    for actor in cluster_actors:
        identities = actor.get('identity_markers', [])
        if isinstance(identities, list):
            all_identities.extend(identities)
    
    common_identities = Counter(all_identities).most_common(3)
    
    return {
        'dominant_driver': dominant_driver,
        'dominant_percentage': dominant_percentage,
        'avg_contradiction': avg_contradiction,
        'contradiction_distribution': contradiction_distribution,
        'superposition_prevalence': quantum_analysis['superposition_prevalence'],
        'avg_coherence': quantum_analysis['avg_coherence'],
        'common_identities': [identity for identity, count in common_identities],
        'driver_variance': _calculate_driver_variance(cluster_actors),
        'cluster_cohesion': _calculate_cluster_cohesion(cluster_features)
    }

def _analyze_quantum_states(cluster_actors: List[Dict[str, Any]]) -> Dict[str, float]:
    """Analyze quantum states in cluster."""
    if 'superposition_detected' not in cluster_actors[0]:
        return {'superposition_prevalence': 0.0, 'avg_coherence': 0.0}
    
    superposition_count = sum(1 for actor in cluster_actors if actor.get('superposition_detected', False))
    superposition_prevalence = (superposition_count / len(cluster_actors)) * 100
    
    coherence_scores = [actor.get('coherence', 0.0) for actor in cluster_actors]
    avg_coherence = np.mean(coherence_scores)
    
    return {
        'superposition_prevalence': superposition_prevalence,
        'avg_coherence': avg_coherence
    }

def _calculate_driver_variance(cluster_actors: List[Dict[str, Any]]) -> float:
    """Calculate variance in driver distributions within cluster."""
    drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
    variances = []
    
    for driver in drivers:
        values = [actor['driver_distribution'][driver] for actor in cluster_actors]
        variances.append(np.var(values))
    
    return float(np.mean(variances))

def _calculate_cluster_cohesion(cluster_features: np.ndarray) -> float:
    """Calculate cluster cohesion (how similar actors are within cluster)."""
    if len(cluster_features) < 2:
        return 1.0
    
    # Calculate pairwise distances
    from scipy.spatial.distance import pdist
    distances = pdist(cluster_features)
    
    # Cohesion is inverse of average distance
    avg_distance = np.mean(distances)
    max_possible_distance = np.sqrt(cluster_features.shape[1])  # Max distance in normalized space
    cohesion = max(0, 1 - (avg_distance / max_possible_distance))
    
    return float(cohesion)

def _calculate_behavioral_signature(cluster_actors: List[Dict[str, Any]], 
                                  cluster_features: np.ndarray) -> Dict[str, Any]:
    """Calculate behavioral signature for cluster."""
    
    # Signal count analysis
    signal_counts = [actor['signal_count'] for actor in cluster_actors]
    avg_signal_count = np.mean(signal_counts)
    
    # Profile completeness
    completeness_scores = [actor.get('profile_completeness', 0.0) for actor in cluster_actors]
    avg_completeness = np.mean(completeness_scores)
    
    # Data quality
    quality_scores = [actor.get('data_quality_score', 0.0) for actor in cluster_actors]
    avg_quality = np.mean(quality_scores)
    
    return {
        'avg_signal_count': avg_signal_count,
        'avg_profile_completeness': avg_completeness,
        'avg_data_quality': avg_quality,
        'driver_variance': _calculate_driver_variance(cluster_actors),
        'cluster_cohesion': _calculate_cluster_cohesion(cluster_features)
    }

def generate_messaging_strategy(driver_profile: Dict[str, float], 
                              characteristics: Dict[str, Any]) -> Dict[str, Any]:
    """
    Generate messaging strategy based on driver profile and characteristics.
    
    Args:
        driver_profile: Mean driver values for cluster
        characteristics: Cluster characteristics
    
    Returns:
        Dictionary with messaging strategy recommendations
    """
    
    # Find dominant driver
    dominant_driver = max(driver_profile, key=driver_profile.get)
    dominant_value = driver_profile[dominant_driver]
    
    # Get contradiction level
    avg_contradiction = characteristics.get('avg_contradiction', 0.0)
    
    # Determine tone based on dominant driver
    tone = _get_messaging_tone(dominant_driver, dominant_value)
    
    # Determine themes based on driver profile
    themes = _get_messaging_themes(driver_profile)
    
    # Determine channels based on characteristics
    channels = _get_messaging_channels(characteristics)
    
    # Determine timing based on behavioral patterns
    timing = _get_messaging_timing(characteristics)
    
    # Generate collapse strategy if high contradiction
    collapse_strategy = _get_collapse_strategy(avg_contradiction, driver_profile)
    
    return {
        'tone': tone,
        'themes': themes,
        'channels': channels,
        'timing': timing,
        'collapse_strategy': collapse_strategy,
        'dominant_driver': dominant_driver,
        'contradiction_level': 'high' if avg_contradiction > 0.6 else 'medium' if avg_contradiction > 0.3 else 'low'
    }

def _get_messaging_tone(dominant_driver: str, dominant_value: float) -> str:
    """Get messaging tone based on dominant driver."""
    tones = {
        'Safety': 'reassuring and trustworthy',
        'Connection': 'warm and community-focused',
        'Status': 'sophisticated and exclusive',
        'Growth': 'inspiring and educational',
        'Freedom': 'liberating and empowering',
        'Purpose': 'meaningful and impactful'
    }
    
    base_tone = tones.get(dominant_driver, 'engaging')
    
    # Adjust based on strength
    if dominant_value > 0.7:
        return f"strongly {base_tone}"
    elif dominant_value > 0.5:
        return f"moderately {base_tone}"
    else:
        return base_tone

def _get_messaging_themes(driver_profile: Dict[str, float]) -> List[str]:
    """Get messaging themes based on driver profile."""
    themes = []
    
    # Add themes for drivers above threshold
    driver_themes = {
        'Safety': ['security', 'reliability', 'trust', 'protection'],
        'Connection': ['community', 'relationships', 'belonging', 'social'],
        'Status': ['prestige', 'recognition', 'exclusivity', 'achievement'],
        'Growth': ['learning', 'development', 'improvement', 'progress'],
        'Freedom': ['independence', 'choice', 'flexibility', 'autonomy'],
        'Purpose': ['meaning', 'impact', 'contribution', 'values']
    }
    
    for driver, value in driver_profile.items():
        if value > 0.3:  # Above threshold
            themes.extend(driver_themes.get(driver, []))
    
    # Remove duplicates and return top themes
    unique_themes = list(set(themes))
    return unique_themes[:5]  # Top 5 themes

def _get_messaging_channels(characteristics: Dict[str, Any]) -> List[str]:
    """Get recommended messaging channels based on characteristics."""
    channels = []
    
    # Base channels
    channels.extend(['Email', 'Website'])
    
    # Add based on characteristics
    if characteristics.get('superposition_prevalence', 0) > 20:
        channels.extend(['Social Media', 'Mobile App'])
    
    if characteristics.get('avg_contradiction', 0) > 0.5:
        channels.extend(['Personal Consultation', 'Phone'])
    
    # Add based on dominant driver
    dominant_driver = characteristics.get('dominant_driver', '')
    if dominant_driver == 'Connection':
        channels.extend(['Social Media', 'Community Forums'])
    elif dominant_driver == 'Status':
        channels.extend(['Premium Channels', 'Exclusive Events'])
    
    return list(set(channels))

def _get_messaging_timing(characteristics: Dict[str, Any]) -> str:
    """Get messaging timing recommendations."""
    avg_contradiction = characteristics.get('avg_contradiction', 0.0)
    superposition_prevalence = characteristics.get('superposition_prevalence', 0.0)
    
    if avg_contradiction > 0.6:
        return "careful timing to address conflicts"
    elif superposition_prevalence > 30:
        return "context-aware timing based on current state"
    else:
        return "consistent routine timing"

def _get_collapse_strategy(avg_contradiction: float, driver_profile: Dict[str, float]) -> str:
    """Get collapse strategy for high contradiction clusters."""
    if avg_contradiction < 0.6:
        return "No special strategy needed - low contradiction"
    
    # Find conflicting drivers
    sorted_drivers = sorted(driver_profile.items(), key=lambda x: x[1], reverse=True)
    top_drivers = [driver for driver, value in sorted_drivers[:3] if value > 0.2]
    
    if len(top_drivers) >= 2:
        return f"Address tension between {top_drivers[0]} and {top_drivers[1]} through integrated messaging"
    else:
        return "Focus on resolving internal conflicts through targeted communication"

def _find_notable_actors(cluster_actors: List[Dict[str, Any]], 
                        cluster_features: np.ndarray) -> List[str]:
    """Find notable actors (representative examples) for cluster."""
    if len(cluster_actors) < 3:
        return [actor['actor_id'] for actor in cluster_actors]
    
    # Find actors closest to cluster centroid
    centroid = np.mean(cluster_features, axis=0)
    distances = []
    
    for i, actor in enumerate(cluster_actors):
        distance = np.linalg.norm(cluster_features[i] - centroid)
        distances.append((actor['actor_id'], distance))
    
    # Sort by distance and return top 3
    distances.sort(key=lambda x: x[1])
    return [actor_id for actor_id, _ in distances[:3]]

def _generate_cohort_name(driver_profile: Dict[str, float], 
                         characteristics: Dict[str, Any]) -> str:
    """Generate descriptive name for cohort based on patterns."""
    
    # Find dominant driver
    dominant_driver = max(driver_profile, key=driver_profile.get)
    dominant_value = driver_profile[dominant_driver]
    
    # Get contradiction level
    avg_contradiction = characteristics.get('avg_contradiction', 0.0)
    
    # Generate name based on patterns
    if avg_contradiction > 0.6:
        return f"High-Contradiction {dominant_driver}"
    elif dominant_value > 0.7:
        return f"{dominant_driver}-Focused"
    elif characteristics.get('superposition_prevalence', 0) > 30:
        return f"Quantum {dominant_driver}"
    else:
        return f"Balanced {dominant_driver}"

def _generate_cohort_description(driver_profile: Dict[str, float], 
                               characteristics: Dict[str, Any]) -> str:
    """Generate detailed description for cohort."""
    
    dominant_driver = max(driver_profile, key=driver_profile.get)
    avg_contradiction = characteristics.get('avg_contradiction', 0.0)
    superposition_prevalence = characteristics.get('superposition_prevalence', 0.0)
    
    description = f"Customers with {dominant_driver.lower()}-focused motivations"
    
    if avg_contradiction > 0.6:
        description += " who experience internal conflicts between competing drivers"
    elif superposition_prevalence > 30:
        description += " whose preferences shift based on context"
    
    return description

def create_cohort_summary(cohorts: List[Dict[str, Any]]) -> str:
    """Create a summary of all cohorts."""
    if not cohorts:
        return "No cohorts available."
    
    summary = f"# Cohort Summary ({len(cohorts)} segments)\n\n"
    
    for i, cohort in enumerate(cohorts, 1):
        summary += f"## {i}. {cohort['cohort_name']}\n"
        summary += f"**Size:** {cohort['size']} actors ({cohort['percentage']:.1f}%)\n"
        summary += f"**Dominant Driver:** {cohort['characteristics']['dominant_driver']}\n"
        summary += f"**Contradiction Level:** {cohort['characteristics']['avg_contradiction']:.2f}\n"
        summary += f"**Messaging Tone:** {cohort['messaging_strategy']['tone']}\n"
        summary += f"**Key Themes:** {', '.join(cohort['messaging_strategy']['themes'][:3])}\n\n"
    
    return summary
