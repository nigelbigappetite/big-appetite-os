"""
Database connection using raw SQL to bypass schema cache issues
Big Appetite OS - Quantum Psychology System
"""

import logging
from typing import Dict, List, Optional, Any
from supabase import create_client
from .config import SUPABASE_URL, SUPABASE_KEY, DRIVER_NAMES

logger = logging.getLogger(__name__)

class DatabaseManagerSQL:
    """Manages Supabase database connections using raw SQL"""
    
    def __init__(self):
        self.client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    def get_driver_ontology(self) -> Dict[str, Any]:
        """Get complete driver ontology from database using raw SQL"""
        try:
            # Use raw SQL to bypass schema cache issues
            response = self.client.rpc('exec_sql', {
                'sql': 'SELECT * FROM actors.drivers'
            }).execute()
            
            if not response.data:
                raise ValueError("No drivers found in database")
            
            ontology = {}
            for driver in response.data:
                ontology[driver["driver_name"]] = {
                    "core_meaning": driver["core_meaning"],
                    "core_need": driver["core_need"],
                    "emotional_tone": driver["emotional_tone"],
                    "typical_behaviors": driver["typical_behaviors"],
                    "language_patterns": driver["language_patterns"],
                    "friction_indicators": driver["friction_indicators"],
                    "driver_dynamics": driver["driver_dynamics"]
                }
            
            return ontology
        except Exception as e:
            logger.error(f"Failed to get driver ontology: {e}")
            raise
    
    def get_driver_conflicts(self) -> Dict[str, List[Dict[str, Any]]]:
        """Get driver conflict matrix from database using raw SQL"""
        try:
            response = self.client.rpc('exec_sql', {
                'sql': 'SELECT driver_name, driver_dynamics FROM actors.drivers'
            }).execute()
            
            conflicts = {}
            for driver in response.data:
                driver_name = driver["driver_name"]
                dynamics = driver.get("driver_dynamics", {})
                conflicts[driver_name] = dynamics.get("conflicts_with", [])
            
            return conflicts
        except Exception as e:
            logger.error(f"Failed to get driver conflicts: {e}")
            return {}
    
    def get_actor_profile(self, actor_id: str) -> Dict[str, Any]:
        """Get actor profile by ID using raw SQL"""
        try:
            response = self.client.rpc('exec_sql', {
                'sql': f"SELECT * FROM actors.actor_profiles WHERE actor_id = '{actor_id}'"
            }).execute()
            
            if not response.data:
                raise ValueError(f"Actor {actor_id} not found")
            
            return response.data[0]
        except Exception as e:
            logger.error(f"Failed to get actor profile: {e}")
            raise
    
    def get_actor_history(self, actor_id: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Get recent actor update history using raw SQL"""
        try:
            response = self.client.rpc('exec_sql', {
                'sql': f"SELECT * FROM actors.actor_updates WHERE actor_id = '{actor_id}' ORDER BY update_timestamp DESC LIMIT {limit}"
            }).execute()
            
            return response.data
        except Exception as e:
            logger.error(f"Failed to get actor history: {e}")
            return []
    
    def update_actor_profile(self, actor_id: str, update_data: Dict[str, Any]) -> bool:
        """Update actor profile using existing database function"""
        try:
            # Call the existing update function
            result = self.client.rpc(
                "update_actor_profile_quantum",
                {
                    "p_actor_id": actor_id,
                    "signal_analysis": update_data.get("signal_analysis", {}),
                    "signal_id": update_data.get("signal_id"),
                    "signal_type": update_data.get("signal_type", "unknown"),
                    "signal_context": update_data.get("signal_context", {})
                }
            ).execute()
            
            return True
        except Exception as e:
            logger.error(f"Failed to update actor profile: {e}")
            return False
    
    def log_decoder_output(self, log_data: Dict[str, Any]) -> str:
        """Log decoder output to database using raw SQL"""
        try:
            # Insert using raw SQL
            response = self.client.rpc('exec_sql', {
                'sql': f"""
                INSERT INTO actors.decoder_log (signal_id, actor_id, decoder_output, processing_timestamp, model_used, api_cost)
                VALUES ('{log_data.get("signal_id", "NULL")}', '{log_data.get("actor_id", "NULL")}', 
                        '{log_data.get("decoder_output", "{}")}', NOW(), 
                        '{log_data.get("model_used", "unknown")}', {log_data.get("api_cost", 0)})
                RETURNING log_id
                """
            }).execute()
            
            if response.data:
                return response.data[0]["log_id"]
            else:
                raise ValueError("Failed to insert decoder log")
        except Exception as e:
            logger.error(f"Failed to log decoder output: {e}")
            raise

# Global database instance
db_sql = DatabaseManagerSQL()

# Convenience functions
def get_driver_ontology() -> Dict[str, Any]:
    """Get driver ontology"""
    return db_sql.get_driver_ontology()

def get_driver_conflicts() -> Dict[str, List[Dict[str, Any]]]:
    """Get driver conflicts"""
    return db_sql.get_driver_conflicts()

def get_actor_profile(actor_id: str) -> Dict[str, Any]:
    """Get actor profile"""
    return db_sql.get_actor_profile(actor_id)

def get_actor_history(actor_id: str, limit: int = 10) -> List[Dict[str, Any]]:
    """Get actor history"""
    return db_sql.get_actor_history(actor_id, limit)

def update_actor_profile(actor_id: str, update_data: Dict[str, Any]) -> bool:
    """Update actor profile"""
    return db_sql.update_actor_profile(actor_id, update_data)

def log_decoder_output(log_data: Dict[str, Any]) -> str:
    """Log decoder output"""
    return db_sql.log_decoder_output(log_data)
