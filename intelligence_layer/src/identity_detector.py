from .llm_client import LLMClient
from .config import IDENTITY_ARCHETYPES
import json

def detect_identity_fragments(signal_text, context=None):
    """
    Detect identity fragments and role identities from signals.
    
    Args:
        signal_text (str): The signal text to analyze
        context (dict, optional): Additional context information
    
    Returns:
        dict: Identity analysis results
    """
    try:
        # Initialize LLM client
        llm_client = LLMClient()
        
        # Build prompt for identity analysis
        prompt = llm_client._build_identity_analysis_prompt(signal_text, context)
        
        # Get LLM response
        response = llm_client.analyze_with_llm(
            prompt,
            "identity_analysis",
            signal_text
        )
        
        if not response['success']:
            return {
                'success': False,
                'error': response['error'],
                'primary_identity': 'Unknown',
                'secondary_identity': 'Unknown',
                'identity_coherence': 0.0,
                'fragmentation_detected': False
            }
        
        # Parse response
        result = response['result']
        
        return {
            'success': True,
            'primary_identity': result.get('primary_identity', 'Unknown'),
            'secondary_identity': result.get('secondary_identity', 'Unknown'),
            'identity_coherence': result.get('identity_coherence', 0.0),
            'fragmentation_detected': result.get('fragmentation_detected', False),
            'model_used': response.get('model_used'),
            'api_cost': response.get('api_cost', 0.0)
        }
        
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'primary_identity': 'Unknown',
            'secondary_identity': 'Unknown',
            'identity_coherence': 0.0,
            'fragmentation_detected': False
        }
