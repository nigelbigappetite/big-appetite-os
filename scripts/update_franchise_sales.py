#!/usr/bin/env python3
"""
Manual Franchise Sales Update Tool
==================================
This script helps you update franchise sales data manually.

Usage:
1. Export new CSV files from each platform
2. Place them in the data/ folder
3. Run: python3 scripts/update_franchise_sales.py
4. Upload the generated CSV to Supabase
"""

import csv
import json
import os
from datetime import datetime
import glob

print("🔄 Wing Shack Franchise Sales Update Tool")
print("==========================================\n")

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

# Site mapping
SITE_MAPPING = {
    1: "Loughton",
    2: "Maidstone", 
    3: "Chatham",
    4: "Wanstead"
}

def find_latest_csv_files():
    """Find the most recent CSV files for each site"""
    
    # Look for files with pattern: orders_clean_*.csv
    csv_files = glob.glob("data/orders_clean_*.csv")
    
    if not csv_files:
        print("❌ No CSV files found in data/ folder")
        print("   Expected files: orders_clean_Loughton.csv, orders_clean_Maidstone.csv, etc.")
        return []
    
    print(f"📁 Found {len(csv_files)} CSV files:")
    for file in csv_files:
        print(f"   - {file}")
    
    return csv_files

def check_for_new_data(csv_files):
    """Check if there's new data since last update"""
    
    print("\n🔍 Checking for new data...")
    
    # This is a simple check - you could enhance this by:
    # 1. Checking the last update timestamp in the database
    # 2. Comparing file modification dates
    # 3. Checking for new dates in the CSV files
    
    for file_path in csv_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                rows = list(reader)
                
                if rows:
                    # Get the latest date from the file
                    latest_date = max(row.get('order_date', '') for row in rows if row.get('order_date'))
                    print(f"   - {os.path.basename(file_path)}: Latest date {latest_date}")
                else:
                    print(f"   - {os.path.basename(file_path)}: No data")
                    
        except Exception as e:
            print(f"   - {os.path.basename(file_path)}: Error reading file - {e}")

def process_update_data(csv_files):
    """Process the CSV files for update"""
    
    print("\n⚙️ Processing update data...")
    
    results = []
    total_records = 0
    
    for file_path in csv_files:
        site_name = os.path.basename(file_path).replace('orders_clean_', '').replace('.csv', '')
        site_id = None
        
        # Find site ID
        for sid, sname in SITE_MAPPING.items():
            if sname.lower() == site_name.lower():
                site_id = sid
                break
        
        if not site_id:
            print(f"⚠️ Unknown site: {site_name}")
            continue
            
        print(f"   Processing {site_name} (ID: {site_id})...")
        
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                
                site_records = 0
                for row in reader:
                    # Skip rows with no sales data
                    if not row.get('gross_sales') or row['gross_sales'] == '0':
                        continue
                    
                    # Parse order date
                    order_date = None
                    if row.get('order_date'):
                        try:
                            order_date = datetime.fromisoformat(row['order_date'].replace('Z', '+00:00')).date()
                        except:
                            continue
                    
                    # Create raw content
                    raw_content = {
                        "original_id": row.get('id', ''),
                        "network_id": row.get('network_id', ''),
                        "network_type": row.get('network_type', ''),
                        "platform": row.get('platform', ''),
                        "order_date": row.get('order_date', ''),
                        "reporting_week": row.get('reporting_week', ''),
                        "inserted_at": row.get('inserted_at', ''),
                        "source_file": file_path,
                        "update_timestamp": datetime.now().isoformat()
                    }
                    
                    # Create intake metadata
                    intake_metadata = {
                        "intake_source": "franchise_sales_manual_update",
                        "intake_timestamp": datetime.now().isoformat(),
                        "site_name": site_name,
                        "platform": row.get('platform', ''),
                        "data_batch": f"franchise_sales_update_{datetime.now().strftime('%Y%m%d')}"
                    }
                    
                    # Create record for database
                    record = {
                        "brand_id": WING_SHACK_BRAND_ID,
                        "site_id": site_id,
                        "site_name": site_name,
                        "platform": row.get('platform', ''),
                        "order_date": order_date.isoformat() if order_date else None,
                        "reporting_week": row.get('reporting_week', ''),
                        "orders_count": int(row.get('orders_count', 0)) if row.get('orders_count') else 0,
                        "gross_sales": float(row.get('gross_sales', 0)) if row.get('gross_sales') else 0,
                        "refunds": float(row.get('refunds', 0)) if row.get('refunds') else 0,
                        "net_sales": float(row.get('net_sales', 0)) if row.get('net_sales') else 0,
                        "avg_order_value": float(row.get('avg_order_value', 0)) if row.get('avg_order_value') else 0,
                        "avg_prep_time": int(row.get('avg_prep_time', 0)) if row.get('avg_prep_time') else None,
                        "avg_fulfilment_time": int(row.get('avg_fulfilment_time', 0)) if row.get('avg_fulfilment_time') else None,
                        "completion_rate": float(row.get('completion_rate', 0)) if row.get('completion_rate') else None,
                        "delivery_rating": float(row.get('delivery_rating', 0)) if row.get('delivery_rating') else None,
                        "royalty_rate": float(row.get('royalty_rate', 0)) if row.get('royalty_rate') else None,
                        "royalty_value": float(row.get('royalty_value', 0)) if row.get('royalty_value') else None,
                        "raw_content": json.dumps(raw_content),
                        "received_at": datetime.now().isoformat(),
                        "intake_method": "franchise_sales_manual_update",
                        "intake_metadata": json.dumps(intake_metadata)
                    }
                    
                    results.append(record)
                    site_records += 1
                    total_records += 1
                
                print(f"     - {site_records} records processed")
                    
        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")
            continue
    
    print(f"\n📊 Update summary:")
    print(f"   - Total records: {total_records}")
    
    if results:
        total_sales = sum(r['net_sales'] for r in results)
        total_orders = sum(r['orders_count'] for r in results)
        avg_order_value = total_sales / total_orders if total_orders > 0 else 0
        
        print(f"   - Total net sales: £{total_sales:,.2f}")
        print(f"   - Total orders: {total_orders:,}")
        print(f"   - Average order value: £{avg_order_value:.2f}")
    
    return results

def generate_update_csv(results):
    """Generate CSV for the update"""
    
    if not results:
        print("❌ No data to process")
        return None
    
    print("\n📝 Generating update CSV...")
    
    def escape_csv(value):
        if value is None:
            return ''
        str_value = str(value)
        if ',' in str_value or '"' in str_value or '\n' in str_value:
            return '"' + str_value.replace('"', '""') + '"'
        return str_value
    
    csv_header = "brand_id,site_id,site_name,platform,order_date,reporting_week,orders_count,gross_sales,refunds,net_sales,avg_order_value,avg_prep_time,avg_fulfilment_time,completion_rate,delivery_rating,royalty_rate,royalty_value,raw_content,received_at,intake_method,intake_metadata\n"
    
    csv_rows = []
    for record in results:
        row = [
            escape_csv(record["brand_id"]),
            escape_csv(record["site_id"]),
            escape_csv(record["site_name"]),
            escape_csv(record["platform"]),
            escape_csv(record["order_date"]),
            escape_csv(record["reporting_week"]),
            escape_csv(record["orders_count"]),
            escape_csv(record["gross_sales"]),
            escape_csv(record["refunds"]),
            escape_csv(record["net_sales"]),
            escape_csv(record["avg_order_value"]),
            escape_csv(record["avg_prep_time"]),
            escape_csv(record["avg_fulfilment_time"]),
            escape_csv(record["completion_rate"]),
            escape_csv(record["delivery_rating"]),
            escape_csv(record["royalty_rate"]),
            escape_csv(record["royalty_value"]),
            escape_csv(record["raw_content"]),
            escape_csv(record["received_at"]),
            escape_csv(record["intake_method"]),
            escape_csv(record["intake_metadata"])
        ]
        csv_rows.append(','.join(row))
    
    csv_content = csv_header + '\n'.join(csv_rows)
    
    # Generate filename with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f'data/franchise_sales_update_{timestamp}.csv'
    
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ Update CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

def main():
    print("🎯 Big Appetite OS - Franchise Sales Update Tool")
    print("================================================\n")
    
    # Find CSV files
    csv_files = find_latest_csv_files()
    
    if not csv_files:
        return
    
    # Check for new data
    check_for_new_data(csv_files)
    
    # Process the data
    results = process_update_data(csv_files)
    
    if results:
        # Generate update CSV
        csv_file = generate_update_csv(results)
        
        if csv_file:
            print("\n🎉 Update processing complete!")
            print(f"📁 Ready to upload: {csv_file}")
            print("\n📋 Next steps:")
            print("1. Go to Supabase Dashboard → Table Editor")
            print("2. Select ops.franchise_sales table")
            print("3. Click 'Import data from CSV'")
            print("4. Upload the generated CSV file")
            print("5. Verify the new data in the table")
    else:
        print("\n❌ No data to update.")

if __name__ == "__main__":
    main()
