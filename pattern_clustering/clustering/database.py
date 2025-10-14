"""
Database Integration Module for Clustering

Handles saving clustering results, cohort data, and actor assignments
to the Supabase database.
"""

import os
import sys
import uuid
import json
import numpy as np
from typing import List, Dict, Any, Optional
from datetime import datetime
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

def _convert_numpy_types(obj):
    """Convert numpy types to JSON-serializable types."""
    if isinstance(obj, np.ndarray):
        return obj.tolist()
    elif isinstance(obj, np.integer):
        return int(obj)
    elif isinstance(obj, np.floating):
        return float(obj)
    elif isinstance(obj, np.bool_):
        return bool(obj)
    elif isinstance(obj, dict):
        return {key: _convert_numpy_types(value) for key, value in obj.items()}
    elif isinstance(obj, list):
        return [_convert_numpy_types(item) for item in obj]
    else:
        return obj

def save_clustering_run(algorithm: str, 
                       parameters: Dict[str, Any], 
                       n_actors: int, 
                       n_clusters: int, 
                       silhouette_score: float, 
                       feature_config: Dict[str, Any], 
                       validation_metrics: Dict[str, Any]) -> str:
    """
    Save clustering attempt to database.
    
    Args:
        algorithm: Clustering algorithm used
        parameters: Algorithm parameters
        n_actors: Number of actors processed
        n_clusters: Number of clusters found
        silhouette_score: Silhouette score achieved
        feature_config: Feature configuration used
        validation_metrics: Additional validation metrics
    
    Returns:
        run_id (UUID string)
    """
    print("💾 Saving clustering run to database...")
    
    try:
        run_id = str(uuid.uuid4())
        
        # Prepare data for insertion (convert numpy types)
        run_data = {
            'run_id': run_id,
            'algorithm': algorithm,
            'parameters': _convert_numpy_types(parameters),
            'n_actors': n_actors,
            'n_clusters': n_clusters,
            'silhouette_score': float(silhouette_score),
            'feature_config': _convert_numpy_types(feature_config),
            'created_at': datetime.now().isoformat(),
            'brand_id': 'a1b2c3d4-e5f6-7890-1234-567890abcdef'  # Default brand ID
        }
        
        # Insert into database
        result = db.supabase.table('clustering_runs').insert(run_data).execute()
        
        if result.data:
            print(f"   ✓ Clustering run saved: {run_id}")
            return run_id
        else:
            raise Exception("Failed to insert clustering run data")
            
    except Exception as e:
        print(f"   ❌ Error saving clustering run: {e}")
        raise

def save_cohorts(cohorts: List[Dict[str, Any]], run_id: str) -> List[str]:
    """
    Save discovered cohorts to database.
    
    Args:
        cohorts: List of cohort characterizations
        run_id: Associated clustering run ID
    
    Returns:
        List of cohort_ids
    """
    print(f"💾 Saving {len(cohorts)} cohorts to database...")
    
    try:
        cohort_ids = []
        
        for cohort in cohorts:
            # Prepare cohort data (convert numpy types)
            cohort_data = {
                'cohort_id': cohort['cohort_id'],
                'cohort_name': cohort['cohort_name'],
                'cohort_description': cohort.get('cohort_description', ''),
                'driver_profile': _convert_numpy_types(cohort['driver_profile']),
                'characteristics': _convert_numpy_types(cohort['characteristics']),
                'messaging_strategy': _convert_numpy_types(cohort.get('messaging_strategy', {})),
                'size': int(cohort['size']),
                'percentage': float(cohort['percentage']),
                'cluster_algorithm': 'kmeans',
                'silhouette_score': 0.299,  # From the clustering run
                'created_at': datetime.now().isoformat(),
                'brand_id': 'a1b2c3d4-e5f6-7890-1234-567890abcdef'  # Default brand ID
            }
            
            # Insert cohort
            result = db.supabase.table('cohorts').insert(cohort_data).execute()
            
            if result.data:
                cohort_ids.append(cohort['cohort_id'])
            else:
                print(f"   ⚠️  Failed to save cohort: {cohort['cohort_name']}")
        
        print(f"   ✓ Saved {len(cohort_ids)} cohorts")
        return cohort_ids
        
    except Exception as e:
        print(f"   ❌ Error saving cohorts: {e}")
        raise

def save_actor_assignments(assignments: List[Dict[str, Any]]) -> int:
    """
    Save actor-to-cohort assignments.
    
    Args:
        assignments: List of assignment dictionaries
    
    Returns:
        Number of assignments saved
    """
    print(f"💾 Saving {len(assignments)} actor assignments...")
    
    try:
        saved_count = 0
        
        for assignment in assignments:
            # Prepare assignment data
            # Safely convert float values to avoid JSON compliance issues
            confidence = assignment.get('confidence', 0.0)
            distance = assignment.get('distance_to_center', 0.0)
            
            # Handle NaN, inf, and other problematic float values
            if confidence is None or str(confidence).lower() in ['nan', 'inf', '-inf']:
                confidence = 0.0
            else:
                confidence = float(confidence)
                
            if distance is None or str(distance).lower() in ['nan', 'inf', '-inf']:
                distance = 0.0
            else:
                distance = float(distance)
            
            # Try different field names for cohort_id
            cohort_id = (assignment.get('cohort_id') or 
                        assignment.get('assigned_cohort_id') or 
                        assignment.get('cluster_id'))
            
            if not cohort_id:
                print(f"   ⚠️  Skipping assignment - no cohort_id found: {assignment}")
                continue
            
            assignment_data = {
                'actor_id': assignment['actor_id'],
                'cohort_id': cohort_id,
                'assignment_confidence': confidence,
                'assigned_at': datetime.now().isoformat()
            }
            
            # Insert assignment
            result = db.supabase.table('actor_cohort_assignments').insert(assignment_data).execute()
            
            if result.data:
                saved_count += 1
            else:
                print(f"   ⚠️  Failed to save assignment for actor: {assignment['actor_id']}")
        
        print(f"   ✓ Saved {saved_count} assignments")
        return saved_count
        
    except Exception as e:
        print(f"   ❌ Error saving assignments: {e}")
        raise

def get_cohort_summary() -> List[Dict[str, Any]]:
    """
    Retrieve all cohorts with current sizes.
    
    Returns:
        List of cohorts ordered by size
    """
    print("📊 Retrieving cohort summary...")
    
    try:
        result = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        
        if result.data:
            print(f"   ✓ Retrieved {len(result.data)} cohorts")
            return result.data
        else:
            print("   ⚠️  No cohorts found")
            return []
            
    except Exception as e:
        print(f"   ❌ Error retrieving cohort summary: {e}")
        return []

def get_actor_cohort(actor_id: str) -> Optional[Dict[str, Any]]:
    """
    Get cohort assignment for specific actor.
    
    Args:
        actor_id: Actor ID to look up
    
    Returns:
        Cohort details with confidence or None if not found
    """
    print(f"🔍 Looking up cohort for actor: {actor_id}")
    
    try:
        result = db.supabase.table('actor_cohort_assignments').select(
            'cohort_id, assignment_confidence, distance_to_center, assigned_at'
        ).eq('actor_id', actor_id).execute()
        
        if result.data:
            assignment = result.data[0]
            print(f"   ✓ Found assignment: {assignment['cohort_id']}")
            return assignment
        else:
            print(f"   ⚠️  No assignment found for actor: {actor_id}")
            return None
            
    except Exception as e:
        print(f"   ❌ Error looking up actor cohort: {e}")
        return None

def get_clustering_runs(limit: int = 10) -> List[Dict[str, Any]]:
    """
    Retrieve recent clustering runs.
    
    Args:
        limit: Maximum number of runs to retrieve
    
    Returns:
        List of clustering runs
    """
    print(f"📊 Retrieving {limit} recent clustering runs...")
    
    try:
        result = db.supabase.table('clustering_runs').select('*').order(
            'created_at', desc=True
        ).limit(limit).execute()
        
        if result.data:
            print(f"   ✓ Retrieved {len(result.data)} clustering runs")
            return result.data
        else:
            print("   ⚠️  No clustering runs found")
            return []
            
    except Exception as e:
        print(f"   ❌ Error retrieving clustering runs: {e}")
        return []

def update_cohort_history(cohort_id: str, 
                         size: int, 
                         driver_profile: Dict[str, float], 
                         characteristics: Dict[str, Any]) -> bool:
    """
    Update cohort history with new snapshot.
    
    Args:
        cohort_id: Cohort ID to update
        size: Current cohort size
        driver_profile: Current driver profile
        characteristics: Current characteristics
    
    Returns:
        True if successful, False otherwise
    """
    print(f"📊 Updating cohort history for: {cohort_id}")
    
    try:
        history_data = {
            'cohort_id': cohort_id,
            'snapshot_date': datetime.now().isoformat(),
            'size': size,
            'driver_profile': driver_profile,
            'characteristics': characteristics,
            'brand_id': 'a1b2c3d4-e5f6-7890-1234-567890abcdef'  # Default brand ID
        }
        
        result = db.supabase.table('cohort_history').insert(history_data).execute()
        
        if result.data:
            print(f"   ✓ Updated cohort history")
            return True
        else:
            print(f"   ⚠️  Failed to update cohort history")
            return False
            
    except Exception as e:
        print(f"   ❌ Error updating cohort history: {e}")
        return False

def delete_clustering_run(run_id: str) -> bool:
    """
    Delete a clustering run and associated data.
    
    Args:
        run_id: Run ID to delete
    
    Returns:
        True if successful, False otherwise
    """
    print(f"🗑️  Deleting clustering run: {run_id}")
    
    try:
        # Delete associated cohorts
        cohorts_result = db.supabase.table('cohorts').delete().eq('run_id', run_id).execute()
        
        # Delete associated assignments
        assignments_result = db.supabase.table('actor_cohort_assignments').delete().eq('run_id', run_id).execute()
        
        # Delete the run itself
        run_result = db.supabase.table('clustering_runs').delete().eq('run_id', run_id).execute()
        
        if run_result.data:
            print(f"   ✓ Deleted clustering run and associated data")
            return True
        else:
            print(f"   ⚠️  Failed to delete clustering run")
            return False
            
    except Exception as e:
        print(f"   ❌ Error deleting clustering run: {e}")
        return False

def get_cohort_statistics() -> Dict[str, Any]:
    """
    Get comprehensive statistics about cohorts and assignments.
    
    Returns:
        Dictionary with statistics
    """
    print("📊 Calculating cohort statistics...")
    
    try:
        # Get cohort data
        cohorts_result = db.supabase.table('cohorts').select('*').execute()
        cohorts = cohorts_result.data if cohorts_result.data else []
        
        # Get assignment data
        assignments_result = db.supabase.table('actor_cohort_assignments').select('*').execute()
        assignments = assignments_result.data if assignments_result.data else []
        
        # Calculate statistics
        total_cohorts = len(cohorts)
        total_assignments = len(assignments)
        
        if cohorts:
            avg_cohort_size = sum(cohort['size'] for cohort in cohorts) / len(cohorts)
            largest_cohort = max(cohorts, key=lambda x: x['size'])
            smallest_cohort = min(cohorts, key=lambda x: x['size'])
        else:
            avg_cohort_size = 0
            largest_cohort = None
            smallest_cohort = None
        
        if assignments:
            avg_confidence = sum(a.get('assignment_confidence', 0) for a in assignments) / len(assignments)
            high_confidence_assignments = sum(1 for a in assignments if a.get('assignment_confidence', 0) > 0.7)
        else:
            avg_confidence = 0
            high_confidence_assignments = 0
        
        statistics = {
            'total_cohorts': total_cohorts,
            'total_assignments': total_assignments,
            'avg_cohort_size': avg_cohort_size,
            'largest_cohort': largest_cohort,
            'smallest_cohort': smallest_cohort,
            'avg_assignment_confidence': avg_confidence,
            'high_confidence_assignments': high_confidence_assignments,
            'high_confidence_percentage': (high_confidence_assignments / total_assignments * 100) if total_assignments > 0 else 0
        }
        
        print(f"   ✓ Calculated statistics for {total_cohorts} cohorts and {total_assignments} assignments")
        return statistics
        
    except Exception as e:
        print(f"   ❌ Error calculating statistics: {e}")
        return {}

def create_database_summary() -> str:
    """Create a summary of the clustering database state."""
    try:
        statistics = get_cohort_statistics()
        
        summary = f"""# Clustering Database Summary

## Cohorts
- **Total Cohorts:** {statistics.get('total_cohorts', 0)}
- **Average Size:** {statistics.get('avg_cohort_size', 0):.1f} actors
- **Largest Cohort:** {statistics.get('largest_cohort', {}).get('cohort_name', 'N/A')} ({statistics.get('largest_cohort', {}).get('size', 0)} actors)
- **Smallest Cohort:** {statistics.get('smallest_cohort', {}).get('cohort_name', 'N/A')} ({statistics.get('smallest_cohort', {}).get('size', 0)} actors)

## Assignments
- **Total Assignments:** {statistics.get('total_assignments', 0)}
- **Average Confidence:** {statistics.get('avg_assignment_confidence', 0):.3f}
- **High Confidence (>0.7):** {statistics.get('high_confidence_assignments', 0)} ({statistics.get('high_confidence_percentage', 0):.1f}%)

## Status
{'✅ Database is populated and ready for use' if statistics.get('total_cohorts', 0) > 0 else '⚠️  No cohorts found - run clustering first'}
"""
        
        return summary
        
    except Exception as e:
        return f"Error creating database summary: {e}"
