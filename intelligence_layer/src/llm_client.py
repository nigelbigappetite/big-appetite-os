import openai
import json
import time
from typing import List, Dict, Any, Optional
from tenacity import retry, stop_after_attempt, wait_exponential
from .config import (
    OPENAI_API_KEY, OPENAI_ORG_ID, DEFAULT_MODEL, FALLBACK_MODEL,
    USE_SMART_ROUTING, TEMPERATURE, MAX_TOKENS, COMPLEXITY_THRESHOLD,
    MAX_RETRIES, TIMEOUT, TRACK_COSTS, LOG_MODEL_DECISIONS,
    PRICING, COMPLEXITY_WEIGHTS, CONTRADICTION_KEYWORDS, DRIVER_NAMES
)

class LLMClient:
    def __init__(self):
        """Initialize OpenAI client with API key"""
        self.client = openai.OpenAI(
            api_key=OPENAI_API_KEY,
            organization=OPENAI_ORG_ID
        )
        self.api_costs = []
        
    def calculate_complexity(self, text: str) -> float:
        """Calculate complexity score for model selection"""
        complexity = 0.0
        
        # Length factors
        if len(text) < 50:
            complexity += COMPLEXITY_WEIGHTS["length_short"]
        elif len(text) > 200:
            complexity += COMPLEXITY_WEIGHTS["length_long"]
        
        # Keyword complexity
        complex_keywords = ["however", "although", "despite", "nevertheless", "furthermore"]
        if any(keyword in text.lower() for keyword in complex_keywords):
            complexity += COMPLEXITY_WEIGHTS["keywords"]
        
        # Sentiment variance
        positive_words = ["love", "amazing", "perfect", "excellent", "fantastic"]
        negative_words = ["hate", "terrible", "awful", "disappointed", "worst"]
        has_positive = any(word in text.lower() for word in positive_words)
        has_negative = any(word in text.lower() for word in negative_words)
        if has_positive and has_negative:
            complexity += COMPLEXITY_WEIGHTS["sentiment_variance"]
        
        # No history (new actor)
        complexity += COMPLEXITY_WEIGHTS["no_history"]
        
        # Contradiction indicators
        if any(keyword in text.lower() for keyword in CONTRADICTION_KEYWORDS):
            complexity += COMPLEXITY_WEIGHTS["contradiction"]
        
        # Emotional content
        emotional_words = ["feel", "emotion", "excited", "worried", "anxious", "thrilled"]
        if any(word in text.lower() for word in emotional_words):
            complexity += COMPLEXITY_WEIGHTS["emotional"]
        
        # Technical language
        technical_words = ["algorithm", "optimization", "efficiency", "performance", "analysis"]
        if any(word in text.lower() for word in technical_words):
            complexity += COMPLEXITY_WEIGHTS["technical"]
        
        return min(complexity, 1.0)
    
    def select_model(self, text: str) -> str:
        """Select appropriate model based on complexity"""
        if not USE_SMART_ROUTING:
            return DEFAULT_MODEL
        
        complexity = self.calculate_complexity(text)
        
        if complexity > COMPLEXITY_THRESHOLD:
            model = FALLBACK_MODEL
        else:
            model = DEFAULT_MODEL
        
        if LOG_MODEL_DECISIONS:
            print(f"Complexity: {complexity:.2f}, Selected: {model}")
        
        return model
    
    @retry(stop=stop_after_attempt(MAX_RETRIES), wait=wait_exponential(multiplier=1, min=4, max=10))
    def analyze_with_llm(self, prompt: str, analysis_type: str, signal_text: str) -> Dict[str, Any]:
        """Analyze text using LLM with retry logic"""
        try:
            model = self.select_model(signal_text)
            
            response = self.client.chat.completions.create(
                model=model,
                messages=[
                    {"role": "system", "content": "You are a psychological analysis expert. Respond only with valid JSON."},
                    {"role": "user", "content": prompt}
                ],
                temperature=TEMPERATURE,
                max_tokens=MAX_TOKENS,
                response_format={"type": "json_object"}
            )
            
            # Parse response
            result = json.loads(response.choices[0].message.content)
            
            # Calculate costs
            input_tokens = response.usage.prompt_tokens
            output_tokens = response.usage.completion_tokens
            cost = self._calculate_cost(model, input_tokens, output_tokens)
            
            # Track costs
            if TRACK_COSTS:
                self.api_costs.append({
                    'model': model,
                    'input_tokens': input_tokens,
                    'output_tokens': output_tokens,
                    'cost': cost,
                    'analysis_type': analysis_type
                })
            
            return {
                'success': True,
                'result': result,
                'model_used': model,
                'api_cost': cost,
                'input_tokens': input_tokens,
                'output_tokens': output_tokens
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'model_used': None,
                'api_cost': 0.0
            }
    
    def _calculate_cost(self, model: str, input_tokens: int, output_tokens: int) -> float:
        """Calculate API cost based on token usage"""
        if model not in PRICING:
            return 0.0
        
        input_cost = (input_tokens / 1_000_000) * PRICING[model]["input"]
        output_cost = (output_tokens / 1_000_000) * PRICING[model]["output"]
        return input_cost + output_cost
    
    def _build_driver_analysis_prompt(self, signal_text: str, driver_ontology: List[Dict], actor_history: List[Dict]) -> str:
        """Build prompt for driver analysis"""
        drivers_info = "\n".join([
            f"- {driver['driver_name']}: {driver['core_meaning']} (Behaviors: {', '.join(driver['typical_behaviors'][:3])})"
            for driver in driver_ontology
        ])
        
        history_context = ""
        if actor_history:
            history_context = f"\n\nActor History:\n{json.dumps(actor_history[-3:], indent=2)}"
        
        return f"""Analyze this customer signal for psychological drivers:

Signal: "{signal_text}"

Available Drivers:
{drivers_info}

{history_context}

Return JSON with:
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
  "reasoning": "Why you assigned these probabilities"
}}

Ensure driver_distribution values sum to 1.0."""
    
    def _build_quantum_analysis_prompt(self, driver_distribution: Dict, driver_conflicts: List[Dict], signal_text: str) -> str:
        """Build prompt for quantum analysis"""
        conflicts_info = "\n".join([
            f"- {driver['driver_name']}: {driver['driver_dynamics']}"
            for driver in driver_conflicts
        ])
        
        return f"""Analyze quantum psychological effects:

Driver Distribution: {json.dumps(driver_distribution, indent=2)}
Signal: "{signal_text}"

Driver Conflicts:
{conflicts_info}

Return JSON with:
{{
  "superposition_detected": true/false,
  "interfering_drivers": ["driver1", "driver2"],
  "interference_strength": 0.0-1.0,
  "coherence": 0.0-1.0
}}"""
    
    def _build_identity_analysis_prompt(self, signal_text: str, context: Optional[Dict] = None) -> str:
        """Build prompt for identity analysis"""
        return f"""Analyze identity fragments in this signal:

Signal: "{signal_text}"

Return JSON with:
{{
  "primary_identity": "Provider/Explorer/Connoisseur/etc",
  "secondary_identity": "Secondary role or null",
  "identity_coherence": 0.0-1.0,
  "fragmentation_detected": true/false
}}"""
