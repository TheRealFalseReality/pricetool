# Sales Tracking Feature - Visual Summary

## New UI Elements

### Product Card with Sales Tracking

```
┌───────────────────────────────────────────────────┐
│ ┌─────┐                                           │
│ │ IMG │  Elephant Figurine                   🔵+  │
│ │ 60x │  S: $30 ($12) | M: $46 ($18)         🔗  │
│ └─────┘  Sales: 12 • Revenue: $456.00        →   │
└───────────────────────────────────────────────────┘
         └─ New sales info row
                                               └─ +1 quick add button
```

### Statistics Page - New Cards

```
┌──────────────────────────┬──────────────────────────┐
│ 🛒                       │ 💰                       │
│    67                    │    $1,248.50            │
│ Total Sales              │ Revenue                 │
└──────────────────────────┴──────────────────────────┘
```

### Enhanced Product Performance

```
┌───────────────────────────────────────────────────┐
│ ⭐ Best Performer (Most Sales)                    │
│    Elephant Figurine                              │
│    12 sales • $456.00 revenue                 →   │
└───────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────┐
│ 📊 Needs Attention (Low Sales)                    │
│    Bunny Figurine                                 │
│    2 sales • $52.00 revenue                   →   │
└───────────────────────────────────────────────────┘
```

### Add Sale Dialog

```
┌─────────────────────────────┐
│ Add Sale                    │
├─────────────────────────────┤
│ Product: Elephant Figurine  │
│                             │
│ Sale Amount ($)             │
│ $ [38.00              ]     │
│                             │
│         [Cancel] [Add Sale] │
└─────────────────────────────┘
```

### Settings Page - New Import Button

```
┌───────────────────────────────────────┐
│ 🗄️  Data Management                   │
│                                       │
│ ┌──────────────────────────────────┐ │
│ │  📦 Backup Data                 │ │
│ └──────────────────────────────────┘ │
│                                       │
│ ┌──────────────────────────────────┐ │
│ │  🔄 Restore Data                │ │
│ └──────────────────────────────────┘ │
│                                       │
│ ┌──────────────────────────────────┐ │
│ │  📤 Import Sales from CSV       │ │  ← NEW!
│ └──────────────────────────────────┘ │
└───────────────────────────────────────┘
```

## Feature Flow

### Adding a Sale

1. User sees product card with current sales count
2. Clicks green (+) button
3. Dialog opens with pre-filled average price
4. User adjusts amount if needed
5. Clicks "Add Sale"
6. Sales count increments by 1
7. Revenue increases by sale amount
8. Statistics update automatically

### Importing from CSV

1. User navigates to Settings
2. Clicks "Import Sales from CSV"
3. Selects Etsy order history CSV
4. App parses CSV and extracts:
   - Item Name
   - Quantity
   - Price
   - Item Total
5. App performs fuzzy matching on product names:
   - "The Elegant Elephant - Majestic Modernity" → "Elephant Figurine"
   - "Black Cat Figurine: Modern Minimalist Sculpture" → "Cat Figurine"
6. Aggregates sales by product
7. Updates all matched products
8. Shows success message: "Imported sales for 8 products!"

### Product Name Matching Examples

CSV names matched to product names:

| CSV Name | Product Name | Match Type |
|----------|--------------|------------|
| "The Elegant Elephant - Majestic Modernity" | "Elephant Figurine" | Contains "elephant" |
| "Sculpted Elephant Figurine: Modern 3D Print" | "Elephant Figurine" | Contains "elephant" |
| "Black Cat Figurine: Modern Minimalist Sculpture" | "Cat Figurine" | Contains "cat" |
| "The Contemplative Cat - Silent Silhouette" | "Cat Figurine" | Contains "cat" |
| "Dog Labrador Figurine" | "Dog Labrador Figurine" | Exact match |
| "Light Lifters (Set of 2) (Black)" | "Light Lifters" | Contains match |

## Data Model Changes

### Product Class - New Fields

```dart
@HiveField(7)
late int totalSales;

@HiveField(8)
late double totalRevenue;
```

### BLoC Events - New Event

```dart
class IncrementSales extends DataEvent {
  final String productId;
  final double saleAmount;
  IncrementSales(this.productId, this.saleAmount);
}
```

## Statistics Calculation Changes

### Before
```dart
// Performance based on profit
if (avgProductProfit > maxProfit) {
  maxProfit = avgProductProfit;
  bestProduct = product;
}
```

### After
```dart
// Performance based on sales count
if (product.totalSales >= maxSales) {
  maxSales = product.totalSales;
  bestProduct = product;
}

// Track total sales and revenue
totalSalesCount += product.totalSales;
totalActualRevenue += product.totalRevenue;
```

## CSV Import Algorithm

### Fuzzy Matching Strategy

1. **Normalize Names**: Remove common words
   - "figurine", "sculpture", "modern", "3d print"
   - Special characters (: - )
   - Leading "the"
   
2. **Compare Cleaned Names**:
   - Check if one contains the other
   - Calculate Levenshtein distance
   - Accept if distance < 5 characters

3. **Example**:
   ```
   Product: "Elephant Figurine"
   CSV: "The Elegant Elephant - Majestic Modernity"
   
   Cleaned Product: "elephant"
   Cleaned CSV: "elegant elephant majestic modernity"
   
   Result: MATCH (CSV contains product name)
   ```

### Aggregation

From CSV data:
```
Line 1: Elephant, Quantity: 1, Total: $36.00
Line 2: Elephant, Quantity: 1, Total: $46.00
Line 3: Elephant, Quantity: 1, Total: $30.00

Aggregated:
- Total Sales: 3
- Total Revenue: $112.00
```

## User Benefits

### Quick Recording
- No need to navigate to product detail
- One tap to record sale
- Pre-filled with average price
- Instant feedback

### Historical Data
- Import years of sales history
- Automatic product matching
- Aggregated statistics
- No manual entry needed

### Better Insights
- See which products actually sell
- Track revenue vs potential
- Identify bestsellers
- Focus on profitable products

### Performance Metrics
- Sales-based ranking (not just profit)
- Revenue tracking
- Easy comparison
- Actionable data

## Technical Implementation

### Backward Compatibility
- New fields default to 0
- Existing products work unchanged
- Optional feature (can be unused)
- No data migration needed

### State Management
- BLoC handles sales increment
- Automatic UI updates
- Consistent state across app
- Proper event handling

### CSV Parsing
- Handles quoted fields
- Supports multi-line data
- Error handling
- Progress feedback

### Fuzzy Matching
- Levenshtein distance algorithm
- Common word removal
- Case-insensitive comparison
- Configurable threshold
