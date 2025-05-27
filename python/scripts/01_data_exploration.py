import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

def explore_data():
    """Initial data exploration and quality assessment"""
    
    print("🔍 Starting Data Exploration...")
    print("=" * 50)
    
    # Load the data
    try:
        # Try CSV first
        df = pd.read_csv('data/raw/ecommerce_data.csv')
        print("✅ Loaded CSV file successfully")
    except:
        try:
            # Try Excel if CSV fails
            df = pd.read_excel('data/raw/online_retail.xlsx')
            print("✅ Loaded Excel file successfully")
        except Exception as e:
            print(f"❌ Error loading data: {e}")
            return None
    
    # Basic information
    print(f"\n📊 Dataset Overview:")
    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns)}")
    print(f"Memory usage: {df.memory_usage(deep=True).sum() / 1024**2:.1f} MB")
    
    # Column information
    print(f"\n📋 Column Information:")
    for i, col in enumerate(df.columns):
        null_count = df[col].isnull().sum()
        null_pct = (null_count / len(df)) * 100
        print(f"{i+1}. {col}: {null_count:,} nulls ({null_pct:.1f}%)")
    
    # Data types
    print(f"\n🏷️ Data Types:")
    print(df.dtypes)
    
    # Sample data
    print(f"\n📝 First 5 Rows:")
    print(df.head())
    
    # Statistical summary
    print(f"\n📈 Statistical Summary:")
    print(df.describe())
    
    # Check for duplicates
    duplicates = df.duplicated().sum()
    print(f"\n🔄 Duplicates: {duplicates:,} ({(duplicates/len(df)*100):.1f}%)")
    
    # Create visualizations
    create_exploration_plots(df)
    
    # Save basic info to file
    with open('docs/data_exploration_summary.txt', 'w') as f:
        f.write(f"Data Exploration Summary - {datetime.now()}\n")
        f.write("=" * 50 + "\n")
        f.write(f"Total Records: {len(df):,}\n")
        f.write(f"Total Columns: {len(df.columns)}\n")
        f.write(f"Duplicates: {duplicates:,}\n")
        f.write(f"Memory Usage: {df.memory_usage(deep=True).sum() / 1024**2:.1f} MB\n")
    
    return df

def create_exploration_plots(df):
    """Create initial exploration visualizations"""
    
    plt.style.use('default')
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    
    # Plot 1: Missing values heatmap
    if df.isnull().sum().sum() > 0:
        sns.heatmap(df.isnull(), ax=axes[0,0], cbar=True, yticklabels=False)
        axes[0,0].set_title('Missing Values Pattern')
    else:
        axes[0,0].text(0.5, 0.5, 'No Missing Values', ha='center', va='center', transform=axes[0,0].transAxes)
        axes[0,0].set_title('Missing Values Check')
    
    # Plot 2: Data types distribution
    dtype_counts = df.dtypes.value_counts()
    axes[0,1].pie(dtype_counts.values, labels=dtype_counts.index, autopct='%1.1f%%')
    axes[0,1].set_title('Data Types Distribution')
    
    # Plot 3: Record count over time (if date column exists)
    date_cols = [col for col in df.columns if 'date' in col.lower() or 'time' in col.lower()]
    if date_cols:
        try:
            df[date_cols[0]] = pd.to_datetime(df[date_cols[0]], errors='coerce')
            daily_counts = df.groupby(df[date_cols[0]].dt.date).size()
            daily_counts.plot(ax=axes[1,0])
            axes[1,0].set_title('Records Over Time')
            axes[1,0].tick_params(axis='x', rotation=45)
        except:
            axes[1,0].text(0.5, 0.5, 'Could not plot time series', ha='center', va='center', transform=axes[1,0].transAxes)
    else:
        axes[1,0].text(0.5, 0.5, 'No date column found', ha='center', va='center', transform=axes[1,0].transAxes)
    
    # Plot 4: Numeric columns distribution
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) > 0:
        df[numeric_cols[0]].hist(bins=30, ax=axes[1,1])
        axes[1,1].set_title(f'Distribution: {numeric_cols[0]}')
    else:
        axes[1,1].text(0.5, 0.5, 'No numeric columns', ha='center', va='center', transform=axes[1,1].transAxes)
    
    plt.tight_layout()
    plt.savefig('images/data_exploration.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    print("📊 Exploration plots saved to 'images/data_exploration.png'")

if __name__ == "__main__":
    # Run exploration
    data = explore_data()
    
    if data is not None:
        print(f"\n✅ Data exploration completed successfully!")
        print(f"📁 Summary saved to 'docs/data_exploration_summary.txt'")
        print(f"📊 Plots saved to 'images/data_exploration.png'")
    else:
        print("❌ Data exploration failed. Check your data file.")