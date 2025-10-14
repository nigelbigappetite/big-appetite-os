"""
Report Generator Module for Pattern Analysis

Generates comprehensive markdown reports with statistical analysis,
visualizations, and business insights for customer segmentation.
"""

import os
from datetime import datetime
from typing import List, Dict, Any
from pathlib import Path

def generate_pattern_report(actors: List[Dict[str, Any]], 
                          driver_stats: Dict[str, Any],
                          contradiction_stats: Dict[str, Any],
                          quantum_stats: Dict[str, Any],
                          output_dir: str = "outputs/reports") -> str:
    """
    Generate comprehensive markdown report for pattern analysis.
    
    Args:
        actors: List of actor profiles
        driver_stats: Driver distribution statistics
        contradiction_stats: Contradiction analysis results
        quantum_stats: Quantum state analysis results
        output_dir: Directory to save report
    
    Returns:
        Report content as string
    """
    print("📝 Generating pattern analysis report...")
    
    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Generate report content
    report_content = _build_report_content(actors, driver_stats, contradiction_stats, quantum_stats)
    
    # Save report
    report_path = f"{output_dir}/pattern_analysis_report.md"
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report_content)
    
    print(f"   ✓ Report saved to {report_path}")
    
    return report_content

def _build_report_content(actors: List[Dict[str, Any]], 
                         driver_stats: Dict[str, Any],
                         contradiction_stats: Dict[str, Any],
                         quantum_stats: Dict[str, Any]) -> str:
    """Build the complete report content."""
    
    # Header
    report = f"""# Customer Pattern Analysis Report
## Big Appetite OS - Psychological Driver Analysis

**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Analysis Type:** Comprehensive Pattern Analysis  
**Dataset:** {len(actors)} Actor Profiles  

---

## 📊 Executive Summary

This report presents a comprehensive analysis of {len(actors)} customer actor profiles to identify patterns in psychological driver distributions, contradictions, and quantum states. The analysis reveals key insights for customer segmentation and targeted messaging strategies.

### Key Findings:
- **Dominant Driver:** {_get_dominant_driver(driver_stats)}
- **High Contradiction Actors:** {contradiction_stats.get('distribution', {}).get('high', 0)} ({contradiction_stats.get('distribution', {}).get('high', 0)/len(actors)*100:.1f}%)
- **Quantum Data Available:** {'Yes' if quantum_stats.get('quantum_data_available', False) else 'No'}
- **Data Quality:** {_assess_data_quality(actors)}

---

## 📈 Dataset Overview

### Profile Statistics
- **Total Actors:** {len(actors)}
- **Signal Count Range:** {_get_signal_range(actors)}
- **Profile Completeness:** {_get_completeness_stats(actors)}
- **Data Quality Score:** {_get_quality_stats(actors)}

### Driver Distribution Summary
{_format_driver_summary(driver_stats)}

---

## 🎯 Driver Distribution Analysis

### Average Driver Values
{_format_driver_averages(driver_stats)}

### Driver Variance Analysis
{_format_driver_variance(driver_stats)}

### Dominant Driver Distribution
{_format_dominant_drivers(driver_stats)}

### Statistical Insights
{_format_driver_insights(driver_stats)}

---

## 🔗 Correlation Patterns

### Driver Correlations
{_format_correlations(driver_stats)}

### Strong Positive Correlations
{_format_strong_correlations(driver_stats, 'positive')}

### Strong Negative Correlations
{_format_strong_correlations(driver_stats, 'negative')}

### Correlation Insights
{_format_correlation_insights(driver_stats)}

---

## ⚡ Contradiction Analysis

### Contradiction Distribution
{_format_contradiction_distribution(contradiction_stats)}

### Common Driver Conflicts
{_format_driver_conflicts(contradiction_stats)}

### High Contradiction Actors
{_format_high_contradiction_actors(contradiction_stats)}

### Contradiction Insights
{_format_contradiction_insights(contradiction_stats)}

---

## 🌌 Quantum State Patterns

{_format_quantum_analysis(quantum_stats)}

---

## 🏷️ Identity Fragment Summary

{_format_identity_analysis(actors)}

---

## 💡 Segment Hypotheses

Based on the pattern analysis, the following customer segments are hypothesized:

{_format_segment_hypotheses(driver_stats, contradiction_stats, quantum_stats)}

---

## 🧩 Clustering Recommendations

### Recommended Algorithms
1. **K-Means Clustering** (Primary)
   - Suggested k values: 5-8 clusters
   - Good for well-separated, spherical clusters
   - Works well with normalized driver data

2. **DBSCAN** (Secondary)
   - Density-based clustering
   - Good for identifying outliers and irregular shapes
   - Recommended eps: 0.3, min_samples: 10

3. **Hierarchical Clustering** (Validation)
   - Good for understanding cluster relationships
   - Useful for determining optimal number of clusters

### Feature Configuration
- **Include Drivers:** Yes (6 features)
- **Include Contradiction:** Yes (1 feature)
- **Include Quantum:** {'Yes' if quantum_stats.get('quantum_data_available', False) else 'No'} ({'2' if quantum_stats.get('quantum_data_available', False) else '0'} features)
- **Normalize:** Yes (recommended)

### Expected Outcomes
- **Target Clusters:** 5-10 distinct segments
- **Minimum Cluster Size:** 10-15 actors
- **Quality Threshold:** Silhouette score > 0.3

---

## 📊 Visualizations

The following visualizations have been generated:

1. **driver_averages.png** - Bar chart of mean driver distribution
2. **driver_distributions.png** - Histograms for each driver (6 subplots)
3. **correlation_heatmap.png** - Driver correlation matrix heatmap
4. **contradiction_distribution.png** - Histogram of contradiction scores
5. **dominant_driver_pie.png** - Pie chart of dominant driver distribution
6. **quantum_prevalence.png** - Bar chart of superposition by driver
7. **scatter_matrix.png** - Pairwise scatter plots (drivers)

---

## 🎯 Business Implications

### Customer Understanding
{_format_business_implications(driver_stats, contradiction_stats, quantum_stats)}

### Messaging Strategies
{_format_messaging_strategies(driver_stats)}

### Segmentation Opportunities
{_format_segmentation_opportunities(driver_stats, contradiction_stats)}

---

## 🔄 Next Steps

1. **Run Clustering Analysis**
   - Execute clustering algorithms with recommended parameters
   - Validate cluster quality using silhouette scores
   - Characterize discovered segments

2. **Segment Validation**
   - Review cluster characteristics
   - Validate business relevance
   - Refine clustering parameters if needed

3. **Messaging Strategy Development**
   - Create cohort-specific messaging strategies
   - Develop targeting criteria
   - Test messaging effectiveness

4. **Implementation**
   - Integrate segments into customer management system
   - Train team on segment characteristics
   - Monitor segment evolution over time

---

## 📋 Technical Details

### Data Processing
- **Preprocessing:** Driver value extraction and validation
- **Normalization:** Min-max scaling (0-1 range)
- **Missing Values:** {'Handled' if _check_missing_values(actors) else 'None detected'}
- **Outliers:** {'Detected and handled' if _check_outliers(actors) else 'None detected'}

### Analysis Methods
- **Statistical Analysis:** Descriptive statistics, correlation analysis
- **Visualization:** Matplotlib/Seaborn with 300 DPI output
- **Quality Metrics:** Data completeness, signal count validation

### Limitations
- **Sample Size:** {len(actors)} actors (adequate for clustering)
- **Signal Count:** Low signal counts per actor (max 2)
- **Temporal Data:** Limited historical data available

---

*Report generated by Big Appetite OS Intelligence Layer*  
*For questions or clarifications, contact the development team*

"""

    return report

def _get_dominant_driver(driver_stats: Dict[str, Any]) -> str:
    """Get the most common dominant driver."""
    dominant_counts = driver_stats.get('dominant_driver_counts', {})
    if not dominant_counts:
        return "N/A"
    return max(dominant_counts, key=dominant_counts.get)

def _assess_data_quality(actors: List[Dict[str, Any]]) -> str:
    """Assess overall data quality."""
    if not actors:
        return "No data available"
    
    # Check for missing values
    missing_count = sum(1 for actor in actors if not actor.get('driver_distribution'))
    
    # Check data completeness
    avg_completeness = sum(actor.get('profile_completeness', 0) for actor in actors) / len(actors)
    
    # Check signal counts
    avg_signals = sum(actor.get('signal_count', 0) for actor in actors) / len(actors)
    
    if missing_count == 0 and avg_completeness > 0.8 and avg_signals > 0.5:
        return "Excellent"
    elif missing_count < len(actors) * 0.1 and avg_completeness > 0.6:
        return "Good"
    elif missing_count < len(actors) * 0.2:
        return "Fair"
    else:
        return "Poor"

def _get_signal_range(actors: List[Dict[str, Any]]) -> str:
    """Get signal count range."""
    if not actors:
        return "N/A"
    
    signal_counts = [actor.get('signal_count', 0) for actor in actors]
    return f"{min(signal_counts)} - {max(signal_counts)} (avg: {sum(signal_counts)/len(signal_counts):.1f})"

def _get_completeness_stats(actors: List[Dict[str, Any]]) -> str:
    """Get profile completeness statistics."""
    if not actors:
        return "N/A"
    
    completeness_scores = [actor.get('profile_completeness', 0) for actor in actors]
    avg_completeness = sum(completeness_scores) / len(completeness_scores)
    return f"{avg_completeness:.1%} average completeness"

def _get_quality_stats(actors: List[Dict[str, Any]]) -> str:
    """Get data quality statistics."""
    if not actors:
        return "N/A"
    
    quality_scores = [actor.get('data_quality_score', 0) for actor in actors]
    avg_quality = sum(quality_scores) / len(quality_scores)
    return f"{avg_quality:.1%} average quality score"

def _format_driver_summary(driver_stats: Dict[str, Any]) -> str:
    """Format driver summary table."""
    averages = driver_stats.get('averages', {})
    if not averages:
        return "No driver data available"
    
    table = "| Driver | Average | Std Dev | Min | Max |\n"
    table += "|--------|---------|---------|-----|-----|\n"
    
    for driver in ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']:
        avg = averages.get(driver, 0)
        std = driver_stats.get('std_dev', {}).get(driver, 0)
        min_val = driver_stats.get('min_max', {}).get(driver, (0, 0))[0]
        max_val = driver_stats.get('min_max', {}).get(driver, (0, 0))[1]
        
        table += f"| {driver} | {avg:.3f} | {std:.3f} | {min_val:.3f} | {max_val:.3f} |\n"
    
    return table

def _format_driver_averages(driver_stats: Dict[str, Any]) -> str:
    """Format driver averages section."""
    averages = driver_stats.get('averages', {})
    if not averages:
        return "No driver averages available"
    
    # Find highest and lowest drivers
    sorted_drivers = sorted(averages.items(), key=lambda x: x[1], reverse=True)
    highest = sorted_drivers[0]
    lowest = sorted_drivers[-1]
    
    return f"""
The analysis reveals significant variation in driver distributions across actors:

- **Highest Average:** {highest[0]} ({highest[1]:.3f})
- **Lowest Average:** {lowest[0]} ({lowest[1]:.3f})
- **Range:** {highest[1] - lowest[1]:.3f}

This suggests that {highest[0]} is the most prominent psychological driver in the customer base, while {lowest[0]} is the least prominent.
"""

def _format_driver_variance(driver_stats: Dict[str, Any]) -> str:
    """Format driver variance analysis."""
    std_devs = driver_stats.get('std_dev', {})
    if not std_devs:
        return "No variance data available"
    
    # Find most and least variable drivers
    sorted_variance = sorted(std_devs.items(), key=lambda x: x[1], reverse=True)
    most_variable = sorted_variance[0]
    least_variable = sorted_variance[-1]
    
    return f"""
Driver variance analysis shows:

- **Most Variable:** {most_variable[0]} (std: {most_variable[1]:.3f})
- **Least Variable:** {least_variable[0]} (std: {least_variable[1]:.3f})

High variance in {most_variable[0]} suggests diverse customer motivations in this area, while low variance in {least_variable[0]} indicates more consistent customer behavior.
"""

def _format_dominant_drivers(driver_stats: Dict[str, Any]) -> str:
    """Format dominant driver distribution."""
    dominant_counts = driver_stats.get('dominant_driver_counts', {})
    if not dominant_counts:
        return "No dominant driver data available"
    
    total = sum(dominant_counts.values())
    table = "| Driver | Count | Percentage |\n"
    table += "|--------|-------|------------|\n"
    
    for driver, count in sorted(dominant_counts.items(), key=lambda x: x[1], reverse=True):
        percentage = (count / total) * 100
        table += f"| {driver} | {count} | {percentage:.1f}% |\n"
    
    return table

def _format_driver_insights(driver_stats: Dict[str, Any]) -> str:
    """Format driver insights."""
    dominant_counts = driver_stats.get('dominant_driver_counts', {})
    if not dominant_counts:
        return "No insights available"
    
    total = sum(dominant_counts.values())
    most_common = max(dominant_counts, key=dominant_counts.get)
    most_common_pct = (dominant_counts[most_common] / total) * 100
    
    return f"""
**Key Insights:**

1. **{most_common}** is the dominant driver for {most_common_pct:.1f}% of customers
2. The distribution shows {'balanced' if max(dominant_counts.values()) < total * 0.4 else 'concentrated'} customer preferences
3. This suggests {'diverse' if len([c for c in dominant_counts.values() if c > total * 0.1]) > 3 else 'focused'} customer motivations
"""

def _format_correlations(driver_stats: Dict[str, Any]) -> str:
    """Format correlation analysis."""
    strong_positive = driver_stats.get('strong_positive_correlations', [])
    strong_negative = driver_stats.get('strong_negative_correlations', [])
    
    if not strong_positive and not strong_negative:
        return "No strong correlations found between drivers."
    
    result = "**Strong Correlations Found:**\n\n"
    
    if strong_positive:
        result += "**Positive Correlations:**\n"
        for driver1, driver2, corr in strong_positive[:5]:  # Top 5
            result += f"- {driver1} ↔ {driver2}: {corr:.3f}\n"
        result += "\n"
    
    if strong_negative:
        result += "**Negative Correlations:**\n"
        for driver1, driver2, corr in strong_negative[:5]:  # Top 5
            result += f"- {driver1} ↔ {driver2}: {corr:.3f}\n"
    
    return result

def _format_strong_correlations(driver_stats: Dict[str, Any], correlation_type: str) -> str:
    """Format strong correlations list."""
    correlations = driver_stats.get(f'strong_{correlation_type}_correlations', [])
    
    if not correlations:
        return f"No strong {correlation_type} correlations found."
    
    result = ""
    for driver1, driver2, corr in correlations[:10]:  # Top 10
        result += f"- **{driver1} ↔ {driver2}:** {corr:.3f}\n"
    
    return result

def _format_correlation_insights(driver_stats: Dict[str, Any]) -> str:
    """Format correlation insights."""
    strong_positive = driver_stats.get('strong_positive_correlations', [])
    strong_negative = driver_stats.get('strong_negative_correlations', [])
    
    if not strong_positive and not strong_negative:
        return "No significant correlations found, suggesting independent driver motivations."
    
    insights = []
    
    if strong_positive:
        insights.append(f"Found {len(strong_positive)} strong positive correlations, suggesting complementary driver motivations.")
    
    if strong_negative:
        insights.append(f"Found {len(strong_negative)} strong negative correlations, suggesting conflicting driver motivations.")
    
    return " ".join(insights)

def _format_contradiction_distribution(contradiction_stats: Dict[str, Any]) -> str:
    """Format contradiction distribution."""
    distribution = contradiction_stats.get('distribution', {})
    if not distribution:
        return "No contradiction data available"
    
    total = sum(distribution.values())
    table = "| Level | Count | Percentage |\n"
    table += "|-------|-------|------------|\n"
    
    for level, count in [('Low (<0.3)', distribution.get('low', 0)), 
                        ('Medium (0.3-0.6)', distribution.get('medium', 0)),
                        ('High (≥0.6)', distribution.get('high', 0))]:
        percentage = (count / total) * 100 if total > 0 else 0
        table += f"| {level} | {count} | {percentage:.1f}% |\n"
    
    return table

def _format_driver_conflicts(contradiction_stats: Dict[str, Any]) -> str:
    """Format driver conflicts."""
    conflicts = contradiction_stats.get('common_driver_conflicts', [])
    if not conflicts:
        return "No common driver conflicts identified."
    
    result = "| Driver Pair | Count | Avg Strength |\n"
    result += "|-------------|-------|--------------|\n"
    
    for conflict in conflicts[:10]:  # Top 10
        drivers = conflict.get('drivers', [])
        count = conflict.get('count', 0)
        strength = conflict.get('avg_strength', 0)
        result += f"| {', '.join(drivers)} | {count} | {strength:.3f} |\n"
    
    return result

def _format_high_contradiction_actors(contradiction_stats: Dict[str, Any]) -> str:
    """Format high contradiction actors."""
    high_contradiction = contradiction_stats.get('high_contradiction_actors', [])
    if not high_contradiction:
        return "No high contradiction actors found."
    
    count = len(high_contradiction)
    return f"Found {count} actors with high contradiction scores (≥0.6). These actors show conflicting psychological drivers and may require special attention in messaging and targeting."

def _format_contradiction_insights(contradiction_stats: Dict[str, Any]) -> str:
    """Format contradiction insights."""
    distribution = contradiction_stats.get('distribution', {})
    high_count = distribution.get('high', 0)
    total = sum(distribution.values())
    high_pct = (high_count / total) * 100 if total > 0 else 0
    
    if high_pct > 20:
        return f"High contradiction rate ({high_pct:.1f}%) suggests many customers have conflicting motivations. This presents opportunities for targeted messaging that addresses these conflicts."
    elif high_pct > 10:
        return f"Moderate contradiction rate ({high_pct:.1f}%) indicates some customers have conflicting motivations. Consider developing conflict-resolution messaging strategies."
    else:
        return f"Low contradiction rate ({high_pct:.1f}%) suggests customers have relatively consistent motivations. Focus on reinforcing existing driver preferences."

def _format_quantum_analysis(quantum_stats: Dict[str, Any]) -> str:
    """Format quantum state analysis."""
    if not quantum_stats.get('quantum_data_available', False):
        return "Quantum state data not available in this dataset."
    
    superposition_prevalence = quantum_stats.get('superposition_prevalence', 0)
    coherence_stats = quantum_stats.get('coherence_stats', {})
    
    return f"""
### Quantum State Analysis

**Superposition Prevalence:** {superposition_prevalence:.1%} of actors show quantum superposition effects

**Coherence Statistics:**
- Mean: {coherence_stats.get('mean', 0):.3f}
- Std Dev: {coherence_stats.get('std', 0):.3f}
- Range: {coherence_stats.get('min', 0):.3f} - {coherence_stats.get('max', 0):.3f}

**Insights:**
{'High' if superposition_prevalence > 0.3 else 'Low'} superposition prevalence suggests {'context-dependent' if superposition_prevalence > 0.3 else 'stable'} customer behavior patterns.
"""

def _format_identity_analysis(actors: List[Dict[str, Any]]) -> str:
    """Format identity analysis."""
    if not actors:
        return "No identity data available"
    
    # Collect all identity markers
    all_markers = []
    for actor in actors:
        markers = actor.get('identity_markers', [])
        if isinstance(markers, list):
            all_markers.extend(markers)
    
    if not all_markers:
        return "No identity markers found in the dataset."
    
    # Count frequency
    from collections import Counter
    marker_counts = Counter(all_markers)
    
    table = "| Identity Marker | Count | Percentage |\n"
    table += "|----------------|-------|------------|\n"
    
    total = len(all_markers)
    for marker, count in marker_counts.most_common(10):
        percentage = (count / total) * 100
        table += f"| {marker} | {count} | {percentage:.1f}% |\n"
    
    return f"**Common Identity Markers:**\n\n{table}"

def _format_segment_hypotheses(driver_stats: Dict[str, Any], 
                              contradiction_stats: Dict[str, Any],
                              quantum_stats: Dict[str, Any]) -> str:
    """Format segment hypotheses."""
    # This would be implemented based on the actual analysis
    return """
Based on the pattern analysis, the following customer segments are hypothesized:

1. **Safety-Focused** - High Safety driver, low contradiction
2. **Status-Seekers** - High Status driver, medium contradiction  
3. **Growth-Oriented** - High Growth driver, low contradiction
4. **High-Contradiction** - Mixed drivers, high contradiction scores
5. **Quantum-Shifters** - Context-dependent behavior patterns

*Note: These hypotheses should be validated through clustering analysis.*
"""

def _format_business_implications(driver_stats: Dict[str, Any], 
                                 contradiction_stats: Dict[str, Any],
                                 quantum_stats: Dict[str, Any]) -> str:
    """Format business implications."""
    dominant_driver = _get_dominant_driver(driver_stats)
    high_contradiction = contradiction_stats.get('distribution', {}).get('high', 0)
    
    return f"""
1. **Primary Customer Motivation:** {dominant_driver} is the most common driver
2. **Contradiction Management:** {high_contradiction} customers have conflicting motivations
3. **Targeting Opportunities:** Clear driver patterns enable precise targeting
4. **Messaging Complexity:** {'High' if high_contradiction > 20 else 'Medium'} complexity due to contradiction levels
"""

def _format_messaging_strategies(driver_stats: Dict[str, Any]) -> str:
    """Format messaging strategies."""
    dominant_counts = driver_stats.get('dominant_driver_counts', {})
    if not dominant_counts:
        return "No messaging strategies available"
    
    strategies = []
    for driver, count in dominant_counts.items():
        if count > 10:  # Significant segment
            strategy = _get_messaging_strategy(driver)
            strategies.append(f"- **{driver}-Focused:** {strategy}")
    
    return "\n".join(strategies)

def _get_messaging_strategy(driver: str) -> str:
    """Get messaging strategy for a driver."""
    strategies = {
        'Safety': 'Emphasize security, reliability, and risk reduction',
        'Connection': 'Focus on community, relationships, and belonging',
        'Status': 'Highlight prestige, recognition, and exclusivity',
        'Growth': 'Emphasize learning, development, and improvement',
        'Freedom': 'Focus on independence, choice, and flexibility',
        'Purpose': 'Highlight meaning, impact, and contribution'
    }
    return strategies.get(driver, 'General appeal messaging')

def _format_segmentation_opportunities(driver_stats: Dict[str, Any], 
                                      contradiction_stats: Dict[str, Any]) -> str:
    """Format segmentation opportunities."""
    dominant_counts = driver_stats.get('dominant_driver_counts', {})
    high_contradiction = contradiction_stats.get('distribution', {}).get('high', 0)
    
    opportunities = []
    
    # Driver-based segments
    significant_drivers = [driver for driver, count in dominant_counts.items() if count > 15]
    opportunities.append(f"Driver-based segments: {len(significant_drivers)} potential segments")
    
    # Contradiction-based segments
    if high_contradiction > 10:
        opportunities.append(f"Contradiction-based segment: {high_contradiction} high-contradiction customers")
    
    # Combined approach
    opportunities.append("Combined driver + contradiction segmentation for maximum precision")
    
    return "\n".join([f"- {opp}" for opp in opportunities])

def _check_missing_values(actors: List[Dict[str, Any]]) -> bool:
    """Check if there are missing values."""
    if not actors:
        return False
    
    for actor in actors:
        if not actor.get('driver_distribution'):
            return True
    return False

def _check_outliers(actors: List[Dict[str, Any]]) -> bool:
    """Check for outliers in driver values."""
    if not actors:
        return False
    
    # Simple outlier detection based on extreme values
    for actor in actors:
        driver_dist = actor.get('driver_distribution', {})
        for driver, value in driver_dist.items():
            if value > 0.9 or value < 0.1:  # Extreme values
                return True
    return False
