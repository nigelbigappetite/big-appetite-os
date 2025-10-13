"""
Quantum Psychology Detector - Function 2
Detects superposition, entanglement, and driver conflicts
Big Appetite OS - Quantum Psychology System
"""

import logging
from typing import Dict, Any, Optional, List, Tuple
from .database import get_driver_conflicts
from .llm_client import llm_client

logger = logging.getLogger(__name__)

def detect_quantum_effects(driver_distribution: Dict[str, float],
                          signal_context: Optional[Dict[str, Any]] = None,
                          actor_history: Optional[List[Dict[str, Any]]] = None) -> Dict[str, Any]:
    """
    Detect superposition, entanglement, and driver conflicts
    
    Args:
        driver_distribution: Output from signal analyzer
        signal_context: Context metadata
        actor_history: Previous driver patterns
    
    Returns:
        Dict containing quantum effects analysis
    """
    
    try:
        logger.info("Detecting quantum effects...")
        
        # Check for superposition (multiple high-probability drivers)
        high_prob_drivers = get_high_probability_drivers(driver_distribution, threshold=0.3)
        
        if len(high_prob_drivers) < 2:
            logger.info("No superposition detected - single dominant driver")
            return {
                "superposition_detected": False,
                "interfering_drivers": [],
                "interference_strength": 0.0,
                "entanglement": None,
                "coherence": 1.0,
                "collapse_trigger": None,
                "collapse_hypothesis": None,
                "measurement_effect": None,
                "model_used": None,
                "api_cost": 0.0
            }
        
        # Get driver conflicts from database
        driver_conflicts = get_driver_conflicts()
        
        # Check for known conflicts
        conflict_pairs = find_conflict_pairs(high_prob_drivers, driver_conflicts)
        
        if not conflict_pairs:
            logger.info("No known conflicts detected")
            return {
                "superposition_detected": True,
                "interfering_drivers": high_prob_drivers,
                "interference_strength": 0.5,
                "entanglement": None,
                "coherence": 0.7,
                "collapse_trigger": "unknown",
                "collapse_hypothesis": "Unknown driver interaction",
                "measurement_effect": "observation_required",
                "model_used": None,
                "api_cost": 0.0
            }
        
        # Use LLM to analyze quantum effects
        result = llm_client.analyze_quantum_effects(
            driver_distribution=driver_distribution,
            signal_context=signal_context or {},
            actor_history=actor_history
        )
        
        # Add conflict analysis
        result["conflict_pairs"] = conflict_pairs
        result["high_probability_drivers"] = high_prob_drivers
        
        logger.info(f"Quantum effects detected: {result.get('superposition_detected', False)}")
        
        return result
        
    except Exception as e:
        logger.error(f"Quantum effects detection failed: {e}")
        return {
            "superposition_detected": False,
            "interfering_drivers": [],
            "interference_strength": 0.0,
            "entanglement": None,
            "coherence": 0.0,
            "collapse_trigger": None,
            "collapse_hypothesis": None,
            "measurement_effect": None,
            "model_used": None,
            "api_cost": 0.0,
            "error": str(e)
        }

def get_high_probability_drivers(driver_distribution: Dict[str, float], 
                                threshold: float = 0.3) -> List[str]:
    """
    Get drivers with probability above threshold
    
    Args:
        driver_distribution: Dictionary of driver probabilities
        threshold: Minimum probability threshold
    
    Returns:
        List of high-probability drivers
    """
    
    return [driver for driver, prob in driver_distribution.items() if prob >= threshold]

def find_conflict_pairs(high_prob_drivers: List[str], 
                       driver_conflicts: Dict[str, List[Dict[str, Any]]]) -> List[Dict[str, Any]]:
    """
    Find conflicting driver pairs from high-probability drivers
    
    Args:
        high_prob_drivers: List of high-probability drivers
        driver_conflicts: Conflict matrix from database
    
    Returns:
        List of conflict pairs with details
    """
    
    conflict_pairs = []
    
    for i, driver_a in enumerate(high_prob_drivers):
        for driver_b in high_prob_drivers[i+1:]:
            # Check if driver_a conflicts with driver_b
            if driver_a in driver_conflicts:
                for conflict in driver_conflicts[driver_a]:
                    if conflict.get("driver") == driver_b:
                        conflict_pairs.append({
                            "driver_a": driver_a,
                            "driver_b": driver_b,
                            "conflict_strength": conflict.get("conflict_strength", 0.5),
                            "tension_manifestation": conflict.get("tension_manifestation", "Unknown tension"),
                            "collapse_strategies": conflict.get("collapse_strategies", [])
                        })
                        break
    
    return conflict_pairs

def calculate_interference_strength(driver_a: str, driver_b: str, 
                                  driver_distribution: Dict[str, float],
                                  conflict_pairs: List[Dict[str, Any]]) -> float:
    """
    Calculate interference strength between two drivers
    
    Args:
        driver_a: First driver
        driver_b: Second driver
        driver_distribution: Current driver probabilities
        conflict_pairs: Known conflict pairs
    
    Returns:
        Interference strength (0-1)
    """
    
    # Find conflict pair
    conflict_pair = None
    for pair in conflict_pairs:
        if (pair["driver_a"] == driver_a and pair["driver_b"] == driver_b) or \
           (pair["driver_a"] == driver_b and pair["driver_b"] == driver_a):
            conflict_pair = pair
            break
    
    if not conflict_pair:
        return 0.0
    
    # Calculate interference based on probabilities and conflict strength
    prob_a = driver_distribution.get(driver_a, 0.0)
    prob_b = driver_distribution.get(driver_b, 0.0)
    conflict_strength = conflict_pair.get("conflict_strength", 0.5)
    
    # Interference is higher when both drivers are active and conflict is strong
    interference = (prob_a * prob_b) * conflict_strength
    
    return min(interference, 1.0)

def calculate_coherence(driver_distribution: Dict[str, float],
                       conflict_pairs: List[Dict[str, Any]]) -> float:
    """
    Calculate coherence level of driver distribution
    
    Args:
        driver_distribution: Dictionary of driver probabilities
        conflict_pairs: Known conflict pairs
    
    Returns:
        Coherence level (0-1, higher = more coherent)
    """
    
    if not conflict_pairs:
        return 1.0
    
    # Calculate total interference
    total_interference = 0.0
    for pair in conflict_pairs:
        interference = calculate_interference_strength(
            pair["driver_a"], pair["driver_b"], driver_distribution, conflict_pairs
        )
        total_interference += interference
    
    # Coherence is inverse of interference
    coherence = max(0.0, 1.0 - total_interference)
    
    return coherence

def detect_entanglement(driver_a: str, driver_b: str,
                       driver_distribution: Dict[str, float],
                       conflict_pairs: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Detect entanglement between two drivers
    
    Args:
        driver_a: First driver
        driver_b: Second driver
        driver_distribution: Current driver probabilities
        conflict_pairs: Known conflict pairs
    
    Returns:
        Entanglement analysis
    """
    
    # Find conflict pair
    conflict_pair = None
    for pair in conflict_pairs:
        if (pair["driver_a"] == driver_a and pair["driver_b"] == driver_b) or \
           (pair["driver_a"] == driver_b and pair["driver_b"] == driver_a):
            conflict_pair = pair
            break
    
    if not conflict_pair:
        return {
            "driver_a": driver_a,
            "driver_b": driver_b,
            "correlation": 0.0,
            "entanglement_strength": 0.0,
            "entanglement_type": "none"
        }
    
    # Calculate correlation (negative for conflicts)
    prob_a = driver_distribution.get(driver_a, 0.0)
    prob_b = driver_distribution.get(driver_b, 0.0)
    conflict_strength = conflict_pair.get("conflict_strength", 0.5)
    
    # Negative correlation for conflicting drivers
    correlation = -conflict_strength
    
    # Entanglement strength based on both probabilities and conflict
    entanglement_strength = (prob_a + prob_b) / 2 * conflict_strength
    
    return {
        "driver_a": driver_a,
        "driver_b": driver_b,
        "correlation": correlation,
        "entanglement_strength": entanglement_strength,
        "entanglement_type": "conflict" if conflict_strength > 0.5 else "tension"
    }

def predict_collapse_trigger(superposition_drivers: List[str],
                           signal_context: Optional[Dict[str, Any]] = None) -> str:
    """
    Predict what might cause superposition to collapse
    
    Args:
        superposition_drivers: List of drivers in superposition
        signal_context: Context metadata
    
    Returns:
        Predicted collapse trigger
    """
    
    if not signal_context:
        return "unknown"
    
    context_type = signal_context.get("context", "unknown")
    audience = signal_context.get("audience", "unknown")
    
    # Context-based collapse predictions
    if "social" in context_type.lower() or "group" in audience.lower():
        return "social_observation"
    elif "private" in context_type.lower() or "alone" in audience.lower():
        return "private_reflection"
    elif "work" in context_type.lower():
        return "professional_context"
    elif "family" in context_type.lower():
        return "family_dynamics"
    else:
        return "contextual_shift"

def analyze_quantum_evolution(actor_history: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Analyze quantum state evolution over time
    
    Args:
        actor_history: List of actor updates
    
    Returns:
        Quantum evolution analysis
    """
    
    if len(actor_history) < 2:
        return {
            "evolution_detected": False,
            "stability_trend": "insufficient_data",
            "collapse_frequency": 0.0,
            "coherence_trend": "stable"
        }
    
    # Analyze driver distribution changes
    driver_changes = []
    coherence_changes = []
    
    for i in range(1, len(actor_history)):
        prev_update = actor_history[i-1]
        curr_update = actor_history[i]
        
        # Extract driver distributions (assuming they're stored in update data)
        prev_drivers = prev_update.get("driver_distribution", {})
        curr_drivers = curr_update.get("driver_distribution", {})
        
        if prev_drivers and curr_drivers:
            # Calculate change magnitude
            change = sum(abs(curr_drivers.get(driver, 0) - prev_drivers.get(driver, 0)) 
                        for driver in ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"])
            driver_changes.append(change)
            
            # Extract coherence if available
            prev_coherence = prev_update.get("coherence", 1.0)
            curr_coherence = curr_update.get("coherence", 1.0)
            coherence_changes.append(curr_coherence - prev_coherence)
    
    # Calculate trends
    avg_change = sum(driver_changes) / len(driver_changes) if driver_changes else 0
    avg_coherence_change = sum(coherence_changes) / len(coherence_changes) if coherence_changes else 0
    
    return {
        "evolution_detected": avg_change > 0.1,
        "stability_trend": "stable" if avg_change < 0.1 else "unstable",
        "collapse_frequency": avg_change,
        "coherence_trend": "improving" if avg_coherence_change > 0 else "declining"
    }

# Example usage and testing
if __name__ == "__main__":
    # Test quantum detection
    test_distribution = {
        "Safety": 0.4,
        "Connection": 0.1,
        "Status": 0.35,
        "Growth": 0.05,
        "Freedom": 0.05,
        "Purpose": 0.05
    }
    
    result = detect_quantum_effects(
        driver_distribution=test_distribution,
        signal_context={"context": "social", "audience": "friends"},
        actor_history=None
    )
    
    print("Quantum Effects Analysis:")
    print(f"Superposition Detected: {result['superposition_detected']}")
    print(f"Interfering Drivers: {result['interfering_drivers']}")
    print(f"Interference Strength: {result['interference_strength']}")
    print(f"Coherence: {result['coherence']}")
    print(f"Model Used: {result.get('model_used', 'None')}")
    print(f"API Cost: ${result.get('api_cost', 0):.4f}")
