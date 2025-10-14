#!/usr/bin/env python3
"""
Quick visualization of cohort data - no full dashboard needed
"""

import os
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
from dotenv import load_dotenv

# Add intelligence_layer to path
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PKG_PATH = os.path.join(ROOT, 'intelligence_layer')
if PKG_PATH not in sys.path:
    sys.path.append(PKG_PATH)

# Also add the parent directory to path for direct imports
PARENT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PARENT_DIR not in sys.path:
    sys.path.append(PARENT_DIR)

load_dotenv()

from intelligence_layer.src.database import DatabaseManager

def create_quick_visualizations():
    print("📊 Creating Quick Cohort Visualizations")
    print("="*50)
    
    db = DatabaseManager()
    
    try:
        # Get cohorts data
        cohorts_result = db.supabase.table('cohorts').select('*').order('size', desc=True).execute()
        cohorts = cohorts_result.data
        
        if not cohorts:
            print("❌ No cohorts found")
            return
        
        # Convert to DataFrame
        df = pd.DataFrame(cohorts)
        
        # Create visualizations
        plt.style.use('seaborn-v0_8')
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        fig.suptitle('Customer Cohort Analysis Dashboard', fontsize=16, fontweight='bold')
        
        # 1. Cohort Size Distribution
        ax1 = axes[0, 0]
        cohort_sizes = df.groupby('cohort_name')['size'].sum().sort_values(ascending=True)
        colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7']
        bars = ax1.barh(cohort_sizes.index, cohort_sizes.values, color=colors[:len(cohort_sizes)])
        ax1.set_title('Cohort Size Distribution', fontweight='bold')
        ax1.set_xlabel('Number of Customers')
        
        # Add value labels on bars
        for i, bar in enumerate(bars):
            width = bar.get_width()
            ax1.text(width + 1, bar.get_y() + bar.get_height()/2, 
                    f'{int(width)}', ha='left', va='center', fontweight='bold')
        
        # 2. Driver Profile Radar Chart
        ax2 = axes[0, 1]
        
        # Get driver profiles for each unique cohort
        unique_cohorts = df.drop_duplicates(subset=['cohort_name'])
        
        # Extract driver data
        drivers = ['Safety', 'Connection', 'Status', 'Growth', 'Freedom', 'Purpose']
        driver_data = []
        cohort_names = []
        
        for _, cohort in unique_cohorts.iterrows():
            driver_profile = cohort.get('driver_profile', {})
            if driver_profile:
                values = [driver_profile.get(driver, 0) for driver in drivers]
                driver_data.append(values)
                cohort_names.append(cohort['cohort_name'])
        
        if driver_data:
            # Create radar chart
            angles = np.linspace(0, 2 * np.pi, len(drivers), endpoint=False).tolist()
            angles += angles[:1]  # Complete the circle
            
            ax2 = plt.subplot(2, 2, 2, projection='polar')
            colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7']
            
            for i, (values, name) in enumerate(zip(driver_data, cohort_names)):
                values += values[:1]  # Complete the circle
                ax2.plot(angles, values, 'o-', linewidth=2, label=name, color=colors[i % len(colors)])
                ax2.fill(angles, values, alpha=0.25, color=colors[i % len(colors)])
            
            ax2.set_xticks(angles[:-1])
            ax2.set_xticklabels(drivers)
            ax2.set_ylim(0, 1)
            ax2.set_title('Psychological Driver Profiles', fontweight='bold', pad=20)
            ax2.legend(loc='upper right', bbox_to_anchor=(1.3, 1.0))
        
        # 3. Contradiction Scores
        ax3 = axes[1, 0]
        contradiction_scores = []
        cohort_names_cont = []
        
        for _, cohort in unique_cohorts.iterrows():
            characteristics = cohort.get('characteristics', {})
            if characteristics:
                contradiction = characteristics.get('avg_contradiction', 0)
                contradiction_scores.append(contradiction)
                cohort_names_cont.append(cohort['cohort_name'])
        
        if contradiction_scores:
            bars = ax3.bar(cohort_names_cont, contradiction_scores, 
                          color=['#FF6B6B' if x > 0.7 else '#4ECDC4' for x in contradiction_scores])
            ax3.set_title('Contradiction Scores by Cohort', fontweight='bold')
            ax3.set_ylabel('Contradiction Score')
            ax3.set_ylim(0, 1)
            
            # Rotate x-axis labels
            plt.setp(ax3.get_xticklabels(), rotation=45, ha='right')
            
            # Add value labels on bars
            for bar, score in zip(bars, contradiction_scores):
                height = bar.get_height()
                ax3.text(bar.get_x() + bar.get_width()/2., height + 0.01,
                        f'{score:.2f}', ha='center', va='bottom', fontweight='bold')
        
        # 4. Cohort Percentage Pie Chart
        ax4 = axes[1, 1]
        percentages = df.groupby('cohort_name')['percentage'].sum()
        colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7']
        
        wedges, texts, autotexts = ax4.pie(percentages.values, labels=percentages.index, 
                                          autopct='%1.1f%%', colors=colors[:len(percentages)],
                                          startangle=90)
        ax4.set_title('Cohort Distribution (%)', fontweight='bold')
        
        # Make percentage text bold
        for autotext in autotexts:
            autotext.set_fontweight('bold')
            autotext.set_fontsize(10)
        
        plt.tight_layout()
        
        # Save the plot
        output_path = 'cohort_analysis_dashboard.png'
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
        print(f"✅ Dashboard saved as: {output_path}")
        
        # Show summary statistics
        print(f"\n📊 Cohort Summary:")
        print("="*30)
        for _, cohort in unique_cohorts.iterrows():
            print(f"• {cohort['cohort_name']}")
            print(f"  Size: {cohort['size']} customers ({cohort['percentage']:.1f}%)")
            
            characteristics = cohort.get('characteristics', {})
            if characteristics:
                contradiction = characteristics.get('avg_contradiction', 0)
                dominant = characteristics.get('dominant_driver', 'Unknown')
                print(f"  Dominant Driver: {dominant}")
                print(f"  Contradiction: {contradiction:.2f}")
            print()
        
        print("💡 Key Insights:")
        print("• High contradiction scores indicate complex customer needs")
        print("• Driver profiles show psychological motivations")
        print("• Size distribution helps prioritize marketing efforts")
        print("• Use this data to inform stimuli generation strategies")
        
        return output_path
        
    except Exception as e:
        print(f"❌ Error creating visualizations: {e}")
        return None

if __name__ == "__main__":
    create_quick_visualizations()
