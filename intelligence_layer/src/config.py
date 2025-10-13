"""
Configuration for LLM Intelligence Integration
Big Appetite OS - Quantum Psychology System
"""

import os
from typing import Dict, Any

# API Configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_ORG_ID = os.getenv("OPENAI_ORG_ID")  # Optional

# Model Selection
DEFAULT_MODEL = "gpt-4o-mini"  # $0.15/$0.60 per 1M tokens
FALLBACK_MODEL = "gpt-4o"      # $2.50/$10 per 1M tokens
USE_SMART_ROUTING = True       # Enable complexity-based routing
COMPLEXITY_THRESHOLD = 0.7     # When to upgrade to gpt-4o

# API Parameters
TEMPERATURE = 0.3              # Lower = more consistent
MAX_TOKENS = 2000              # Max output length
TIMEOUT = 30                   # Seconds before timeout
MAX_RETRIES = 3                # Retry attempts

# Cost Tracking
TRACK_COSTS = True             # Log token usage and costs
LOG_MODEL_DECISIONS = True     # Log which model was chosen and why

# Supabase Configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Driver Configuration
DRIVER_NAMES = ["Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"]

# Model Pricing (per 1M tokens)
PRICING = {
    "gpt-4o-mini": {
        "input": 0.15,
        "output": 0.60
    },
    "gpt-4o": {
        "input": 2.50,
        "output": 10.00
    }
}

# Complexity Analysis Weights
COMPLEXITY_WEIGHTS = {
    "length_short": 0.1,        # < 20 chars = ambiguous
    "length_long": 0.3,         # > 200 chars = complex
    "no_history": 0.2,          # No actor baseline
    "contradiction": 0.3,       # Contradictory language
    "emotional": 0.2,           # High emotional content
    "technical": 0.1            # Technical/sophisticated language
}

# Contradiction Keywords
CONTRADICTION_KEYWORDS = [
    "but", "however", "although", "even though", "despite", 
    "yet", "still", "nevertheless", "on the other hand",
    "actually", "really", "honestly", "to be honest"
]

# Identity Archetypes
IDENTITY_ARCHETYPES = {
    "protector": {
        "keywords": ["family", "everyone", "take care", "for them", "responsibility"],
        "driver_alignment": {"Safety": 0.9, "Connection": 0.8}
    },
    "provider": {
        "keywords": ["order", "get", "bring", "pick up", "delivery"],
        "driver_alignment": {"Purpose": 0.7, "Connection": 0.6}
    },
    "explorer": {
        "keywords": ["try", "new", "different", "adventure", "discover"],
        "driver_alignment": {"Freedom": 0.9, "Growth": 0.8}
    },
    "connoisseur": {
        "keywords": ["sophisticated", "quality", "expert", "premium", "artisanal"],
        "driver_alignment": {"Status": 0.8, "Purpose": 0.6}
    },
    "rebel": {
        "keywords": ["against", "different from", "unique", "unconventional", "alternative"],
        "driver_alignment": {"Freedom": 0.9, "Purpose": 0.7}
    },
    "connector": {
        "keywords": ["together", "share", "community", "group", "everyone"],
        "driver_alignment": {"Connection": 0.9, "Purpose": 0.6}
    }
}

# Error Messages
ERROR_MESSAGES = {
    "api_failure": "OpenAI API call failed",
    "json_parse_error": "Failed to parse LLM response as JSON",
    "rate_limit": "Rate limit exceeded, retrying with backoff",
    "timeout": "Request timed out after 30 seconds",
    "invalid_drivers": "Driver probabilities do not sum to 1.0",
    "database_error": "Database connection or query failed",
    "missing_signal": "Signal not found in database",
    "missing_actor": "Actor not found in database"
}

# Logging Configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# Validation
def validate_config() -> Dict[str, Any]:
    """Validate configuration and return status"""
    status = {
        "valid": True,
        "errors": [],
        "warnings": []
    }
    
    # Required environment variables
    if not OPENAI_API_KEY:
        status["valid"] = False
        status["errors"].append("OPENAI_API_KEY not set")
    
    if not SUPABASE_URL:
        status["valid"] = False
        status["errors"].append("SUPABASE_URL not set")
    
    if not SUPABASE_KEY:
        status["valid"] = False
        status["errors"].append("SUPABASE_KEY not set")
    
    # Optional warnings
    if not OPENAI_ORG_ID:
        status["warnings"].append("OPENAI_ORG_ID not set (optional)")
    
    if not TRACK_COSTS:
        status["warnings"].append("Cost tracking disabled")
    
    return status

# Export configuration
__all__ = [
    "OPENAI_API_KEY", "OPENAI_ORG_ID", "DEFAULT_MODEL", "FALLBACK_MODEL",
    "USE_SMART_ROUTING", "COMPLEXITY_THRESHOLD", "TEMPERATURE", "MAX_TOKENS",
    "TIMEOUT", "MAX_RETRIES", "TRACK_COSTS", "LOG_MODEL_DECISIONS",
    "SUPABASE_URL", "SUPABASE_KEY", "DRIVER_NAMES", "PRICING",
    "COMPLEXITY_WEIGHTS", "CONTRADICTION_KEYWORDS", "IDENTITY_ARCHETYPES",
    "ERROR_MESSAGES", "LOG_LEVEL", "LOG_FORMAT", "validate_config"
]
