from .database import DatabaseManager
from .llm_client import LLMClient
from .config import DRIVER_NAMES
import json

def analyze_signal(signal_text, context=None):
    """
    Analyze a signal to infer psychological driver probabilities.
    
    Args:
        signal_text (str): The raw signal text to analyze
        context (dict, optional): Additional context information
    
    Returns:
        dict: Analysis results with driver distribution and metadata
    """
    try:
        # Initialize clients
        db = DatabaseManager()
        llm_client = LLMClient()
        
        # Get driver ontology
        driver_ontology = db.get_driver_ontology()
        if not driver_ontology:
            return {
                'success': False,
                'error': 'Failed to get driver ontology',
                'driver_distribution': {driver: 0.0 for driver in DRIVER_NAMES},
                'dominant_driver': 'Safety',
                'confidence': 0.0,
                'reasoning': 'No driver data available'
            }
        
        # Build prompt for driver analysis
        prompt = llm_client._build_driver_analysis_prompt(
            signal_text, driver_ontology, []
        )
        
        # Get LLM response
        response = llm_client.analyze_with_llm(
            prompt, 
            "driver_analysis",
            signal_text
        )
        
        if not response['success']:
            return {
                'success': False,
                'error': response['error'],
                'driver_distribution': {driver: 0.0 for driver in DRIVER_NAMES},
                'dominant_driver': 'Safety',
                'confidence': 0.0,
                'reasoning': f'LLM analysis failed: {response["error"]}'
            }
        
        # Parse response
        result = response['result']
        driver_distribution = result.get('driver_distribution', {})
        
        # Ensure all drivers are present and sum to 1.0
        total = sum(driver_distribution.values())
        if total > 0:
            driver_distribution = {k: v/total for k, v in driver_distribution.items()}
        else:
            driver_distribution = {driver: 1.0/len(DRIVER_NAMES) for driver in DRIVER_NAMES}
        
        # Find dominant driver
        dominant_driver = max(driver_distribution, key=driver_distribution.get)
        
        return {
            'success': True,
            'driver_distribution': driver_distribution,
            'dominant_driver': dominant_driver,
            'confidence': result.get('confidence', 0.5),
            'reasoning': result.get('reasoning', 'Analysis completed'),
            'model_used': response.get('model_used'),
            'api_cost': response.get('api_cost', 0.0)
        }
        
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'driver_distribution': {driver: 0.0 for driver in DRIVER_NAMES},
            'dominant_driver': 'Safety',
            'confidence': 0.0,
            'reasoning': f'Analysis failed: {str(e)}'
        }
