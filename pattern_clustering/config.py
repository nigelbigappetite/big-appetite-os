"""
Configuration Module for Pattern Analysis & Clustering

Centralized configuration for all clustering and pattern analysis parameters.
"""

import os
from pathlib import Path

# =====================================================
# PATHS AND DIRECTORIES
# =====================================================

# Base paths
ROOT_DIR = Path(__file__).parent
OUTPUT_DIR = ROOT_DIR / "outputs"
VISUALIZATIONS_DIR = OUTPUT_DIR / "visualizations"
REPORTS_DIR = OUTPUT_DIR / "reports"

# Create directories if they don't exist
OUTPUT_DIR.mkdir(exist_ok=True)
VISUALIZATIONS_DIR.mkdir(exist_ok=True)
REPORTS_DIR.mkdir(exist_ok=True)

# =====================================================
# DATABASE CONFIGURATION
# =====================================================

# Database connection (inherited from intelligence_layer)
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Default brand ID (for single-brand setup)
DEFAULT_BRAND_ID = "a1b2c3d4-e5f6-7890-1234-567890abcdef"

# =====================================================
# FEATURE CONFIGURATION
# =====================================================

# Default feature configuration
DEFAULT_FEATURE_CONFIG = {
    "include_drivers": True,
    "include_contradiction": True,
    "include_quantum": True,  # Use with 299+ actors
    "normalize": True
}

# Feature names
DRIVER_FEATURES = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
QUANTUM_FEATURES = ['superposition_strength', 'coherence']
CONTRADICTION_FEATURES = ['contradiction_score']

# =====================================================
# CLUSTERING PARAMETERS
# =====================================================

# K-Means parameters
KMEANS_K_RANGE = [3, 5, 7, 10]
KMEANS_DEFAULT_K = 7
KMEANS_RANDOM_STATE = 42
KMEANS_MAX_ITER = 300
KMEANS_N_INIT = 10

# DBSCAN parameters
DBSCAN_EPS = 0.3
DBSCAN_MIN_SAMPLES = 10
DBSCAN_METRIC = 'euclidean'

# Hierarchical parameters
HIERARCHICAL_LINKAGE = 'ward'
HIERARCHICAL_DEFAULT_K = 7

# Gaussian Mixture parameters
GMM_DEFAULT_COMPONENTS = 7
GMM_RANDOM_STATE = 42
GMM_MAX_ITER = 200
GMM_COVARIANCE_TYPE = 'full'

# =====================================================
# VALIDATION THRESHOLDS
# =====================================================

# Silhouette score thresholds
MIN_SILHOUETTE_SCORE = 0.3
EXCELLENT_SILHOUETTE = 0.5
GOOD_SILHOUETTE = 0.3
FAIR_SILHOUETTE = 0.2

# Cluster size thresholds
MIN_CLUSTER_SIZE = 10
MAX_CLUSTER_SIZE = 100  # Maximum actors per cluster

# Assignment confidence thresholds
HIGH_CONFIDENCE_THRESHOLD = 0.7
MEDIUM_CONFIDENCE_THRESHOLD = 0.4

# =====================================================
# VISUALIZATION CONFIGURATION
# =====================================================

# Figure settings
FIGURE_SIZE = (12, 8)
DPI = 300
COLOR_PALETTE = "viridis"

# Chart colors
CHART_COLORS = {
    'primary': '#1f77b4',
    'secondary': '#ff7f0e',
    'success': '#2ca02c',
    'warning': '#d62728',
    'info': '#9467bd',
    'light': '#8c564b',
    'dark': '#e377c2'
}

# =====================================================
# MESSAGING STRATEGY CONFIGURATION
# =====================================================

# Driver-based messaging themes
DRIVER_THEMES = {
    'Safety': ['security', 'reliability', 'trust', 'protection', 'stability'],
    'Connection': ['community', 'relationships', 'belonging', 'social', 'togetherness'],
    'Status': ['prestige', 'recognition', 'exclusivity', 'achievement', 'success'],
    'Growth': ['learning', 'development', 'improvement', 'progress', 'potential'],
    'Freedom': ['independence', 'choice', 'flexibility', 'autonomy', 'liberation'],
    'Purpose': ['meaning', 'impact', 'contribution', 'values', 'mission']
}

# Messaging tones
MESSAGING_TONES = {
    'Safety': 'reassuring and trustworthy',
    'Connection': 'warm and community-focused',
    'Status': 'sophisticated and exclusive',
    'Growth': 'inspiring and educational',
    'Freedom': 'liberating and empowering',
    'Purpose': 'meaningful and impactful'
}

# Channel recommendations
CHANNEL_RECOMMENDATIONS = {
    'Safety': ['Email', 'Website', 'Phone'],
    'Connection': ['Social Media', 'Community Forums', 'Email'],
    'Status': ['Premium Channels', 'Exclusive Events', 'Website'],
    'Growth': ['Educational Content', 'Webinars', 'Email'],
    'Freedom': ['Mobile App', 'Self-Service', 'Website'],
    'Purpose': ['Storytelling', 'Social Media', 'Email']
}

# =====================================================
# COHORT NAMING CONFIGURATION
# =====================================================

# Cohort name templates
COHORT_NAME_TEMPLATES = {
    'high_contradiction': 'High-Contradiction {driver}',
    'quantum': 'Quantum {driver}',
    'focused': '{driver}-Focused',
    'balanced': 'Balanced {driver}',
    'mixed': 'Mixed {driver}'
}

# Contradiction thresholds for naming
HIGH_CONTRADICTION_THRESHOLD = 0.6
QUANTUM_PREVALENCE_THRESHOLD = 30
FOCUSED_DRIVER_THRESHOLD = 0.7

# =====================================================
# DATA QUALITY CONFIGURATION
# =====================================================

# Minimum data requirements
MIN_ACTORS_FOR_ANALYSIS = 10
MIN_ACTORS_FOR_CLUSTERING = 50
MIN_SIGNALS_PER_ACTOR = 1  # Adjusted for current data

# Data quality thresholds
EXCELLENT_QUALITY_THRESHOLD = 0.8
GOOD_QUALITY_THRESHOLD = 0.6
FAIR_QUALITY_THRESHOLD = 0.4

# =====================================================
# LOGGING CONFIGURATION
# =====================================================

# Log levels
LOG_LEVEL = 'INFO'
LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

# Log files
LOG_DIR = OUTPUT_DIR / "logs"
LOG_DIR.mkdir(exist_ok=True)
LOG_FILE = LOG_DIR / "clustering.log"

# =====================================================
# PERFORMANCE CONFIGURATION
# =====================================================

# Parallel processing
USE_PARALLEL = True
MAX_WORKERS = 4

# Memory management
CHUNK_SIZE = 1000  # For processing large datasets
CACHE_SIZE = 100   # For caching intermediate results

# =====================================================
# EXPERIMENTAL FEATURES
# =====================================================

# Enable experimental features
ENABLE_QUANTUM_ANALYSIS = True
ENABLE_ADVANCED_VALIDATION = True
ENABLE_AUTO_TUNING = False

# Advanced clustering algorithms
ENABLE_SPECTRAL_CLUSTERING = False
ENABLE_OPTICS_CLUSTERING = False

# =====================================================
# VALIDATION FUNCTIONS
# =====================================================

def validate_config():
    """Validate configuration parameters."""
    errors = []
    
    # Check required environment variables
    if not SUPABASE_URL:
        errors.append("SUPABASE_URL environment variable not set")
    
    if not SUPABASE_KEY:
        errors.append("SUPABASE_KEY environment variable not set")
    
    # Check parameter ranges
    if KMEANS_DEFAULT_K < 2 or KMEANS_DEFAULT_K > 20:
        errors.append("KMEANS_DEFAULT_K must be between 2 and 20")
    
    if DBSCAN_EPS <= 0 or DBSCAN_EPS > 1:
        errors.append("DBSCAN_EPS must be between 0 and 1")
    
    if DBSCAN_MIN_SAMPLES < 2:
        errors.append("DBSCAN_MIN_SAMPLES must be at least 2")
    
    # Check thresholds
    if MIN_SILHOUETTE_SCORE < -1 or MIN_SILHOUETTE_SCORE > 1:
        errors.append("MIN_SILHOUETTE_SCORE must be between -1 and 1")
    
    if len(errors) > 0:
        raise ValueError(f"Configuration validation failed: {'; '.join(errors)}")
    
    return True

def get_feature_config(include_quantum: bool = None) -> dict:
    """Get feature configuration with optional quantum override."""
    config = DEFAULT_FEATURE_CONFIG.copy()
    
    if include_quantum is not None:
        config['include_quantum'] = include_quantum
    
    return config

def get_clustering_config(algorithm: str) -> dict:
    """Get clustering configuration for specific algorithm."""
    configs = {
        'kmeans': {
            'n_clusters': KMEANS_DEFAULT_K,
            'random_state': KMEANS_RANDOM_STATE,
            'max_iter': KMEANS_MAX_ITER,
            'n_init': KMEANS_N_INIT
        },
        'dbscan': {
            'eps': DBSCAN_EPS,
            'min_samples': DBSCAN_MIN_SAMPLES,
            'metric': DBSCAN_METRIC
        },
        'hierarchical': {
            'n_clusters': HIERARCHICAL_DEFAULT_K,
            'linkage': HIERARCHICAL_LINKAGE
        },
        'gmm': {
            'n_components': GMM_DEFAULT_COMPONENTS,
            'random_state': GMM_RANDOM_STATE,
            'max_iter': GMM_MAX_ITER,
            'covariance_type': GMM_COVARIANCE_TYPE
        }
    }
    
    return configs.get(algorithm, {})

# Validate configuration on import
if __name__ != "__main__":
    try:
        validate_config()
    except ValueError as e:
        print(f"Configuration error: {e}")
        print("Please check your environment variables and configuration settings.")
