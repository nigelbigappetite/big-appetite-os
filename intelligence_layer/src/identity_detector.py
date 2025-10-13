"""
Identity Fragment Detector - Function 3
Identifies role identities and self-concept from signals
Big Appetite OS - Quantum Psychology System
"""

import logging
from typing import Dict, Any, Optional, List
from .llm_client import llm_client
from .config import IDENTITY_ARCHETYPES

logger = logging.getLogger(__name__)

def detect_identity_fragments(signal_text: str,
                            behavioral_history: Optional[List[Dict[str, Any]]] = None,
                            existing_identities: Optional[List[Dict[str, Any]]] = None) -> Dict[str, Any]:
    """
    Identify role identities and self-concept from signals
    
    Args:
        signal_text: Raw signal text
        behavioral_history: Pattern of past behaviors
        existing_identities: Current identity fragments from database
    
    Returns:
        Dict containing identity analysis
    """
    
    try:
        logger.info("Detecting identity fragments...")
        
        # Use LLM to analyze identity
        result = llm_client.analyze_identity(
            signal_text=signal_text,
            behavioral_history=behavioral_history,
            existing_identities=existing_identities
        )
        
        # Add additional analysis
        result["identity_archetypes"] = IDENTITY_ARCHETYPES
        result["signal_text"] = signal_text
        
        # Calculate identity coherence if multiple identities detected
        if result.get("primary_identity") and result.get("secondary_identity"):
            coherence = calculate_identity_coherence(
                result["primary_identity"],
                result["secondary_identity"]
            )
            result["identity_coherence"] = coherence
        
        logger.info(f"Identity analysis completed. Primary: {result.get('primary_identity', {}).get('label', 'None')}")
        
        return result
        
    except Exception as e:
        logger.error(f"Identity detection failed: {e}")
        return {
            "primary_identity": None,
            "secondary_identity": None,
            "identity_coherence": 0.0,
            "fragmentation_detected": False,
            "integration_status": "unknown",
            "signal_text": signal_text,
            "error": str(e),
            "model_used": None,
            "api_cost": 0.0
        }

def calculate_identity_coherence(primary_identity: Dict[str, Any],
                               secondary_identity: Dict[str, Any]) -> float:
    """
    Calculate coherence between two identity fragments
    
    Args:
        primary_identity: Primary identity fragment
        secondary_identity: Secondary identity fragment
    
    Returns:
        Coherence score (0-1, higher = more coherent)
    """
    
    if not primary_identity or not secondary_identity:
        return 0.0
    
    # Get driver alignments
    primary_alignment = primary_identity.get("driver_alignment", {})
    secondary_alignment = secondary_identity.get("driver_alignment", {})
    
    if not primary_alignment or not secondary_alignment:
        return 0.5  # Default moderate coherence
    
    # Calculate correlation between driver alignments
    drivers = ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"]
    correlations = []
    
    for driver in drivers:
        primary_val = primary_alignment.get(driver, 0.0)
        secondary_val = secondary_alignment.get(driver, 0.0)
        
        # Simple correlation calculation
        if primary_val > 0 and secondary_val > 0:
            correlation = min(primary_val, secondary_val) / max(primary_val, secondary_val)
            correlations.append(correlation)
    
    if not correlations:
        return 0.0
    
    # Average correlation as coherence measure
    coherence = sum(correlations) / len(correlations)
    
    return coherence

def detect_identity_conflicts(identities: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Detect conflicts between identity fragments
    
    Args:
        identities: List of identity fragments
    
    Returns:
        List of detected conflicts
    """
    
    conflicts = []
    
    for i, identity_a in enumerate(identities):
        for identity_b in identities[i+1:]:
            # Check for conflicting driver alignments
            alignment_a = identity_a.get("driver_alignment", {})
            alignment_b = identity_b.get("driver_alignment", {})
            
            # Find drivers where one identity is high and other is low
            conflicting_drivers = []
            for driver in ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"]:
                val_a = alignment_a.get(driver, 0.0)
                val_b = alignment_b.get(driver, 0.0)
                
                # Conflict if one is high (>0.7) and other is low (<0.3)
                if (val_a > 0.7 and val_b < 0.3) or (val_b > 0.7 and val_a < 0.3):
                    conflicting_drivers.append(driver)
            
            if conflicting_drivers:
                conflicts.append({
                    "identity_a": identity_a.get("label", "Unknown"),
                    "identity_b": identity_b.get("label", "Unknown"),
                    "conflicting_drivers": conflicting_drivers,
                    "conflict_strength": len(conflicting_drivers) / 6.0,
                    "manifestation": f"{identity_a.get('label', 'Unknown')} vs {identity_b.get('label', 'Unknown')} on {', '.join(conflicting_drivers)}"
                })
    
    return conflicts

def track_identity_evolution(identity_history: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Track how identity fragments evolve over time
    
    Args:
        identity_history: List of identity updates over time
    
    Returns:
        Identity evolution analysis
    """
    
    if len(identity_history) < 2:
        return {
            "evolution_detected": False,
            "stability_trend": "insufficient_data",
            "fragmentation_trend": "stable",
            "integration_trend": "stable"
        }
    
    # Analyze identity changes
    identity_changes = []
    coherence_changes = []
    
    for i in range(1, len(identity_history)):
        prev_identities = identity_history[i-1].get("identity_fragments", [])
        curr_identities = identity_history[i].get("identity_fragments", [])
        
        # Count identity changes
        prev_labels = {id.get("label") for id in prev_identities}
        curr_labels = {id.get("label") for id in curr_identities}
        
        added = len(curr_labels - prev_labels)
        removed = len(prev_labels - curr_labels)
        identity_changes.append(added + removed)
        
        # Track coherence changes
        prev_coherence = identity_history[i-1].get("identity_coherence", 1.0)
        curr_coherence = identity_history[i].get("identity_coherence", 1.0)
        coherence_changes.append(curr_coherence - prev_coherence)
    
    # Calculate trends
    avg_identity_change = sum(identity_changes) / len(identity_changes) if identity_changes else 0
    avg_coherence_change = sum(coherence_changes) / len(coherence_changes) if coherence_changes else 0
    
    return {
        "evolution_detected": avg_identity_change > 0,
        "stability_trend": "stable" if avg_identity_change < 0.5 else "unstable",
        "fragmentation_trend": "increasing" if avg_coherence_change < -0.1 else "stable",
        "integration_trend": "improving" if avg_coherence_change > 0.1 else "stable"
    }

def generate_identity_integration_strategies(conflicts: List[Dict[str, Any]]) -> List[str]:
    """
    Generate strategies for integrating conflicting identities
    
    Args:
        conflicts: List of identity conflicts
    
    Returns:
        List of integration strategies
    """
    
    strategies = []
    
    for conflict in conflicts:
        identity_a = conflict["identity_a"]
        identity_b = conflict["identity_b"]
        conflicting_drivers = conflict["conflicting_drivers"]
        
        # Generate context-specific strategies
        if "Safety" in conflicting_drivers and "Freedom" in conflicting_drivers:
            strategies.append(f"Allow {identity_a} in private contexts, {identity_b} in social contexts")
        elif "Status" in conflicting_drivers and "Connection" in conflicting_drivers:
            strategies.append(f"Position {identity_a} as community leader, {identity_b} as team player")
        elif "Growth" in conflicting_drivers and "Safety" in conflicting_drivers:
            strategies.append(f"Frame {identity_a} as safe exploration, {identity_b} as risk mitigation")
        else:
            strategies.append(f"Create dual-identity messaging that honors both {identity_a} and {identity_b}")
    
    return strategies

def analyze_identity_archetypes(signal_text: str) -> Dict[str, float]:
    """
    Analyze signal for identity archetype indicators
    
    Args:
        signal_text: Raw signal text
    
    Returns:
        Dictionary of archetype confidence scores
    """
    
    signal_lower = signal_text.lower()
    archetype_scores = {}
    
    for archetype, data in IDENTITY_ARCHETYPES.items():
        keywords = data["keywords"]
        score = 0.0
        
        for keyword in keywords:
            if keyword in signal_lower:
                score += 1.0
        
        # Normalize by number of keywords
        archetype_scores[archetype] = min(score / len(keywords), 1.0)
    
    return archetype_scores

def detect_identity_fragmentation(identities: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Detect identity fragmentation patterns
    
    Args:
        identities: List of identity fragments
    
    Returns:
        Fragmentation analysis
    """
    
    if len(identities) <= 1:
        return {
            "fragmentation_detected": False,
            "fragmentation_level": 0.0,
            "fragmentation_type": "none",
            "integration_capacity": 1.0
        }
    
    # Calculate fragmentation level
    conflicts = detect_identity_conflicts(identities)
    fragmentation_level = len(conflicts) / max(len(identities) - 1, 1)
    
    # Determine fragmentation type
    if fragmentation_level > 0.7:
        fragmentation_type = "severe"
    elif fragmentation_level > 0.4:
        fragmentation_type = "moderate"
    else:
        fragmentation_type = "mild"
    
    # Calculate integration capacity
    integration_capacity = max(0.0, 1.0 - fragmentation_level)
    
    return {
        "fragmentation_detected": fragmentation_level > 0.3,
        "fragmentation_level": fragmentation_level,
        "fragmentation_type": fragmentation_type,
        "integration_capacity": integration_capacity,
        "conflicts": conflicts
    }

# Example usage and testing
if __name__ == "__main__":
    # Test identity detection
    test_signal = "I always order for my family, making sure everyone gets what they like. Today I'm trying something new to impress my friends."
    
    result = detect_identity_fragments(
        signal_text=test_signal,
        behavioral_history=None,
        existing_identities=None
    )
    
    print("Identity Analysis Result:")
    print(f"Primary Identity: {result.get('primary_identity', {}).get('label', 'None')}")
    print(f"Secondary Identity: {result.get('secondary_identity', {}).get('label', 'None')}")
    print(f"Identity Coherence: {result.get('identity_coherence', 0.0)}")
    print(f"Fragmentation Detected: {result.get('fragmentation_detected', False)}")
    print(f"Model Used: {result.get('model_used', 'None')}")
    print(f"API Cost: ${result.get('api_cost', 0):.4f}")
