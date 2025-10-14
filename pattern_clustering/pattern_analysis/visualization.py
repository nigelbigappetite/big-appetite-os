"""
Visualization Module for Pattern Analysis

Creates comprehensive visualizations for pattern analysis including
driver distributions, correlations, contradictions, and quantum states.
"""

import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd
from typing import List, Dict, Any, Optional
import os
from pathlib import Path

# Set style
plt.style.use('default')
sns.set_palette("husl")

# Configuration
FIGURE_SIZE = (12, 8)
DPI = 300
COLOR_PALETTE = "viridis"

def create_all_visualizations(actors: List[Dict[str, Any]], 
                            driver_stats: Dict[str, Any],
                            contradiction_stats: Dict[str, Any],
                            quantum_stats: Dict[str, Any],
                            output_dir: str = "outputs/visualizations") -> None:
    """
    Generate all pattern analysis visualizations.
    
    Args:
        actors: List of actor profiles
        driver_stats: Driver distribution statistics
        contradiction_stats: Contradiction analysis results
        quantum_stats: Quantum state analysis results
        output_dir: Directory to save visualizations
    """
    print("🎨 Creating visualizations...")
    
    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    try:
        # 1. Driver averages bar chart
        plot_driver_averages(driver_stats, output_dir)
        
        # 2. Driver distributions histograms
        plot_driver_distributions(actors, output_dir)
        
        # 3. Correlation heatmap
        plot_correlation_heatmap(driver_stats, output_dir)
        
        # 4. Contradiction distribution
        plot_contradiction_distribution(contradiction_stats, output_dir)
        
        # 5. Dominant driver pie chart
        plot_dominant_driver_pie(driver_stats, output_dir)
        
        # 6. Quantum prevalence (if available)
        if quantum_stats.get('quantum_data_available', False):
            plot_quantum_prevalence(quantum_stats, output_dir)
        
        # 7. Scatter matrix
        plot_scatter_matrix(actors, output_dir)
        
        print(f"   ✓ Created 7 visualization files in {output_dir}/")
        
    except Exception as e:
        print(f"   ❌ Error creating visualizations: {e}")
        raise

def plot_driver_averages(driver_stats: Dict[str, Any], output_dir: str) -> None:
    """Create bar chart of average driver distribution."""
    try:
        averages = driver_stats.get('averages', {})
        if not averages:
            return
        
        drivers = list(averages.keys())
        values = list(averages.values())
        
        plt.figure(figsize=FIGURE_SIZE)
        bars = plt.bar(drivers, values, color=sns.color_palette(COLOR_PALETTE, len(drivers)))
        
        # Add value labels on bars
        for bar, value in zip(bars, values):
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{value:.3f}', ha='center', va='bottom', fontweight='bold')
        
        plt.title('Average Driver Distribution Across All Actors', fontsize=16, fontweight='bold')
        plt.xlabel('Psychological Drivers', fontsize=12)
        plt.ylabel('Average Value', fontsize=12)
        plt.ylim(0, max(values) * 1.1)
        plt.xticks(rotation=45)
        plt.grid(axis='y', alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{output_dir}/driver_averages.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created driver_averages.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating driver averages plot: {e}")

def plot_driver_distributions(actors: List[Dict[str, Any]], output_dir: str) -> None:
    """Create histograms for each driver distribution."""
    try:
        drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
        
        fig, axes = plt.subplots(2, 3, figsize=(18, 12))
        axes = axes.flatten()
        
        for i, driver in enumerate(drivers):
            values = [actor['driver_distribution'][driver] for actor in actors]
            
            axes[i].hist(values, bins=20, alpha=0.7, color=sns.color_palette(COLOR_PALETTE)[i])
            axes[i].set_title(f'{driver} Distribution', fontweight='bold')
            axes[i].set_xlabel('Value')
            axes[i].set_ylabel('Frequency')
            axes[i].grid(alpha=0.3)
            
            # Add statistics
            mean_val = np.mean(values)
            std_val = np.std(values)
            axes[i].axvline(mean_val, color='red', linestyle='--', alpha=0.8, label=f'Mean: {mean_val:.3f}')
            axes[i].legend()
        
        plt.suptitle('Driver Distribution Histograms', fontsize=16, fontweight='bold')
        plt.tight_layout()
        plt.savefig(f"{output_dir}/driver_distributions.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created driver_distributions.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating driver distributions plot: {e}")

def plot_correlation_heatmap(driver_stats: Dict[str, Any], output_dir: str) -> None:
    """Create correlation heatmap with annotations."""
    try:
        correlation_matrix = driver_stats.get('correlation_matrix')
        if correlation_matrix is None:
            return
        
        drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
        
        plt.figure(figsize=FIGURE_SIZE)
        
        # Create heatmap
        mask = np.triu(np.ones_like(correlation_matrix, dtype=bool))
        sns.heatmap(correlation_matrix, 
                   mask=mask,
                   annot=True, 
                   cmap='RdBu_r', 
                   center=0,
                   square=True,
                   xticklabels=drivers,
                   yticklabels=drivers,
                   fmt='.3f',
                   cbar_kws={'label': 'Correlation Coefficient'})
        
        plt.title('Driver Correlation Matrix', fontsize=16, fontweight='bold')
        plt.tight_layout()
        plt.savefig(f"{output_dir}/correlation_heatmap.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created correlation_heatmap.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating correlation heatmap: {e}")

def plot_contradiction_distribution(contradiction_stats: Dict[str, Any], output_dir: str) -> None:
    """Create histogram of contradiction scores with zones."""
    try:
        distribution = contradiction_stats.get('distribution', {})
        if not distribution:
            return
        
        # Create data for plotting
        categories = ['Low (<0.3)', 'Medium (0.3-0.6)', 'High (≥0.6)']
        counts = [distribution.get('low', 0), distribution.get('medium', 0), distribution.get('high', 0)]
        colors = ['green', 'orange', 'red']
        
        plt.figure(figsize=FIGURE_SIZE)
        bars = plt.bar(categories, counts, color=colors, alpha=0.7)
        
        # Add count labels on bars
        for bar, count in zip(bars, counts):
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                    str(count), ha='center', va='bottom', fontweight='bold')
        
        plt.title('Contradiction Score Distribution', fontsize=16, fontweight='bold')
        plt.xlabel('Contradiction Level', fontsize=12)
        plt.ylabel('Number of Actors', fontsize=12)
        plt.grid(axis='y', alpha=0.3)
        
        # Add total count
        total = sum(counts)
        plt.text(0.5, 0.95, f'Total Actors: {total}', transform=plt.gca().transAxes,
                ha='center', va='top', fontsize=12, bbox=dict(boxstyle='round', facecolor='wheat'))
        
        plt.tight_layout()
        plt.savefig(f"{output_dir}/contradiction_distribution.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created contradiction_distribution.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating contradiction distribution plot: {e}")

def plot_dominant_driver_pie(driver_stats: Dict[str, Any], output_dir: str) -> None:
    """Create pie chart of dominant driver distribution."""
    try:
        dominant_counts = driver_stats.get('dominant_driver_counts', {})
        if not dominant_counts:
            return
        
        drivers = list(dominant_counts.keys())
        counts = list(dominant_counts.values())
        
        plt.figure(figsize=FIGURE_SIZE)
        
        # Create pie chart
        wedges, texts, autotexts = plt.pie(counts, labels=drivers, autopct='%1.1f%%', 
                                          colors=sns.color_palette(COLOR_PALETTE, len(drivers)),
                                          startangle=90)
        
        # Enhance text
        for autotext in autotexts:
            autotext.set_color('white')
            autotext.set_fontweight('bold')
        
        plt.title('Dominant Driver Distribution', fontsize=16, fontweight='bold')
        
        # Add total count
        total = sum(counts)
        plt.text(0, -1.2, f'Total Actors: {total}', ha='center', fontsize=12,
                bbox=dict(boxstyle='round', facecolor='wheat'))
        
        plt.tight_layout()
        plt.savefig(f"{output_dir}/dominant_driver_pie.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created dominant_driver_pie.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating dominant driver pie chart: {e}")

def plot_quantum_prevalence(quantum_stats: Dict[str, Any], output_dir: str) -> None:
    """Create bar chart of quantum state prevalence."""
    try:
        if not quantum_stats.get('quantum_data_available', False):
            return
        
        coherence_by_driver = quantum_stats.get('avg_coherence_by_dominant_driver', {})
        if not coherence_by_driver:
            return
        
        drivers = list(coherence_by_driver.keys())
        coherence_values = list(coherence_by_driver.values())
        
        plt.figure(figsize=FIGURE_SIZE)
        bars = plt.bar(drivers, coherence_values, color=sns.color_palette(COLOR_PALETTE, len(drivers)))
        
        # Add value labels
        for bar, value in zip(bars, coherence_values):
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{value:.3f}', ha='center', va='bottom', fontweight='bold')
        
        plt.title('Average Coherence by Dominant Driver', fontsize=16, fontweight='bold')
        plt.xlabel('Dominant Driver', fontsize=12)
        plt.ylabel('Average Coherence Score', fontsize=12)
        plt.xticks(rotation=45)
        plt.grid(axis='y', alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{output_dir}/quantum_prevalence.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created quantum_prevalence.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating quantum prevalence plot: {e}")

def plot_scatter_matrix(actors: List[Dict[str, Any]], output_dir: str) -> None:
    """Create pairwise scatter plots for drivers."""
    try:
        if len(actors) < 10:
            print("   ⚠️  Not enough actors for scatter matrix")
            return
        
        # Extract driver data
        drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
        data = {driver: [actor['driver_distribution'][driver] for actor in actors] for driver in drivers}
        df = pd.DataFrame(data)
        
        # Create scatter matrix
        fig, axes = plt.subplots(6, 6, figsize=(20, 20))
        
        for i, driver1 in enumerate(drivers):
            for j, driver2 in enumerate(drivers):
                if i == j:
                    # Diagonal: histogram
                    axes[i, j].hist(df[driver1], bins=15, alpha=0.7, color=sns.color_palette(COLOR_PALETTE)[i])
                    axes[i, j].set_title(f'{driver1} Distribution')
                else:
                    # Off-diagonal: scatter plot
                    axes[i, j].scatter(df[driver2], df[driver1], alpha=0.6, s=20)
                    axes[i, j].set_xlabel(driver2)
                    axes[i, j].set_ylabel(driver1)
                    
                    # Add correlation coefficient
                    corr = df[driver1].corr(df[driver2])
                    axes[i, j].text(0.05, 0.95, f'r={corr:.3f}', transform=axes[i, j].transAxes,
                                   bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
        
        plt.suptitle('Driver Scatter Matrix', fontsize=16, fontweight='bold')
        plt.tight_layout()
        plt.savefig(f"{output_dir}/scatter_matrix.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created scatter_matrix.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating scatter matrix: {e}")

def plot_cluster_visualization_2d(features: np.ndarray, labels: np.ndarray, 
                                 output_dir: str, title: str = "Cluster Visualization") -> None:
    """
    Create 2D PCA projection of clusters with color coding.
    
    Args:
        features: Feature matrix (n_samples, n_features)
        labels: Cluster labels (n_samples,)
        output_dir: Directory to save visualization
        title: Title for the plot
    """
    try:
        from sklearn.decomposition import PCA
        
        if features.shape[1] < 2:
            print("   ⚠️  Not enough features for 2D visualization")
            return
        
        # Apply PCA to reduce to 2D
        pca = PCA(n_components=2)
        features_2d = pca.fit_transform(features)
        
        # Create plot
        plt.figure(figsize=FIGURE_SIZE)
        
        # Get unique labels and colors
        unique_labels = np.unique(labels)
        colors = sns.color_palette(COLOR_PALETTE, len(unique_labels))
        
        # Plot each cluster
        for i, label in enumerate(unique_labels):
            if label == -1:  # Outliers in DBSCAN
                plt.scatter(features_2d[labels == label, 0], 
                          features_2d[labels == label, 1],
                          c='black', marker='x', s=50, alpha=0.6, label='Outliers')
            else:
                plt.scatter(features_2d[labels == label, 0], 
                          features_2d[labels == label, 1],
                          c=[colors[i]], label=f'Cluster {label}', alpha=0.7, s=30)
        
        plt.xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.1%} variance)')
        plt.ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.1%} variance)')
        plt.title(title, fontsize=16, fontweight='bold')
        plt.legend()
        plt.grid(alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{output_dir}/cluster_visualization_2d.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created cluster_visualization_2d.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating cluster visualization: {e}")

def create_summary_dashboard(actors: List[Dict[str, Any]], 
                           driver_stats: Dict[str, Any],
                           contradiction_stats: Dict[str, Any],
                           quantum_stats: Dict[str, Any],
                           output_dir: str) -> None:
    """
    Create a comprehensive summary dashboard.
    
    Args:
        actors: List of actor profiles
        driver_stats: Driver distribution statistics
        contradiction_stats: Contradiction analysis results
        quantum_stats: Quantum state analysis results
        output_dir: Directory to save dashboard
    """
    try:
        fig = plt.figure(figsize=(20, 16))
        
        # Create grid layout
        gs = fig.add_gridspec(4, 4, hspace=0.3, wspace=0.3)
        
        # 1. Driver averages (top left)
        ax1 = fig.add_subplot(gs[0, :2])
        averages = driver_stats.get('averages', {})
        drivers = list(averages.keys())
        values = list(averages.values())
        bars = ax1.bar(drivers, values, color=sns.color_palette(COLOR_PALETTE, len(drivers)))
        ax1.set_title('Average Driver Distribution', fontweight='bold')
        ax1.set_ylabel('Average Value')
        ax1.tick_params(axis='x', rotation=45)
        
        # 2. Dominant driver pie (top right)
        ax2 = fig.add_subplot(gs[0, 2:])
        dominant_counts = driver_stats.get('dominant_driver_counts', {})
        if dominant_counts:
            ax2.pie(dominant_counts.values(), labels=dominant_counts.keys(), autopct='%1.1f%%')
            ax2.set_title('Dominant Driver Distribution', fontweight='bold')
        
        # 3. Contradiction distribution (middle left)
        ax3 = fig.add_subplot(gs[1, :2])
        distribution = contradiction_stats.get('distribution', {})
        if distribution:
            categories = ['Low', 'Medium', 'High']
            counts = [distribution.get('low', 0), distribution.get('medium', 0), distribution.get('high', 0)]
            ax3.bar(categories, counts, color=['green', 'orange', 'red'], alpha=0.7)
            ax3.set_title('Contradiction Distribution', fontweight='bold')
            ax3.set_ylabel('Number of Actors')
        
        # 4. Correlation heatmap (middle right)
        ax4 = fig.add_subplot(gs[1, 2:])
        correlation_matrix = driver_stats.get('correlation_matrix')
        if correlation_matrix is not None:
            sns.heatmap(correlation_matrix, annot=True, cmap='RdBu_r', center=0,
                       xticklabels=drivers, yticklabels=drivers, ax=ax4)
            ax4.set_title('Driver Correlations', fontweight='bold')
        
        # 5. Driver distributions (bottom)
        for i, driver in enumerate(drivers[:4]):  # Show first 4 drivers
            ax = fig.add_subplot(gs[2, i])
            values = [actor['driver_distribution'][driver] for actor in actors]
            ax.hist(values, bins=15, alpha=0.7, color=sns.color_palette(COLOR_PALETTE)[i])
            ax.set_title(f'{driver} Distribution')
            ax.set_xlabel('Value')
            ax.set_ylabel('Frequency')
        
        # Add summary text
        ax_text = fig.add_subplot(gs[3, :])
        ax_text.axis('off')
        
        summary_text = f"""
        Pattern Analysis Summary:
        • Total Actors: {len(actors)}
        • Dominant Driver: {max(dominant_counts, key=dominant_counts.get) if dominant_counts else 'N/A'}
        • High Contradiction: {distribution.get('high', 0)} actors
        • Quantum Data Available: {quantum_stats.get('quantum_data_available', False)}
        """
        
        ax_text.text(0.1, 0.5, summary_text, fontsize=12, verticalalignment='center',
                    bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
        
        plt.suptitle('Customer Pattern Analysis Dashboard', fontsize=20, fontweight='bold')
        plt.tight_layout()
        plt.savefig(f"{output_dir}/summary_dashboard.png", dpi=DPI, bbox_inches='tight')
        plt.close()
        
        print("   ✓ Created summary_dashboard.png")
        
    except Exception as e:
        print(f"   ⚠️  Error creating summary dashboard: {e}")
