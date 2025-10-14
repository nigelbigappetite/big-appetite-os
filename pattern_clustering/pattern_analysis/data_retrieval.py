"""
Data Retrieval Module for Pattern Analysis

Handles retrieval and preprocessing of actor profiles from the database
for pattern analysis and clustering.
"""

import os
import sys
import pandas as pd
import numpy as np
from typing import List, Dict, Any, Optional
from dotenv import load_dotenv

# Add intelligence_layer to path
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PKG_PATH = os.path.join(ROOT, 'intelligence_layer')
if PKG_PATH not in sys.path:
    sys.path.append(PKG_PATH)

# Also add the parent directory to path for direct imports
PARENT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if PARENT_DIR not in sys.path:
    sys.path.append(PARENT_DIR)

load_dotenv()

from intelligence_layer.src.database import DatabaseManager

# Initialize database connection
db = DatabaseManager()

def get_actor_profiles(min_signals: int = 1, include_quantum: bool = True) -> List[Dict[str, Any]]:
    """
    Retrieve actor profiles from Supabase database.
    
    Args:
        min_signals: Minimum number of signals required (default: 1, since max is 2)
        include_quantum: Whether to include quantum state data (default: True)
    
    Returns:
        List of actor profile dictionaries with cleaned data structure
    
    Raises:
        Exception: If database connection fails or no profiles found
    """
    try:
        print(f"🔍 Retrieving actor profiles (min_signals={min_signals})...")
        
        # Build query with filters
        query = db.supabase.table('actor_profiles').select('*')
        
        # Filter by minimum signals
        if min_signals > 0:
            query = query.gte('signal_count', min_signals)
        
        # Filter for actors with driver distributions
        query = query.not_.is_('driver_distribution', 'null')
        
        # Execute query
        result = query.execute()
        
        if not result.data:
            raise Exception("No actor profiles found matching criteria")
        
        print(f"   ✓ Found {len(result.data)} actor profiles")
        
        # Clean and validate data
        cleaned_actors = []
        for actor in result.data:
            try:
                cleaned_actor = _clean_actor_profile(actor, include_quantum)
                if cleaned_actor:
                    cleaned_actors.append(cleaned_actor)
            except Exception as e:
                print(f"   ⚠️  Skipping actor {actor.get('actor_id', 'unknown')}: {e}")
                continue
        
        print(f"   ✓ Cleaned {len(cleaned_actors)} valid profiles")
        
        if len(cleaned_actors) < 10:
            print(f"   ⚠️  Warning: Only {len(cleaned_actors)} profiles available for analysis")
        
        return cleaned_actors
        
    except Exception as e:
        print(f"   ❌ Error retrieving actor profiles: {e}")
        raise

def _clean_actor_profile(actor: Dict[str, Any], include_quantum: bool = True) -> Optional[Dict[str, Any]]:
    """
    Clean and validate a single actor profile.
    
    Args:
        actor: Raw actor profile from database
        include_quantum: Whether to include quantum state data
    
    Returns:
        Cleaned actor profile or None if invalid
    """
    try:
        # Extract driver distribution
        driver_dist = actor.get('driver_distribution', {})
        if not isinstance(driver_dist, dict):
            return None
        
        # Validate driver distribution has all 6 drivers
        required_drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
        if not all(driver in driver_dist for driver in required_drivers):
            return None
        
        # Convert driver values to float
        driver_values = {}
        for driver in required_drivers:
            try:
                driver_values[driver] = float(driver_dist[driver])
            except (ValueError, TypeError):
                driver_values[driver] = 0.0
        
        # Calculate dominant driver
        dominant_driver = max(driver_values, key=driver_values.get)
        
        # Extract quantum states if requested
        quantum_data = {}
        if include_quantum:
            quantum_states = actor.get('quantum_states', {})
            if isinstance(quantum_states, dict):
                quantum_data = {
                    'superposition_detected': quantum_states.get('superposition', 'none') != 'none',
                    'coherence': float(quantum_states.get('coherence', 0.0)),
                    'superposition_type': str(quantum_states.get('superposition', 'none'))
                }
            else:
                quantum_data = {
                    'superposition_detected': False,
                    'coherence': 0.0,
                    'superposition_type': 'none'
                }
        
        # Extract contradiction data
        contradiction_score = float(actor.get('contradiction_complexity', 0.0))
        
        # Extract identity markers
        identity_markers = actor.get('identity_markers', [])
        if not isinstance(identity_markers, list):
            identity_markers = []
        
        # Build cleaned profile
        cleaned = {
            'actor_id': str(actor['actor_id']),
            'brand_id': str(actor.get('brand_id', '')),
            'driver_distribution': driver_values,
            'dominant_driver': dominant_driver,
            'driver_confidence': float(actor.get('driver_confidence', 0.0)),
            'contradiction_score': contradiction_score,
            'identity_markers': identity_markers,
            'signal_count': int(actor.get('signal_count', 0)),
            'signal_sources': actor.get('signal_sources', []),
            'profile_completeness': float(actor.get('profile_completeness', 0.0)),
            'data_quality_score': float(actor.get('data_quality_score', 0.0)),
            'created_at': actor.get('created_at', ''),
            'updated_at': actor.get('updated_at', '')
        }
        
        # Add quantum data if requested
        if include_quantum:
            cleaned.update(quantum_data)
        
        return cleaned
        
    except Exception as e:
        print(f"   ⚠️  Error cleaning actor profile: {e}")
        return None

def export_to_dataframe(actors: List[Dict[str, Any]]) -> pd.DataFrame:
    """
    Convert actor profiles to pandas DataFrame for analysis.
    
    Args:
        actors: List of cleaned actor profiles
    
    Returns:
        DataFrame with columns for all driver values and metadata
    
    Raises:
        Exception: If conversion fails
    """
    try:
        print("📊 Converting actors to DataFrame...")
        
        if not actors:
            raise Exception("No actors provided for DataFrame conversion")
        
        # Extract driver distributions
        driver_data = []
        for actor in actors:
            row = {
                'actor_id': actor['actor_id'],
                'brand_id': actor['brand_id'],
                'Safety': actor['driver_distribution']['Safety'],
                'Connection': actor['driver_distribution']['Connection'],
                'Status': actor['driver_distribution']['Status'],
                'Growth': actor['driver_distribution']['Growth'],
                'Freedom': actor['driver_distribution']['Freedom'],
                'Purpose': actor['driver_distribution']['Purpose'],
                'dominant_driver': actor['dominant_driver'],
                'driver_confidence': actor['driver_confidence'],
                'contradiction_score': actor['contradiction_score'],
                'signal_count': actor['signal_count'],
                'profile_completeness': actor['profile_completeness'],
                'data_quality_score': actor['data_quality_score']
            }
            
            # Add quantum data if available
            if 'superposition_detected' in actor:
                row.update({
                    'superposition_detected': actor['superposition_detected'],
                    'coherence': actor['coherence'],
                    'superposition_type': actor['superposition_type']
                })
            
            driver_data.append(row)
        
        # Create DataFrame
        df = pd.DataFrame(driver_data)
        
        # Validate DataFrame
        if df.empty:
            raise Exception("DataFrame is empty after conversion")
        
        print(f"   ✓ DataFrame created: {df.shape[0]} rows, {df.shape[1]} columns")
        
        # Check for missing values
        missing_count = df.isnull().sum().sum()
        if missing_count > 0:
            print(f"   ⚠️  Warning: {missing_count} missing values found")
        
        # Display basic statistics
        print(f"   ✓ Driver value ranges:")
        for driver in ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']:
            if driver in df.columns:
                min_val = df[driver].min()
                max_val = df[driver].max()
                mean_val = df[driver].mean()
                print(f"      {driver}: {min_val:.3f} - {max_val:.3f} (avg: {mean_val:.3f})")
        
        return df
        
    except Exception as e:
        print(f"   ❌ Error creating DataFrame: {e}")
        raise

def get_actor_summary(actors: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Generate summary statistics for actor profiles.
    
    Args:
        actors: List of actor profiles
    
    Returns:
        Dictionary with summary statistics
    """
    if not actors:
        return {}
    
    # Basic counts
    total_actors = len(actors)
    
    # Signal count distribution
    signal_counts = [actor['signal_count'] for actor in actors]
    
    # Driver distribution summary
    driver_stats = {}
    for driver in ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']:
        values = [actor['driver_distribution'][driver] for actor in actors]
        driver_stats[driver] = {
            'mean': np.mean(values),
            'std': np.std(values),
            'min': np.min(values),
            'max': np.max(values)
        }
    
    # Dominant driver distribution
    dominant_drivers = [actor['dominant_driver'] for actor in actors]
    dominant_counts = {}
    for driver in set(dominant_drivers):
        dominant_counts[driver] = dominant_drivers.count(driver)
    
    # Contradiction score distribution
    contradiction_scores = [actor['contradiction_score'] for actor in actors]
    
    # Quantum state summary (if available)
    quantum_summary = {}
    if 'superposition_detected' in actors[0]:
        superposition_count = sum(1 for actor in actors if actor['superposition_detected'])
        quantum_summary = {
            'superposition_prevalence': superposition_count / total_actors,
            'avg_coherence': np.mean([actor['coherence'] for actor in actors])
        }
    
    return {
        'total_actors': total_actors,
        'signal_count_stats': {
            'min': min(signal_counts),
            'max': max(signal_counts),
            'mean': np.mean(signal_counts),
            'std': np.std(signal_counts)
        },
        'driver_stats': driver_stats,
        'dominant_driver_counts': dominant_counts,
        'contradiction_stats': {
            'min': min(contradiction_scores),
            'max': max(contradiction_scores),
            'mean': np.mean(contradiction_scores),
            'std': np.std(contradiction_scores)
        },
        'quantum_summary': quantum_summary
    }
