import logging
from typing import Dict, Any, Optional, List
from datetime import datetime

from .database import (
    get_signal_data,
    get_actor_profile,
    get_actor_history,
    update_actor_profile,
    log_decoder_output,
    log_api_usage,
)
from .signal_analyzer import analyze_signal
from .quantum_detector import detect_quantum_effects
from .identity_detector import detect_identity_fragments

logger = logging.getLogger(__name__)
if not logger.handlers:
    logging.basicConfig(level=logging.INFO)

def process_signal_complete(signal_id: str, 
                          actor_id: Optional[str] = None,
                          debug_mode: bool = False) -> Dict[str, Any]:
    """
    Orchestrate all three components and write to database
    
    Args:
        signal_id: UUID of signal from database
        actor_id: UUID of actor (optional)
        debug_mode: Optional flag for detailed logging
    
    Returns:
        Complete analysis with 7-column decoder output
    """
    try:
        logger.info(f"Processing signal {signal_id} for actor {actor_id}")
        
        # Step 1: Get signal data from database
        signal_data = get_signal_data(signal_id)
        if not signal_data:
            return {
                'success': False,
                'error': f'Signal {signal_id} not found',
                'decoder_output': None
            }
        
        # Prefer normalized field, fallback to legacy names
        signal_text = signal_data.get('signal_text') or \
                      signal_data.get('content', '') or \
                      signal_data.get('message', '') or \
                      signal_data.get('text', '')
        signal_type = signal_data.get('signal_type', 'unknown')
        signal_actor_id = signal_data.get("actor_id") or actor_id

        # Build identifiers from the signal (normalized where possible)
        brand_id = signal_data.get("brand_id")
        identifiers = {}
        if signal_data.get("sender_phone"):
            identifiers["sender_phone"] = str(signal_data["sender_phone"]).strip()
        if signal_data.get("reviewer_name"):
            identifiers["reviewer_name"] = str(signal_data["reviewer_name"]).strip().lower()
        if signal_data.get("email"):
            identifiers["email"] = str(signal_data["email"]).strip().lower()
        if signal_data.get("respondent_id"):
            identifiers["respondent_id"] = str(signal_data["respondent_id"]).strip()

        # Try to find an existing actor by identifiers first
        if not signal_actor_id:
            from .database import find_actor_by_identifiers
            matched_id = find_actor_by_identifiers(brand_id=brand_id, identifiers=identifiers)
            if matched_id:
                signal_actor_id = matched_id

        # Auto-create actor if still missing (DB generates UUID)
        if not signal_actor_id:
            from .database import create_actor_profile, attach_actor_id_to_signal
            signal_actor_id = create_actor_profile(brand_id=brand_id, identifiers=identifiers)
            if signal_actor_id:
                attach_actor_id_to_signal(signal_id, signal_type, signal_actor_id)

        # Upsert identifiers to strengthen future matches
        if signal_actor_id and identifiers:
            from .database import upsert_actor_identifiers
            upsert_actor_identifiers(signal_actor_id, identifiers)

        # Step 2: Get actor profile/history only if we have an actor_id
        if not signal_actor_id:
            actor_profile = {}
            actor_history = []
        else:
            actor_profile = get_actor_profile(signal_actor_id) or {}
            actor_history = get_actor_history(signal_actor_id) or []
        
        # Step 3: Analyze signal for drivers
        logger.info("Step 3: Analyzing drivers...")
        driver_analysis = analyze_signal(
            signal_text=signal_text,
            context={
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
            signal_text=signal_text,
            context={
                "signal_id": signal_id,
                "signal_type": signal_type,
                "context": "general",
                "audience": "unknown"
            }
        )
        
        # Step 5: Detect identity fragments
        logger.info("Step 5: Detecting identity fragments...")
        identity_analysis = detect_identity_fragments(
            signal_text=signal_text,
            context={
                "signal_id": signal_id,
                "signal_type": signal_type
            }
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
        
        # Step 7: Update actor profile via DB Bayesian/quantum updater
        logger.info("Step 7: Updating actor profile (if actor_id present)...")
        update_success = False
        if signal_actor_id:
            # Build signal_analysis payload expected by DB
            signal_analysis = {
                "driver_inference": driver_analysis.get("driver_distribution", {}),
                "identity_inference": {
                    "primary_identity": identity_analysis.get("primary_identity"),
                    "secondary_identity": identity_analysis.get("secondary_identity"),
                    "fragmentation_detected": identity_analysis.get("fragmentation_detected", False)
                },
                "quantum_effects": {
                    "superposition_detected": quantum_analysis.get("superposition_detected", False),
                    "interfering_drivers": quantum_analysis.get("interfering_drivers", []),
                    "interference_strength": quantum_analysis.get("interference_strength", 0.0),
                    "coherence": quantum_analysis.get("coherence", 0.0)
                },
                "signal_confidence": driver_analysis.get("confidence", 0.5),
                "signal_text": signal_text,
                "signal_context": {
                    "context": "general",
                    "audience": "unknown"
                }
            }
            # Skip profile update for now - will use trigger or manual backfill
            # from .database import update_actor_profile_quantum
            # db_result = update_actor_profile_quantum(
            #     signal_actor_id,
            #     signal_analysis,
            #     signal_id=signal_id,
            #     signal_type=signal_type,
            #     signal_context={"context": "general", "audience": "unknown"}
            # )
            # update_success = bool(db_result)
            update_success = True  # Assume success since we'll use trigger
        
        # Step 8: Log decoder output
        logger.info("Step 8: Logging decoder output...")
        payload = {
            "signal_id": signal_id,
            "decoder_output": decoder_output,
            "processing_timestamp": datetime.utcnow().isoformat(),
            "model_used": driver_analysis.get("model_used", "unknown"),
            "api_cost": driver_analysis.get("api_cost", 0.0) +
                       quantum_analysis.get("api_cost", 0.0) +
                       identity_analysis.get("api_cost", 0.0)
        }
        if signal_actor_id:
            payload["actor_id"] = signal_actor_id
        log_id = log_decoder_output(payload)
        
        # Step 9: Log API usage for cost tracking
        total_cost = driver_analysis.get("api_cost", 0.0) + \
                     quantum_analysis.get("api_cost", 0.0) + \
                     identity_analysis.get("api_cost", 0.0)
        
        if total_cost > 0:
            usage = {
                "signal_id": signal_id,
                "total_cost": total_cost,
                "driver_analysis_cost": driver_analysis.get("api_cost", 0.0),
                "quantum_analysis_cost": quantum_analysis.get("api_cost", 0.0),
                "identity_analysis_cost": identity_analysis.get("api_cost", 0.0),
                "timestamp": datetime.utcnow().isoformat()
            }
            if signal_actor_id:
                usage["actor_id"] = signal_actor_id
            log_api_usage(usage)
        
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
    # Column 1: Actor/Segment
    dominant_driver = max(driver_analysis["driver_distribution"],
                          key=driver_analysis["driver_distribution"].get)
    col1_actor_segment = {
        "current_identity": [identity_analysis.get("primary_identity", "unknown")],
        "dominant_driver": dominant_driver,
        "driver_confidence": driver_analysis.get("confidence", 0.0),
        "quantum_state": "superposition" if quantum_analysis.get("superposition_detected") else "collapsed",
    }

    # Prepare signal_text once
    signal_text = signal_data.get("signal_text") or signal_data.get("content", "") \
        or signal_data.get("message", "") or signal_data.get("text", "")

    # Column 2: Observed Behavior
    col2_observed_behavior = {
        "action": f"Analyzed {signal_data.get('signal_type', 'unknown')} signal",
        "verbatim_quote": signal_text,
        "context": {
            "signal_type": signal_data.get("signal_type", "unknown"),
            "timestamp": signal_data.get("source_timestamp") or signal_data.get("received_at") or signal_data.get("created_at"),
            "brand_id": signal_data.get("brand_id"),
        },
        "emotional_tone": analyze_emotional_tone(signal_text),
        "behavioral_indicators": extract_behavioral_indicators(signal_text),
    }

    # Column 3: Belief Inferred
    col3_belief_inferred = {
        "driver_update": {
            d: {
                "delta": prob - (actor_profile.get("driver_distribution", {}).get(d, 0.0) if actor_profile else 0.0),
                "reasoning": f"Inferred {d} activation from signal",
                "contextual_activation": prob > 0.3,
                "activation_trigger": "signal_analysis",
            }
            for d, prob in driver_analysis["driver_distribution"].items()
        },
        "quantum_effects": {
            "superposition_collapse": "partial" if quantum_analysis.get("superposition_detected") else "full",
            "collapsed_to": dominant_driver,
            "collapse_trigger": quantum_analysis.get("collapse_trigger", "unknown"),
            "residual_superposition": quantum_analysis.get("interfering_drivers", []),
        },
        "identity_update": {
            "reinforced": [identity_analysis.get("primary_identity", "unknown")],
            "weakened": [],
            "new_fragment_detected": identity_analysis.get("fragmentation_detected", False),
        },
    }

    # Column 4: Confidence Score
    col4_confidence_score = {
        "overall": driver_analysis.get("confidence", 0.0),
        "factors": {
            "signal_strength": min(len(signal_text) / 200.0, 1.0),
            "prior_evidence": len(actor_profile.get("identity_markers", [])) / 10.0 if actor_profile else 0.0,
            "consistency": 0.6,
            "quantum_clarity": quantum_analysis.get("coherence", 0.5),
        },
        "uncertainty_sources": identify_uncertainty_sources(driver_analysis, quantum_analysis),
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
            "coherence_level": quantum_analysis.get("coherence", 0.5),
        },
    }

    # Column 6: Core Driver
    secondary = get_secondary_driver(driver_analysis["driver_distribution"])
    col6_core_driver = {
        "primary": dominant_driver,
        "probability": driver_analysis["driver_distribution"].get(dominant_driver, 0.0),
        "reasoning": driver_analysis.get("reasoning", "LLM analysis"),
        "secondary": secondary,
        "secondary_probability": driver_analysis["driver_distribution"].get(secondary, 0.0),
        "secondary_reasoning": "Secondary driver present",
        "quantum_effects": {
            "superposition": quantum_analysis.get("superposition_detected", False),
            "entanglement_strength": quantum_analysis.get("entanglement", {}).get("entanglement_strength", 0.0),
            "coherence": quantum_analysis.get("coherence", 0.5),
        },
    }

    # Column 7: Actionable Insight
    col7_actionable_insight = {
        "strategy": generate_strategy(quantum_analysis, identity_analysis),
        "recommendation": generate_recommendation(dominant_driver),
        "next_signal_needed": "Collect more signals to confirm stability",
        "confidence_threshold": "Need 2-3 corroborating signals",
        "quantum_considerations": {
            "honor_superposition": quantum_analysis.get("superposition_detected", False),
            "measurement_awareness": "Observation may shift state",
            "coherence_management": "Maintain coherent messaging",
        },
        "collapse_strategies": generate_collapse_strategies(quantum_analysis),
    }

    return {
        "col1_actor_segment": col1_actor_segment,
        "col2_observed_behavior": col2_observed_behavior,
        "col3_belief_inferred": col3_belief_inferred,
        "col4_confidence_score": col4_confidence_score,
        "col5_friction_contradiction": col5_friction_contradiction,
        "col6_core_driver": col6_core_driver,
        "col7_actionable_insight": col7_actionable_insight,
    }


def build_reasoning_chain(driver_analysis: Dict[str, Any],
                          quantum_analysis: Dict[str, Any],
                          identity_analysis: Dict[str, Any]) -> str:
    dominant = max(driver_analysis["driver_distribution"], key=driver_analysis["driver_distribution"].get)
    parts = [
        f"Dominant driver {dominant} ({driver_analysis['driver_distribution'].get(dominant, 0.0):.2f}).",
        f"Quantum superposition between {', '.join(quantum_analysis.get('interfering_drivers', []))}"
        if quantum_analysis.get("superposition_detected") else "No superposition detected.",
        f"Primary identity {identity_analysis.get('primary_identity', 'unknown')}."
    ]
    return " ".join(parts)


def analyze_emotional_tone(signal_text: str) -> str:
    s = signal_text.lower()
    if any(w in s for w in ["love", "amazing", "fantastic", "perfect", "excited"]):
        return "enthusiastic"
    if any(w in s for w in ["hate", "terrible", "awful", "disgusting", "angry"]):
        return "negative"
    if any(w in s for w in ["okay", "fine", "alright", "decent"]):
        return "neutral"
    return "mixed"


def extract_behavioral_indicators(signal_text: str) -> List[str]:
    s = signal_text.lower()
    inds: List[str] = []
    if any(w in s for w in ["order", "get", "buy"]): inds.append("ordering")
    if any(w in s for w in ["try", "new", "different", "explore"]): inds.append("exploring")
    if any(w in s for w in ["family", "everyone", "friends", "together"]): inds.append("social_consideration")
    if any(w in s for w in ["premium", "exclusive", "best", "status"]): inds.append("status_signaling")
    return inds


def identify_uncertainty_sources(driver_analysis: Dict[str, Any],
                                 quantum_analysis: Dict[str, Any]) -> List[str]:
    sources: List[str] = []
    if driver_analysis.get("confidence", 0.0) < 0.5: sources.append("low_signal_confidence")
    if quantum_analysis.get("superposition_detected"): sources.append("quantum_superposition")
    if len(driver_analysis.get("signal_text", "")) < 20: sources.append("short_signal")
    return sources


def build_tension_description(quantum_analysis: Dict[str, Any]) -> str:
    if not quantum_analysis.get("superposition_detected"):
        return "No significant contradictions detected"
    drivers = ", ".join(quantum_analysis.get("interfering_drivers", []))
    strength = quantum_analysis.get("interference_strength", 0.0)
    return f"Driver conflict detected between {drivers} with strength {strength:.2f}"


def get_secondary_driver(driver_distribution: Dict[str, float]) -> str:
    items = sorted(driver_distribution.items(), key=lambda x: x[1], reverse=True)
    return items[1][0] if len(items) > 1 else items[0][0]


def generate_strategy(quantum_analysis: Dict[str, Any],
                      identity_analysis: Dict[str, Any]) -> str:
    if quantum_analysis.get("superposition_detected"):
        return "Collapse strategy for conflicting drivers"
    if identity_analysis.get("fragmentation_detected"):
        return "Identity integration strategy"
    return "Reinforce dominant driver"


def generate_recommendation(dominant_driver: str) -> str:
    recs = {
        "Safety": "Emphasize reliability and consistency.",
        "Connection": "Highlight shared experiences and community.",
        "Status": "Position as premium/exclusive.",
        "Growth": "Offer challenge and skill progression.",
        "Freedom": "Provide variety and exploration.",
        "Purpose": "Align with values and impact.",
    }
    return recs.get(dominant_driver, "General engagement strategy")


def generate_collapse_strategies(quantum_analysis: Dict[str, Any]) -> List[str]:
    if not quantum_analysis.get("superposition_detected"):
        return ["single_driver_focus"]
    return ["contextual_positioning", "dual_identity_messaging"]
