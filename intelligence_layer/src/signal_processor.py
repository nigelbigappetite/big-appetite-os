"""
Complete Signal Processing - Function 4
Orchestrates all three components and writes to database
Big Appetite OS - Quantum Psychology System
"""

import logging
import uuid
from typing import Dict, Any, Optional, List
from datetime import datetime
from .database import (
    get_signal_data, get_actor_profile, get_actor_history, update_actor_profile, 
    log_decoder_output, log_api_usage
)
from .signal_analyzer import analyze_signal
from .quantum_detector import detect_quantum_effects
from .identity_detector import detect_identity_fragments

logger = logging.getLogger(__name__)

def process_signal_complete(signal_id: str, 
                          actor_id: Optional[str] = None,
                          debug_mode: bool = False) -> Dict[str, Any]:
    """
    Orchestrate all three components and write to database
    
    Args:
        signal_id: UUID of signal from database
        actor_id: UUID of actor (optional, will be inferred if not provided)
        debug_mode: Optional flag for detailed logging
    
    Returns:
        Complete analysis with 7-column decoder output
    """
    
    try:
        logger.info(f"Processing signal {signal_id} for actor {actor_id}")
        
        # Step 1: Get signal data from database
        signal_data = get_signal_data(signal_id)
        signal_text = signal_data["signal_text"]
        signal_type = signal_data["signal_type"]
        signal_actor_id = signal_data.get("actor_id") or actor_id
        
        if not signal_actor_id:
            raise ValueError("No actor ID available for signal")
        
        # Step 2: Get actor profile and history
        actor_profile = get_actor_profile(signal_actor_id)
        actor_history = get_actor_history(signal_actor_id, limit=5)
        
        # Step 3: Analyze signal for drivers
        logger.info("Step 3: Analyzing drivers...")
        driver_analysis = analyze_signal(
            signal_text=signal_text,
            actor_id=signal_actor_id,
            signal_context={
                "signal_id": signal_id,
                "signal_type": signal_type,
                "context": "general",
                "audience": "unknown"
            }
        )
        
        # Step 4: Detect quantum effects
        logger.info("Step 4: Detecting quantum effects...")
        quantum_analysis = detect_quantum_effects(
            driver_distribution=driver_analysis["driver_distribution"],
            signal_context={
                "signal_id": signal_id,
                "signal_type": signal_type,
                "context": "general",
                "audience": "unknown"
            },
            actor_history=actor_history
        )
        
        # Step 5: Detect identity fragments
        logger.info("Step 5: Detecting identity fragments...")
        identity_analysis = detect_identity_fragments(
            signal_text=signal_text,
            behavioral_history=actor_history,
            existing_identities=actor_profile.get("identity_markers", [])
        )
        
        # Step 6: Build 7-column decoder output
        logger.info("Step 6: Building 7-column output...")
        decoder_output = build_seven_column_output(
            driver_analysis=driver_analysis,
            quantum_analysis=quantum_analysis,
            identity_analysis=identity_analysis,
            signal_data=signal_data,
            actor_profile=actor_profile
        )
        
        # Step 7: Update actor profile
        logger.info("Step 7: Updating actor profile...")
        update_success = update_actor_profile(signal_actor_id, {
            "signal_analysis": {
                "driver_distribution": driver_analysis["driver_distribution"],
                "quantum_effects": quantum_analysis,
                "identity_fragments": identity_analysis
            },
            "signal_id": signal_id,
            "signal_type": signal_type,
            "signal_context": {
                "context": "general",
                "audience": "unknown"
            }
        })
        
        # Step 8: Log decoder output
        logger.info("Step 8: Logging decoder output...")
        log_id = log_decoder_output({
            "signal_id": signal_id,
            "actor_id": signal_actor_id,
            "decoder_output": decoder_output,
            "processing_timestamp": datetime.utcnow().isoformat(),
            "model_used": driver_analysis.get("model_used", "unknown"),
            "api_cost": driver_analysis.get("api_cost", 0.0) + 
                       quantum_analysis.get("api_cost", 0.0) + 
                       identity_analysis.get("api_cost", 0.0)
        })
        
        # Step 9: Log API usage for cost tracking
        total_cost = driver_analysis.get("api_cost", 0.0) + \
                    quantum_analysis.get("api_cost", 0.0) + \
                    identity_analysis.get("api_cost", 0.0)
        
        if total_cost > 0:
            log_api_usage({
                "signal_id": signal_id,
                "actor_id": signal_actor_id,
                "total_cost": total_cost,
                "driver_analysis_cost": driver_analysis.get("api_cost", 0.0),
                "quantum_analysis_cost": quantum_analysis.get("api_cost", 0.0),
                "identity_analysis_cost": identity_analysis.get("api_cost", 0.0),
                "timestamp": datetime.utcnow().isoformat()
            })
        
        # Build final result
        result = {
            **decoder_output,
            "decoder_reasoning": build_reasoning_chain(
                driver_analysis, quantum_analysis, identity_analysis
            ),
            "profile_updated": update_success,
            "actor_id": signal_actor_id,
            "signal_id": signal_id,
            "log_id": log_id,
            "total_api_cost": total_cost,
            "processing_timestamp": datetime.utcnow().isoformat()
        }
        
        if debug_mode:
            result["debug_info"] = {
                "driver_analysis": driver_analysis,
                "quantum_analysis": quantum_analysis,
                "identity_analysis": identity_analysis,
                "signal_data": signal_data,
                "actor_profile": actor_profile
            }
        
        logger.info(f"Signal processing completed successfully. Total cost: ${total_cost:.4f}")
        
        return result
        
    except Exception as e:
        logger.error(f"Signal processing failed: {e}")
        return {
            "error": str(e),
            "signal_id": signal_id,
            "actor_id": actor_id,
            "profile_updated": False,
            "total_api_cost": 0.0,
            "processing_timestamp": datetime.utcnow().isoformat()
        }

def build_seven_column_output(driver_analysis: Dict[str, Any],
                            quantum_analysis: Dict[str, Any],
                            identity_analysis: Dict[str, Any],
                            signal_data: Dict[str, Any],
                            actor_profile: Dict[str, Any]) -> Dict[str, Any]:
    """
    Build 7-column decoder output format
    
    Args:
        driver_analysis: Output from signal analyzer
        quantum_analysis: Output from quantum detector
        identity_analysis: Output from identity detector
        signal_data: Raw signal data
        actor_profile: Current actor profile
    
    Returns:
        7-column decoder output
    """
    
    # Column 1: Actor/Segment
    col1_actor_segment = {
        "current_identity": [
            identity_analysis.get("primary_identity", {}).get("label", "unknown")
        ],
        "dominant_driver": max(driver_analysis["driver_distribution"], 
                             key=driver_analysis["driver_distribution"].get),
        "driver_confidence": driver_analysis["confidence"],
        "quantum_state": "superposition" if quantum_analysis.get("superposition_detected") else "collapsed"
    }
    
    # Column 2: Observed Behavior
    col2_observed_behavior = {
        "action": f"Analyzed {signal_data['signal_type']} signal for psychological patterns",
        "verbatim_quote": signal_data["signal_text"],
        "context": {
            "signal_type": signal_data["signal_type"],
            "timestamp": signal_data.get("timestamp"),
            "brand_id": signal_data.get("brand_id")
        },
        "emotional_tone": analyze_emotional_tone(signal_data["signal_text"]),
        "behavioral_indicators": extract_behavioral_indicators(signal_data["signal_text"])
    }
    
    # Column 3: Belief Inferred
    col3_belief_inferred = {
        "driver_update": {
            driver: {
                "delta": prob - actor_profile.get("driver_distribution", {}).get(driver, 0.0),
                "reasoning": f"Signal analysis revealed {driver} driver activation",
                "contextual_activation": prob > 0.3,
                "activation_trigger": "signal_analysis"
            }
            for driver, prob in driver_analysis["driver_distribution"].items()
        },
        "quantum_effects": {
            "superposition_collapse": "partial" if quantum_analysis.get("superposition_detected") else "full",
            "collapsed_to": col1_actor_segment["dominant_driver"],
            "collapse_trigger": quantum_analysis.get("collapse_trigger", "unknown"),
            "residual_superposition": quantum_analysis.get("interfering_drivers", [])
        },
        "identity_update": {
            "reinforced": [identity_analysis.get("primary_identity", {}).get("label", "unknown")],
            "weakened": [],
            "new_fragment_detected": identity_analysis.get("fragmentation_detected", False)
        }
    }
    
    # Column 4: Confidence Score
    col4_confidence_score = {
        "overall": driver_analysis["confidence"],
        "factors": {
            "signal_strength": len(signal_data["signal_text"]) / 200.0,  # Normalize by length
            "prior_evidence": len(actor_profile.get("identity_markers", [])) / 10.0,
            "consistency": 0.6,  # Placeholder
            "quantum_clarity": quantum_analysis.get("coherence", 0.5)
        },
        "uncertainty_sources": identify_uncertainty_sources(driver_analysis, quantum_analysis)
    }
    
    # Column 5: Friction/Contradiction
    col5_friction_contradiction = {
        "detected": quantum_analysis.get("superposition_detected", False),
        "type": "driver_conflict" if quantum_analysis.get("superposition_detected") else "none",
        "drivers_in_tension": quantum_analysis.get("interfering_drivers", []),
        "conflict_strength": quantum_analysis.get("interference_strength", 0.0),
        "tension": build_tension_description(quantum_analysis),
        "entanglement": quantum_analysis.get("entanglement", {}),
        "quantum_signature": {
            "superposition_active": quantum_analysis.get("superposition_detected", False),
            "interference_pattern": quantum_analysis.get("interference_strength", 0.0),
            "coherence_level": quantum_analysis.get("coherence", 0.5)
        }
    }
    
    # Column 6: Core Driver
    col6_core_driver = {
        "primary": col1_actor_segment["dominant_driver"],
        "probability": driver_analysis["driver_distribution"][col1_actor_segment["dominant_driver"]],
        "reasoning": driver_analysis["reasoning"],
        "secondary": get_secondary_driver(driver_analysis["driver_distribution"]),
        "secondary_probability": driver_analysis["driver_distribution"].get(
            get_secondary_driver(driver_analysis["driver_distribution"]), 0.0
        ),
        "secondary_reasoning": f"Secondary driver detected with moderate activation",
        "quantum_effects": {
            "superposition": quantum_analysis.get("superposition_detected", False),
            "entanglement_strength": quantum_analysis.get("entanglement", {}).get("entanglement_strength", 0.0),
            "coherence": quantum_analysis.get("coherence", 0.5)
        }
    }
    
    # Column 7: Actionable Insight
    col7_actionable_insight = {
        "strategy": generate_strategy(quantum_analysis, identity_analysis),
        "recommendation": generate_recommendation(col1_actor_segment["dominant_driver"]),
        "next_signal_needed": "Track behavioral patterns to confirm driver stability",
        "confidence_threshold": "Need 2-3 more signals to confirm driver dominance",
        "quantum_considerations": {
            "honor_superposition": quantum_analysis.get("superposition_detected", False),
            "measurement_awareness": "Observation may change actor state",
            "coherence_management": "Maintain psychological coherence in messaging"
        },
        "collapse_strategies": generate_collapse_strategies(quantum_analysis)
    }
    
    return {
        "col1_actor_segment": col1_actor_segment,
        "col2_observed_behavior": col2_observed_behavior,
        "col3_belief_inferred": col3_belief_inferred,
        "col4_confidence_score": col4_confidence_score,
        "col5_friction_contradiction": col5_friction_contradiction,
        "col6_core_driver": col6_core_driver,
        "col7_actionable_insight": col7_actionable_insight
    }

def build_reasoning_chain(driver_analysis: Dict[str, Any],
                        quantum_analysis: Dict[str, Any],
                        identity_analysis: Dict[str, Any]) -> str:
    """Build complete reasoning chain for the analysis"""
    
    reasoning_parts = []
    
    # Driver analysis reasoning
    dominant_driver = max(driver_analysis["driver_distribution"], 
                        key=driver_analysis["driver_distribution"].get)
    reasoning_parts.append(
        f"Signal analysis revealed {dominant_driver} as dominant driver "
        f"({driver_analysis['driver_distribution'][dominant_driver]:.2f} probability) "
        f"based on: {driver_analysis['reasoning']}"
    )
    
    # Quantum effects reasoning
    if quantum_analysis.get("superposition_detected"):
        reasoning_parts.append(
            f"Quantum superposition detected between {', '.join(quantum_analysis.get('interfering_drivers', []))} "
            f"with interference strength {quantum_analysis.get('interference_strength', 0.0):.2f}"
        )
    
    # Identity reasoning
    primary_identity = identity_analysis.get("primary_identity", {}).get("label", "unknown")
    reasoning_parts.append(
        f"Identity analysis identified {primary_identity} as primary identity fragment"
    )
    
    return " | ".join(reasoning_parts)

def analyze_emotional_tone(signal_text: str) -> str:
    """Analyze emotional tone of signal"""
    signal_lower = signal_text.lower()
    
    if any(word in signal_lower for word in ["love", "amazing", "fantastic", "perfect"]):
        return "enthusiastic"
    elif any(word in signal_lower for word in ["hate", "terrible", "awful", "disgusting"]):
        return "negative"
    elif any(word in signal_lower for word in ["okay", "fine", "alright", "decent"]):
        return "neutral"
    else:
        return "mixed"

def extract_behavioral_indicators(signal_text: str) -> List[str]:
    """Extract behavioral indicators from signal"""
    indicators = []
    signal_lower = signal_text.lower()
    
    if "order" in signal_lower or "get" in signal_lower:
        indicators.append("ordering")
    if "try" in signal_lower or "new" in signal_lower:
        indicators.append("exploring")
    if "love" in signal_lower or "hate" in signal_lower:
        indicators.append("expressing_preference")
    if "family" in signal_lower or "everyone" in signal_lower:
        indicators.append("social_consideration")
    
    return indicators

def identify_uncertainty_sources(driver_analysis: Dict[str, Any],
                               quantum_analysis: Dict[str, Any]) -> List[str]:
    """Identify sources of uncertainty in analysis"""
    sources = []
    
    if driver_analysis["confidence"] < 0.5:
        sources.append("low_signal_confidence")
    
    if quantum_analysis.get("superposition_detected"):
        sources.append("quantum_superposition")
    
    if len(driver_analysis["signal_text"]) < 20:
        sources.append("short_signal")
    
    return sources

def build_tension_description(quantum_analysis: Dict[str, Any]) -> str:
    """Build description of driver tensions"""
    if not quantum_analysis.get("superposition_detected"):
        return "No significant contradictions detected"
    
    interfering_drivers = quantum_analysis.get("interfering_drivers", [])
    interference_strength = quantum_analysis.get("interference_strength", 0.0)
    
    return f"Driver conflict detected between {', '.join(interfering_drivers)} with strength {interference_strength:.2f}"

def get_secondary_driver(driver_distribution: Dict[str, float]) -> str:
    """Get secondary driver from distribution"""
    sorted_drivers = sorted(driver_distribution.items(), key=lambda x: x[1], reverse=True)
    return sorted_drivers[1][0] if len(sorted_drivers) > 1 else sorted_drivers[0][0]

def generate_strategy(quantum_analysis: Dict[str, Any],
                     identity_analysis: Dict[str, Any]) -> str:
    """Generate strategy based on analysis"""
    if quantum_analysis.get("superposition_detected"):
        return "Collapse strategy for quantum superposition"
    elif identity_analysis.get("fragmentation_detected"):
        return "Resolution strategy for identity fragmentation"
    else:
        return "Reinforcement strategy for dominant driver"

def generate_recommendation(dominant_driver: str) -> str:
    """Generate recommendation based on dominant driver"""
    recommendations = {
        "Safety": "Position offerings as reliable and consistent choices",
        "Connection": "Emphasize shared experiences and community",
        "Status": "Highlight premium positioning and exclusivity",
        "Growth": "Offer challenging and skill-building options",
        "Freedom": "Provide variety and exploration opportunities",
        "Purpose": "Align with values and meaningful impact"
    }
    
    return recommendations.get(dominant_driver, "General engagement strategy")

def generate_collapse_strategies(quantum_analysis: Dict[str, Any]) -> List[str]:
    """Generate collapse strategies for quantum effects"""
    if not quantum_analysis.get("superposition_detected"):
        return ["single_driver_focus"]
    
    return ["contextual_positioning", "dual_identity_messaging"]

def process_batch_signals(signal_ids: List[str], 
                         batch_size: int = 10) -> List[Dict[str, Any]]:
    """
    Process multiple signals in batch
    
    Args:
        signal_ids: List of signal IDs to process
        batch_size: Number of signals to process in parallel
    
    Returns:
        List of processing results
    """
    
    results = []
    
    for i in range(0, len(signal_ids), batch_size):
        batch = signal_ids[i:i + batch_size]
        logger.info(f"Processing batch {i//batch_size + 1}: {len(batch)} signals")
        
        batch_results = []
        for signal_id in batch:
            try:
                result = process_signal_complete(signal_id)
                batch_results.append(result)
            except Exception as e:
                logger.error(f"Failed to process signal {signal_id}: {e}")
                batch_results.append({
                    "error": str(e),
                    "signal_id": signal_id,
                    "profile_updated": False
                })
        
        results.extend(batch_results)
    
    return results

# Example usage and testing
if __name__ == "__main__":
    # Test complete signal processing
    test_signal_id = str(uuid.uuid4())
    
    # This would normally come from the database
    print("Complete Signal Processing Test:")
    print("Note: This requires a valid signal_id from the database")
    print("Use process_signal_complete(signal_id) with a real signal ID")
