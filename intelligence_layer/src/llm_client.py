"""
OpenAI API client with smart model selection and cost tracking
Big Appetite OS - Quantum Psychology System
"""

import json
import logging
import time
from typing import Dict, Any, Optional, Tuple, List
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from .config import (
    OPENAI_API_KEY, OPENAI_ORG_ID, DEFAULT_MODEL, FALLBACK_MODEL,
    USE_SMART_ROUTING, COMPLEXITY_THRESHOLD, TEMPERATURE, MAX_TOKENS,
    TIMEOUT, MAX_RETRIES, PRICING, TRACK_COSTS, LOG_MODEL_DECISIONS,
    COMPLEXITY_WEIGHTS, CONTRADICTION_KEYWORDS, DRIVER_NAMES
)

logger = logging.getLogger(__name__)

class CostTracker:
    """Track OpenAI API costs and usage"""
    
    def __init__(self):
        self.total_cost = 0.0
        self.usage_log = []
    
    def calculate_cost(self, model: str, input_tokens: int, output_tokens: int) -> float:
        """Calculate cost for a single API call"""
        pricing = PRICING.get(model, PRICING["gpt-4o-mini"])
        input_cost = input_tokens * pricing["input"] / 1_000_000
        output_cost = output_tokens * pricing["output"] / 1_000_000
        return input_cost + output_cost
    
    def log_usage(self, model: str, input_tokens: int, output_tokens: int, 
                  signal_id: Optional[str] = None, complexity_score: float = 0.0) -> float:
        """Log usage and return cost"""
        cost = self.calculate_cost(model, input_tokens, output_tokens)
        
        usage_entry = {
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cost": cost,
            "signal_id": signal_id,
            "complexity_score": complexity_score,
            "timestamp": time.time()
        }
        
        self.usage_log.append(usage_entry)
        self.total_cost += cost
        
        if TRACK_COSTS:
            logger.info(f"API Usage: {model} | Input: {input_tokens} | Output: {output_tokens} | Cost: ${cost:.4f}")
        
        return cost
    
    def get_summary(self) -> Dict[str, Any]:
        """Get usage summary"""
        mini_calls = sum(1 for entry in self.usage_log if entry["model"] == "gpt-4o-mini")
        gpt4_calls = sum(1 for entry in self.usage_log if entry["model"] == "gpt-4o")
        
        return {
            "total_calls": len(self.usage_log),
            "mini_calls": mini_calls,
            "gpt4_calls": gpt4_calls,
            "total_cost": self.total_cost,
            "avg_cost_per_call": self.total_cost / len(self.usage_log) if self.usage_log else 0
        }

class LLMClient:
    """OpenAI API client with smart model selection"""
    
    def __init__(self):
        self.client = OpenAI(
            api_key=OPENAI_API_KEY,
            organization=OPENAI_ORG_ID
        )
        self.cost_tracker = CostTracker()
    
    def calculate_complexity(self, signal_text: str, actor_history: Optional[List[Dict[str, Any]]] = None) -> float:
        """Calculate signal complexity score for model selection"""
        complexity = 0.0
        
        # Length factors
        if len(signal_text) < 20:
            complexity += COMPLEXITY_WEIGHTS["length_short"]
        elif len(signal_text) > 200:
            complexity += COMPLEXITY_WEIGHTS["length_long"]
        
        # History factors
        if not actor_history or len(actor_history) < 3:
            complexity += COMPLEXITY_WEIGHTS["no_history"]
        
        # Contradiction indicators
        signal_lower = signal_text.lower()
        if any(keyword in signal_lower for keyword in CONTRADICTION_KEYWORDS):
            complexity += COMPLEXITY_WEIGHTS["contradiction"]
        
        # Emotional content
        emotional_keywords = ["love", "hate", "amazing", "terrible", "excited", "disappointed", "frustrated"]
        if any(keyword in signal_lower for keyword in emotional_keywords):
            complexity += COMPLEXITY_WEIGHTS["emotional"]
        
        # Technical/sophisticated language
        technical_keywords = ["sophisticated", "premium", "artisanal", "expert", "connoisseur"]
        if any(keyword in signal_lower for keyword in technical_keywords):
            complexity += COMPLEXITY_WEIGHTS["technical"]
        
        return min(complexity, 1.0)
    
    def select_model(self, signal_text: str, actor_history: Optional[List[Dict[str, Any]]] = None) -> str:
        """Select appropriate model based on signal complexity"""
        if not USE_SMART_ROUTING:
            return DEFAULT_MODEL
        
        complexity = self.calculate_complexity(signal_text, actor_history)
        
        if complexity >= COMPLEXITY_THRESHOLD:
            model = FALLBACK_MODEL
            reason = f"High complexity ({complexity:.2f})"
        else:
            model = DEFAULT_MODEL
            reason = f"Low complexity ({complexity:.2f})"
        
        if LOG_MODEL_DECISIONS:
            logger.info(f"Model selection: {model} - {reason}")
        
        return model
    
    @retry(
        stop=stop_after_attempt(MAX_RETRIES),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type((Exception,))
    )
    def call_api(self, messages: List[Dict[str, str]], model: str, 
                 signal_id: Optional[str] = None) -> Tuple[Dict[str, Any], float]:
        """Make API call with retry logic and cost tracking"""
        try:
            response = self.client.chat.completions.create(
                model=model,
                messages=messages,
                response_format={"type": "json_object"},
                temperature=TEMPERATURE,
                max_tokens=MAX_TOKENS,
                timeout=TIMEOUT
            )
            
            # Extract response
            content = response.choices[0].message.content
            input_tokens = response.usage.prompt_tokens
            output_tokens = response.usage.completion_tokens
            
            # Calculate and log cost
            cost = self.cost_tracker.log_usage(
                model, input_tokens, output_tokens, signal_id
            )
            
            # Parse JSON response
            try:
                parsed_response = json.loads(content)
            except json.JSONDecodeError as e:
                logger.error(f"Failed to parse JSON response: {e}")
                logger.error(f"Raw response: {content}")
                raise ValueError(f"Invalid JSON response: {e}")
            
            return parsed_response, cost
            
        except Exception as e:
            logger.error(f"API call failed: {e}")
            raise
    
    def analyze_drivers(self, signal_text: str, driver_ontology: Dict[str, Any],
                       actor_history: Optional[List[Dict[str, Any]]] = None,
                       signal_id: Optional[str] = None) -> Dict[str, Any]:
        """Analyze signal for driver probabilities"""
        
        # Select model
        model = self.select_model(signal_text, actor_history)
        
        # Build prompt
        prompt = self._build_driver_analysis_prompt(signal_text, driver_ontology, actor_history)
        
        messages = [
            {"role": "system", "content": "You are a psychological analysis expert specializing in customer behavior patterns."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            response, cost = self.call_api(messages, model, signal_id)
            
            # Validate response
            validated_response = self._validate_driver_response(response)
            
            return {
                **validated_response,
                "model_used": model,
                "api_cost": cost,
                "complexity_score": self.calculate_complexity(signal_text, actor_history)
            }
            
        except Exception as e:
            logger.error(f"Driver analysis failed: {e}")
            return {
                "driver_distribution": {driver: 1.0/6 for driver in DRIVER_NAMES},
                "confidence": 0.0,
                "reasoning": f"Analysis failed: {str(e)}",
                "evidence": {},
                "model_used": model,
                "api_cost": 0.0,
                "error": str(e)
            }
    
    def analyze_quantum_effects(self, driver_distribution: Dict[str, float],
                               signal_context: Dict[str, Any],
                               actor_history: Optional[List[Dict[str, Any]]] = None,
                               signal_id: Optional[str] = None) -> Dict[str, Any]:
        """Analyze quantum effects and driver conflicts"""
        
        # Check if superposition is detected
        high_prob_drivers = [driver for driver, prob in driver_distribution.items() if prob > 0.3]
        
        if len(high_prob_drivers) < 2:
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
        
        # Select model
        model = self.select_model(f"Driver analysis: {driver_distribution}", actor_history)
        
        # Build prompt
        prompt = self._build_quantum_analysis_prompt(driver_distribution, signal_context, actor_history)
        
        messages = [
            {"role": "system", "content": "You are a quantum psychology expert analyzing driver conflicts and superposition states."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            response, cost = self.call_api(messages, model, signal_id)
            
            return {
                **response,
                "model_used": model,
                "api_cost": cost
            }
            
        except Exception as e:
            logger.error(f"Quantum analysis failed: {e}")
            return {
                "superposition_detected": True,
                "interfering_drivers": high_prob_drivers[:2],
                "interference_strength": 0.5,
                "entanglement": None,
                "coherence": 0.5,
                "collapse_trigger": "unknown",
                "collapse_hypothesis": "Driver conflict detected",
                "measurement_effect": "observation_required",
                "model_used": model,
                "api_cost": 0.0,
                "error": str(e)
            }
    
    def analyze_identity(self, signal_text: str, behavioral_history: Optional[List[Dict[str, Any]]] = None,
                        existing_identities: Optional[List[Dict[str, Any]]] = None,
                        signal_id: Optional[str] = None) -> Dict[str, Any]:
        """Analyze identity fragments and role archetypes"""
        
        # Select model
        model = self.select_model(signal_text, behavioral_history)
        
        # Build prompt
        prompt = self._build_identity_analysis_prompt(signal_text, behavioral_history, existing_identities)
        
        messages = [
            {"role": "system", "content": "You are an identity analysis expert specializing in role archetypes and self-concept patterns."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            response, cost = self.call_api(messages, model, signal_id)
            
            return {
                **response,
                "model_used": model,
                "api_cost": cost
            }
            
        except Exception as e:
            logger.error(f"Identity analysis failed: {e}")
            return {
                "primary_identity": None,
                "secondary_identity": None,
                "identity_coherence": 0.0,
                "fragmentation_detected": False,
                "integration_status": "unknown",
                "model_used": model,
                "api_cost": 0.0,
                "error": str(e)
            }
    
    def _build_driver_analysis_prompt(self, signal_text: str, driver_ontology: Dict[str, Any],
                                    actor_history: Optional[List[Dict[str, Any]]] = None) -> str:
        """Build prompt for driver analysis"""
        
        # Format driver ontology
        ontology_text = ""
        for driver_name, driver_data in driver_ontology.items():
            ontology_text += f"\n{driver_name}:\n"
            ontology_text += f"  Core Meaning: {driver_data['core_meaning']}\n"
            ontology_text += f"  Core Need: {driver_data['core_need']}\n"
            ontology_text += f"  Language Patterns: {', '.join(driver_data['language_patterns'])}\n"
            ontology_text += f"  Typical Behaviors: {', '.join(driver_data['typical_behaviors'])}\n"
        
        # Format actor history
        history_text = ""
        if actor_history:
            history_text = "\nActor History:\n"
            for update in actor_history[:3]:  # Last 3 updates
                history_text += f"- {update.get('update_timestamp', 'Unknown time')}: {update.get('reasoning_chain', 'No details')}\n"
        
        prompt = f"""Analyze the following customer signal for psychological driver activation.

DRIVER ONTOLOGY:
{ontology_text}

CUSTOMER SIGNAL:
"{signal_text}"

{history_text}

INSTRUCTIONS:
1. Analyze the signal for evidence of each of the 6 drivers
2. Assign probabilities that sum to exactly 1.0
3. Provide confidence score (0-1)
4. Explain your reasoning
5. List specific evidence for each driver

RESPONSE FORMAT (JSON):
{{
  "driver_distribution": {{
    "Safety": 0.0-1.0,
    "Connection": 0.0-1.0,
    "Status": 0.0-1.0,
    "Growth": 0.0-1.0,
    "Freedom": 0.0-1.0,
    "Purpose": 0.0-1.0
  }},
  "confidence": 0.0-1.0,
  "reasoning": "Detailed explanation of analysis",
  "evidence": {{
    "Safety": ["specific evidence"],
    "Connection": ["specific evidence"],
    "Status": ["specific evidence"],
    "Growth": ["specific evidence"],
    "Freedom": ["specific evidence"],
    "Purpose": ["specific evidence"]
  }}
}}"""
        return prompt
    
    def _build_quantum_analysis_prompt(self, driver_distribution: Dict[str, float],
                                     signal_context: Dict[str, Any],
                                     actor_history: Optional[List[Dict[str, Any]]] = None) -> str:
        """Build prompt for quantum effects analysis"""
        
        actor_history_text = f"ACTOR HISTORY:\n{str(actor_history)}" if actor_history else ""
        
        prompt = f"""Analyze the following driver distribution for quantum psychological effects.

DRIVER DISTRIBUTION:
{driver_distribution}

SIGNAL CONTEXT:
{signal_context}

{actor_history_text}

INSTRUCTIONS:
1. Detect if multiple drivers are simultaneously active (superposition)
2. Calculate interference strength between conflicting drivers
3. Identify entanglement patterns
4. Determine coherence level
5. Predict collapse triggers and measurement effects

RESPONSE FORMAT (JSON):
{{
  "superposition_detected": true/false,
  "interfering_drivers": ["driver1", "driver2"],
  "interference_strength": 0.0-1.0,
  "entanglement": {{
    "driver_a": "driver1",
    "driver_b": "driver2",
    "correlation": -1.0 to 1.0,
    "entanglement_strength": 0.0-1.0
  }},
  "coherence": 0.0-1.0,
  "collapse_trigger": "contextual trigger",
  "collapse_hypothesis": "explanation of collapse",
  "measurement_effect": "effect of observation"
}}"""
        return prompt
    
    def _build_identity_analysis_prompt(self, signal_text: str,
                                      behavioral_history: Optional[List[Dict[str, Any]]] = None,
                                      existing_identities: Optional[List[Dict[str, Any]]] = None) -> str:
        """Build prompt for identity analysis"""
        
        behavioral_history_text = f"BEHAVIORAL HISTORY:\n{str(behavioral_history)}" if behavioral_history else ""
        existing_identities_text = f"EXISTING IDENTITIES:\n{str(existing_identities)}" if existing_identities else ""
        
        prompt = f"""Analyze the following customer signal for identity fragments and role archetypes.

CUSTOMER SIGNAL:
"{signal_text}"

{behavioral_history_text}

{existing_identities_text}

INSTRUCTIONS:
1. Identify role-based identities (protector, provider, explorer, connoisseur, rebel, connector)
2. Detect identity fragmentation (multiple conflicting self-concepts)
3. Calculate identity coherence
4. Assess integration status

RESPONSE FORMAT (JSON):
{{
  "primary_identity": {{
    "label": "identity_name",
    "archetype": "archetype_type",
    "confidence": 0.0-1.0,
    "evidence": ["evidence1", "evidence2"],
    "driver_alignment": {{"Safety": 0.0-1.0, "Connection": 0.0-1.0, ...}}
  }},
  "secondary_identity": {{
    "label": "identity_name",
    "confidence": 0.0-1.0,
    "evidence": ["evidence1", "evidence2"]
  }},
  "identity_coherence": 0.0-1.0,
  "fragmentation_detected": true/false,
  "integration_status": "integrated/partially_integrated/fragmented"
}}"""
        return prompt
    
    def _validate_driver_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Validate and fix driver response"""
        
        # Ensure driver_distribution exists
        if "driver_distribution" not in response:
            response["driver_distribution"] = {driver: 1.0/6 for driver in DRIVER_NAMES}
        
        # Ensure all drivers are present
        for driver in DRIVER_NAMES:
            if driver not in response["driver_distribution"]:
                response["driver_distribution"][driver] = 0.0
        
        # Normalize probabilities to sum to 1.0
        total = sum(response["driver_distribution"].values())
        if total > 0:
            for driver in response["driver_distribution"]:
                response["driver_distribution"][driver] /= total
        else:
            response["driver_distribution"] = {driver: 1.0/6 for driver in DRIVER_NAMES}
        
        # Ensure confidence exists
        if "confidence" not in response:
            response["confidence"] = 0.5
        
        # Ensure reasoning exists
        if "reasoning" not in response:
            response["reasoning"] = "Analysis completed"
        
        # Ensure evidence exists
        if "evidence" not in response:
            response["evidence"] = {driver: [] for driver in DRIVER_NAMES}
        
        return response

# Global client instance
llm_client = LLMClient()
