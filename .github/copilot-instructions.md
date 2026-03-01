# Copilot Instructions for pricetool

## Project Overview

**pricetool** is a Flutter web application that calculates optimal pricing for Etsy products (primarily 3D-printed items). It tracks product variations (Small, Medium, Large), computes Etsy fees and profit margins, provides a statistics dashboard, and supports sales tracking with CSV import from Etsy order history.

The app is deployed as a static web site to GitHub Pages via the `.github/workflows/deploy.yml` workflow.

## Repository Structure

```
lib/
  main.dart          # Entire application in one file (~3850 lines)
web/
  index.html         # Flutter web entry point
  manifest.json
pubspec.yaml         # Project manifest and dependencies
analysis_options.yaml # Dart linting configuration
.github/
  workflows/
    deploy.yml       # GitHub Actions: build Flutter web + deploy to GitHub Pages
```

## Tech Stack

- **Language**: Dart (SDK `^3.9.2`)
- **Framework**: Flutter (stable channel, `3.x` in CI)
- **State Management**: `flutter_bloc` (BLoC pattern with `DataBloc`)
- **Local Storage**: `hive` + `hive_flutter` (typed boxes with manual adapters)
- **Packages**: `url_launcher`, `uuid`, `intl`, `file_picker`, `file_saver`, `cupertino_icons`
- **Linting**: `flutter_lints`
- **Design**: Material 3 dark theme (teal accent `#00BFA5`, backgrounds `#0D1117` / `#161B22`)

## Architecture: Single-File Design

All application code lives in `lib/main.dart`. The file is structured in clearly labeled sections:

1. **Part 1 – Data Models** (HiveObjects): `Category`, `ProductVariation`, `Product`, `Settings`
2. **Part 2 – Hive Type Adapters**: Manual adapters (`CategoryAdapter`, `ProductAdapter`, etc.)
3. **Part 3 – State Management (BLoC)**: `DataEvent` subclasses, `DataState`, `DataBloc`
4. **UI – Pages and Widgets**: `MyApp`, `MainNavigationPage`, `HomePage`, `StatisticsPage`, `SettingsPage`, `CategoryEditPage`, `ProductDetailPage`, and helper widgets

When adding new features, follow this same file layout. Do **not** split code into multiple files unless the single-file constraint is explicitly relaxed.

## Data Models

### `Product` (HiveType 0)
- `id`, `name`, `imageUrl`, `etsyUrl`, `categoryId`
- `smallVariation`, `mediumVariation`, `largeVariation` (required `ProductVariation`)
- `smallMulticolorVariation`, `mediumMulticolorVariation`, `largeMulticolorVariation` (optional)
- `totalSales` (int, default 0), `totalRevenue` (double, default 0.0)

### `ProductVariation` (HiveType 2)
- `printTimeHours`, `filamentGrams`, `etsyPrice`, `profit`, `originalPrice` (doubles)
- `numberOfModels` (int, for multicolor batch pricing, default 1)

### `Category` (HiveType 3)
Per-category cost settings: `filamentCostPerKg` (default 17.50), `laborCost` (3.00), `licenseFee` (2.00), `shippingCost` (2.00), `profitMargin` (40.0%). Advanced pricing fields (all default 0): `avoidanceZoneMin`/`Max`/`Threshold` (price range to avoid crossing), `smallPriceCap` (max price for small variation), `minGapSmallMedium`/`minGapMediumLarge` (minimum price gaps between sizes), `multicolorSmallPriceCap`/`multicolorSmallPriceMin` (caps for multicolor variant pricing).

### `Settings` (HiveType 1 via adapter)
Global Etsy settings: `electricityCostKwh` (0.15), `etsyFeesPercent` (9.5), `etsyListingFee` (0.20).

## BLoC Events

```dart
LoadData, AddProduct, UpdateProduct, DeleteProduct,
UpdateSettings, AddCategory, UpdateCategory, DeleteCategory,
RestoreData, IncrementSales
```

State: `DataState(products: List<Product>, settings: Settings, categories: List<Category>)`

## Key UI Pages

| Page | Class | Description |
|------|-------|-------------|
| Navigation shell | `MainNavigationPage` | Bottom nav bar with 3 tabs |
| Products list | `HomePage` | Search, product cards, quick-sale (+) button |
| Statistics | `StatisticsPage` | Dashboard with totals, best/worst performers |
| Settings | `SettingsPage` | Global costs, backup/restore, CSV import |
| Category editor | `CategoryEditPage` | Per-category cost configuration |
| Product editor | `ProductDetailPage` | Tabbed form (Small/Medium/Large + multicolor), pricing calculator |

## Common Development Commands

```bash
# Install dependencies
flutter pub get

# Lint / static analysis
flutter analyze

# Run in browser (development)
flutter run -d chrome

# Build for web production
flutter build web --release --base-href /pricetool/

# No automated tests exist yet (no test/ directory)
```

## CI/CD Pipeline

The `.github/workflows/deploy.yml` workflow triggers on every push to `main`:
1. Checks out the repo
2. Sets up Flutter stable (`3.x`)
3. Runs `flutter pub get`
4. Builds with `flutter build web --release --base-href /${{ github.event.repository.name }}/`
5. Deploys the `./build/web` directory to the `gh-pages` branch via `peaceiris/actions-gh-pages@v3`

## Known Issues / Workarounds

### `pubspec.yaml`: Dependencies in wrong section
Several runtime packages are listed under `dev_dependencies` instead of `dependencies` in `pubspec.yaml`:
- `flutter_bloc`, `hive`, `hive_flutter`, `path_provider`, `uuid`, `url_launcher`, `intl`, `file_picker`, `file_saver`

**Why it still works**: For a standalone compiled Flutter app, `flutter build web` includes all imported packages regardless of which section they're in. However, this is technically incorrect and would break if this package were ever used as a library dependency. When adding new runtime packages, place them under `dependencies:`, not `dev_dependencies:`.

### Hive Adapters
Hive adapters are written manually (no code generation). When adding new `@HiveField` annotations to existing models, you must also update the corresponding `TypeAdapter.read()` and `write()` methods in Part 2, and handle missing fields gracefully for backward compatibility (use `fields.containsKey(n) ? ... : defaultValue`).

### Single-File Limitation
The entire application is one large file. When making changes, be careful about:
- Maintaining the existing section comments (`// --- Part X: ... ---`)
- Not breaking Hive type IDs (they must remain stable across app versions)

## Coding Conventions

- Use `const` constructors wherever possible
- Widget classes follow Flutter naming: `class FooPage extends StatefulWidget` / `class _FooPageState extends State<FooPage>`
- Helper widgets use underscore prefix: `class _StatCard extends StatelessWidget`
- JSON serialization: every model has `toJson()` and `fromJson()` methods; use `(json['field'] as num? ?? defaultValue).toDouble()` pattern for nullable/legacy fields
- Theme colors: use `Theme.of(context).colorScheme` or the constants already defined in `MyApp`
- Use `BlocBuilder<DataBloc, DataState>` to read state; dispatch events via `context.read<DataBloc>().add(...)`
- Date formatting uses `intl` package (`DateFormat`, `NumberFormat`)
