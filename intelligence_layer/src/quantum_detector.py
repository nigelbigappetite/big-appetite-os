from .database import DatabaseManager
from .llm_client import LLMClient
import json

def detect_quantum_effects(driver_distribution, signal_text=None, context=None):
    """
    Detect quantum psychological effects like superposition and entanglement.
    
    Args:
        driver_distribution (dict): Current driver probability distribution
        signal_text (str, optional): Signal text for context
        context (dict, optional): Additional context information
    
    Returns:
        dict: Quantum effects analysis
    """
    try:
        # Initialize clients
        db = DatabaseManager()
        llm_client = LLMClient()
        
        # Get driver conflicts
        driver_conflicts = db.get_driver_conflicts()
        if not driver_conflicts:
            return {
                'success': False,
                'error': 'Failed to get driver conflicts',
                'superposition_detected': False,
                'interfering_drivers': [],
                'interference_strength': 0.0,
                'coherence': 0.0
            }
        
        # Build prompt for quantum analysis
        prompt = llm_client._build_quantum_analysis_prompt(
            driver_distribution, driver_conflicts, signal_text
        )
        
        # Get LLM response
        response = llm_client.analyze_with_llm(
            prompt,
            "quantum_analysis", 
            signal_text or "quantum analysis"
        )
        
        if not response['success']:
            return {
                'success': False,
                'error': response['error'],
                'superposition_detected': False,
                'interfering_drivers': [],
                'interference_strength': 0.0,
                'coherence': 0.0
            }
        
        # Parse response
        result = response['result']
        
        return {
            'success': True,
            'superposition_detected': result.get('superposition_detected', False),
            'interfering_drivers': result.get('interfering_drivers', []),
            'interference_strength': result.get('interference_strength', 0.0),
            'coherence': result.get('coherence', 0.0),
            'model_used': response.get('model_used'),
            'api_cost': response.get('api_cost', 0.0)
        }
        
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'superposition_detected': False,
            'interfering_drivers': [],
            'interference_strength': 0.0,
            'coherence': 0.0
        }
