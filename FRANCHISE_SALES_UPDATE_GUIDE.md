# 🚀 Franchise Sales Manual Update Guide

## 📋 **Your Manual Update Workflow**

### **Step 1: Export New Data**
1. **Log into each platform** (Deliveroo, Just Eat, Uber Eats, Wingverse)
2. **Export daily/weekly sales data** as CSV
3. **Save files** in `data/` folder with names:
   - `orders_clean_Loughton.csv`
   - `orders_clean_Maidstone.csv` 
   - `orders_clean_Chatham.csv`
   - `orders_clean_Wanstead.csv`

### **Step 2: Process the Data**
```bash
python3 scripts/update_franchise_sales.py
```

This will:
- ✅ Check for new data
- ✅ Process all CSV files
- ✅ Generate clean CSV for upload
- ✅ Show summary statistics

### **Step 3: Upload to Supabase**
1. **Go to Supabase Dashboard** → Table Editor
2. **Select `ops.franchise_sales`** table
3. **Click "Import data from CSV"**
4. **Upload the generated CSV** (e.g., `franchise_sales_update_20241212_143022.csv`)
5. **Verify the upload** was successful

### **Step 4: Verify the Data**
Run these queries in Supabase SQL Editor:

```sql
-- Check latest records
SELECT 
    site_name, 
    platform, 
    order_date, 
    orders_count, 
    net_sales
FROM ops.franchise_sales 
ORDER BY order_date DESC, created_at DESC 
LIMIT 20;

-- Check total records
SELECT COUNT(*) as total_records FROM ops.franchise_sales;

-- Check recent updates
SELECT 
    site_name,
    COUNT(*) as records,
    MAX(order_date) as latest_date,
    SUM(net_sales) as total_sales
FROM ops.franchise_sales 
WHERE created_at > NOW() - INTERVAL '1 day'
GROUP BY site_name;
```

## 🔄 **Update Frequency Recommendations**

### **Daily Updates** (Best for real-time insights)
- **Export data** every morning
- **Process and upload** same day
- **Get daily performance** insights

### **Weekly Updates** (Balanced approach)
- **Export data** every Monday
- **Process and upload** weekly
- **Get weekly trends** and patterns

### **Monthly Updates** (Minimal effort)
- **Export data** monthly
- **Process and upload** monthly
- **Get monthly** performance reports

## 📊 **Business Intelligence Queries**

### **Site Performance Comparison**
```sql
SELECT 
    site_name,
    COUNT(DISTINCT order_date) as active_days,
    SUM(orders_count) as total_orders,
    SUM(net_sales) as total_sales,
    ROUND(AVG(avg_order_value), 2) as avg_order_value,
    ROUND(SUM(net_sales) / COUNT(DISTINCT order_date), 2) as daily_avg_sales
FROM ops.franchise_sales 
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY site_name 
ORDER BY total_sales DESC;
```

### **Platform Performance**
```sql
SELECT 
    platform,
    SUM(orders_count) as total_orders,
    SUM(net_sales) as total_sales,
    ROUND(AVG(avg_order_value), 2) as avg_order_value,
    ROUND(AVG(delivery_rating), 2) as avg_rating
FROM ops.franchise_sales 
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY platform 
ORDER BY total_sales DESC;
```

### **Daily Sales Trends**
```sql
SELECT 
    order_date,
    SUM(orders_count) as total_orders,
    SUM(net_sales) as total_sales,
    ROUND(AVG(avg_order_value), 2) as avg_order_value
FROM ops.franchise_sales 
WHERE order_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY order_date 
ORDER BY order_date DESC;
```

## 🎯 **Pro Tips**

### **Data Quality Checks**
- **Check for missing dates** - ensure no gaps in data
- **Verify sales amounts** - spot-check against platform reports
- **Monitor order counts** - ensure they match platform data

### **Performance Monitoring**
- **Set up alerts** for unusual sales patterns
- **Track completion rates** - identify operational issues
- **Monitor delivery ratings** - maintain service quality

### **Future Automation**
- **API Integration** - connect directly to platform APIs
- **Scheduled Updates** - automate daily data pulls
- **Real-time Dashboards** - live performance monitoring

## 🚨 **Troubleshooting**

### **Common Issues**
- **Missing CSV files** - ensure all 4 site files are present
- **Date format errors** - check CSV date formats match expected
- **Upload failures** - verify CSV column mapping in Supabase
- **Duplicate records** - check for existing data before upload

### **Getting Help**
- **Check logs** - review processing script output
- **Verify data** - run verification queries
- **Test with sample** - try with small dataset first

---

**Happy updating! 🎉**
