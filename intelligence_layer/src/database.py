"""
Database connection and query functions
Big Appetite OS - Quantum Psychology System
"""

import logging
from typing import Dict, List, Optional, Any, Tuple
from supabase import create_client, Client
from .config import SUPABASE_URL, SUPABASE_KEY, DRIVER_NAMES

logger = logging.getLogger(__name__)

class DatabaseManager:
    """Manages Supabase database connections and queries"""
    
    def __init__(self):
        self.client: Optional[Client] = None
        self._connect()
    
    def _connect(self):
        """Initialize Supabase connection"""
        try:
            self.client = create_client(SUPABASE_URL, SUPABASE_KEY)
            logger.info("Database connection established")
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise
    
    def get_driver_ontology(self) -> Dict[str, Any]:
        """Get complete driver ontology from database"""
        try:
            # Use custom RPC function to access actors.drivers table
            response = self.client.rpc('get_drivers').execute()
            
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
            
            logger.info(f"Successfully loaded {len(ontology)} drivers from database")
            return ontology
        except Exception as e:
            logger.error(f"Failed to get driver ontology: {e}")
            raise
    
    def get_signal_data(self, signal_id: str) -> Dict[str, Any]:
        """Get signal data by ID"""
        try:
            # Try different signal tables with correct schemas
            tables = ["whatsapp_messages", "reviews", "survey_responses", "orders"]
            
            for table in tables:
                try:
                    response = self.client.table(table).select("*").eq("signal_id", signal_id).execute()
                    if response.data:
                        signal = response.data[0]
                        return {
                            "signal_id": signal["signal_id"],
                            "signal_type": table.replace("_messages", "").replace("_responses", ""),
                            "signal_text": self._extract_signal_text(signal, table),
                            "actor_id": signal.get("actor_id"),
                            "brand_id": signal.get("brand_id"),
                            "timestamp": signal.get("message_timestamp") or signal.get("review_timestamp") or signal.get("survey_timestamp") or signal.get("order_timestamp"),
                            "raw_data": signal
                        }
                except Exception:
                    continue
            
            raise ValueError(f"Signal {signal_id} not found in any signal table")
        except Exception as e:
            logger.error(f"Failed to get signal data: {e}")
            raise
    
    def _extract_signal_text(self, signal: Dict[str, Any], table: str) -> str:
        """Extract text content from signal based on table type"""
        if table == "whatsapp_messages":
            return signal.get("message_text", "")
        elif table == "reviews":
            return signal.get("review_text", "")
        elif table == "survey_responses":
            return signal.get("response_text", "")
        elif table == "orders":
            return str(signal.get("order_items", ""))
        else:
            return ""
    
    def get_actor_profile(self, actor_id: str) -> Dict[str, Any]:
        """Get actor profile by ID"""
        try:
            response = self.client.table("actor_profiles").select("*").eq("actor_id", actor_id).execute()
            
            if not response.data:
                raise ValueError(f"Actor {actor_id} not found")
            
            return response.data[0]
        except Exception as e:
            logger.error(f"Failed to get actor profile: {e}")
            raise
    
    def get_actor_history(self, actor_id: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Get recent actor update history"""
        try:
            response = (
                self.client.table("actor_updates")
                .select("*")
                .eq("actor_id", actor_id)
                .order("created_at", desc=True)
                .limit(limit)
                .execute()
            )
            
            return response.data
        except Exception as e:
            logger.error(f"Failed to get actor history: {e}")
            return []
    
    def get_driver_conflicts(self) -> Dict[str, List[Dict[str, Any]]]:
        """Get driver conflict matrix from database"""
        try:
            response = self.client.rpc('get_driver_conflicts').execute()
            
            conflicts = {}
            for driver in response.data:
                driver_name = driver["driver_name"]
                dynamics = driver.get("driver_dynamics", {})
                conflicts[driver_name] = dynamics.get("conflicts_with", [])
            
            return conflicts
        except Exception as e:
            logger.error(f"Failed to get driver conflicts: {e}")
            return {}
    
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
        """Log decoder output to database"""
        try:
            response = self.client.table("actors.decoder_log").insert(log_data).execute()
            
            if response.data:
                return response.data[0]["log_id"]
            else:
                raise ValueError("Failed to insert decoder log")
        except Exception as e:
            logger.error(f"Failed to log decoder output: {e}")
            raise
    
    def log_api_usage(self, usage_data: Dict[str, Any]) -> bool:
        """Log API usage for cost tracking"""
        try:
            # Create API usage table if it doesn't exist
            response = self.client.table("intelligence.api_usage").insert(usage_data).execute()
            return True
        except Exception as e:
            logger.warning(f"Failed to log API usage: {e}")
            return False
    
    def get_cost_summary(self, period: str = "today") -> Dict[str, Any]:
        """Get cost summary for period"""
        try:
            # This would query the api_usage table
            # For now, return placeholder
            return {
                "signal_count": 0,
                "mini_calls": 0,
                "gpt4_calls": 0,
                "total_cost": 0.0
            }
        except Exception as e:
            logger.error(f"Failed to get cost summary: {e}")
            return {"error": str(e)}

# Global database instance
db = DatabaseManager()

# Convenience functions
def get_driver_ontology() -> Dict[str, Any]:
    """Get driver ontology"""
    return db.get_driver_ontology()

def get_signal_data(signal_id: str) -> Dict[str, Any]:
    """Get signal data"""
    return db.get_signal_data(signal_id)

def get_actor_profile(actor_id: str) -> Dict[str, Any]:
    """Get actor profile"""
    return db.get_actor_profile(actor_id)

def get_actor_history(actor_id: str, limit: int = 10) -> List[Dict[str, Any]]:
    """Get actor history"""
    return db.get_actor_history(actor_id, limit)

def get_driver_conflicts() -> Dict[str, List[Dict[str, Any]]]:
    """Get driver conflicts"""
    return db.get_driver_conflicts()

def update_actor_profile(actor_id: str, update_data: Dict[str, Any]) -> bool:
    """Update actor profile"""
    return db.update_actor_profile(actor_id, update_data)

def log_decoder_output(log_data: Dict[str, Any]) -> str:
    """Log decoder output"""
    return db.log_decoder_output(log_data)

def log_api_usage(usage_data: Dict[str, Any]) -> bool:
    """Log API usage"""
    return db.log_api_usage(usage_data)

def get_cost_summary(period: str = "today") -> Dict[str, Any]:
    """Get cost summary"""
    return db.get_cost_summary(period)
