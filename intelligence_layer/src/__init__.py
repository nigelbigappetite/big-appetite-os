# Core intelligence functions
from .signal_analyzer import analyze_signal
from .quantum_detector import detect_quantum_effects
from .identity_detector import detect_identity_fragments
from .signal_processor import process_signal_complete

# Database functions
from .database import (
    get_driver_ontology,
    get_actor_profile,
    update_actor_profile,
    get_actor_history,
    get_signal_data,
    get_cost_summary,
    log_decoder_output,
    log_api_usage,
    get_unprocessed_signals,
    mark_signal_processed
)

# LLM client
from .llm_client import LLMClient

# Configuration
from .config import *

# Batch processing function (no actor_id needed)
def analyze_signal_batch(signals):
    """Process multiple signals in batch"""
    results = []
    for signal in signals:
        result = analyze_signal(signal)
        results.append(result)
    return results
