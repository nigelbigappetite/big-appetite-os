"""
Signal Analyzer - Function 1
Analyzes raw signal text and infers psychological driver probabilities
Big Appetite OS - Quantum Psychology System
"""

import logging
from typing import Dict, Any, Optional, List
from .database import get_driver_ontology, get_actor_history
from .config import DRIVER_NAMES
from .llm_client import llm_client

logger = logging.getLogger(__name__)

def analyze_signal(signal_text: str, 
                  actor_id: Optional[str] = None,
                  signal_context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Analyze raw signal text and infer psychological driver probabilities
    
    Args:
        signal_text: The raw message/review/order text
        actor_id: Optional actor ID for historical context
        signal_context: Optional metadata (time, location, social setting, etc.)
    
    Returns:
        Dict containing driver distribution, confidence, reasoning, and evidence
    """
    
    try:
        logger.info(f"Analyzing signal: {signal_text[:50]}...")
        
        # Get driver ontology from database
        driver_ontology = get_driver_ontology()
        
        # Get actor history if actor_id provided
        actor_history = None
        if actor_id:
            actor_history = get_actor_history(actor_id, limit=5)
        
        # Analyze using LLM
        result = llm_client.analyze_drivers(
            signal_text=signal_text,
            driver_ontology=driver_ontology,
            actor_history=actor_history,
            signal_id=signal_context.get("signal_id") if signal_context else None
        )
        
        # Add metadata
        result["signal_text"] = signal_text
        result["actor_id"] = actor_id
        result["signal_context"] = signal_context or {}
        result["analysis_timestamp"] = __import__("datetime").datetime.utcnow().isoformat()
        
        logger.info(f"Signal analysis completed. Dominant driver: {max(result['driver_distribution'], key=result['driver_distribution'].get)}")
        
        return result
        
    except Exception as e:
        logger.error(f"Signal analysis failed: {e}")
        return {
            "driver_distribution": {driver: 1.0/6 for driver in ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"]},
            "confidence": 0.0,
            "reasoning": f"Analysis failed: {str(e)}",
            "evidence": {},
            "signal_text": signal_text,
            "actor_id": actor_id,
            "signal_context": signal_context or {},
            "error": str(e),
            "analysis_timestamp": __import__("datetime").datetime.utcnow().isoformat()
        }

def validate_driver_distribution(driver_distribution: Dict[str, float]) -> bool:
    """
    Validate that driver distribution is valid
    
    Args:
        driver_distribution: Dictionary of driver probabilities
    
    Returns:
        True if valid, False otherwise
    """
    
    # Check if all drivers are present
    required_drivers = ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"]
    if not all(driver in driver_distribution for driver in required_drivers):
        logger.warning("Missing required drivers in distribution")
        return False
    
    # Check if all values are numbers
    if not all(isinstance(prob, (int, float)) for prob in driver_distribution.values()):
        logger.warning("Non-numeric values in driver distribution")
        return False
    
    # Check if all values are non-negative
    if not all(prob >= 0 for prob in driver_distribution.values()):
        logger.warning("Negative probabilities in driver distribution")
        return False
    
    # Check if probabilities sum to approximately 1.0
    total = sum(driver_distribution.values())
    if abs(total - 1.0) > 0.01:  # Allow small floating point errors
        logger.warning(f"Driver probabilities sum to {total}, not 1.0")
        return False
    
    return True

def normalize_driver_distribution(driver_distribution: Dict[str, float]) -> Dict[str, float]:
    """
    Normalize driver distribution to sum to 1.0
    
    Args:
        driver_distribution: Dictionary of driver probabilities
    
    Returns:
        Normalized distribution
    """
    
    total = sum(driver_distribution.values())
    
    if total == 0:
        # If all probabilities are 0, return equal distribution
        return {driver: 1.0/6 for driver in ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"]}
    
    # Normalize
    return {driver: prob/total for driver, prob in driver_distribution.items()}

def get_dominant_driver(driver_distribution: Dict[str, float]) -> str:
    """
    Get the dominant driver from distribution
    
    Args:
        driver_distribution: Dictionary of driver probabilities
    
    Returns:
        Name of dominant driver
    """
    
    return max(driver_distribution, key=driver_distribution.get)

def get_driver_entropy(driver_distribution: Dict[str, float]) -> float:
    """
    Calculate entropy of driver distribution (measure of uncertainty)
    
    Args:
        driver_distribution: Dictionary of driver probabilities
    
    Returns:
        Entropy value (higher = more uncertain)
    """
    
    import math
    
    entropy = 0.0
    for prob in driver_distribution.values():
        if prob > 0:
            entropy -= prob * math.log2(prob)
    
    return entropy

def analyze_signal_batch(signals: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Analyze multiple signals in batch
    
    Args:
        signals: List of signal dictionaries with 'signal_text' and optional metadata
    
    Returns:
        List of analysis results
    """
    
    results = []
    
    for i, signal in enumerate(signals):
        try:
            logger.info(f"Processing signal {i+1}/{len(signals)}")
            
            result = analyze_signal(
                signal_text=signal["signal_text"],
                actor_id=signal.get("actor_id"),
                signal_context=signal.get("signal_context")
            )
            
            results.append(result)
            
        except Exception as e:
            logger.error(f"Failed to process signal {i+1}: {e}")
            results.append({
                "driver_distribution": {driver: 1.0/6 for driver in ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"]},
                "confidence": 0.0,
                "reasoning": f"Batch processing failed: {str(e)}",
                "evidence": {},
                "signal_text": signal.get("signal_text", ""),
                "actor_id": signal.get("actor_id"),
                "signal_context": signal.get("signal_context", {}),
                "error": str(e),
                "analysis_timestamp": __import__("datetime").datetime.utcnow().isoformat()
            })
    
    return results

# Example usage and testing
if __name__ == "__main__":
    # Test signal analysis
    test_signal = "I love the premium wings, they are so exclusive and everyone is talking about them!"
    
    result = analyze_signal(
        signal_text=test_signal,
        actor_id=None,
        signal_context={"signal_type": "whatsapp", "context": "social"}
    )
    
    print("Signal Analysis Result:")
    print(f"Dominant Driver: {get_dominant_driver(result['driver_distribution'])}")
    print(f"Confidence: {result['confidence']}")
    print(f"Reasoning: {result['reasoning']}")
    print(f"Model Used: {result.get('model_used', 'Unknown')}")
    print(f"API Cost: ${result.get('api_cost', 0):.4f}")
