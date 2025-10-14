import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# --- OpenAI API Configuration ---
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_ORG_ID = os.getenv("OPENAI_ORG_ID")  # Optional

# --- Supabase Configuration ---
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# --- Model Selection and Routing ---
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gpt-4o-mini")
FALLBACK_MODEL = os.getenv("FALLBACK_MODEL", "gpt-4o")
USE_SMART_ROUTING = os.getenv("USE_SMART_ROUTING", "True").lower() == "true"

# --- LLM Parameters ---
TEMPERATURE = float(os.getenv("TEMPERATURE", "0.7"))
MAX_TOKENS = int(os.getenv("MAX_TOKENS", "1024"))
COMPLEXITY_THRESHOLD = float(os.getenv("COMPLEXITY_THRESHOLD", "0.6"))

# --- Retry and Timeout Settings ---
MAX_RETRIES = int(os.getenv("MAX_RETRIES", "3"))
TIMEOUT = int(os.getenv("TIMEOUT_SECONDS", "30"))

# --- Cost Tracking and Logging ---
TRACK_COSTS = os.getenv("TRACK_COSTS", "True").lower() == "true"
LOG_MODEL_DECISIONS = os.getenv("LOG_MODEL_DECISIONS", "True").lower() == "true"

# --- Driver Names ---
DRIVER_NAMES = [
    "Safety", "Connection", "Status", "Growth", "Freedom", "Purpose"
]

# --- Identity Archetypes ---
IDENTITY_ARCHETYPES = [
    "Provider", "Explorer", "Connoisseur", "Rebel", "Connector", 
    "Protector", "Achiever", "Seeker", "Individualist", "Collectivist"
]

# --- Pricing (per million tokens) ---
PRICING = {
    "gpt-4o-mini": {
        "input": 0.15,   # $0.15 per 1M input tokens
        "output": 0.60,  # $0.60 per 1M output tokens
    },
    "gpt-4o": {
        "input": 5.00,   # $5.00 per 1M input tokens
        "output": 15.00, # $15.00 per 1M output tokens
    },
}

# --- Complete Complexity Weights (All Missing Ones Added) ---
COMPLEXITY_WEIGHTS = {
    "length_short": 0.10,      # Missing: length_short
    "length_long": 0.10,       # Missing: length_long  
    "no_history": 0.10,        # Missing: no_history
    "contradiction": 0.10,     # Missing: contradiction
    "emotional": 0.10,         # Missing: emotional
    "technical": 0.10,         # Missing: technical
    "keywords": 0.10,          # Existing
    "sentiment_variance": 0.10, # Existing
    "context_dependent": 0.10,  # Existing
    "abstract": 0.10,          # Bonus: abstract
}

# --- Contradiction Keywords ---
CONTRADICTION_KEYWORDS = [
    "but", "however", "yet", "on the other hand", "despite", "although",
    "contradictory", "inconsistent", "conflict", "tension"
]
