#!/usr/bin/env python3
import csv
import json
from datetime import datetime
import os

print("🚀 Processing Wing Shack Franchise Sales Data...")

# Brand ID for Wing Shack
WING_SHACK_BRAND_ID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

# Site mapping
SITE_MAPPING = {
    1: "Loughton",
    2: "Maidstone", 
    3: "Chatham",
    4: "Wanstead"
}

def process_franchise_sales():
    """Process all 4 franchise sales CSV files"""
    
    results = []
    total_records = 0
    
    # Process each site's data
    site_files = [
        ("data/orders_clean_Loughton.csv", 1, "Loughton"),
        ("data/orders_clean_Maidstone.csv", 2, "Maidstone"),
        ("data/orders_clean_Chatham.csv", 3, "Chatham"),
        ("data/orders_clean_Wanstead.csv", 4, "Wanstead")
    ]
    
    for file_path, site_id, site_name in site_files:
        print(f"Processing {site_name} data...")
        
        if not os.path.exists(file_path):
            print(f"⚠️ File not found: {file_path}")
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                
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
                        "source_file": file_path
                    }
                    
                    # Create raw metadata
                    raw_metadata = {
                        "site_id": site_id,
                        "site_name": site_name,
                        "platform": row.get('platform', ''),
                        "data_source": "franchise_export",
                        "processing_timestamp": datetime.now().isoformat()
                    }
                    
                    # Create intake metadata
                    intake_metadata = {
                        "intake_source": "franchise_sales_export",
                        "intake_timestamp": datetime.now().isoformat(),
                        "site_name": site_name,
                        "platform": row.get('platform', ''),
                        "data_batch": "franchise_sales_2024"
                    }
                    
                    # Create record for database (without signal_id - let Supabase generate it)
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
                        "intake_method": "franchise_sales_intake",
                        "intake_metadata": json.dumps(intake_metadata)
                    }
                    
                    results.append(record)
                    total_records += 1
                    
        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")
            continue
    
    print(f"\n📊 Processing complete:")
    print(f"   - Total records processed: {total_records}")
    print(f"   - Sites processed: {len(site_files)}")
    
    # Calculate summary statistics
    if results:
        total_sales = sum(r['net_sales'] for r in results)
        total_orders = sum(r['orders_count'] for r in results)
        avg_order_value = total_sales / total_orders if total_orders > 0 else 0
        
        print(f"   - Total net sales: £{total_sales:,.2f}")
        print(f"   - Total orders: {total_orders:,}")
        print(f"   - Average order value: £{avg_order_value:.2f}")
        
        # Platform breakdown
        platform_stats = {}
        for record in results:
            platform = record['platform']
            if platform not in platform_stats:
                platform_stats[platform] = {'sales': 0, 'orders': 0}
            platform_stats[platform]['sales'] += record['net_sales']
            platform_stats[platform]['orders'] += record['orders_count']
        
        print(f"\n📈 Platform breakdown:")
        for platform, stats in platform_stats.items():
            print(f"   - {platform}: £{stats['sales']:,.2f} ({stats['orders']} orders)")
    
    return results

def generate_clean_csv(results):
    """Generate clean CSV for upload"""
    
    if not results:
        print("❌ No data to process")
        return None
    
    print("\n📝 Generating clean CSV...")
    
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
    
    filename = 'data/franchise_sales_clean.csv'
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(csv_content)
    
    print(f"✅ Clean CSV generated: {filename}")
    print(f"   - Records: {len(results)}")
    print(f"   - File size: {len(csv_content) / 1024:.1f} KB")
    
    return filename

def main():
    print("🎯 Big Appetite OS - Franchise Sales Processing")
    print("===============================================\n")
    
    # Process franchise sales data
    results = process_franchise_sales()
    
    if results:
        # Generate clean CSV
        csv_file = generate_clean_csv(results)
        
        if csv_file:
            print("\n🎉 Processing complete!")
            print(f"📁 Ready to upload: {csv_file}")
            print("\n📋 Next steps:")
            print("1. Create the franchise_sales table in Supabase")
            print("2. Upload the CSV to ops.franchise_sales table")
            print("3. Verify data in the database")
            print("4. Create business intelligence queries")
    else:
        print("\n❌ No data processed.")

if __name__ == "__main__":
    main()
