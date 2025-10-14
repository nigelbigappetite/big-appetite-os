"""
Statistical Analysis Module for Pattern Analysis

Provides comprehensive statistical analysis of actor profiles including
driver distributions, correlations, contradictions, and quantum states.
"""

import numpy as np
import pandas as pd
from typing import List, Dict, Any, Tuple
from collections import Counter
import warnings
warnings.filterwarnings('ignore')

def analyze_driver_distributions(actors: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Calculate comprehensive driver distribution statistics.
    
    Args:
        actors: List of actor profiles
    
    Returns:
        Dictionary with driver statistics including averages, std dev, correlations
    """
    print("📊 Analyzing driver distributions...")
    
    if not actors:
        return {}
    
    # Extract driver values
    drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
    driver_data = {driver: [] for driver in drivers}
    
    for actor in actors:
        for driver in drivers:
            driver_data[driver].append(actor['driver_distribution'][driver])
    
    # Convert to numpy arrays
    driver_arrays = {driver: np.array(values) for driver, values in driver_data.items()}
    
    # Calculate basic statistics
    averages = {driver: np.mean(values) for driver, values in driver_arrays.items()}
    std_devs = {driver: np.std(values) for driver, values in driver_arrays.items()}
    min_vals = {driver: np.min(values) for driver, values in driver_arrays.items()}
    max_vals = {driver: np.max(values) for driver, values in driver_arrays.items()}
    
    # Calculate dominant driver counts
    dominant_drivers = [actor['dominant_driver'] for actor in actors]
    dominant_counts = Counter(dominant_drivers)
    
    # Calculate correlation matrix
    driver_df = pd.DataFrame(driver_arrays)
    correlation_matrix = driver_df.corr().values
    
    # Find strong correlations
    strong_positive = []
    strong_negative = []
    
    for i, driver1 in enumerate(drivers):
        for j, driver2 in enumerate(drivers):
            if i < j:  # Avoid duplicates and self-correlation
                corr = correlation_matrix[i, j]
                if corr > 0.5:
                    strong_positive.append((driver1, driver2, corr))
                elif corr < -0.5:
                    strong_negative.append((driver1, driver2, corr))
    
    # Sort by correlation strength
    strong_positive.sort(key=lambda x: x[2], reverse=True)
    strong_negative.sort(key=lambda x: x[2])
    
    print(f"   ✓ Average driver values: {[f'{driver}: {avg:.3f}' for driver, avg in averages.items()]}")
    print(f"   ✓ Dominant driver: {max(dominant_counts, key=dominant_counts.get)} ({max(dominant_counts.values())} actors)")
    print(f"   ✓ Strong positive correlations: {len(strong_positive)}")
    print(f"   ✓ Strong negative correlations: {len(strong_negative)}")
    
    return {
        'averages': averages,
        'std_dev': std_devs,
        'min_max': {driver: (min_vals[driver], max_vals[driver]) for driver in drivers},
        'dominant_driver_counts': dict(dominant_counts),
        'correlation_matrix': correlation_matrix,
        'strong_positive_correlations': strong_positive,
        'strong_negative_correlations': strong_negative,
        'driver_arrays': driver_arrays
    }

def analyze_contradictions(actors: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Analyze contradiction patterns in actor profiles.
    
    Args:
        actors: List of actor profiles
    
    Returns:
        Dictionary with contradiction analysis results
    """
    print("🔍 Analyzing contradiction patterns...")
    
    if not actors:
        return {}
    
    # Extract contradiction scores
    contradiction_scores = [actor['contradiction_score'] for actor in actors]
    
    # Categorize contradiction levels
    low_contradiction = [score for score in contradiction_scores if score < 0.3]
    medium_contradiction = [score for score in contradiction_scores if 0.3 <= score < 0.6]
    high_contradiction = [score for score in contradiction_scores if score >= 0.6]
    
    distribution = {
        'low': len(low_contradiction),
        'medium': len(medium_contradiction),
        'high': len(high_contradiction)
    }
    
    # Find high contradiction actors
    high_contradiction_actors = [
        actor['actor_id'] for actor in actors 
        if actor['contradiction_score'] >= 0.6
    ]
    
    # Analyze common driver conflicts
    driver_conflicts = _analyze_driver_conflicts(actors)
    
    print(f"   ✓ Contradiction distribution: Low={distribution['low']}, Medium={distribution['medium']}, High={distribution['high']}")
    print(f"   ✓ High contradiction actors: {len(high_contradiction_actors)}")
    print(f"   ✓ Common driver conflicts: {len(driver_conflicts)}")
    
    return {
        'distribution': distribution,
        'common_driver_conflicts': driver_conflicts,
        'high_contradiction_actors': high_contradiction_actors,
        'contradiction_stats': {
            'mean': np.mean(contradiction_scores),
            'std': np.std(contradiction_scores),
            'min': np.min(contradiction_scores),
            'max': np.max(contradiction_scores)
        }
    }

def _analyze_driver_conflicts(actors: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Analyze common driver conflicts in actor profiles.
    
    Args:
        actors: List of actor profiles
    
    Returns:
        List of common driver conflict patterns
    """
    drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
    conflict_patterns = {}
    
    for actor in actors:
        driver_values = actor['driver_distribution']
        
        # Find top 2 drivers for this actor
        sorted_drivers = sorted(driver_values.items(), key=lambda x: x[1], reverse=True)
        top_drivers = [d[0] for d in sorted_drivers[:2]]
        
        # Check if they're conflicting (opposite ends of spectrum)
        conflict_pairs = [
            ('Safety', 'Freedom'),
            ('Status', 'Purpose'),
            ('Growth', 'Connection'),
            ('Safety', 'Status'),
            ('Freedom', 'Purpose'),
            ('Growth', 'Safety')
        ]
        
        for driver1, driver2 in conflict_pairs:
            if driver1 in top_drivers and driver2 in top_drivers:
                # Both are in top 2, potential conflict
                pair_key = tuple(sorted([driver1, driver2]))
                if pair_key not in conflict_patterns:
                    conflict_patterns[pair_key] = {
                        'drivers': list(pair_key),
                        'count': 0,
                        'avg_strength': 0.0,
                        'actors': []
                    }
                
                conflict_patterns[pair_key]['count'] += 1
                conflict_patterns[pair_key]['actors'].append(actor['actor_id'])
                
                # Calculate conflict strength
                strength = abs(driver_values[driver1] - driver_values[driver2])
                conflict_patterns[pair_key]['avg_strength'] = (
                    (conflict_patterns[pair_key]['avg_strength'] * (conflict_patterns[pair_key]['count'] - 1) + strength) 
                    / conflict_patterns[pair_key]['count']
                )
    
    # Convert to list and sort by count
    conflicts = list(conflict_patterns.values())
    conflicts.sort(key=lambda x: x['count'], reverse=True)
    
    return conflicts

def analyze_quantum_states(actors: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Analyze quantum psychology patterns in actor profiles.
    
    Args:
        actors: List of actor profiles
    
    Returns:
        Dictionary with quantum state analysis results
    """
    print("🌌 Analyzing quantum states...")
    
    if not actors:
        return {}
    
    # Check if quantum data is available
    if 'superposition_detected' not in actors[0]:
        print("   ⚠️  No quantum data available, skipping quantum analysis")
        return {'quantum_data_available': False}
    
    # Extract quantum data
    superposition_count = sum(1 for actor in actors if actor['superposition_detected'])
    superposition_prevalence = superposition_count / len(actors)
    
    coherence_scores = [actor['coherence'] for actor in actors]
    superposition_types = [actor['superposition_type'] for actor in actors if actor['superposition_detected']]
    
    # Analyze common superposition patterns
    common_patterns = _analyze_superposition_patterns(actors)
    
    # Analyze coherence by dominant driver
    coherence_by_driver = {}
    for actor in actors:
        dominant = actor['dominant_driver']
        if dominant not in coherence_by_driver:
            coherence_by_driver[dominant] = []
        coherence_by_driver[dominant].append(actor['coherence'])
    
    avg_coherence_by_driver = {
        driver: np.mean(coherence_scores) if coherence_scores else 0.0
        for driver, coherence_scores in coherence_by_driver.items()
    }
    
    print(f"   ✓ Superposition prevalence: {superposition_prevalence:.1%}")
    print(f"   ✓ Average coherence: {np.mean(coherence_scores):.3f}")
    print(f"   ✓ Common patterns: {len(common_patterns)}")
    
    return {
        'quantum_data_available': True,
        'superposition_prevalence': superposition_prevalence,
        'superposition_count': superposition_count,
        'coherence_stats': {
            'mean': np.mean(coherence_scores),
            'std': np.std(coherence_scores),
            'min': np.min(coherence_scores),
            'max': np.max(coherence_scores)
        },
        'common_patterns': common_patterns,
        'avg_coherence_by_dominant_driver': avg_coherence_by_driver,
        'superposition_types': Counter(superposition_types)
    }

def _analyze_superposition_patterns(actors: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Analyze common superposition patterns in actor profiles.
    
    Args:
        actors: List of actor profiles with superposition detected
    
    Returns:
        List of common superposition patterns
    """
    drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
    patterns = {}
    
    for actor in actors:
        if not actor['superposition_detected']:
            continue
        
        driver_values = actor['driver_distribution']
        
        # Find drivers with similar high values (potential superposition)
        sorted_drivers = sorted(driver_values.items(), key=lambda x: x[1], reverse=True)
        
        # Look for drivers with values within 0.1 of each other
        high_drivers = []
        for i, (driver1, value1) in enumerate(sorted_drivers):
            for j, (driver2, value2) in enumerate(sorted_drivers[i+1:], i+1):
                if abs(value1 - value2) < 0.1 and value1 > 0.2:  # Both significant
                    pair = tuple(sorted([driver1, driver2]))
                    if pair not in patterns:
                        patterns[pair] = {
                            'drivers': list(pair),
                            'count': 0,
                            'avg_strength': 0.0
                        }
                    
                    patterns[pair]['count'] += 1
                    patterns[pair]['avg_strength'] = (
                        (patterns[pair]['avg_strength'] * (patterns[pair]['count'] - 1) + 
                         (value1 + value2) / 2) / patterns[pair]['count']
                    )
    
    # Convert to list and sort by count
    pattern_list = list(patterns.values())
    pattern_list.sort(key=lambda x: x['count'], reverse=True)
    
    return pattern_list

def calculate_correlations(actors: List[Dict[str, Any]]) -> Tuple[pd.DataFrame, List, List]:
    """
    Calculate pairwise driver correlations.
    
    Args:
        actors: List of actor profiles
    
    Returns:
        Tuple of (correlation_matrix, strong_positive, strong_negative)
    """
    print("🔗 Calculating driver correlations...")
    
    if not actors:
        return pd.DataFrame(), [], []
    
    # Extract driver values
    drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
    driver_data = {driver: [] for driver in drivers}
    
    for actor in actors:
        for driver in drivers:
            driver_data[driver].append(actor['driver_distribution'][driver])
    
    # Create DataFrame
    df = pd.DataFrame(driver_data)
    
    # Calculate correlation matrix
    correlation_matrix = df.corr()
    
    # Find strong correlations
    strong_positive = []
    strong_negative = []
    
    for i, driver1 in enumerate(drivers):
        for j, driver2 in enumerate(drivers):
            if i < j:  # Avoid duplicates and self-correlation
                corr = correlation_matrix.loc[driver1, driver2]
                if corr > 0.5:
                    strong_positive.append((driver1, driver2, corr))
                elif corr < -0.5:
                    strong_negative.append((driver1, driver2, corr))
    
    # Sort by correlation strength
    strong_positive.sort(key=lambda x: x[2], reverse=True)
    strong_negative.sort(key=lambda x: x[2])
    
    print(f"   ✓ Correlation matrix calculated: {correlation_matrix.shape}")
    print(f"   ✓ Strong positive correlations: {len(strong_positive)}")
    print(f"   ✓ Strong negative correlations: {len(strong_negative)}")
    
    return correlation_matrix, strong_positive, strong_negative

def generate_segment_hypotheses(driver_stats: Dict[str, Any], 
                               contradiction_stats: Dict[str, Any],
                               quantum_stats: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Generate initial segment hypotheses based on pattern analysis.
    
    Args:
        driver_stats: Driver distribution statistics
        contradiction_stats: Contradiction analysis results
        quantum_stats: Quantum state analysis results
    
    Returns:
        List of proposed customer segments with characteristics
    """
    print("💡 Generating segment hypotheses...")
    
    hypotheses = []
    
    # Get dominant driver distribution
    dominant_counts = driver_stats.get('dominant_driver_counts', {})
    driver_averages = driver_stats.get('averages', {})
    
    # Generate hypotheses based on dominant drivers
    for driver, count in dominant_counts.items():
        if count > 10:  # Minimum segment size
            hypothesis = {
                'segment_name': f"{driver}-Focused",
                'primary_driver': driver,
                'estimated_size': count,
                'characteristics': {
                    'dominant_driver': driver,
                    'avg_driver_value': driver_averages.get(driver, 0.0),
                    'expected_contradiction': 'low' if driver in ['Safety', 'Purpose'] else 'medium',
                    'messaging_theme': _get_messaging_theme(driver)
                },
                'confidence': 'high' if count > 30 else 'medium'
            }
            hypotheses.append(hypothesis)
    
    # Generate hypotheses based on contradiction patterns
    high_contradiction_count = contradiction_stats.get('distribution', {}).get('high', 0)
    if high_contradiction_count > 15:
        hypothesis = {
            'segment_name': "High-Contradiction",
            'primary_driver': 'mixed',
            'estimated_size': high_contradiction_count,
            'characteristics': {
                'dominant_driver': 'mixed',
                'contradiction_level': 'high',
                'expected_behavior': 'unpredictable',
                'messaging_theme': 'resolution-focused'
            },
            'confidence': 'medium'
        }
        hypotheses.append(hypothesis)
    
    # Generate hypotheses based on quantum states
    if quantum_stats.get('quantum_data_available', False):
        superposition_count = quantum_stats.get('superposition_count', 0)
        if superposition_count > 20:
            hypothesis = {
                'segment_name': "Quantum-Shifters",
                'primary_driver': 'context-dependent',
                'estimated_size': superposition_count,
                'characteristics': {
                    'dominant_driver': 'context-dependent',
                    'quantum_behavior': True,
                    'expected_behavior': 'context-sensitive',
                    'messaging_theme': 'adaptive'
                },
                'confidence': 'medium'
            }
            hypotheses.append(hypothesis)
    
    # Sort by estimated size
    hypotheses.sort(key=lambda x: x['estimated_size'], reverse=True)
    
    print(f"   ✓ Generated {len(hypotheses)} segment hypotheses")
    for hyp in hypotheses:
        print(f"      - {hyp['segment_name']}: {hyp['estimated_size']} actors ({hyp['confidence']} confidence)")
    
    return hypotheses

def _get_messaging_theme(driver: str) -> str:
    """Get messaging theme based on dominant driver."""
    themes = {
        'Safety': 'security and reliability',
        'Connection': 'community and relationships',
        'Status': 'prestige and recognition',
        'Growth': 'learning and development',
        'Freedom': 'independence and choice',
        'Purpose': 'meaning and impact'
    }
    return themes.get(driver, 'general appeal')
