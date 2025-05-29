import pandas as pd
import pyodbc
import numpy as np
from datetime import datetime
import sys
import os

def get_database_connection():
    """Create connection to SQL Server database"""
    
    # Connection parameters - adjust these for your SQL Server setup
    server = 'localhost'  # or '.\SQLEXPRESS' 
    database = 'ECommerceAnalytics'
    
    # Try Windows Authentication first
    connection_string = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'
    
    try:
        conn = pyodbc.connect(connection_string)
        print("✅ Connected to SQL Server successfully!")
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        print("\n🔧 Troubleshooting tips:")
        print("1. Make sure SQL Server is running")
        print("2. Check if server name is correct (try 'localhost' or '.\\SQLEXPRESS')")
        print("3. Ensure Windows Authentication is enabled")
        return None

def load_raw_data():
    """Load raw data from CSV/Excel files"""
    
    print("📂 Loading raw data files...")
    
    # Try to find data file
    possible_files = [
        'data/raw/ecommerce_data.csv',
        'data/raw/data.csv', 
        'data/raw/online_retail.xlsx',
        'data/raw/Online Retail.xlsx'
    ]
    
    df = None
    for file_path in possible_files:
        if os.path.exists(file_path):
            print(f"📁 Found data file: {file_path}")
            try:
                if file_path.endswith('.csv'):
                    df = pd.read_csv(file_path, encoding='utf-8')
                else:
                    df = pd.read_excel(file_path)
                print(f"✅ Successfully loaded {len(df):,} records")
                break
            except Exception as e:
                print(f"❌ Error loading {file_path}: {e}")
                continue
    
    if df is None:
        print("❌ No data file found. Please ensure you have downloaded the data.")
        return None
    
    # Display basic info about the data
    print(f"\n📊 Data Overview:")
    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns)}")
    print(f"Columns: {list(df.columns)}")
    
    return df

def clean_and_prepare_data(df):
    """Clean and prepare data for database loading"""
    
    print("\n🧹 Cleaning and preparing data...")
    
    # Make a copy to avoid modifying original
    df_clean = df.copy()
    
    # Standardize column names (handle different data sources)
    column_mapping = {
        'Invoice': 'InvoiceNo',
        'InvoiceNo': 'InvoiceNo',
        'Stock Code': 'StockCode', 
        'StockCode': 'StockCode',
        'Description': 'Description',
        'Quantity': 'Quantity',
        'Invoice Date': 'InvoiceDate',
        'InvoiceDate': 'InvoiceDate',
        'Unit Price': 'UnitPrice',
        'UnitPrice': 'UnitPrice',
        'Price': 'UnitPrice',
        'Customer ID': 'CustomerID',
        'CustomerID': 'CustomerID',
        'Country': 'Country'
    }
    
    # Rename columns
    for old_name, new_name in column_mapping.items():
        if old_name in df_clean.columns:
            df_clean = df_clean.rename(columns={old_name: new_name})
    
    # Required columns
    required_columns = ['InvoiceNo', 'StockCode', 'Description', 'Quantity', 'InvoiceDate', 'UnitPrice', 'CustomerID', 'Country']
    
    # Check if we have all required columns
    missing_columns = [col for col in required_columns if col not in df_clean.columns]
    if missing_columns:
        print(f"❌ Missing columns: {missing_columns}")
        print(f"Available columns: {list(df_clean.columns)}")
        return None
    
    # Select only the columns we need
    df_clean = df_clean[required_columns]
    
    # Data cleaning steps
    print("🔧 Applying data cleaning rules...")
    
    original_count = len(df_clean)
    
    # Convert data types
    df_clean['InvoiceNo'] = df_clean['InvoiceNo'].astype(str)
    df_clean['StockCode'] = df_clean['StockCode'].astype(str) 
    df_clean['CustomerID'] = df_clean['CustomerID'].astype(str)
    
    # Handle missing descriptions
    df_clean['Description'] = df_clean['Description'].fillna('Unknown Product')
    
    # Convert date column
    df_clean['InvoiceDate'] = pd.to_datetime(df_clean['InvoiceDate'], errors='coerce')
    
    # Remove records with invalid dates
    df_clean = df_clean.dropna(subset=['InvoiceDate'])
    
    # Remove records with missing customer ID (convert 'nan' string to actual NaN)
    df_clean['CustomerID'] = df_clean['CustomerID'].replace('nan', np.nan)
    df_clean = df_clean.dropna(subset=['CustomerID'])
    
    # Remove records with zero or negative quantities (keep returns separate if needed)
    df_clean = df_clean[df_clean['Quantity'] > 0]
    
    # Remove records with zero or negative unit prices
    df_clean = df_clean[df_clean['UnitPrice'] > 0]
    
    # Remove extreme outliers (optional - adjust thresholds as needed)
    # Remove quantities > 10000 (likely data errors)
    df_clean = df_clean[df_clean['Quantity'] <= 10000]
    
    # Remove unit prices > 1000 (adjust based on your business)
    df_clean = df_clean[df_clean['UnitPrice'] <= 1000]
    
    # Final cleanup
    df_clean = df_clean.dropna()
    
    cleaned_count = len(df_clean)
    removed_count = original_count - cleaned_count
    
    print(f"📊 Cleaning Results:")
    print(f"Original records: {original_count:,}")
    print(f"Clean records: {cleaned_count:,}")
    print(f"Removed records: {removed_count:,} ({removed_count/original_count*100:.1f}%)")
    
    return df_clean

def insert_data_to_database(df, conn):
    """Insert cleaned data into SQL Server staging table"""
    
    print(f"\n💾 Inserting {len(df):,} records into database...")
    
    cursor = conn.cursor()
    
    try:
        # Clear existing data in staging table
        cursor.execute("TRUNCATE TABLE staging.raw_sales")
        print("🗑️ Cleared existing staging data")
        
        # Insert data in batches for better performance
        batch_size = 1000
        total_batches = (len(df) + batch_size - 1) // batch_size
        
        for i in range(0, len(df), batch_size):
            batch = df.iloc[i:i+batch_size]
            batch_num = (i // batch_size) + 1
            
            # Prepare batch insert
            insert_query = """
                INSERT INTO staging.raw_sales 
                (InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """
            
            # Convert batch to list of tuples
            batch_data = []
            for _, row in batch.iterrows():
                batch_data.append((
                    row['InvoiceNo'],
                    row['StockCode'], 
                    row['Description'],
                    int(row['Quantity']),
                    row['InvoiceDate'],
                    float(row['UnitPrice']),
                    row['CustomerID'],
                    row['Country']
                ))
            
            # Execute batch insert
            cursor.executemany(insert_query, batch_data)
            conn.commit()
            
            # Progress update
            if batch_num % 10 == 0 or batch_num == total_batches:
                print(f"📦 Processed batch {batch_num}/{total_batches} ({len(batch_data)} records)")
        
        print("✅ Data insertion completed successfully!")
        
        # Verify the insert
        cursor.execute("SELECT COUNT(*) FROM staging.raw_sales")
        count = cursor.fetchone()[0]
        print(f"✔️ Verified: {count:,} records in staging table")
        
        return True
        
    except Exception as e:
        print(f"❌ Error inserting data: {e}")
        conn.rollback()
        return False

def main():
    """Main function to orchestrate the data loading process"""
    
    print("🚀 Starting Data Loading Process")
    print("=" * 50)
    
    # Step 1: Connect to database
    conn = get_database_connection()
    if not conn:
        return False
    
    # Step 2: Load raw data
    raw_data = load_raw_data()
    if raw_data is None:
        return False
    
    # Step 3: Clean and prepare data
    clean_data = clean_and_prepare_data(raw_data)
    if clean_data is None:
        return False
    
    # Step 4: Insert data into database
    success = insert_data_to_database(clean_data, conn)
    
    # Step 5: Close connection
    conn.close()
    
    if success:
        print("\n🎉 Data loading process completed successfully!")
        print(f"📊 Summary:")
        print(f"- Raw records loaded: {len(raw_data):,}")
        print(f"- Clean records inserted: {len(clean_data):,}")
        print(f"- Database: ECommerceAnalytics.staging.raw_sales")
        
        # Save summary to file
        with open('docs/data_loading_summary.txt', 'w') as f:
            f.write(f"Data Loading Summary - {datetime.now()}\n")
            f.write("=" * 50 + "\n")
            f.write(f"Raw records: {len(raw_data):,}\n")
            f.write(f"Clean records: {len(clean_data):,}\n")
            f.write(f"Success: True\n")
        
        return True
    else:
        print("\n❌ Data loading process failed!")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)