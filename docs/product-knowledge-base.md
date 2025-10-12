# 🎯 Product Intelligence Foundation - Complete Guide

## Overview

The Product Intelligence Foundation is Stage 0 of Big Appetite OS, providing the essential knowledge base that enables accurate belief extraction from customer signals. Without this foundation, the AI system would make incorrect inferences about customer preferences.

## 🎯 **Why This Matters**

**The Problem**: Without product knowledge, the system might think:
- "honey sesame" = spicy (❌ Wrong - it's actually sweet)
- "mango mazzaline" = mild (❌ Wrong - it's very hot, level 9)
- "buffalo" = sweet (❌ Wrong - it's tangy and spicy)

**The Solution**: Complete product knowledge base with:
- Precise spice levels (0-10 scale)
- Flavor profiles (sweet, savory, spicy, tangy, smoky)
- Customer descriptors and aliases
- Product-sauce mappings

## 🏗️ **Database Schema**

### **Core Tables**

1. **`products.sauces`** - Complete sauce knowledge base
2. **`products.spice_scale`** - Reference for spice level meanings
3. **`products.categories`** - Product organization
4. **`products.catalog`** - Main product catalog
5. **`products.product_sauces`** - Product-sauce mappings
6. **`products.product_aliases`** - Aliases for mention detection

### **Key Features**

- **Flavor Dimensions**: 0-10 scale for sweetness, savory, tanginess, smokiness, heat
- **Spice Levels**: 0-10 with customer tolerance guidance
- **Customer Intelligence**: How customers actually refer to products
- **Aliases**: Abbreviations, misspellings, colloquial terms
- **Business Intelligence**: Price tiers, popularity tiers, dietary flags

## 📊 **Data Population**

### **15 Sauces with Complete Attributes**

| Sauce | Spice Level | Primary Flavor | Sweetness | Key Attributes |
|-------|-------------|----------------|-----------|----------------|
| Chang's Honey Sesame | 1 | Sweet | 9 | Sticky, nutty, "the sweet one" |
| Jarv's Tangy Buffalo | 5 | Tangy | 2 | Vinegary, buttery, "the tangy one" |
| Mango Mazzaline | 9 | Spicy | 7 | Scotch bonnet, tropical heat |
| Korean Heat | 7 | Spicy | 5 | Gochujang, umami depth |
| Island BBQ | 3 | Smoky | 6 | Chipotle warmth, sticky |
| Plain | 0 | Savory | 0 | No sauce, naked wings |

### **Complete Menu Import**

- **Bundles**: 3 items (Deluxe, Snuggle, Family Feast)
- **Sandwiches**: 4 items with fixed sauces
- **Wraps**: 3 items with fixed sauces
- **Wings**: 3 sizes with 9 sauce options each
- **Boneless Bites**: 3 sizes with all sauce options
- **Tenders**: 2 sizes with 9 sauce options each
- **Loaded Fries**: 2 items with fixed sauces
- **Sides**: 7 items including Cajun Fries (spice level 4)
- **Kids Meals**: 2 items with sauce options
- **Drinks**: 8 beverage options

## 🔍 **Query Functions for Belief Extraction**

### **1. `detect_product_mention(signal_text)`**
Detects product and sauce mentions in customer signals.

```sql
SELECT * FROM products.detect_product_mention('I love honey sesame wings');
-- Returns: Chang's Honey Sesame with confidence 0.95, spice_level 1, primary_flavor 'sweet'
```

### **2. `get_sauce_attributes(search_sauce)`**
Gets complete sauce attributes as JSON.

```sql
SELECT products.get_sauce_attributes('honey sesame');
-- Returns: Complete JSON with all flavor dimensions, tags, etc.
```

### **3. `get_products_by_spice_level(min_level, max_level)`**
Finds products within a spice range.

```sql
SELECT * FROM products.get_products_by_spice_level(3, 5);
-- Returns: Island BBQ (3), Flamin Hoisin (5), Buffalo (5)
```

### **4. `search_sauces_by_attributes(min_sweetness, max_spice, required_tags)`**
Searches sauces by flavor attributes.

```sql
SELECT * FROM products.search_sauces_by_attributes(7, 3, NULL);
-- Returns: Sweet, mild sauces (Honey Sesame, Sweet Chilli, Honey Mustard)
```

## 🧪 **Testing & Validation**

### **Comprehensive Test Suite**

Run the test script to validate all functionality:

```bash
node products/test-product-knowledge.js
```

**Test Coverage**:
1. ✅ Sauce count verification (15 sauces)
2. ✅ Spice level distribution
3. ✅ Sweet sauces detection
4. ✅ Medium heat products
5. ✅ Product mention detection
6. ✅ Sauce attribute lookup
7. ✅ Sweet, mild options
8. ✅ Product-sauce mappings
9. ✅ Alias detection
10. ✅ Full integration test

### **Key Test Cases**

```sql
-- Test 1: Verify all sauces imported
SELECT COUNT(*) FROM products.sauces; -- Expected: 15

-- Test 2: Find sweet sauces
SELECT * FROM products.sauces WHERE primary_flavor = 'sweet' OR sweetness >= 7;

-- Test 3: Product mention detection
SELECT * FROM products.detect_product_mention('I love the honey sesame wings');

-- Test 4: Sauce attributes
SELECT products.get_sauce_attributes('honey sesame');
```

## 🚀 **Integration with Cognition Layer**

### **Example: Belief Extraction**

```javascript
// Customer signal: "honey sesame is my favourite"
const signal_text = "honey sesame is my favourite";

// Step 1: Detect product mention
const detected = await supabase.rpc('detect_product_mention', { signal_text });
// Returns: { entity_name: "Chang's Honey Sesame", spice_level: 1, primary_flavor: "sweet" }

// Step 2: Get full attributes
const attributes = await supabase.rpc('get_sauce_attributes', { 
  search_sauce: detected.entity_name 
});
// Returns: { spice_level: 1, sweetness: 9, savory: 4, tags: ["sweet", "sticky", "mild"] }

// Step 3: Extract beliefs (Stage 2 logic)
const beliefs_extracted = {
  sweet_preference: {
    value: 0.85,
    confidence: 0.78,
    evidence: "Mentioned favorite is honey sesame (sweetness: 9/10)"
  },
  mild_spice_preference: {
    value: 0.82,
    confidence: 0.74,
    evidence: "Favorite has spice_level: 1 (mild)"
  }
};

// ✅ Correctly inferred sweet preference
// ❌ Did NOT incorrectly infer spicy preference
```

## 📁 **File Structure**

```
products/
├── menu.json                    # Complete Wing Shack menu
├── import-menu.js              # Menu import script
└── test-product-knowledge.js   # Comprehensive test suite

supabase/migrations/
├── 020_create_products_schema.sql
├── 021_populate_spice_scale.sql
├── 022_populate_categories.sql
├── 023_populate_sauces.sql
├── 024_populate_aliases.sql
└── 025_create_query_functions.sql
```

## 🎯 **Success Criteria**

Stage 0 is complete when:

- ✅ All database tables created in products schema
- ✅ 15 sauces inserted with complete attributes
- ✅ Spice scale (0-10) populated
- ✅ 11 categories created
- ✅ All menu items from JSON imported into catalog
- ✅ Product-sauce mappings created (wings/boneless/tenders have 9 options)
- ✅ Aliases generated for common variations
- ✅ All 6 query functions working
- ✅ All 10 test queries pass
- ✅ Test: `SELECT * FROM products.detect_product_mention('I love honey sesame')` correctly identifies Chang's Honey Sesame
- ✅ Test: `SELECT products.get_sauce_attributes('honey sesame')` returns spice_level=1, primary_flavor='sweet'

## 🔄 **Next Steps**

After Stage 0 completion:

1. **Stage 1**: Actor Identification (match signals to customers)
2. **Stage 2**: Belief Extraction (extract meaning using product knowledge)
3. **Stage 3**: Cohort Discovery (find customer patterns)
4. **Stage 4**: Stimulus Generation (create targeted offers)
5. **Stage 5**: Outcome Analysis (measure and learn)

## 💡 **Key Design Principles**

### **Accuracy First**
- Every sauce has precise spice level and flavor profile
- No guessing - all data provided by domain expert
- Prevents wrong inferences about customer preferences

### **Queryable**
- Functions designed for belief extraction queries
- Fast lookups by spice, flavor, product
- Optimized for AI/cognition layer integration

### **Maintainable**
- Menu changes → update JSON → re-import
- New sauce → add one row with attributes
- Easy to extend and modify

### **Integration-Ready**
- Built to support Stage 1+2 belief extraction
- Query functions match what cognition layer needs
- Prevents wrong inferences about customer preferences

## 🎉 **Ready for Intelligence Layer**

The Product Intelligence Foundation provides the essential knowledge base that enables Big Appetite OS to understand customer preferences accurately. With this foundation, the system can:

- Correctly identify sweet vs. spicy preferences
- Understand flavor profiles and texture preferences
- Detect product mentions in customer signals
- Provide accurate recommendations based on preferences
- Build detailed customer profiles with precise product knowledge

**The foundation is solid - ready to build the intelligence layer!** 🚀
