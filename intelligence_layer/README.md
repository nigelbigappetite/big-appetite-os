# Big Appetite OS - Intelligence Layer

## Quantum Psychology System for Customer Signal Analysis

This is the intelligence layer for the Big Appetite OS, providing LLM-powered analysis of customer signals to infer psychological drivers, detect quantum effects, and identify identity fragments.

## 🧠 What This Does

The intelligence layer analyzes customer signals (WhatsApp messages, reviews, orders) and:

1. **Infers Psychological Drivers** - Determines which of 6 core drivers (Safety, Connection, Status, Growth, Freedom, Purpose) are active
2. **Detects Quantum Effects** - Identifies superposition states, driver conflicts, and entanglement patterns
3. **Identifies Identity Fragments** - Recognizes role-based identities and self-concept patterns
4. **Updates Actor Profiles** - Uses Bayesian reasoning to evolve customer understanding over time

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd intelligence_layer
pip install -r requirements.txt
```

### 2. Set Environment Variables

```bash
# OpenAI Configuration
export OPENAI_API_KEY="sk-proj-xxxxx"
export OPENAI_ORG_ID="org-xxxxx"  # Optional

# Supabase Configuration
export SUPABASE_URL="https://xxxxx.supabase.co"
export SUPABASE_KEY="xxxxx"

# Optional Configuration
export LOG_LEVEL="INFO"
export USE_SMART_ROUTING="true"
export COMPLEXITY_THRESHOLD="0.7"
```

### 3. Basic Usage

```python
from src import analyze_signal, process_signal_complete

# Analyze a single signal
result = analyze_signal(
    signal_text="I love the premium wings, they are so exclusive!",
    actor_id="actor_123",
    signal_context={"context": "social", "audience": "friends"}
)

print(f"Dominant Driver: {max(result['driver_distribution'], key=result['driver_distribution'].get)}")
print(f"Confidence: {result['confidence']}")
print(f"Model Used: {result['model_used']}")
print(f"Cost: ${result['api_cost']:.4f}")

# Process a complete signal (with database updates)
result = process_signal_complete(
    signal_id="signal_456",
    actor_id="actor_123"
)

print(f"Profile Updated: {result['profile_updated']}")
print(f"Total Cost: ${result['total_api_cost']:.4f}")
```

## 📁 Project Structure

```
intelligence_layer/
├── src/
│   ├── __init__.py              # Main exports
│   ├── config.py                # Configuration and constants
│   ├── database.py              # Supabase connection and queries
│   ├── llm_client.py            # OpenAI API client with smart routing
│   ├── signal_analyzer.py       # Function 1: Driver analysis
│   ├── quantum_detector.py      # Function 2: Quantum effects
│   ├── identity_detector.py     # Function 3: Identity fragments
│   └── signal_processor.py      # Function 4: Complete orchestration
├── tests/
│   └── test_integration.py      # Integration tests
├── requirements.txt             # Python dependencies
└── README.md                   # This file
```

## 🔧 Core Functions

### Function 1: Signal Analyzer
```python
from src import analyze_signal

result = analyze_signal(
    signal_text="I always get the same thing, it's reliable",
    actor_id="actor_123"
)
```

**Output:**
```python
{
  "driver_distribution": {
    "Safety": 0.75,
    "Connection": 0.15,
    "Status": 0.05,
    "Growth": 0.00,
    "Freedom": 0.05,
    "Purpose": 0.00
  },
  "confidence": 0.82,
  "reasoning": "Detected 'always' and 'reliable' language patterns...",
  "evidence": {
    "Safety": ["always", "reliable", "same thing"],
    "Connection": ["thanks - polite engagement"]
  },
  "model_used": "gpt-4o-mini",
  "api_cost": 0.001
}
```

### Function 2: Quantum Psychology Detector
```python
from src import detect_quantum_effects

result = detect_quantum_effects(
    driver_distribution={"Safety": 0.4, "Status": 0.35, ...},
    signal_context={"context": "social"}
)
```

**Output:**
```python
{
  "superposition_detected": True,
  "interfering_drivers": ["Safety", "Status"],
  "interference_strength": 0.68,
  "entanglement": {
    "driver_a": "Safety",
    "driver_b": "Status", 
    "correlation": -0.72,
    "entanglement_strength": 0.81
  },
  "coherence": 0.58,
  "collapse_trigger": "social_context"
}
```

### Function 3: Identity Fragment Detector
```python
from src import detect_identity_fragments

result = detect_identity_fragments(
    signal_text="I always order for my family",
    behavioral_history=actor_history
)
```

**Output:**
```python
{
  "primary_identity": {
    "label": "protector",
    "archetype": "caregiver",
    "confidence": 0.85,
    "evidence": ["family language", "responsibility"],
    "driver_alignment": {"Safety": 0.9, "Connection": 0.85}
  },
  "identity_coherence": 0.68,
  "fragmentation_detected": False
}
```

### Function 4: Complete Signal Processing
```python
from src import process_signal_complete

result = process_signal_complete(
    signal_id="signal_456",
    actor_id="actor_123"
)
```

**Output:**
```python
{
  "col1_actor_segment": {...},
  "col2_observed_behavior": {...},
  "col3_belief_inferred": {...},
  "col4_confidence_score": {...},
  "col5_friction_contradiction": {...},
  "col6_core_driver": {...},
  "col7_actionable_insight": {...},
  "profile_updated": True,
  "total_api_cost": 0.003
}
```

## 💰 Cost Optimization

The system uses smart model routing to optimize costs:

- **gpt-4o-mini** (default): $0.15/$0.60 per 1M tokens
- **gpt-4o** (fallback): $2.50/$10.00 per 1M tokens

Model selection is based on signal complexity:
- Simple signals → gpt-4o-mini (15x cheaper)
- Complex/contradictory signals → gpt-4o (more capable)

```python
# Check costs
from src import get_cost_summary

summary = get_cost_summary("today")
print(f"Today's usage: {summary['signal_count']} signals")
print(f"Total cost: ${summary['total_cost']:.2f}")
```

## 🧪 Testing

Run the integration tests:

```bash
cd intelligence_layer
python -m pytest tests/test_integration.py -v
```

## 🔍 Debugging

Enable debug mode for detailed logging:

```python
result = process_signal_complete(
    signal_id="signal_456",
    actor_id="actor_123",
    debug_mode=True
)

# Access debug information
print(result["debug_info"])
```

## 📊 Database Integration

The system integrates with your existing Supabase database:

- **Reads from**: `actors.drivers`, `signals.*`, `actors.actor_profiles`
- **Writes to**: `actors.actor_profiles`, `actors.decoder_log`, `intelligence.api_usage`
- **Uses functions**: `actors.update_actor_profile_quantum()`

## ⚙️ Configuration

Key configuration options in `src/config.py`:

```python
# Model Selection
DEFAULT_MODEL = "gpt-4o-mini"
FALLBACK_MODEL = "gpt-4o"
USE_SMART_ROUTING = True
COMPLEXITY_THRESHOLD = 0.7

# API Parameters
TEMPERATURE = 0.3
MAX_TOKENS = 2000
TIMEOUT = 30
MAX_RETRIES = 3

# Cost Tracking
TRACK_COSTS = True
LOG_MODEL_DECISIONS = True
```

## 🚨 Error Handling

The system handles errors gracefully:

- **API failures**: Retries with exponential backoff
- **JSON parsing errors**: Falls back to default responses
- **Database errors**: Logs errors but continues processing
- **Rate limits**: Implements backoff strategies

## 📈 Performance

- **Batch processing**: Process multiple signals efficiently
- **Connection pooling**: Reuses database connections
- **Smart routing**: Optimizes API costs
- **Caching**: Reuses driver ontology data

## 🔮 Quantum Psychology Concepts

This system implements advanced psychological concepts:

- **Superposition**: Multiple drivers simultaneously active
- **Entanglement**: Drivers affecting each other
- **Coherence**: Stability of psychological state
- **Collapse**: Resolution to single driver state
- **Measurement Effects**: How observation changes behavior

## 🤝 Contributing

1. Follow the existing code structure
2. Add tests for new functionality
3. Update documentation
4. Use type hints and docstrings
5. Handle errors gracefully

## 📝 License

Part of the Big Appetite OS project.

---

**Need help?** Check the test files for usage examples or examine the source code for implementation details.
