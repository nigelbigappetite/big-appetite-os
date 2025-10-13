"""
Big Appetite OS - Intelligence Layer

A sophisticated psychological analysis system that understands customers
at a deep level through driver inference, quantum psychology, and identity
fragment detection.
"""

from .signal_analyzer import analyze_signal, analyze_signal_batch
from .quantum_detector import detect_quantum_effects
from .identity_detector import detect_identity_fragments
from .signal_processor import process_signal_complete

__version__ = "1.0.0"
__author__ = "Big Appetite OS Team"

__all__ = [
    "analyze_signal",
    "analyze_signal_batch", 
    "detect_quantum_effects",
    "detect_identity_fragments",
    "process_signal_complete"
]
