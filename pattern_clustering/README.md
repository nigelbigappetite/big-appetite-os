# Pattern Analysis & Clustering System

A comprehensive customer segmentation system that analyzes psychological driver distributions to discover natural customer segments and generate actionable insights for targeted messaging.

## 🎯 Overview

This system processes 299 actor profiles with psychological driver data to:
- **Analyze patterns** in driver distributions, correlations, and contradictions
- **Discover segments** through multiple clustering algorithms
- **Characterize cohorts** with detailed behavioral profiles
- **Generate messaging strategies** tailored to each segment
- **Store results** in database for production use

## 🏗️ Architecture

### Core Components

1. **Pattern Analysis** (`pattern_analysis/`)
   - Data retrieval and preprocessing
   - Statistical analysis of driver distributions
   - Visualization generation
   - Comprehensive reporting

2. **Clustering Engine** (`clustering/`)
   - Feature preparation and validation
   - Multiple clustering algorithms (K-Means, DBSCAN, Hierarchical, GMM)
   - Cluster validation and quality assessment
   - Cohort characterization and messaging strategies

3. **Database Integration** (`clustering/database.py`)
   - Schema management for clustering results
   - Cohort and assignment storage
   - Query and retrieval functions

4. **Orchestration Scripts**
   - `run_pattern_analysis.py` - Complete pattern analysis
   - `run_clustering.py` - Clustering and segmentation

## 🚀 Quick Start

### Prerequisites

```bash
# Install dependencies
pip install -r requirements.txt

# Ensure environment variables are set
export SUPABASE_URL="your_supabase_url"
export SUPABASE_KEY="your_supabase_key"
```

### Run Pattern Analysis

```bash
# Analyze patterns in actor profiles
python run_pattern_analysis.py
```

**Outputs:**
- Statistical analysis of 299 actors
- 7 visualization files in `outputs/visualizations/`
- Comprehensive report in `outputs/reports/pattern_analysis_report.md`

### Run Clustering

```bash
# Discover customer segments
python run_clustering.py --algorithm all --n-clusters 7
```

**Options:**
- `--algorithm`: `kmeans`, `dbscan`, `hierarchical`, `gmm`, `all`
- `--n-clusters`: Number of clusters (default: 7)

**Outputs:**
- Discovered customer segments
- Cluster validation metrics
- Actor assignments
- Results saved to database

## 📊 Features

### Pattern Analysis

- **Driver Distribution Analysis**: Statistical analysis of 6 psychological drivers
- **Correlation Analysis**: Identify relationships between drivers
- **Contradiction Analysis**: Detect conflicting motivations
- **Quantum State Analysis**: Analyze superposition and coherence patterns
- **Visualization**: 7 comprehensive charts and graphs
- **Reporting**: Detailed markdown reports with business insights

### Clustering Algorithms

- **K-Means**: Spherical clusters with predefined k
- **DBSCAN**: Density-based clustering with outlier detection
- **Hierarchical**: Tree-based clustering with linkage analysis
- **Gaussian Mixture**: Probabilistic clustering with soft assignments

### Validation & Quality

- **Silhouette Score**: Cluster separation quality (-1 to 1)
- **Calinski-Harabasz**: Cluster density quality
- **Davies-Bouldin**: Cluster compactness quality
- **Cross-validation**: Train-test validation for generalization

### Cohort Characterization

- **Driver Profiles**: Mean driver distributions per cohort
- **Behavioral Signatures**: Signal patterns and data quality
- **Messaging Strategies**: Tone, themes, channels, timing
- **Identity Analysis**: Common identity markers and patterns

## 🗄️ Database Schema

### Tables Created

- `clusters.cohorts` - Discovered customer segments
- `clusters.actor_cohort_assignments` - Actor-to-cohort mappings
- `clusters.clustering_runs` - Clustering attempt history
- `clusters.cohort_history` - Cohort evolution tracking
- `clusters.pattern_analysis` - Pattern analysis results

### Key Functions

- `clusters.get_actor_cohort(actor_id)` - Get actor's assigned cohort
- `clusters.get_cohort_summary()` - Get all cohorts with statistics
- `clusters.update_cohort_history()` - Update cohort snapshots

## 📈 Usage Examples

### Basic Pattern Analysis

```python
from pattern_analysis import get_actor_profiles, analyze_driver_distributions

# Load actors
actors = get_actor_profiles(min_signals=1, include_quantum=True)

# Analyze patterns
driver_stats = analyze_driver_distributions(actors)
print(f"Dominant driver: {max(driver_stats['dominant_driver_counts'], key=driver_stats['dominant_driver_counts'].get)}")
```

### Clustering Analysis

```python
from clustering import prepare_feature_matrix, cluster_kmeans, characterize_clusters

# Prepare features
features, actor_ids, feature_names = prepare_feature_matrix(actors, {
    "include_drivers": True,
    "include_contradiction": True,
    "include_quantum": True,
    "normalize": True
})

# Cluster
result = cluster_kmeans(features, n_clusters=7)

# Characterize
cohorts = characterize_clusters(actors, result["labels"], features)
```

### Database Operations

```python
from clustering.database import save_cohorts, get_cohort_summary

# Save results
cohort_ids = save_cohorts(cohorts, run_id)

# Retrieve summary
summary = get_cohort_summary()
```

## 🎨 Visualizations

The system generates 7 comprehensive visualizations:

1. **Driver Averages** - Bar chart of mean driver distribution
2. **Driver Distributions** - Histograms for each driver (6 subplots)
3. **Correlation Heatmap** - Driver correlation matrix
4. **Contradiction Distribution** - Histogram of contradiction scores
5. **Dominant Driver Pie** - Pie chart of dominant driver distribution
6. **Quantum Prevalence** - Bar chart of superposition by driver
7. **Scatter Matrix** - Pairwise scatter plots for drivers

## 📋 Configuration

### Feature Configuration

```python
feature_config = {
    "include_drivers": True,      # 6 psychological drivers
    "include_contradiction": True, # Contradiction scores
    "include_quantum": True,      # Quantum state data
    "normalize": True             # Min-max normalization
}
```

### Clustering Parameters

```python
# K-Means
kmeans_config = {
    "n_clusters": 7,
    "random_state": 42,
    "max_iter": 300
}

# DBSCAN
dbscan_config = {
    "eps": 0.3,
    "min_samples": 10
}
```

## 🔧 Advanced Usage

### Custom Clustering

```python
from clustering.algorithms import run_all_algorithms

# Run all algorithms
results = run_all_algorithms(features, n_clusters=7)

# Compare results
from clustering.validation import compare_clustering_results
best = compare_clustering_results(results)
```

### Feature Selection

```python
from clustering.feature_preparation import suggest_feature_selection

# Get recommended features
recommended = suggest_feature_selection(features, feature_names, max_features=8)
```

### Assignment Validation

```python
from clustering.assignment import validate_assignment_quality

# Validate assignments
quality = validate_assignment_quality(assignments)
print(f"Quality score: {quality['quality_score']:.3f}")
```

## 📊 Output Examples

### Pattern Analysis Report

```markdown
# Customer Pattern Analysis Report

## Executive Summary
- Total Actors: 299
- Dominant Driver: Safety (45.2%)
- High Contradiction: 23 actors (7.7%)
- Quantum Data: Available

## Key Findings
- Safety is the most prominent psychological driver
- Strong positive correlation between Connection and Purpose
- 7.7% of customers show high internal contradictions
```

### Clustering Results

```
✅ Clustering Complete!

🎯 Discovered 7 customer segments:
  1. Safety-Focused: 89 actors (29.8%)
  2. Connection-Seekers: 67 actors (22.4%)
  3. Status-Oriented: 45 actors (15.1%)
  4. Growth-Minded: 38 actors (12.7%)
  5. Freedom-Lovers: 32 actors (10.7%)
  6. Purpose-Driven: 18 actors (6.0%)
  7. High-Contradiction: 10 actors (3.3%)

📊 Quality Metrics:
   • Silhouette Score: 0.456
   • Calinski-Harabasz: 234.7
   • Davies-Bouldin: 1.234
```

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection Error**
   ```bash
   # Check environment variables
   echo $SUPABASE_URL
   echo $SUPABASE_KEY
   ```

2. **Insufficient Data**
   ```python
   # Check actor count
   actors = get_actor_profiles()
   print(f"Loaded {len(actors)} actors")
   ```

3. **Clustering Quality Issues**
   ```python
   # Try different parameters
   result = cluster_kmeans(features, n_clusters=5)  # Try fewer clusters
   result = cluster_dbscan(features, eps=0.5)       # Try different eps
   ```

### Performance Optimization

- Use `normalize=True` for better clustering results
- Adjust `min_samples` for DBSCAN based on data size
- Consider feature selection for large datasets

## 📚 API Reference

### Pattern Analysis

- `get_actor_profiles(min_signals=1, include_quantum=True)` - Load actor data
- `analyze_driver_distributions(actors)` - Statistical analysis
- `analyze_contradictions(actors)` - Contradiction analysis
- `create_all_visualizations(actors, ...)` - Generate charts

### Clustering

- `prepare_feature_matrix(actors, config)` - Feature extraction
- `cluster_kmeans(features, n_clusters=7)` - K-Means clustering
- `validate_clustering(features, labels)` - Quality validation
- `characterize_clusters(actors, labels, features)` - Cohort analysis

### Database

- `save_clustering_run(...)` - Save clustering results
- `save_cohorts(cohorts, run_id)` - Save discovered cohorts
- `get_cohort_summary()` - Retrieve cohort data

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is part of the Big Appetite OS Intelligence Layer.

## 🆘 Support

For questions or issues:
1. Check the troubleshooting section
2. Review the API reference
3. Check database connectivity
4. Verify data quality

---

*Built for Big Appetite OS - Advanced Customer Intelligence Platform*
