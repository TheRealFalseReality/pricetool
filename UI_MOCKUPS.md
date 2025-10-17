# Visual UI Structure

## App Layout

```
┌─────────────────────────────────────────┐
│           App Bar (Teal)                │
│        [Page Title]                     │
└─────────────────────────────────────────┘
│                                         │
│                                         │
│         Main Content Area               │
│          (Dark Gray)                    │
│                                         │
│                                         │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│    Bottom Navigation Bar                │
│  [Products] [Statistics] [Settings]     │
└─────────────────────────────────────────┘
```

## 1. Products Page (Home)

```
┌─────────────────────────────────────────┐
│  Priced Products                        │
└─────────────────────────────────────────┘
│  ┌───────────────────────────────────┐  │
│  │  🔍 Search products...          ✕ │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ ┌─────┐                           │  │
│  │ │ IMG │  Product Name             │  │
│  │ │ 60x │  S: $20 ($8) | M: $25... │  │
│  │ └─────┘                      🔗 → │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ ┌─────┐                           │  │
│  │ │ IMG │  Another Product          │  │
│  │ │     │  S: $15 ($6) | L: $30... │  │
│  │ └─────┘                         → │  │
│  └───────────────────────────────────┘  │
│                                         │
│                    [+ Add Product] ←FAB │
└─────────────────────────────────────────┘
```

## 2. Statistics Page (NEW!)

```
┌─────────────────────────────────────────┐
│  Statistics Dashboard                   │
└─────────────────────────────────────────┘
│  Overview                               │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ 📦          │  │ 📑          │      │
│  │    12       │  │    36       │      │
│  │ Products    │  │ Variations  │      │
│  └─────────────┘  └─────────────┘      │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ 📈          │  │ 💰          │      │
│  │    10       │  │  $24.50     │      │
│  │ Profitable  │  │  Avg Price  │      │
│  └─────────────┘  └─────────────┘      │
│                                         │
│  Financial Overview                     │
│  ┌───────────────────────────────────┐  │
│  │ 💹 Total Potential Revenue        │  │
│  │                        $1,248.00  │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ 💰 Total Profit                   │  │
│  │                          $456.00  │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ 💵 Avg Profit per Variation       │  │
│  │                           $12.67  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Product Performance                    │
│  ┌───────────────────────────────────┐  │
│  │ ⭐ Best Performer                 │  │
│  │    Dragon Figurine            →  │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ 📊 Needs Attention                │  │
│  │    Small Keychain             →  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Quick Tools                            │
│  ┌───────────────────────────────────┐  │
│  │ 🔢 Bulk Discount Calculator       │  │
│  │    Calculate bulk order prices → │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ 📈 Profit Margin Analyzer         │  │
│  │    Compare product margins     → │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 3. Bulk Discount Calculator (NEW!)

```
┌─────────────────────────────────────────┐
│ ← Bulk Discount Calculator              │
└─────────────────────────────────────────┘
│  ┌───────────────────────────────────┐  │
│  │ 🛒 Order Details                  │  │
│  │                                   │  │
│  │ Quantity         [  10  ] items   │  │
│  │ Price per Item   [ 25.00 ] $      │  │
│  │ Bulk Discount    [  15  ] %       │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🧾 Pricing Breakdown              │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ Original Total         $250.00    │  │
│  │ Discount Savings       -$37.50    │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ Total with Discount    $212.50    │  │
│  │ Price per Unit          $21.25    │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 💡 Tip: Common bulk discounts...  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 4. Profit Margin Analyzer (NEW!)

```
┌─────────────────────────────────────────┐
│ ← Profit Margin Analyzer                │
└─────────────────────────────────────────┘
│  ┌───────────────────────────────────┐  │
│  │ ℹ️  Profit margin = (Profit/Price)│  │
│  │    × 100%. Higher = Better        │  │
│  └───────────────────────────────────┘  │
│                                         │
│  All Products by Margin                 │
│  ┌───────────────────────────────────┐  │
│  │ Dragon Figurine     [Excellent]   │  │
│  │ Large variant                     │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ Price  Cost   Profit  Margin      │  │
│  │ $50    $20    $30     60.0%       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ Plant Pot          [Good]         │  │
│  │ Medium variant                    │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ Price  Cost   Profit  Margin      │  │
│  │ $30    $12    $18     35.5%       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ Keychain           [Fair]         │  │
│  │ Small variant                     │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ Price  Cost   Profit  Margin      │  │
│  │ $15    $9     $6      25.0%       │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 5. Settings Page

```
┌─────────────────────────────────────────┐
│  Business Settings                      │
└─────────────────────────────────────────┘
│  ┌───────────────────────────────────┐  │
│  │ 🧮 Calculation Settings           │  │
│  │                                   │  │
│  │ Filament Cost ($/kg)              │  │
│  │ [ 17.50                         ] │  │
│  │                                   │  │
│  │ Electricity Cost ($/kWh)          │  │
│  │ [ 0.15                          ] │  │
│  │                                   │  │
│  │ Labor & Handling ($)              │  │
│  │ [ 3.00                          ] │  │
│  │                                   │  │
│  │ ... (more fields)                 │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────┐      │
│  │  💾 Save Settings             │      │
│  └──────────────────────────────┘      │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🗄️  Data Management               │  │
│  │                                   │  │
│  │ ┌──────────────────────────────┐ │  │
│  │ │  📦 Backup Data             │ │  │
│  │ └──────────────────────────────┘ │  │
│  │                                   │  │
│  │ ┌──────────────────────────────┐ │  │
│  │ │  🔄 Restore Data            │ │  │
│  │ └──────────────────────────────┘ │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 6. Product Detail/Edit Page

```
┌─────────────────────────────────────────┐
│ ← Edit Product                      🗑️  │
└─────────────────────────────────────────┘
│  ┌───────────────────────────────────┐  │
│  │ ℹ️  Product Information           │  │
│  │                                   │  │
│  │ Product Name                      │  │
│  │ [ Dragon Figurine             ] │  │
│  │                                   │  │
│  │ Image URL (Optional)              │  │
│  │ [ https://...                 ] │  │
│  │                                   │  │
│  │ Etsy Listing URL (Optional)       │  │
│  │ [ https://etsy.com/...        ] │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 📏 Product Variations             │  │
│  │ ┌─────┬─────┬─────┐              │  │
│  │ │Small│Medium│Large│              │  │
│  │ └─────┴─────┴─────┘              │  │
│  │                                   │  │
│  │ Print Time (hours)                │  │
│  │ [ 2.5                         ] │  │
│  │                                   │  │
│  │ Filament Used (grams)             │  │
│  │ [ 150                         ] │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────┐      │
│  │  🧮 Calculate & Save          │      │
│  └──────────────────────────────┘      │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🧾 Pricing Breakdown              │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ Size   Cost   Profit  Etsy Price │  │
│  │ Small  $5.50  $8.00      $20     │  │
│  │                 15%: $17.00      │  │
│  │                 25%: $15.00      │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│  │ Medium $7.20  $10.50     $26     │  │
│  │ Large  $9.80  $15.20     $38     │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Color Legend

- **Teal (#00BFA5)**: Primary actions, highlights, active states
- **Light Teal (#64FFDA)**: Secondary accents, success states
- **Dark Background (#0D1117)**: Main app background
- **Card Background (#161B22)**: Elevated surfaces, cards
- **Green**: Positive metrics, profits, good margins
- **Orange**: Warnings, fair margins, attention needed
- **Red**: Errors, low margins, critical items
- **Blue**: Information, tools, neutral actions
- **Purple**: Special tools, unique features
- **Gray**: Disabled states, secondary info

## Icons Used

- 📦 inventory_2 - Products
- 📊 analytics - Statistics
- ⚙️ settings - Settings
- 🔍 search - Search
- ➕ add - Add new
- 🗑️ delete - Delete
- 🔗 open_in_new - External links
- ⭐ star - Best performer
- 📈 trending_down - Needs attention
- 💰 attach_money - Money/pricing
- 💵 savings - Savings/profit
- 🧮 calculate - Calculations
- 📏 straighten - Measurements
- ℹ️ info_outline - Information
- 💡 lightbulb - Tips
- 🛒 shopping_cart - Shopping/bulk
- 🧾 receipt - Receipts/breakdown
- 💾 save - Save
- 📦 backup - Backup
- 🔄 restore - Restore

## Typography Scale

- **Headline Small**: 24sp, Bold - Page titles, section headers
- **Title Large**: 22sp, Bold - Card titles
- **Title Medium**: 16sp, Bold - Subsection titles
- **Body Large**: 16sp, Regular - Main content
- **Body Medium**: 14sp, Regular - Secondary content
- **Body Small**: 12sp, Regular - Tertiary content, captions
- **Label Large**: 14sp, Medium - Button labels
- **Label Medium**: 12sp, Medium - Chips, tags

## Spacing System

- **4px**: Tight spacing between related items
- **8px**: Small gaps, compact layouts
- **12px**: Standard spacing between elements
- **16px**: Default padding for cards and screens
- **20px**: Large spacing between sections
- **24px**: Extra spacing for major sections

## Border Radius

- **8px**: Small elements, chips
- **12px**: Buttons, input fields
- **16px**: Cards, major containers
