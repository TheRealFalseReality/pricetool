import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// --- Platform Specific Packages for Backup/Restore ---
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


// --- Part 1: Database Models ---

@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late double filamentCostPerKg;
  @HiveField(3)
  late double laborCost;
  @HiveField(4)
  late double licenseFee;
  @HiveField(5)
  late double shippingCost;
  @HiveField(6)
  late double profitMargin;
  @HiveField(7)
  late double avoidanceZoneMin;
  @HiveField(8)
  late double avoidanceZoneMax;
  @HiveField(9)
  late double avoidanceZoneThreshold;
  @HiveField(10)
  late double smallPriceCap;
  @HiveField(11)
  late double minGapSmallMedium;
  @HiveField(12)
  late double minGapMediumLarge;
  @HiveField(13)
  late double multicolorSmallPriceCap;
  @HiveField(14)
  late double multicolorSmallPriceMin;
  @HiveField(15)
  List<String>? variationSizeNames;

  /// The ordered list of size names for this category.
  /// Defaults to ['Small', 'Medium', 'Large'] if not set.
  List<String> get effectiveSizeNames => variationSizeNames ?? ['Small', 'Medium', 'Large'];

  Category({
    required this.id,
    required this.name,
    this.filamentCostPerKg = 17.50,
    this.laborCost = 3.00,
    this.licenseFee = 2.00,
    this.shippingCost = 2.00,
    this.profitMargin = 40.0,
    this.avoidanceZoneMin = 0,
    this.avoidanceZoneMax = 0,
    this.avoidanceZoneThreshold = 0,
    this.smallPriceCap = 0,
    this.minGapSmallMedium = 0,
    this.minGapMediumLarge = 0,
    this.multicolorSmallPriceCap = 0,
    this.multicolorSmallPriceMin = 0,
    this.variationSizeNames,
  });

  // For JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'filamentCostPerKg': filamentCostPerKg,
    'laborCost': laborCost,
    'licenseFee': licenseFee,
    'shippingCost': shippingCost,
    'profitMargin': profitMargin,
    'avoidanceZoneMin': avoidanceZoneMin,
    'avoidanceZoneMax': avoidanceZoneMax,
    'avoidanceZoneThreshold': avoidanceZoneThreshold,
    'smallPriceCap': smallPriceCap,
    'minGapSmallMedium': minGapSmallMedium,
    'minGapMediumLarge': minGapMediumLarge,
    'multicolorSmallPriceCap': multicolorSmallPriceCap,
    'multicolorSmallPriceMin': multicolorSmallPriceMin,
    'variationSizeNames': variationSizeNames,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    filamentCostPerKg: (json['filamentCostPerKg'] as num).toDouble(),
    laborCost: (json['laborCost'] as num).toDouble(),
    licenseFee: (json['licenseFee'] as num).toDouble(),
    shippingCost: (json['shippingCost'] as num).toDouble(),
    profitMargin: (json['profitMargin'] as num).toDouble(),
    avoidanceZoneMin: (json['avoidanceZoneMin'] as num? ?? 0).toDouble(),
    avoidanceZoneMax: (json['avoidanceZoneMax'] as num? ?? 0).toDouble(),
    avoidanceZoneThreshold: (json['avoidanceZoneThreshold'] as num? ?? 0).toDouble(),
    smallPriceCap: (json['smallPriceCap'] as num? ?? 0).toDouble(),
    minGapSmallMedium: (json['minGapSmallMedium'] as num? ?? 0).toDouble(),
    minGapMediumLarge: (json['minGapMediumLarge'] as num? ?? 0).toDouble(),
    multicolorSmallPriceCap: (json['multicolorSmallPriceCap'] as num? ?? 0).toDouble(),
    multicolorSmallPriceMin: (json['multicolorSmallPriceMin'] as num? ?? 0).toDouble(),
    variationSizeNames: json['variationSizeNames'] != null
        ? (json['variationSizeNames'] as List).cast<String>()
        : null,
  );
}

@HiveType(typeId: 2)
class ProductVariation extends HiveObject {
  @HiveField(0)
  late double printTimeHours;
  @HiveField(1)
  late double filamentGrams;
  @HiveField(2)
  late double etsyPrice;
  @HiveField(3) // New field to store the calculated profit
  late double profit;
  @HiveField(4) // Field to store the original unadjusted price
  late double originalPrice;
  @HiveField(5) // Number of models (used for multicolor batch pricing)
  late int numberOfModels;

  ProductVariation({
    this.printTimeHours = 0.0,
    this.filamentGrams = 0.0,
    this.etsyPrice = 0.0,
    this.profit = 0.0,
    this.originalPrice = 0.0,
    this.numberOfModels = 1,
  });
  
  // For JSON serialization
  Map<String, dynamic> toJson() => {
    'printTimeHours': printTimeHours,
    'filamentGrams': filamentGrams,
    'etsyPrice': etsyPrice,
    'profit': profit,
    'originalPrice': originalPrice,
    'numberOfModels': numberOfModels,
  };

  factory ProductVariation.fromJson(Map<String, dynamic> json) => ProductVariation(
    printTimeHours: (json['printTimeHours'] as num).toDouble(),
    filamentGrams: (json['filamentGrams'] as num).toDouble(),
    etsyPrice: (json['etsyPrice'] as num? ?? 0.0).toDouble(), // Handle legacy data
    profit: (json['profit'] as num? ?? 0.0).toDouble(), // Handle legacy data
    originalPrice: (json['originalPrice'] as num? ?? 0.0).toDouble(), // Handle legacy data
    numberOfModels: (json['numberOfModels'] as num? ?? 1).toInt(), // Handle legacy data
  );
}

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late ProductVariation smallVariation;
  @HiveField(3)
  late ProductVariation mediumVariation;
  @HiveField(4)
  late ProductVariation largeVariation;
  @HiveField(5)
  late String? imageUrl;
  @HiveField(6)
  late String? listingUrl;
  @HiveField(7)
  late int totalSales;
  @HiveField(8)
  late double totalRevenue;
  @HiveField(9)
  late String categoryId;
  @HiveField(10)
  ProductVariation? smallMulticolorVariation;
  @HiveField(11)
  ProductVariation? mediumMulticolorVariation;
  @HiveField(12)
  ProductVariation? largeMulticolorVariation;
  @HiveField(13)
  List<ProductVariation>? additionalVariations;
  @HiveField(14)
  List<String>? additionalVariationNames;

  Product({
    required this.id,
    required this.name,
    required this.smallVariation,
    required this.mediumVariation,
    required this.largeVariation,
    this.imageUrl,
    this.listingUrl,
    this.totalSales = 0,
    this.totalRevenue = 0.0,
    required this.categoryId,
    this.smallMulticolorVariation,
    this.mediumMulticolorVariation,
    this.largeMulticolorVariation,
    this.additionalVariations,
    this.additionalVariationNames,
  });

  // For JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'smallVariation': smallVariation.toJson(),
    'mediumVariation': mediumVariation.toJson(),
    'largeVariation': largeVariation.toJson(),
    'imageUrl': imageUrl,
    'listingUrl': listingUrl,
    'totalSales': totalSales,
    'totalRevenue': totalRevenue,
    'categoryId': categoryId,
    'smallMulticolorVariation': smallMulticolorVariation?.toJson(),
    'mediumMulticolorVariation': mediumMulticolorVariation?.toJson(),
    'largeMulticolorVariation': largeMulticolorVariation?.toJson(),
    'additionalVariations': additionalVariations?.map((v) => v.toJson()).toList(),
    'additionalVariationNames': additionalVariationNames,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    smallVariation: ProductVariation.fromJson(json['smallVariation']),
    mediumVariation: ProductVariation.fromJson(json['mediumVariation']),
    largeVariation: ProductVariation.fromJson(json['largeVariation']),
    imageUrl: json['imageUrl'] as String?,
    listingUrl: json['listingUrl'] as String?,
    totalSales: (json['totalSales'] as num? ?? 0).toInt(),
    totalRevenue: (json['totalRevenue'] as num? ?? 0.0).toDouble(),
    categoryId: json['categoryId'] as String? ?? 'default_3d_models', // Default for backward compatibility
    smallMulticolorVariation: json['smallMulticolorVariation'] != null 
        ? ProductVariation.fromJson(json['smallMulticolorVariation'])
        : null,
    mediumMulticolorVariation: json['mediumMulticolorVariation'] != null 
        ? ProductVariation.fromJson(json['mediumMulticolorVariation'])
        : null,
    largeMulticolorVariation: json['largeMulticolorVariation'] != null 
        ? ProductVariation.fromJson(json['largeMulticolorVariation'])
        : null,
    additionalVariations: json['additionalVariations'] != null
        ? (json['additionalVariations'] as List).map((v) => ProductVariation.fromJson(v as Map<String, dynamic>)).toList()
        : null,
    additionalVariationNames: json['additionalVariationNames'] != null
        ? (json['additionalVariationNames'] as List).cast<String>()
        : null,
  );
}

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  late double electricityCostKwh;
  @HiveField(1)
  late double etsyFeesPercent;
  @HiveField(2)
  late double etsyListingFee;

  Settings.defaults() {
    electricityCostKwh = 0.15;
    etsyFeesPercent = 9.5;
    etsyListingFee = 0.20;
  }
  
  // For JSON serialization
  Map<String, dynamic> toJson() => {
    'electricityCostKwh': electricityCostKwh,
    'etsyFeesPercent': etsyFeesPercent,
    'etsyListingFee': etsyListingFee,
  };

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings.defaults()
      ..electricityCostKwh = (json['electricityCostKwh'] as num).toDouble()
      ..etsyFeesPercent = (json['etsyFeesPercent'] as num).toDouble()
      ..etsyListingFee = (json['etsyListingFee'] as num).toDouble();
  }
  
  // Helper method to create from old settings for backward compatibility
  factory Settings.fromLegacy(Map<String, dynamic> json) {
    return Settings.defaults()
      ..electricityCostKwh = (json['electricityCostKwh'] as num? ?? 0.15).toDouble()
      ..etsyFeesPercent = (json['etsyFeesPercent'] as num? ?? 9.5).toDouble()
      ..etsyListingFee = (json['etsyListingFee'] as num? ?? 0.20).toDouble();
  }
}

// --- Part 2: Manual Hive Type Adapters ---

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 3;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      id: fields[0] as String,
      name: fields[1] as String,
      filamentCostPerKg: fields[2] as double,
      laborCost: fields[3] as double,
      licenseFee: fields[4] as double,
      shippingCost: fields[5] as double,
      profitMargin: fields[6] as double,
      avoidanceZoneMin: fields.containsKey(7) ? fields[7] as double : 0,
      avoidanceZoneMax: fields.containsKey(8) ? fields[8] as double : 0,
      avoidanceZoneThreshold: fields.containsKey(9) ? fields[9] as double : 0,
      smallPriceCap: fields.containsKey(10) ? fields[10] as double : 0,
      minGapSmallMedium: fields.containsKey(11) ? fields[11] as double : 0,
      minGapMediumLarge: fields.containsKey(12) ? fields[12] as double : 0,
      multicolorSmallPriceCap: fields.containsKey(13) ? fields[13] as double : 0,
      multicolorSmallPriceMin: fields.containsKey(14) ? fields[14] as double : 0,
      variationSizeNames: fields.containsKey(15) ? (fields[15] as List?)?.cast<String>() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.filamentCostPerKg)
      ..writeByte(3)
      ..write(obj.laborCost)
      ..writeByte(4)
      ..write(obj.licenseFee)
      ..writeByte(5)
      ..write(obj.shippingCost)
      ..writeByte(6)
      ..write(obj.profitMargin)
      ..writeByte(7)
      ..write(obj.avoidanceZoneMin)
      ..writeByte(8)
      ..write(obj.avoidanceZoneMax)
      ..writeByte(9)
      ..write(obj.avoidanceZoneThreshold)
      ..writeByte(10)
      ..write(obj.smallPriceCap)
      ..writeByte(11)
      ..write(obj.minGapSmallMedium)
      ..writeByte(12)
      ..write(obj.minGapMediumLarge)
      ..writeByte(13)
      ..write(obj.multicolorSmallPriceCap)
      ..writeByte(14)
      ..write(obj.multicolorSmallPriceMin)
      ..writeByte(15)
      ..write(obj.variationSizeNames);
  }
}

class ProductVariationAdapter extends TypeAdapter<ProductVariation> {
  @override
  final int typeId = 2;

  @override
  ProductVariation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductVariation(
      printTimeHours: fields[0] as double,
      filamentGrams: fields[1] as double,
      etsyPrice: fields[2] as double,
      profit: fields.containsKey(3) ? fields[3] as double : 0.0, // Backwards compatible
      originalPrice: fields.containsKey(4) ? fields[4] as double : 0.0, // Backwards compatible
      numberOfModels: fields.containsKey(5) ? fields[5] as int : 1, // Backwards compatible
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariation obj) {
    writer
      ..writeByte(6) // Total number of fields being serialized
      ..writeByte(0)
      ..write(obj.printTimeHours)
      ..writeByte(1)
      ..write(obj.filamentGrams)
      ..writeByte(2)
      ..write(obj.etsyPrice)
      ..writeByte(3)
      ..write(obj.profit)
      ..writeByte(4)
      ..write(obj.originalPrice)
      ..writeByte(5)
      ..write(obj.numberOfModels);
  }
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      smallVariation: fields[2] as ProductVariation,
      mediumVariation: fields[3] as ProductVariation,
      largeVariation: fields[4] as ProductVariation,
      imageUrl: fields[5] as String?,
      listingUrl: fields[6] as String?,
      totalSales: fields.containsKey(7) ? fields[7] as int : 0,
      totalRevenue: fields.containsKey(8) ? fields[8] as double : 0.0,
      categoryId: fields.containsKey(9) ? fields[9] as String : 'default_3d_models',
      smallMulticolorVariation: fields.containsKey(10) ? fields[10] as ProductVariation? : null,
      mediumMulticolorVariation: fields.containsKey(11) ? fields[11] as ProductVariation? : null,
      largeMulticolorVariation: fields.containsKey(12) ? fields[12] as ProductVariation? : null,
      additionalVariations: fields.containsKey(13) ? (fields[13] as List?)?.cast<ProductVariation>() : null,
      additionalVariationNames: fields.containsKey(14) ? (fields[14] as List?)?.cast<String>() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.smallVariation)
      ..writeByte(3)
      ..write(obj.mediumVariation)
      ..writeByte(4)
      ..write(obj.largeVariation)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.listingUrl)
      ..writeByte(7)
      ..write(obj.totalSales)
      ..writeByte(8)
      ..write(obj.totalRevenue)
      ..writeByte(9)
      ..write(obj.categoryId)
      ..writeByte(10)
      ..write(obj.smallMulticolorVariation)
      ..writeByte(11)
      ..write(obj.mediumMulticolorVariation)
      ..writeByte(12)
      ..write(obj.largeMulticolorVariation)
      ..writeByte(13)
      ..write(obj.additionalVariations)
      ..writeByte(14)
      ..write(obj.additionalVariationNames);
  }
}

class SettingsAdapter extends TypeAdapter<Settings> {
    @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings.defaults()
      ..electricityCostKwh = fields[0] as double
      ..etsyFeesPercent = fields[1] as double
      ..etsyListingFee = fields[2] as double;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.electricityCostKwh)
      ..writeByte(1)
      ..write(obj.etsyFeesPercent)
      ..writeByte(2)
      ..write(obj.etsyListingFee);
  }
}


// --- Part 3: State Management (BLoC) ---
abstract class DataEvent {}
class LoadData extends DataEvent {}
class AddProduct extends DataEvent {
  final Product product;
  AddProduct(this.product);
}
class UpdateProduct extends DataEvent {
  final Product product;
  UpdateProduct(this.product);
}
class DeleteProduct extends DataEvent {
    final String id;
    DeleteProduct(this.id);
}
class UpdateSettings extends DataEvent {
  final Settings settings;
  UpdateSettings(this.settings);
}
class AddCategory extends DataEvent {
  final Category category;
  AddCategory(this.category);
}
class UpdateCategory extends DataEvent {
  final Category category;
  UpdateCategory(this.category);
}
class DeleteCategory extends DataEvent {
  final String id;
  DeleteCategory(this.id);
}
class RestoreData extends DataEvent {
  final String jsonData;
  RestoreData(this.jsonData);
}
class IncrementSales extends DataEvent {
  final String productId;
  final double saleAmount;
  IncrementSales(this.productId, this.saleAmount);
}
class RecalculateAllPrices extends DataEvent {
  final Settings settings;
  final List<Category> categories;
  RecalculateAllPrices({required this.settings, required this.categories});
}

class DataState {
  final List<Product> products;
  final Settings settings;
  final List<Category> categories;
  DataState({required this.products, required this.settings, required this.categories});
}

class DataBloc extends Bloc<DataEvent, DataState> {
  final Box<Product> productBox;
  final Box<Settings> settingsBox;
  final Box<Category> categoryBox;

  DataBloc(this.productBox, this.settingsBox, this.categoryBox) : super(DataState(products: [], settings: Settings.defaults(), categories: [])) {
    on<LoadData>(_onLoadData);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<UpdateSettings>(_onUpdateSettings);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<RestoreData>(_onRestoreData);
    on<IncrementSales>(_onIncrementSales);
    on<RecalculateAllPrices>(_onRecalculateAllPrices);
  }

  void _onLoadData(LoadData event, Emitter<DataState> emit) {
    final products = productBox.values.toList();
    products.sort((a, b) => a.name.compareTo(b.name));
    final settings = settingsBox.get('main', defaultValue: Settings.defaults())!;
    
    // Load categories or create default if none exist
    var categories = categoryBox.values.toList();
    if (categories.isEmpty) {
      final defaultCategory = Category(
        id: 'default_3d_models',
        name: '3D Models',
      );
      categoryBox.put(defaultCategory.id, defaultCategory);
      categories = [defaultCategory];
    }
    categories.sort((a, b) => a.name.compareTo(b.name));
    
    emit(DataState(products: products, settings: settings, categories: categories));
  }

  Future<void> _onAddProduct(AddProduct event, Emitter<DataState> emit) async {
    await productBox.put(event.product.id, event.product);
    add(LoadData());
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<DataState> emit) async {
    await productBox.put(event.product.id, event.product);
    add(LoadData());
  }
  
  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<DataState> emit) async {
    await productBox.delete(event.id);
    add(LoadData());
  }

  Future<void> _onUpdateSettings(UpdateSettings event, Emitter<DataState> emit) async {
    await settingsBox.put('main', event.settings);
    add(LoadData());
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<DataState> emit) async {
    await categoryBox.put(event.category.id, event.category);
    add(LoadData());
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<DataState> emit) async {
    await categoryBox.put(event.category.id, event.category);
    add(LoadData());
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<DataState> emit) async {
    // Don't allow deletion of the last category
    if (categoryBox.length <= 1) {
      return;
    }
    
    // Reassign products from deleted category to the first remaining category
    final products = productBox.values.where((p) => p.categoryId == event.id).toList();
    if (products.isNotEmpty) {
      final remainingCategories = categoryBox.values.where((c) => c.id != event.id).toList();
      if (remainingCategories.isNotEmpty) {
        final newCategoryId = remainingCategories.first.id;
        for (var product in products) {
          product.categoryId = newCategoryId;
          await productBox.put(product.id, product);
        }
      }
    }
    
    await categoryBox.delete(event.id);
    add(LoadData());
  }

  Future<void> _onRestoreData(RestoreData event, Emitter<DataState> emit) async {
    try {
      final data = jsonDecode(event.jsonData) as Map<String, dynamic>;
      
      // Restore Settings
      final settingsData = data['settings'] as Map<String, dynamic>?;
      if (settingsData != null) {
        final newSettings = settingsData.containsKey('filamentCostPerKg') 
            ? Settings.fromLegacy(settingsData)  // Old format
            : Settings.fromJson(settingsData);    // New format
        await settingsBox.put('main', newSettings);
      }

      // Restore Categories
      final categoriesData = data['categories'] as List?;
      if (categoriesData != null && categoriesData.isNotEmpty) {
        final newCategories = categoriesData.map((c) => Category.fromJson(c)).toList();
        await categoryBox.clear();
        for (var category in newCategories) {
          await categoryBox.put(category.id, category);
        }
      } else {
        // If no categories in backup, create default and migrate old settings
        await categoryBox.clear();
        final defaultCategory = Category(
          id: 'default_3d_models',
          name: '3D Models',
        );
        
        // Migrate old settings values if they exist
        if (settingsData != null && settingsData.containsKey('filamentCostPerKg')) {
          defaultCategory.filamentCostPerKg = (settingsData['filamentCostPerKg'] as num? ?? 17.50).toDouble();
          defaultCategory.laborCost = (settingsData['laborCost'] as num? ?? 3.00).toDouble();
          defaultCategory.licenseFee = (settingsData['licenseFee'] as num? ?? 2.00).toDouble();
          defaultCategory.shippingCost = (settingsData['shippingCost'] as num? ?? 2.00).toDouble();
          defaultCategory.profitMargin = (settingsData['profitMargin'] as num? ?? 40.0).toDouble();
        }
        
        await categoryBox.put(defaultCategory.id, defaultCategory);
      }

      // Restore Products
      final productsData = data['products'] as List;
      final newProducts = productsData.map((p) => Product.fromJson(p)).toList();
      await productBox.clear();
      for (var product in newProducts) {
        await productBox.put(product.id, product);
      }
      
      add(LoadData());
    } catch (e) {
      // Handle potential errors during restore
      print("Error restoring data: $e");
    }
  }

  Future<void> _onIncrementSales(IncrementSales event, Emitter<DataState> emit) async {
    final product = productBox.get(event.productId);
    if (product != null) {
      product.totalSales += 1;
      product.totalRevenue += event.saleAmount;
      await productBox.put(event.productId, product);
      add(LoadData());
    }
  }

  Future<void> _onRecalculateAllPrices(RecalculateAllPrices event, Emitter<DataState> emit) async {
    await settingsBox.put('main', event.settings);
    for (final category in event.categories) {
      await categoryBox.put(category.id, category);
    }
    // Build a lookup map to avoid O(N×M) firstWhere inside the product loop
    final categoryMap = {for (final c in event.categories) c.id: c};
    final fallback = event.categories.first;
    for (final product in productBox.values.toList()) {
      final category = categoryMap[product.categoryId] ?? fallback;
      final updated = computeProductPricing(product, category, event.settings);
      await productBox.put(updated.id, updated);
    }
    add(LoadData());
  }
}

// --- Main App Entry Point ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ProductVariationAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SettingsAdapter());

  final productBox = await Hive.openBox<Product>('products');
  final settingsBox = await Hive.openBox<Settings>('settings');
  final categoryBox = await Hive.openBox<Category>('categories');
  
  runApp(MyApp(productBox: productBox, settingsBox: settingsBox, categoryBox: categoryBox));
}

class MyApp extends StatelessWidget {
  final Box<Product> productBox;
  final Box<Settings> settingsBox;
  final Box<Category> categoryBox;

  const MyApp({super.key, required this.productBox, required this.settingsBox, required this.categoryBox});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataBloc(productBox, settingsBox, categoryBox)..add(LoadData()),
      child: MaterialApp(
        title: 'Etsy Pricing Calculator',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          primaryColor: const Color(0xFF00BFA5),
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00BFA5),
            secondary: Color(0xFF64FFDA),
            surface: Color(0xFF161B22),
            background: Color(0xFF0D1117),
            onPrimary: Colors.black,
            onSecondary: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161B22),
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF161B22),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF161B22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
            ),
          ),
        ),
        home: const MainNavigationPage(),
      ),
    );
  }
}

// --- Part 3.5: Shared Pricing Business Logic ---
// These top-level functions are used by both ProductDetailPage and the BLoC
// handler for RecalculateAllPrices. They shadow the instance methods of the
// same name in _ProductDetailPageState (Dart resolves them by scope).

double _roundToNearestEven(double value) {
  double roundedUp = value.ceilToDouble();
  if (roundedUp % 2 != 0) return roundedUp + 1;
  return roundedUp;
}

double _applyAvoidanceZone(double price, double minZone, double maxZone, double threshold) {
  if (minZone <= 0 || maxZone <= 0 || minZone >= maxZone) return price;
  if (price > minZone && price < maxZone) {
    if (threshold > 0 && threshold <= (maxZone - minZone)) {
      return price <= minZone + threshold ? minZone : maxZone;
    }
    return (price - minZone) < (maxZone - price) ? minZone : maxZone;
  }
  return price;
}

/// Recalculates all variation prices for [product] using [category] and [settings].
/// Preserves totalSales and totalRevenue. Applies caps and gap adjustments.
Product computeProductPricing(Product product, Category category, Settings settings) {
  ProductVariation calcSingleColor(ProductVariation v) {
    if (v.printTimeHours <= 0 || v.filamentGrams <= 0) {
      return ProductVariation(printTimeHours: v.printTimeHours, filamentGrams: v.filamentGrams);
    }
    final filamentCost = v.filamentGrams * (category.filamentCostPerKg / 1000);
    final electricityCost = v.printTimeHours * settings.electricityCostKwh;
    final totalCost = filamentCost + electricityCost + category.laborCost + category.licenseFee;
    final profitAmount = totalCost * (category.profitMargin / 100);
    final target = totalCost + profitAmount + category.shippingCost;
    final raw = (target + settings.etsyListingFee) / (1 - settings.etsyFeesPercent / 100);
    final price = _applyAvoidanceZone(
      _roundToNearestEven(raw),
      category.avoidanceZoneMin, category.avoidanceZoneMax, category.avoidanceZoneThreshold,
    );
    return ProductVariation(
      printTimeHours: v.printTimeHours, filamentGrams: v.filamentGrams,
      etsyPrice: price, profit: profitAmount, originalPrice: price,
    );
  }

  ProductVariation? calcMulticolor(ProductVariation? v) {
    if (v == null) return null;
    if (v.printTimeHours <= 0 || v.filamentGrams <= 0 || v.numberOfModels <= 0) {
      return ProductVariation(
        printTimeHours: v.printTimeHours, filamentGrams: v.filamentGrams, numberOfModels: v.numberOfModels,
      );
    }
    final n = v.numberOfModels;
    final filamentCost = v.filamentGrams * (category.filamentCostPerKg / 1000);
    final electricityCost = v.printTimeHours * settings.electricityCostKwh;
    final totalCost = filamentCost + electricityCost + category.laborCost + category.licenseFee;
    final profitAmount = totalCost * (category.profitMargin / 100);
    final target = totalCost + profitAmount + category.shippingCost;
    final raw = (target + settings.etsyListingFee) / (1 - settings.etsyFeesPercent / 100);
    final totalPrice = _applyAvoidanceZone(
      _roundToNearestEven(raw),
      category.avoidanceZoneMin, category.avoidanceZoneMax, category.avoidanceZoneThreshold,
    );
    final price = _roundToNearestEven(totalPrice / n);
    return ProductVariation(
      printTimeHours: v.printTimeHours, filamentGrams: v.filamentGrams,
      etsyPrice: price, profit: profitAmount / n, originalPrice: price, numberOfModels: n,
    );
  }

  var small = calcSingleColor(product.smallVariation);
  var medium = calcSingleColor(product.mediumVariation);
  var large = calcSingleColor(product.largeVariation);
  var mcSmall = calcMulticolor(product.smallMulticolorVariation);
  final mcMedium = calcMulticolor(product.mediumMulticolorVariation);
  final mcLarge = calcMulticolor(product.largeMulticolorVariation);

  // Small price cap
  if (category.smallPriceCap > 0 && small.etsyPrice > category.smallPriceCap) {
    small = ProductVariation(
      printTimeHours: small.printTimeHours, filamentGrams: small.filamentGrams,
      etsyPrice: category.smallPriceCap, profit: small.profit, originalPrice: small.etsyPrice,
    );
  }
  // Multicolor small cap
  if (mcSmall != null && category.multicolorSmallPriceCap > 0 && mcSmall.etsyPrice > category.multicolorSmallPriceCap) {
    mcSmall = ProductVariation(
      printTimeHours: mcSmall.printTimeHours, filamentGrams: mcSmall.filamentGrams,
      etsyPrice: category.multicolorSmallPriceCap, profit: mcSmall.profit,
      originalPrice: mcSmall.etsyPrice, numberOfModels: mcSmall.numberOfModels,
    );
  }
  // Multicolor small min
  if (mcSmall != null && category.multicolorSmallPriceMin > 0 && mcSmall.etsyPrice < category.multicolorSmallPriceMin) {
    mcSmall = ProductVariation(
      printTimeHours: mcSmall.printTimeHours, filamentGrams: mcSmall.filamentGrams,
      etsyPrice: category.multicolorSmallPriceMin, profit: mcSmall.profit,
      originalPrice: mcSmall.originalPrice > 0 ? mcSmall.originalPrice : mcSmall.etsyPrice,
      numberOfModels: mcSmall.numberOfModels,
    );
  }
  // Cascading gap adjustments
  if (category.minGapSmallMedium > 0 || category.minGapMediumLarge > 0) {
    final smallPrice = small.etsyPrice;
    var mediumPrice = medium.etsyPrice;
    final mediumOriginalPrice = medium.originalPrice;
    final largePrice = large.etsyPrice;
    final largeOriginalPrice = large.originalPrice;

    if (smallPrice > 0 && mediumPrice > 0 && category.minGapSmallMedium > 0) {
      if (mediumPrice - smallPrice < category.minGapSmallMedium) {
        final adj = smallPrice + category.minGapSmallMedium;
        if (mediumOriginalPrice > 0 && adj > mediumOriginalPrice) {
          medium = ProductVariation(
            printTimeHours: medium.printTimeHours, filamentGrams: medium.filamentGrams,
            etsyPrice: adj, profit: medium.profit, originalPrice: mediumOriginalPrice,
          );
          mediumPrice = adj;
        }
      }
    }
    if (mediumPrice > 0 && largePrice > 0 && category.minGapMediumLarge > 0) {
      if (largePrice - mediumPrice < category.minGapMediumLarge) {
        final adj = mediumPrice + category.minGapMediumLarge;
        if (largeOriginalPrice > 0 && adj > largeOriginalPrice) {
          large = ProductVariation(
            printTimeHours: large.printTimeHours, filamentGrams: large.filamentGrams,
            etsyPrice: adj, profit: large.profit, originalPrice: largeOriginalPrice,
          );
        }
      }
    }
  }

  return Product(
    id: product.id, name: product.name,
    imageUrl: product.imageUrl, listingUrl: product.listingUrl,
    smallVariation: small, mediumVariation: medium, largeVariation: large,
    categoryId: product.categoryId,
    totalSales: product.totalSales, totalRevenue: product.totalRevenue,
    smallMulticolorVariation: mcSmall,
    mediumMulticolorVariation: mcMedium,
    largeMulticolorVariation: mcLarge,
  );
}

// --- Part 4: UI Screens ---

// --- Main Navigation Page with Bottom Navigation Bar ---
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = const [
    HomePage(),
    StatisticsPage(),
    SettingsPage(),
    SpreadsheetPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart),
            label: 'Spreadsheet',
          ),
        ],
      ),
    );
  }
}

// --- Home Page ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  String? _selectedCategoryId; // null means "All Categories"

  Future<void> _launchURL(String? urlString) async {
    if (urlString != null && urlString.isNotEmpty) {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }
  
  void _addVariationToDisplay(List<String> parts, ProductVariation? variation, String label) {
    if (variation != null && variation.etsyPrice > 0) {
      parts.add('$label: \$${variation.etsyPrice.toStringAsFixed(0)}${variation.profit > 0 ? ' (\$${variation.profit.toStringAsFixed(2)})' : ''}');
    }
  }

  String _formatPrices(Product product) {
    final parts = <String>[];
    
    // Use dynamic variations if available (new-style, set by category-driven sizing)
    if (product.additionalVariations != null &&
        product.additionalVariationNames != null &&
        product.additionalVariations!.isNotEmpty) {
      final names = product.additionalVariationNames!;
      final vars = product.additionalVariations!;
      for (int i = 0; i < names.length && i < vars.length; i++) {
        _addVariationToDisplay(parts, vars[i], names[i]);
      }
    } else {
      // Legacy: fixed small/medium/large display
      if (product.smallVariation.etsyPrice > 0) {
        parts.add('S: \$${product.smallVariation.etsyPrice.toStringAsFixed(0)} (\$${product.smallVariation.profit.toStringAsFixed(2)})');
      }
      if (product.mediumVariation.etsyPrice > 0) {
        parts.add('M: \$${product.mediumVariation.etsyPrice.toStringAsFixed(0)} (\$${product.mediumVariation.profit.toStringAsFixed(2)})');
      }
      if (product.largeVariation.etsyPrice > 0) {
        parts.add('L: \$${product.largeVariation.etsyPrice.toStringAsFixed(0)} (\$${product.largeVariation.profit.toStringAsFixed(2)})');
      }
    }
    
    // Add multicolor prices if they exist
    _addVariationToDisplay(parts, product.smallMulticolorVariation, 'MC-S');
    _addVariationToDisplay(parts, product.mediumMulticolorVariation, 'MC-M');
    _addVariationToDisplay(parts, product.largeMulticolorVariation, 'MC-L');
    
    return parts.join(' | ');
  }

  void _addVariationToAverage(ProductVariation? variation, List<double> prices) {
    if (variation != null && variation.etsyPrice > 0) {
      prices.add(variation.etsyPrice);
    }
  }

  void _showAddSaleDialog(BuildContext context, Product product) {
    final priceController = TextEditingController();
    
    // Calculate average price from all variations (including multicolor)
    final prices = <double>[];
    
    // Add single-color variations (prefer new-style dynamic; fall back to legacy)
    if (product.additionalVariations != null && product.additionalVariations!.isNotEmpty) {
      for (final v in product.additionalVariations!) {
        _addVariationToAverage(v, prices);
      }
    } else {
      if (product.smallVariation.etsyPrice > 0) prices.add(product.smallVariation.etsyPrice);
      if (product.mediumVariation.etsyPrice > 0) prices.add(product.mediumVariation.etsyPrice);
      if (product.largeVariation.etsyPrice > 0) prices.add(product.largeVariation.etsyPrice);
    }
    
    // Add multicolor variations
    _addVariationToAverage(product.smallMulticolorVariation, prices);
    _addVariationToAverage(product.mediumMulticolorVariation, prices);
    _addVariationToAverage(product.largeMulticolorVariation, prices);
    
    if (prices.isNotEmpty) {
      final avgPrice = prices.reduce((a, b) => a + b) / prices.length;
      priceController.text = avgPrice.toStringAsFixed(2);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${product.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Sale Amount (\$)',
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(priceController.text) ?? 0;
              if (amount > 0) {
                context.read<DataBloc>().add(IncrementSales(product.id, amount));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added sale for ${product.name}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add Sale'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Priced Products'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Category filter chips
          BlocBuilder<DataBloc, DataState>(
            builder: (context, state) {
              if (state.categories.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // "All" chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text('All (${state.products.length})'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    // Category chips
                    ...state.categories.map((category) {
                      final productCount = state.products.where((p) => p.categoryId == category.id).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text('${category.name} ($productCount)'),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected ? category.id : null;
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Products list
          Expanded(
            child: BlocBuilder<DataBloc, DataState>(
              builder: (context, state) {
                if (state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          'No products yet',
                          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first product',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  );
                }
                
                // Filter products based on search query and selected category
                final filteredProducts = state.products.where((product) {
                  final matchesSearch = product.name.toLowerCase().contains(_searchQuery);
                  final matchesCategory = _selectedCategoryId == null || product.categoryId == _selectedCategoryId;
                  return matchesSearch && matchesCategory;
                }).toList();
                
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredProducts.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
                    final hasListing = product.listingUrl != null && product.listingUrl!.isNotEmpty;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product image or icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: hasImage
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(
                                                Icons.image_not_supported,
                                                color: Theme.of(context).colorScheme.primary,
                                                size: 30,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.widgets,
                                        size: 30,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatPrices(product),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sales: ${product.totalSales} • Revenue: \$${product.totalRevenue.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Action buttons
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, size: 28),
                                    color: Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      // Show dialog to add sale
                                      _showAddSaleDialog(context, product);
                                    },
                                    tooltip: 'Add Sale (+1)',
                                  ),
                                  if (hasListing)
                                    IconButton(
                                      icon: const Icon(Icons.open_in_new, size: 18),
                                      onPressed: () => _launchURL(product.listingUrl),
                                      tooltip: 'Open Etsy Listing',
                                    ),
                                ],
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailPage()));
        },
      ),
    );
  }
}


// --- Statistics Page ---
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  void _addVariationToStats(ProductVariation? variation, 
      {required double Function() onAdd}) {
    if (variation != null && variation.etsyPrice > 0) {
      onAdd();
    }
  }

  Map<String, dynamic> _calculateStatistics(DataState state) {
    if (state.products.isEmpty) {
      return {
        'totalProducts': 0,
        'avgProfit': 0.0,
        'totalPotentialRevenue': 0.0,
        'avgPrice': 0.0,
        'totalVariations': 0,
        'bestProduct': null,
        'worstProduct': null,
        'profitableProducts': 0,
        'totalSales': 0,
        'totalActualRevenue': 0.0,
      };
    }

    double totalRevenue = 0;
    double totalProfit = 0;
    int variationCount = 0;
    Product? bestProduct;
    Product? worstProduct;
    int maxSales = 0;
    int minSales = 999999;
    int profitableProducts = 0;
    int totalSalesCount = 0;
    double totalActualRevenue = 0;

    for (var product in state.products) {
      double productTotalProfit = 0;
      double productTotalRevenue = 0;
      int productVariations = 0;

      // Add sales tracking
      totalSalesCount += product.totalSales;
      totalActualRevenue += product.totalRevenue;

      // Helper to add variation stats
      void addVariation(ProductVariation variation) {
        productTotalRevenue += variation.etsyPrice;
        productTotalProfit += variation.profit;
        variationCount++;
        productVariations++;
      }

      // Process single-color variations (prefer new-style dynamic; fall back to legacy)
      if (product.additionalVariations != null && product.additionalVariations!.isNotEmpty) {
        for (final variation in product.additionalVariations!) {
          if (variation.etsyPrice > 0) addVariation(variation);
        }
      } else {
        if (product.smallVariation.etsyPrice > 0) addVariation(product.smallVariation);
        if (product.mediumVariation.etsyPrice > 0) addVariation(product.mediumVariation);
        if (product.largeVariation.etsyPrice > 0) addVariation(product.largeVariation);
      }
      
      // Process multicolor variations
      if (product.smallMulticolorVariation?.etsyPrice != null && product.smallMulticolorVariation!.etsyPrice > 0) {
        addVariation(product.smallMulticolorVariation!);
      }
      if (product.mediumMulticolorVariation?.etsyPrice != null && product.mediumMulticolorVariation!.etsyPrice > 0) {
        addVariation(product.mediumMulticolorVariation!);
      }
      if (product.largeMulticolorVariation?.etsyPrice != null && product.largeMulticolorVariation!.etsyPrice > 0) {
        addVariation(product.largeMulticolorVariation!);
      }

      if (productVariations > 0) {
        totalRevenue += productTotalRevenue;
        totalProfit += productTotalProfit;
        
        double avgProductProfit = productTotalProfit / productVariations;
        if (avgProductProfit > 0) profitableProducts++;
        
        // Use sales as the primary performance metric
        if (product.totalSales >= maxSales) {
          maxSales = product.totalSales;
          bestProduct = product;
        }
        if (product.totalSales <= minSales && product.totalSales > 0) {
          minSales = product.totalSales;
          worstProduct = product;
        }
      }
    }

    return {
      'totalProducts': state.products.length,
      'avgProfit': variationCount > 0 ? totalProfit / variationCount : 0.0,
      'totalPotentialRevenue': totalRevenue,
      'avgPrice': variationCount > 0 ? totalRevenue / variationCount : 0.0,
      'totalVariations': variationCount,
      'bestProduct': bestProduct,
      'worstProduct': worstProduct,
      'profitableProducts': profitableProducts,
      'totalProfit': totalProfit,
      'totalSales': totalSalesCount,
      'totalActualRevenue': totalActualRevenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
      ),
      body: BlocBuilder<DataBloc, DataState>(
        builder: (context, state) {
          final stats = _calculateStatistics(state);
          
          if (state.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'No data yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add products to see statistics',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_2,
                        label: 'Products',
                        value: '${stats['totalProducts']}',
                        color: const Color(0xFF00BFA5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.style,
                        label: 'Variations',
                        value: '${stats['totalVariations']}',
                        color: const Color(0xFF64FFDA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        label: 'Profitable',
                        value: '${stats['profitableProducts']}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        label: 'Avg Price',
                        value: '\$${stats['avgPrice'].toStringAsFixed(2)}',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.shopping_cart,
                        label: 'Total Sales',
                        value: '${stats['totalSales']}',
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.paid,
                        label: 'Revenue',
                        value: '\$${stats['totalActualRevenue'].toStringAsFixed(2)}',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Financial Overview
                Text(
                  'Financial Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _FinancialRow(
                          label: 'Total Potential Revenue',
                          value: '\$${stats['totalPotentialRevenue'].toStringAsFixed(2)}',
                          icon: Icons.show_chart,
                          color: const Color(0xFF00BFA5),
                        ),
                        const Divider(height: 24),
                        _FinancialRow(
                          label: 'Total Profit',
                          value: '\$${stats['totalProfit'].toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet,
                          color: Colors.green,
                        ),
                        const Divider(height: 24),
                        _FinancialRow(
                          label: 'Avg Profit per Variation',
                          value: '\$${stats['avgProfit'].toStringAsFixed(2)}',
                          icon: Icons.savings,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Best & Worst Products
                Text(
                  'Product Performance',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (stats['bestProduct'] != null)
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.star, color: Colors.white),
                      ),
                      title: const Text('Best Performer (Most Sales)'),
                      subtitle: Text('${stats['bestProduct'].name}\n${stats['bestProduct'].totalSales} sales • \$${stats['bestProduct'].totalRevenue.toStringAsFixed(2)} revenue'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: stats['bestProduct']),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                if (stats['worstProduct'] != null && stats['worstProduct'] != stats['bestProduct'])
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.trending_down, color: Colors.white),
                      ),
                      title: const Text('Needs Attention (Low Sales)'),
                      subtitle: Text('${stats['worstProduct'].name}\n${stats['worstProduct'].totalSales} sales • \$${stats['worstProduct'].totalRevenue.toStringAsFixed(2)} revenue'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: stats['worstProduct']),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // Cost Breakdown
                Text(
                  'Global Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings that apply to all categories:',
                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 12),
                        _CostRow('Electricity Cost', '\$${state.settings.electricityCostKwh.toStringAsFixed(2)}/kWh'),
                        _CostRow('Etsy Fees', '${state.settings.etsyFeesPercent.toStringAsFixed(1)}%'),
                        _CostRow('Etsy Listing Fee', '\$${state.settings.etsyListingFee.toStringAsFixed(2)}'),
                        const Divider(height: 24),
                        Text(
                          'Category-specific settings (${state.categories.length} categories):',
                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Filament Cost, Labor, License Fee, Shipping, and Profit Margin vary by category',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bulk Pricing Tool
                Text(
                  'Quick Tools',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BulkDiscountCalculator()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.purple.withOpacity(0.2),
                            child: const Icon(Icons.calculate, color: Colors.purple),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bulk Discount Calculator',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Calculate prices for bulk orders',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfitMarginAnalyzer()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            child: const Icon(Icons.timeline, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profit Margin Analyzer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Compare margins across products',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _FinancialRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;

  const _CostRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Bulk Discount Calculator Tool ---
class BulkDiscountCalculator extends StatefulWidget {
  const BulkDiscountCalculator({super.key});

  @override
  _BulkDiscountCalculatorState createState() => _BulkDiscountCalculatorState();
}

class _BulkDiscountCalculatorState extends State<BulkDiscountCalculator> {
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  
  double _totalOriginal = 0;
  double _totalWithDiscount = 0;
  double _savings = 0;
  double _pricePerUnit = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;

    if (quantity > 0 && price > 0) {
      setState(() {
        _totalOriginal = quantity * price;
        _totalWithDiscount = _totalOriginal * (1 - discount / 100);
        _savings = _totalOriginal - _totalWithDiscount;
        _pricePerUnit = _totalWithDiscount / quantity;
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? suffix}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _calculate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Discount Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Text(
                          'Order Details',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_quantityController, 'Quantity', suffix: 'items'),
                    const SizedBox(height: 16),
                    _buildTextField(_priceController, 'Price per Item', suffix: '\$'),
                    const SizedBox(height: 16),
                    _buildTextField(_discountController, 'Bulk Discount', suffix: '%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_totalOriginal > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          const Text(
                            'Pricing Breakdown',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _BulkPriceRow(
                        'Original Total',
                        '\$${_totalOriginal.toStringAsFixed(2)}',
                        Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      _BulkPriceRow(
                        'Discount Savings',
                        '-\$${_savings.toStringAsFixed(2)}',
                        Colors.orange,
                      ),
                      const Divider(height: 24),
                      _BulkPriceRow(
                        'Total with Discount',
                        '\$${_totalWithDiscount.toStringAsFixed(2)}',
                        const Color(0xFF00BFA5),
                      ),
                      const SizedBox(height: 12),
                      _BulkPriceRow(
                        'Price per Unit',
                        '\$${_pricePerUnit.toStringAsFixed(2)}',
                        Colors.tealAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.purple.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.purple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tip: Common bulk discounts are 10% for 5+ items, 15% for 10+ items, and 20% for 20+ items.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulkPriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BulkPriceRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// --- Profit Margin Analyzer Tool ---
class ProfitMarginAnalyzer extends StatelessWidget {
  const ProfitMarginAnalyzer({super.key});

  List<Map<String, dynamic>> _analyzeProducts(List<Product> products) {
    List<Map<String, dynamic>> analysis = [];
    
    for (var product in products) {
      // Use dynamic variations if available; fall back to legacy S/M/L
      if (product.additionalVariations != null &&
          product.additionalVariationNames != null &&
          product.additionalVariations!.isNotEmpty) {
        final names = product.additionalVariationNames!;
        final vars = product.additionalVariations!;
        for (int i = 0; i < vars.length && i < names.length; i++) {
          final variation = vars[i];
          if (variation.etsyPrice > 0) {
            final marginPercent = (variation.profit / variation.etsyPrice) * 100;
            analysis.add({
              'product': product,
              'size': names[i],
              'price': variation.etsyPrice,
              'profit': variation.profit,
              'marginPercent': marginPercent,
              'cost': variation.etsyPrice - variation.profit,
            });
          }
        }
      } else {
        final legacyVariations = [
          {'size': 'Small', 'variation': product.smallVariation},
          {'size': 'Medium', 'variation': product.mediumVariation},
          {'size': 'Large', 'variation': product.largeVariation},
        ];
        for (var v in legacyVariations) {
          final variation = v['variation'] as ProductVariation;
          if (variation.etsyPrice > 0) {
            final marginPercent = (variation.profit / variation.etsyPrice) * 100;
            analysis.add({
              'product': product,
              'size': v['size'],
              'price': variation.etsyPrice,
              'profit': variation.profit,
              'marginPercent': marginPercent,
              'cost': variation.etsyPrice - variation.profit,
            });
          }
        }
      }
    }
    
    // Sort by margin percentage, highest first
    analysis.sort((a, b) => b['marginPercent'].compareTo(a['marginPercent']));
    return analysis;
  }

  Color _getMarginColor(double marginPercent) {
    if (marginPercent >= 40) return Colors.green;
    if (marginPercent >= 30) return Colors.lightGreen;
    if (marginPercent >= 20) return Colors.orange;
    return Colors.red;
  }

  String _getMarginRating(double marginPercent) {
    if (marginPercent >= 40) return 'Excellent';
    if (marginPercent >= 30) return 'Good';
    if (marginPercent >= 20) return 'Fair';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit Margin Analyzer'),
      ),
      body: BlocBuilder<DataBloc, DataState>(
        builder: (context, state) {
          if (state.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'No products to analyze',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add products to see margin analysis',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }

          final analysis = _analyzeProducts(state.products);
          
          if (analysis.isEmpty) {
            return const Center(
              child: Text('No priced variations to analyze'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Profit margin = (Profit / Price) × 100%\nHigher margins mean better profitability.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'All Products by Margin',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...analysis.map((item) {
                  final product = item['product'] as Product;
                  final marginPercent = item['marginPercent'] as double;
                  final color = _getMarginColor(marginPercent);
                  final rating = _getMarginRating(marginPercent);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['size']} variant',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  rating,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _MarginDetailColumn(
                                  'Price',
                                  '\$${item['price'].toStringAsFixed(2)}',
                                  Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: _MarginDetailColumn(
                                  'Cost',
                                  '\$${item['cost'].toStringAsFixed(2)}',
                                  Colors.orange,
                                ),
                              ),
                              Expanded(
                                child: _MarginDetailColumn(
                                  'Profit',
                                  '\$${item['profit'].toStringAsFixed(2)}',
                                  Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _MarginDetailColumn(
                                  'Margin',
                                  '${marginPercent.toStringAsFixed(1)}%',
                                  color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MarginDetailColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MarginDetailColumn(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// --- Settings Page ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final settings = context.read<DataBloc>().state.settings;
    _controllers = {
      'electricityCostKwh': TextEditingController(text: settings.electricityCostKwh.toString()),
      'etsyFeesPercent': TextEditingController(text: settings.etsyFeesPercent.toString()),
      'etsyListingFee': TextEditingController(text: settings.etsyListingFee.toString()),
    };
  }
  
  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final newSettings = Settings.fromJson(_controllers.map((key, value) => MapEntry(key, double.parse(value.text))));
      context.read<DataBloc>().add(UpdateSettings(newSettings));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Global Settings Saved!'), backgroundColor: Colors.green),
      );
    }
  }
  
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g., Resin Models, Miniatures',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newCategory = Category(
                  id: const Uuid().v4(),
                  name: nameController.text.trim(),
                );
                context.read<DataBloc>().add(AddCategory(newCategory));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Category "${newCategory.name}" added!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _editCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryEditPage(category: category),
      ),
    );
  }

  Future<void> _backupData() async {
    final dataState = context.read<DataBloc>().state;
    final backupData = {
      'settings': dataState.settings.toJson(),
      'categories': dataState.categories.map((c) => c.toJson()).toList(),
      'products': dataState.products.map((p) => p.toJson()).toList(),
    };
    final jsonString = jsonEncode(backupData);
    final bytes = utf8.encode(jsonString);
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
    final fileName = 'etsy_pricing_backup_$timestamp.json';

    // Use FileSaver for all platforms. This provides a reliable "Save As..."
    // dialog on desktop browsers and works on mobile too.
    await FileSaver.instance.saveFile(name: fileName, bytes: bytes, ext: 'json', mimeType: MimeType.json);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup file is saving!'), backgroundColor: Colors.blue));
    }
  }
  
  Future<void> _restoreData() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final fileBytes = result.files.single.bytes;
        if (fileBytes != null) {
          final jsonString = utf8.decode(fileBytes);
          context.read<DataBloc>().add(RestoreData(jsonString));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data restored successfully!'), backgroundColor: Colors.green));
        }
      }
  }

  Future<void> _importSalesFromCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      if (fileBytes != null) {
        try {
          final csvString = utf8.decode(fileBytes);
          final lines = csvString.split('\n');
          
          // Skip header row
          final dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty);
          
          // Map to track sales by product name
          final salesMap = <String, Map<String, dynamic>>{};
          
          for (var line in dataLines) {
            // Simple CSV parsing (handles basic cases)
            final fields = _parseCSVLine(line);
            if (fields.length >= 12) {
              final itemName = fields[1].replaceAll('"', '').trim();
              final quantity = int.tryParse(fields[3]) ?? 1;
              final price = double.tryParse(fields[4]) ?? 0.0;
              final itemTotal = double.tryParse(fields[11]) ?? 0.0;
              
              // Aggregate by product name
              if (!salesMap.containsKey(itemName)) {
                salesMap[itemName] = {'count': 0, 'revenue': 0.0};
              }
              salesMap[itemName]!['count'] = (salesMap[itemName]!['count'] as int) + quantity;
              salesMap[itemName]!['revenue'] = (salesMap[itemName]!['revenue'] as double) + itemTotal;
            }
          }
          
          // Match products and update sales
          final products = context.read<DataBloc>().state.products;
          int matchedCount = 0;
          
          for (var product in products) {
            // Try to match product name (fuzzy matching)
            String? matchedName;
            for (var csvName in salesMap.keys) {
              if (_fuzzyMatch(product.name, csvName)) {
                matchedName = csvName;
                break;
              }
            }
            
            if (matchedName != null) {
              final sales = salesMap[matchedName]!;
              product.totalSales = sales['count'] as int;
              product.totalRevenue = sales['revenue'] as double;
              context.read<DataBloc>().add(UpdateProduct(product));
              matchedCount++;
            }
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Imported sales for $matchedCount products!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error importing CSV: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
  
  List<String> _parseCSVLine(String line) {
    List<String> fields = [];
    StringBuffer currentField = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        currentField.write(char);
      } else if (char == ',' && !inQuotes) {
        fields.add(currentField.toString());
        currentField.clear();
      } else {
        currentField.write(char);
      }
    }
    fields.add(currentField.toString());
    return fields;
  }
  
  bool _fuzzyMatch(String productName, String csvName) {
    // Remove common words and compare
    final cleanProduct = productName.toLowerCase()
        .replaceAll('figurine', '')
        .replaceAll('sculpture', '')
        .replaceAll('modern', '')
        .replaceAll('3d print', '')
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('the ', '')
        .replaceAll('matte black', 'black')
        .replaceAll('sculpted', '')
        .trim();
    
    final cleanCSV = csvName.toLowerCase()
        .replaceAll('figurine', '')
        .replaceAll('sculpture', '')
        .replaceAll('modern', '')
        .replaceAll('3d print', '')
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('the ', '')
        .replaceAll('matte black', 'black')
        .replaceAll('sculpted', '')
        .trim();
    
    // Check if one contains the other or they're similar
    return cleanProduct.contains(cleanCSV) || 
           cleanCSV.contains(cleanProduct) ||
           _levenshteinDistance(cleanProduct, cleanCSV) < 5;
  }
  
  int _levenshteinDistance(String s1, String s2) {
    if (s1.length > s2.length) {
      return _levenshteinDistance(s2, s1);
    }
    
    List<int> costs = List.generate(s2.length + 1, (i) => i);
    
    for (int i = 1; i <= s1.length; i++) {
      int lastCost = i - 1;
      costs[0] = i;
      
      for (int j = 1; j <= s2.length; j++) {
        int newCost = costs[j];
        costs[j] = s1[i - 1] == s2[j - 1]
            ? lastCost
            : 1 + [lastCost, costs[j], costs[j - 1]].reduce((a, b) => a < b ? a : b);
        lastCost = newCost;
      }
    }
    
    return costs[s2.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Settings')),
      body: BlocBuilder<DataBloc, DataState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Global Settings Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.public, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Global Settings',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'These settings apply to all categories',
                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('electricityCostKwh', 'Electricity Cost (\$/kWh)'),
                        _buildTextField('etsyFeesPercent', 'Etsy Fees (%)'),
                        _buildTextField('etsyListingFee', 'Etsy Listing Fee (\$)'),
                        const SizedBox(height: 8),
                        Text(
                          'Note: Price avoidance zone, price cap, and gap settings are now configured per category.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Global Settings', style: TextStyle(fontSize: 16)),
                    onPressed: _saveSettings,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Categories Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Product Categories',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: _showAddCategoryDialog,
                              tooltip: 'Add Category',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Each category can have different calculation settings',
                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        ...state.categories.map((category) {
                          final productCount = state.products.where((p) => p.categoryId == category.id).length;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                child: Icon(
                                  Icons.widgets,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('$productCount products • Margin: ${category.profitMargin.toStringAsFixed(1)}%'),
                              trailing: const Icon(Icons.edit),
                              onTap: () => _editCategory(category),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                // Data Management Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.storage, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Data Management',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.backup),
                            label: const Text('Backup Data'),
                            onPressed: _backupData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.restore),
                            label: const Text('Restore Data'),
                            onPressed: _restoreData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Import Sales from CSV'),
                            onPressed: _importSalesFromCSV,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}

// --- Category Edit Page ---
class CategoryEditPage extends StatefulWidget {
  final Category category;
  const CategoryEditPage({super.key, required this.category});

  @override
  _CategoryEditPageState createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Map<String, TextEditingController> _controllers;
  final List<TextEditingController> _sizeNameControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _controllers = {
      'filamentCostPerKg': TextEditingController(text: widget.category.filamentCostPerKg.toString()),
      'laborCost': TextEditingController(text: widget.category.laborCost.toString()),
      'licenseFee': TextEditingController(text: widget.category.licenseFee.toString()),
      'shippingCost': TextEditingController(text: widget.category.shippingCost.toString()),
      'profitMargin': TextEditingController(text: widget.category.profitMargin.toString()),
      'avoidanceZoneMin': TextEditingController(text: widget.category.avoidanceZoneMin.toString()),
      'avoidanceZoneMax': TextEditingController(text: widget.category.avoidanceZoneMax.toString()),
      'avoidanceZoneThreshold': TextEditingController(text: widget.category.avoidanceZoneThreshold.toString()),
      'smallPriceCap': TextEditingController(text: widget.category.smallPriceCap.toString()),
      'minGapSmallMedium': TextEditingController(text: widget.category.minGapSmallMedium.toString()),
      'minGapMediumLarge': TextEditingController(text: widget.category.minGapMediumLarge.toString()),
      'multicolorSmallPriceCap': TextEditingController(text: widget.category.multicolorSmallPriceCap.toString()),
      'multicolorSmallPriceMin': TextEditingController(text: widget.category.multicolorSmallPriceMin.toString()),
    };
    for (final name in widget.category.effectiveSizeNames) {
      _sizeNameControllers.add(TextEditingController(text: name));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    for (final c in _sizeNameControllers) c.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final sizeNames = _sizeNameControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final updatedCategory = Category(
        id: widget.category.id,
        name: _nameController.text.trim(),
        filamentCostPerKg: double.parse(_controllers['filamentCostPerKg']!.text),
        laborCost: double.parse(_controllers['laborCost']!.text),
        licenseFee: double.parse(_controllers['licenseFee']!.text),
        shippingCost: double.parse(_controllers['shippingCost']!.text),
        profitMargin: double.parse(_controllers['profitMargin']!.text),
        avoidanceZoneMin: double.parse(_controllers['avoidanceZoneMin']!.text),
        avoidanceZoneMax: double.parse(_controllers['avoidanceZoneMax']!.text),
        avoidanceZoneThreshold: double.parse(_controllers['avoidanceZoneThreshold']!.text),
        smallPriceCap: double.parse(_controllers['smallPriceCap']!.text),
        minGapSmallMedium: double.parse(_controllers['minGapSmallMedium']!.text),
        minGapMediumLarge: double.parse(_controllers['minGapMediumLarge']!.text),
        multicolorSmallPriceCap: double.parse(_controllers['multicolorSmallPriceCap']!.text),
        multicolorSmallPriceMin: double.parse(_controllers['multicolorSmallPriceMin']!.text),
        variationSizeNames: sizeNames.isNotEmpty ? sizeNames : null,
      );
      
      context.read<DataBloc>().add(UpdateCategory(updatedCategory));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "${updatedCategory.name}" saved!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _deleteCategory() {
    final productCount = context.read<DataBloc>().state.products.where((p) => p.categoryId == widget.category.id).length;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          productCount > 0
              ? 'This category has $productCount products. They will be moved to the first remaining category. Continue?'
              : 'Are you sure you want to delete this category?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DataBloc>().add(DeleteCategory(widget.category.id));
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = context.read<DataBloc>().state.categories.length > 1;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCategory,
              tooltip: 'Delete Category',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Category Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Calculation Settings',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These settings are specific to this category',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('filamentCostPerKg', 'Filament Cost (\$/kg)'),
                    _buildTextField('laborCost', 'Labor & Handling (\$)'),
                    _buildTextField('licenseFee', 'License Fee (\$)'),
                    _buildTextField('shippingCost', 'Shipping & Packaging (\$)'),
                    _buildTextField('profitMargin', 'Desired Profit Margin (%)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.straighten, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Product Sizes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Define the available sizes for products in this category. Drag to reorder. All sizes are optional per product.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 12),
                    if (_sizeNameControllers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No sizes defined. Tap "Add Size" to add one.',
                          style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                      ),
                    if (_sizeNameControllers.isNotEmpty)
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final ctrl = _sizeNameControllers.removeAt(oldIndex);
                            _sizeNameControllers.insert(newIndex, ctrl);
                          });
                        },
                        itemCount: _sizeNameControllers.length,
                        itemBuilder: (context, index) {
                          return Row(
                            key: ValueKey('size_$index'),
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(Icons.drag_handle, color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: TextFormField(
                                    controller: _sizeNameControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Size ${index + 1} Name',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Size name cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _sizeNameControllers[index].dispose();
                                    _sizeNameControllers.removeAt(index);
                                  });
                                },
                                tooltip: 'Remove size',
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Size'),
                      onPressed: () {
                        setState(() {
                          _sizeNameControllers.add(TextEditingController(
                            text: 'Size ${_sizeNameControllers.length + 1}',
                          ));
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.price_check, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Price Avoidance Zone',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Round prices in this range to min or max. Set all to 0 to disable.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('avoidanceZoneMin', 'Minimum Price (\$)'),
                    _buildTextField('avoidanceZoneMax', 'Maximum Price (\$)'),
                    _buildTextField('avoidanceZoneThreshold', 'Threshold from Min (\$)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.space_bar, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Price Cap & Gap Settings',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Control pricing limits and spacing between sizes. Set to 0 to disable.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('smallPriceCap', 'First Size Price Cap (\$)'),
                    _buildTextField('multicolorSmallPriceCap', 'Multicolor First Size Price Cap (\$)'),
                    _buildTextField('multicolorSmallPriceMin', 'Multicolor First Size Price Min (\$)'),
                    _buildTextField('minGapSmallMedium', 'Min Gap: 1st ↔ 2nd Size (\$)'),
                    _buildTextField('minGapMediumLarge', 'Min Gap: 2nd ↔ 3rd Size (\$)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Category', style: TextStyle(fontSize: 16)),
                onPressed: _saveCategory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}

// --- Product Detail/Add/Edit Page ---
class ProductDetailPage extends StatefulWidget {
  final Product? product;
  const ProductDetailPage({super.key, this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TabController? _tabController;
  late TabController _multicolorTabController;
  
  late TextEditingController _nameController, _imageUrlController, _listingUrlController;

  // Dynamic size controllers — indexed to match _currentSizeNames
  final List<TextEditingController> _sizeTimeControllers = [];
  final List<TextEditingController> _sizeGramControllers = [];
  List<String> _currentSizeNames = [];
  
  // Multicolor variation controllers
  late TextEditingController _sMcTimeController, _sMcGramController, _sMcModelsController;
  late TextEditingController _mMcTimeController, _mMcGramController, _mMcModelsController;
  late TextEditingController _lMcTimeController, _lMcGramController, _lMcModelsController;
  
  late String _selectedCategoryId;
  Map<String, Map<String, double?>> _pricingResult = {};

  bool get _isEditing => widget.product != null;

  /// Builds a map from size name to existing ProductVariation, for pre-filling controllers.
  /// Prefers the new-style dynamic variations; falls back to legacy S/M/L fields.
  Map<String, ProductVariation> _buildExistingVariationMap() {
    if (widget.product == null) return {};
    final product = widget.product!;
    if (product.additionalVariations != null &&
        product.additionalVariationNames != null &&
        product.additionalVariations!.isNotEmpty) {
      final map = <String, ProductVariation>{};
      final names = product.additionalVariationNames!;
      final vars = product.additionalVariations!;
      for (int i = 0; i < names.length && i < vars.length; i++) {
        map[names[i]] = vars[i];
      }
      return map;
    }
    // Legacy fallback
    return {
      'Small': product.smallVariation,
      'Medium': product.mediumVariation,
      'Large': product.largeVariation,
    };
  }

  /// (Re)initializes size controllers for the given category.
  /// Safe to call from initState or during a setState call.
  void _initializeSizeControllers(String categoryId) {
    final state = context.read<DataBloc>().state;
    if (state.categories.isEmpty) return;
    final category = state.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => state.categories.first,
    );
    _currentSizeNames = category.effectiveSizeNames;

    // Dispose previous controllers
    for (final c in _sizeTimeControllers) c.dispose();
    for (final c in _sizeGramControllers) c.dispose();
    _sizeTimeControllers.clear();
    _sizeGramControllers.clear();

    // Rebuild tab controller with correct length
    _tabController?.dispose();
    _tabController = TabController(
      length: _currentSizeNames.isEmpty ? 1 : _currentSizeNames.length,
      vsync: this,
    );

    final existingMap = _buildExistingVariationMap();
    for (final sizeName in _currentSizeNames) {
      final existing = existingMap[sizeName];
      _sizeTimeControllers.add(TextEditingController(
        text: (existing != null && existing.printTimeHours > 0)
            ? existing.printTimeHours.toString()
            : '',
      ));
      _sizeGramControllers.add(TextEditingController(
        text: (existing != null && existing.filamentGrams > 0)
            ? existing.filamentGrams.toString()
            : '',
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _multicolorTabController = TabController(length: 3, vsync: this);
    
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _listingUrlController = TextEditingController(text: widget.product?.listingUrl ?? '');

    // Multicolor variation controllers
    _sMcTimeController = TextEditingController(text: widget.product?.smallMulticolorVariation?.printTimeHours.toString() ?? '0');
    _sMcGramController = TextEditingController(text: widget.product?.smallMulticolorVariation?.filamentGrams.toString() ?? '0');
    _sMcModelsController = TextEditingController(text: widget.product?.smallMulticolorVariation?.numberOfModels.toString() ?? '1');
    _mMcTimeController = TextEditingController(text: widget.product?.mediumMulticolorVariation?.printTimeHours.toString() ?? '0');
    _mMcGramController = TextEditingController(text: widget.product?.mediumMulticolorVariation?.filamentGrams.toString() ?? '0');
    _mMcModelsController = TextEditingController(text: widget.product?.mediumMulticolorVariation?.numberOfModels.toString() ?? '1');
    _lMcTimeController = TextEditingController(text: widget.product?.largeMulticolorVariation?.printTimeHours.toString() ?? '0');
    _lMcGramController = TextEditingController(text: widget.product?.largeMulticolorVariation?.filamentGrams.toString() ?? '0');
    _lMcModelsController = TextEditingController(text: widget.product?.largeMulticolorVariation?.numberOfModels.toString() ?? '1');

    // Set initial category and initialize size controllers
    final categories = context.read<DataBloc>().state.categories;
    _selectedCategoryId = widget.product?.categoryId ?? (categories.isNotEmpty ? categories.first.id : 'default_3d_models');
    _initializeSizeControllers(_selectedCategoryId);

    // If editing, show existing prices immediately
    if (_isEditing) {
      _showExistingPrices();
    }
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    _multicolorTabController.dispose();
    _nameController.dispose();
    _imageUrlController.dispose();
    _listingUrlController.dispose();
    for (final c in _sizeTimeControllers) c.dispose();
    for (final c in _sizeGramControllers) c.dispose();
    _sMcTimeController.dispose();
    _sMcGramController.dispose();
    _sMcModelsController.dispose();
    _mMcTimeController.dispose();
    _mMcGramController.dispose();
    _mMcModelsController.dispose();
    _lMcTimeController.dispose();
    _lMcGramController.dispose();
    _lMcModelsController.dispose();
    super.dispose();
  }
  
  void _showExistingPrices() {
      final state = context.read<DataBloc>().state;
      final settings = state.settings;
      final category = state.categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => state.categories.first);
      final product = widget.product!;

      // Use dynamic variations map (prefers additionalVariations, falls back to legacy S/M/L)
      final variations = Map<String, ProductVariation>.from(_buildExistingVariationMap());

      // Add multicolor variations if they exist
      if (product.smallMulticolorVariation != null) {
        variations['Multicolor Small'] = product.smallMulticolorVariation!;
      }
      if (product.mediumMulticolorVariation != null) {
        variations['Multicolor Medium'] = product.mediumMulticolorVariation!;
      }
      if (product.largeMulticolorVariation != null) {
        variations['Multicolor Large'] = product.largeMulticolorVariation!;
      }

      Map<String, Map<String, double?>> newResults = {};
      
      variations.forEach((key, variation) {
        if (variation.etsyPrice > 0) {
            final filamentCostPerGram = category.filamentCostPerKg / 1000;
            final calculatedFilamentCost = variation.filamentGrams * filamentCostPerGram;
            final calculatedElectricityCost = variation.printTimeHours * settings.electricityCostKwh;
            final totalProductionCost = calculatedFilamentCost + calculatedElectricityCost + category.laborCost + category.licenseFee;

            // Determine if the price was adjusted (different from original)
            final wasAdjusted = variation.originalPrice > 0 && variation.originalPrice != variation.etsyPrice;

            newResults[key] = {
              'totalProductionCost': totalProductionCost,
              'etsyPrice': variation.etsyPrice,
              'profit': variation.profit,
              'originalPrice': wasAdjusted ? variation.originalPrice : null,
            };
        }
      });
      setState(() { _pricingResult = newResults; });
  }

  double _roundToNearestEven(double value) {
      double roundedUp = value.ceilToDouble();
      if (roundedUp % 2 != 0) {
          return roundedUp + 1;
      }
      return roundedUp;
  }

  double _applyAvoidanceZone(double price, double minZone, double maxZone, double threshold) {
    // If avoidance zone min/max are not configured properly, return original price
    if (minZone <= 0 || maxZone <= 0 || minZone >= maxZone) {
      return price;
    }
    
    // If price is within the avoidance zone (strictly greater than min and strictly less than max)
    if (price > minZone && price < maxZone) {
      // If threshold is set and valid, use threshold-based rounding
      if (threshold > 0 && threshold <= (maxZone - minZone)) {
        // If price is within threshold distance from min, round down to min
        if (price <= minZone + threshold) {
          return minZone;
        } else {
          // Otherwise round up to max
          return maxZone;
        }
      } else {
        // Fallback to nearest extreme if threshold is 0 or not configured properly
        final distanceToMin = price - minZone;
        final distanceToMax = maxZone - price;
        
        if (distanceToMin < distanceToMax) {
          return minZone;
        } else {
          return maxZone;
        }
      }
    }
    
    // Price is outside the avoidance zone, return as-is
    return price;
  }

  void _calculateAndSave() {
    if (_formKey.currentState!.validate()) {
      final state = context.read<DataBloc>().state;
      final settings = state.settings;
      final category = state.categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => state.categories.first);
      
      // Build variationsData dynamically from category sizes
      final variationsData = <String, Map<String, double>>{};
      for (int i = 0; i < _currentSizeNames.length; i++) {
        variationsData[_currentSizeNames[i]] = {
          'time': double.tryParse(_sizeTimeControllers[i].text) ?? 0,
          'grams': double.tryParse(_sizeGramControllers[i].text) ?? 0,
        };
      }
      
      // Multicolor variations data with number of models
      final multicolorVariationsData = {
        'Multicolor Small': {
          'time': double.tryParse(_sMcTimeController.text) ?? 0, 
          'grams': double.tryParse(_sMcGramController.text) ?? 0,
          'models': int.tryParse(_sMcModelsController.text) ?? 1,
        },
        'Multicolor Medium': {
          'time': double.tryParse(_mMcTimeController.text) ?? 0, 
          'grams': double.tryParse(_mMcGramController.text) ?? 0,
          'models': int.tryParse(_mMcModelsController.text) ?? 1,
        },
        'Multicolor Large': {
          'time': double.tryParse(_lMcTimeController.text) ?? 0, 
          'grams': double.tryParse(_lMcGramController.text) ?? 0,
          'models': int.tryParse(_lMcModelsController.text) ?? 1,
        },
      };

      Map<String, Map<String, double?>> newResults = {};
      final newVariations = <String, ProductVariation>{};
      
      // Helper function to calculate price for a single-color variation
      void calculateVariationPrice(String key, Map<String, double> value) {
        final printTime = value['time']!;
        final filamentGrams = value['grams']!;
        double calculatedPrice = 0;
        double profitAmount = 0;
        double originalPriceValue = 0;
        
        if (printTime > 0 && filamentGrams > 0) {
            final filamentCostPerGram = category.filamentCostPerKg / 1000;
            final calculatedFilamentCost = filamentGrams * filamentCostPerGram;
            final calculatedElectricityCost = printTime * settings.electricityCostKwh;
            
            final totalProductionCost = calculatedFilamentCost + calculatedElectricityCost + category.laborCost + category.licenseFee;
            profitAmount = totalProductionCost * (category.profitMargin / 100);
            final targetAmount = totalProductionCost + profitAmount + category.shippingCost;
            final etsyPrice = (targetAmount + settings.etsyListingFee) / (1 - (settings.etsyFeesPercent / 100));
            
            // Apply even rounding first
            double roundedPrice = _roundToNearestEven(etsyPrice);
            
            // Then apply avoidance zone with threshold (priority)
            calculatedPrice = _applyAvoidanceZone(roundedPrice, category.avoidanceZoneMin, category.avoidanceZoneMax, category.avoidanceZoneThreshold);
            
            // Store the price after avoidance zone as the original (before cap/gap adjustments)
            originalPriceValue = calculatedPrice;

            newResults[key] = {
              'totalProductionCost': totalProductionCost,
              'etsyPrice': calculatedPrice,
              'profit': profitAmount,
              'originalPrice': null, // Will be set if price is capped or gap-adjusted
            };
        }
        newVariations[key] = ProductVariation(
          printTimeHours: printTime, 
          filamentGrams: filamentGrams, 
          etsyPrice: calculatedPrice,
          profit: profitAmount,
          originalPrice: originalPriceValue,
          numberOfModels: 1,
        );
      }
      
      // Helper function to calculate price for a multicolor variation (with batch pricing)
      void calculateMulticolorVariationPrice(String key, Map<String, dynamic> value) {
        final printTime = value['time'] as double;
        final filamentGrams = value['grams'] as double;
        final numberOfModels = value['models'] as int;
        double calculatedPrice = 0;
        double profitAmount = 0;
        double originalPriceValue = 0;
        double totalPrice = 0;
        
        if (printTime > 0 && filamentGrams > 0 && numberOfModels > 0) {
            final filamentCostPerGram = category.filamentCostPerKg / 1000;
            final calculatedFilamentCost = filamentGrams * filamentCostPerGram;
            final calculatedElectricityCost = printTime * settings.electricityCostKwh;
            
            final totalProductionCost = calculatedFilamentCost + calculatedElectricityCost + category.laborCost + category.licenseFee;
            profitAmount = totalProductionCost * (category.profitMargin / 100);
            final targetAmount = totalProductionCost + profitAmount + category.shippingCost;
            final etsyPrice = (targetAmount + settings.etsyListingFee) / (1 - (settings.etsyFeesPercent / 100));
            
            // Apply even rounding first
            double roundedPrice = _roundToNearestEven(etsyPrice);
            
            // Then apply avoidance zone with threshold (priority)
            totalPrice = _applyAvoidanceZone(roundedPrice, category.avoidanceZoneMin, category.avoidanceZoneMax, category.avoidanceZoneThreshold);
            
            // Calculate individual price by dividing by number of models
            double individualPriceRaw = totalPrice / numberOfModels;
            
            // Round individual price to nearest even whole number
            calculatedPrice = _roundToNearestEven(individualPriceRaw);
            
            // Store the price after avoidance zone as the original (before cap/gap adjustments)
            originalPriceValue = calculatedPrice;

            newResults[key] = {
              'totalProductionCost': totalProductionCost,
              'etsyPrice': calculatedPrice,  // Individual price (rounded)
              'profit': profitAmount / numberOfModels,  // Individual profit
              'originalPrice': null,
              'totalPrice': totalPrice,  // Store total for display
              'numberOfModels': numberOfModels.toDouble(),
              'totalCost': totalProductionCost,  // Total cost for display
              'totalProfit': profitAmount,  // Total profit for display
            };
        }
        newVariations[key] = ProductVariation(
          printTimeHours: printTime, 
          filamentGrams: filamentGrams, 
          etsyPrice: calculatedPrice,
          profit: profitAmount / (numberOfModels > 0 ? numberOfModels : 1),
          originalPrice: originalPriceValue,
          numberOfModels: numberOfModels,
        );
      }
      
      // First pass: calculate all prices with avoidance zone
      variationsData.forEach(calculateVariationPrice);
      multicolorVariationsData.forEach(calculateMulticolorVariationPrice);

      // Second pass: apply 1st-size price cap
      final firstName = _currentSizeNames.isNotEmpty ? _currentSizeNames[0] : null;
      final secondName = _currentSizeNames.length > 1 ? _currentSizeNames[1] : null;
      final thirdName = _currentSizeNames.length > 2 ? _currentSizeNames[2] : null;

      if (firstName != null && newResults.containsKey(firstName) && category.smallPriceCap > 0) {
        final firstPrice = newResults[firstName]!['etsyPrice']!;
        if (firstPrice > category.smallPriceCap) {
          newResults[firstName]!['originalPrice'] = firstPrice;
          newResults[firstName]!['etsyPrice'] = category.smallPriceCap;
          newVariations[firstName]!.etsyPrice = category.smallPriceCap;
        }
      }

      // Apply multicolor small price cap (only for multicolor small)
      if (newResults.containsKey('Multicolor Small') && category.multicolorSmallPriceCap > 0) {
        final mcSmallPrice = newResults['Multicolor Small']!['etsyPrice']!;
        if (mcSmallPrice > category.multicolorSmallPriceCap) {
          newResults['Multicolor Small']!['originalPrice'] = mcSmallPrice;
          newResults['Multicolor Small']!['etsyPrice'] = category.multicolorSmallPriceCap;
          newVariations['Multicolor Small']!.etsyPrice = category.multicolorSmallPriceCap;
        }
      }

      // Apply multicolor small price minimum
      if (newResults.containsKey('Multicolor Small') && category.multicolorSmallPriceMin > 0) {
        final mcSmallPrice = newResults['Multicolor Small']!['etsyPrice']!;
        if (mcSmallPrice < category.multicolorSmallPriceMin) {
          if (newResults['Multicolor Small']!['originalPrice'] == null) {
            newResults['Multicolor Small']!['originalPrice'] = mcSmallPrice;
          }
          newResults['Multicolor Small']!['etsyPrice'] = category.multicolorSmallPriceMin;
          newVariations['Multicolor Small']!.etsyPrice = category.multicolorSmallPriceMin;
        }
      }

      // Apply cascading gap adjustments for 1st↔2nd and 2nd↔3rd sizes
      if (category.minGapSmallMedium > 0 || category.minGapMediumLarge > 0) {
        final firstPrice = firstName != null ? (newResults[firstName]?['etsyPrice'] ?? 0) : 0.0;
        double secondPrice = secondName != null ? (newResults[secondName]?['etsyPrice'] ?? 0) : 0.0;
        final secondOriginalPrice = secondName != null ? (newVariations[secondName]?.originalPrice ?? 0) : 0.0;
        double thirdPrice = thirdName != null ? (newResults[thirdName]?['etsyPrice'] ?? 0) : 0.0;
        final thirdOriginalPrice = thirdName != null ? (newVariations[thirdName]?.originalPrice ?? 0) : 0.0;

        if (secondName != null && firstPrice > 0 && secondPrice > 0 && category.minGapSmallMedium > 0) {
          final gap = secondPrice - firstPrice;
          if (gap < category.minGapSmallMedium) {
            final adjusted = firstPrice + category.minGapSmallMedium;
            if (secondOriginalPrice > 0 && adjusted > secondOriginalPrice) {
              newResults[secondName]!['originalPrice'] = secondOriginalPrice;
              newResults[secondName]!['etsyPrice'] = adjusted;
              newVariations[secondName]!.etsyPrice = adjusted;
              secondPrice = adjusted;
            }
          }
        }

        if (thirdName != null && secondPrice > 0 && thirdPrice > 0 && category.minGapMediumLarge > 0) {
          final gap = thirdPrice - secondPrice;
          if (gap < category.minGapMediumLarge) {
            final adjusted = secondPrice + category.minGapMediumLarge;
            if (thirdOriginalPrice > 0 && adjusted > thirdOriginalPrice) {
              newResults[thirdName]!['originalPrice'] = thirdOriginalPrice;
              newResults[thirdName]!['etsyPrice'] = adjusted;
              newVariations[thirdName]!.etsyPrice = adjusted;
            }
          }
        }
      }

      setState(() {
         _pricingResult = newResults;
      });

      // Build dynamic variation lists from the current sizes
      // Filter out sizes that have no user input (time and grams both zero/empty)
      final savedNames = <String>[];
      final savedVars = <ProductVariation>[];
      for (final name in _currentSizeNames) {
        final v = newVariations[name] ?? ProductVariation();
        if (v.printTimeHours > 0 || v.filamentGrams > 0) {
          savedNames.add(name);
          savedVars.add(v);
        }
      }

      // Map to legacy fields for backward compatibility (S/M/L by name, then by index)
      final legacySmall = newVariations['Small'] ??
          (savedVars.isNotEmpty ? savedVars[0] : ProductVariation());
      final legacyMedium = newVariations['Medium'] ??
          (savedVars.length > 1 ? savedVars[1] : ProductVariation());
      final legacyLarge = newVariations['Large'] ??
          (savedVars.length > 2 ? savedVars[2] : ProductVariation());

      final product = Product(
        id: _isEditing ? widget.product!.id : const Uuid().v4(),
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        listingUrl: _listingUrlController.text,
        smallVariation: legacySmall,
        mediumVariation: legacyMedium,
        largeVariation: legacyLarge,
        categoryId: _selectedCategoryId,
        smallMulticolorVariation: newVariations['Multicolor Small'],
        mediumMulticolorVariation: newVariations['Multicolor Medium'],
        largeMulticolorVariation: newVariations['Multicolor Large'],
        additionalVariations: savedVars.isNotEmpty ? savedVars : null,
        additionalVariationNames: savedNames.isNotEmpty ? savedNames : null,
      );
      
      if (_isEditing) {
        // Preserve sales data when editing
        product.totalSales = widget.product!.totalSales;
        product.totalRevenue = widget.product!.totalRevenue;
        context.read<DataBloc>().add(UpdateProduct(product));
      } else {
        context.read<DataBloc>().add(AddProduct(product));
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product ${ _isEditing ? "Updated" : "Saved"}!'), backgroundColor: Colors.green),
      );
    }
  }

  void _deleteProduct() {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this product?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<DataBloc>().add(DeleteProduct(widget.product!.id));
                  Navigator.of(ctx).pop(); 
                  Navigator.of(context).pop(); 
                },
                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
            if (_isEditing)
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteProduct,
                )
        ],
      ),
      body: BlocBuilder<DataBloc, DataState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                'Product Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(_nameController, 'Product Name'),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: state.categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategoryId = value;
                                  _initializeSizeControllers(value);
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(_imageUrlController, 'Image URL (Optional)', isRequired: false),
                          const SizedBox(height: 12),
                          _buildTextField(_listingUrlController, 'Etsy Listing URL (Optional)', isRequired: false),
                        ],
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            Card(
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: Icon(Icons.straighten, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  'Product Sizes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'All sizes optional — leave blank to skip',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                children: [
                  if (_currentSizeNames.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No sizes configured for this category. Edit the category to add sizes.'),
                    ),
                  if (_currentSizeNames.isNotEmpty) ...[
                    TabBar(
                      controller: _tabController!,
                      labelColor: Theme.of(context).colorScheme.primary,
                      isScrollable: true,
                      tabs: _currentSizeNames.map((name) => Tab(text: name)).toList(),
                    ),
                    SizedBox(
                      height: 180,
                      child: TabBarView(
                        controller: _tabController!,
                        children: List.generate(
                          _currentSizeNames.length,
                          (i) => _buildVariationTab(_sizeTimeControllers[i], _sizeGramControllers[i]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: Icon(Icons.palette, color: Theme.of(context).colorScheme.secondary),
                title: Text(
                  'Multicolor Variations (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  TabBar(
                    controller: _multicolorTabController,
                    labelColor: Theme.of(context).colorScheme.secondary,
                    tabs: const [
                      Tab(text: 'MC Small'),
                      Tab(text: 'MC Medium'),
                      Tab(text: 'MC Large'),
                    ],
                  ),
                  SizedBox(
                    height: 220,
                    child: TabBarView(
                      controller: _multicolorTabController,
                      children: [
                        _buildMulticolorVariationTab(_sMcTimeController, _sMcGramController, _sMcModelsController),
                        _buildMulticolorVariationTab(_mMcTimeController, _mMcGramController, _mMcModelsController),
                        _buildMulticolorVariationTab(_lMcTimeController, _lMcGramController, _lMcModelsController),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: Text(
                  _isEditing ? 'Recalculate & Save' : 'Calculate & Save',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _calculateAndSave,
              ),
            ),
            const SizedBox(height: 20),
            if (_pricingResult.isNotEmpty)
              _buildResultsCard()
          ],
        ),
      );
        },
      ),
    );
  }

  Widget _buildVariationTab(TextEditingController timeController, TextEditingController gramController) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            _buildTextField(timeController, 'Print Time (hours)', isRequired: false),
            const SizedBox(height: 12),
            _buildTextField(gramController, 'Filament Used (grams)', isRequired: false),
          ],
        ),
      );
  }

  Widget _buildMulticolorVariationTab(TextEditingController timeController, TextEditingController gramController, TextEditingController modelsController) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: [
            _buildTextField(timeController, 'Total Print Time (hours)'),
            const SizedBox(height: 8),
            _buildTextField(gramController, 'Total Filament Used (grams)'),
            const SizedBox(height: 8),
            _buildTextField(modelsController, 'Number of Models Printed'),
          ],
        ),
      );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = true}) {
    TextInputType keyboardType = (label.contains('URL') || label.contains('Name'))
        ? TextInputType.text
        : const TextInputType.numberWithOptions(decimal: true);

    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (keyboardType != TextInputType.text && value != null && value.isNotEmpty && double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      );
  }
  
  Widget _buildResultsCard() {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Text(
                          'Pricing Breakdown',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        SizedBox(width: 50, child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        SizedBox(width: 60, child: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
                        SizedBox(width: 60, child: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
                        SizedBox(width: 80, child: Text('Etsy Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.end)),
                      ],
                    ),
                    const Divider(height: 16),
                    ..._pricingResult.entries.map((entry) {
                      return _ResultRow(
                          entry.key,
                          entry.value['totalProductionCost']!,
                          entry.value['profit']!,
                          entry.value['etsyPrice']!,
                          entry.value['suggestedPrice'],
                          entry.value['originalPrice'],
                          entry.value['totalPrice'],
                          entry.value['numberOfModels'],
                          entry.value['totalCost'],
                          entry.value['totalProfit'],
                      );
                    }).toList(),
                ],
            )
        )
    );
  }
}

// --- Spreadsheet View Page ---
class SpreadsheetPage extends StatefulWidget {
  const SpreadsheetPage({super.key});

  @override
  _SpreadsheetPageState createState() => _SpreadsheetPageState();
}

class _SpreadsheetPageState extends State<SpreadsheetPage> {
  bool _settingsModified = false;
  late TextEditingController _electricityController;
  late TextEditingController _etsyFeesController;
  late TextEditingController _etsyListingFeeController;
  final Map<String, TextEditingController> _categoryControllers = {};

  @override
  void initState() {
    super.initState();
    final s = context.read<DataBloc>().state.settings;
    _electricityController = TextEditingController(text: s.electricityCostKwh.toString())
      ..addListener(_onChanged);
    _etsyFeesController = TextEditingController(text: s.etsyFeesPercent.toString())
      ..addListener(_onChanged);
    _etsyListingFeeController = TextEditingController(text: s.etsyListingFee.toString())
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _electricityController.dispose();
    _etsyFeesController.dispose();
    _etsyListingFeeController.dispose();
    for (final c in _categoryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    if (!_settingsModified) setState(() => _settingsModified = true);
  }

  /// Lazily creates and caches a controller for a category field.
  TextEditingController _catCtrl(String catId, String field, double defaultVal) {
    final key = '${catId}_$field';
    if (!_categoryControllers.containsKey(key)) {
      _categoryControllers[key] = TextEditingController(text: defaultVal.toString())
        ..addListener(_onChanged);
    }
    return _categoryControllers[key]!;
  }

  void _applyAndRecalculate() {
    final state = context.read<DataBloc>().state;

    final newSettings = Settings.defaults()
      ..electricityCostKwh = double.tryParse(_electricityController.text) ?? state.settings.electricityCostKwh
      ..etsyFeesPercent = double.tryParse(_etsyFeesController.text) ?? state.settings.etsyFeesPercent
      ..etsyListingFee = double.tryParse(_etsyListingFeeController.text) ?? state.settings.etsyListingFee;

    double getVal(Category cat, String field, double def) =>
        double.tryParse(_catCtrl(cat.id, field, def).text) ?? def;

    final updatedCategories = state.categories.map((cat) => Category(
      id: cat.id,
      name: cat.name,
      filamentCostPerKg: getVal(cat, 'filamentCostPerKg', cat.filamentCostPerKg),
      laborCost: getVal(cat, 'laborCost', cat.laborCost),
      licenseFee: getVal(cat, 'licenseFee', cat.licenseFee),
      shippingCost: getVal(cat, 'shippingCost', cat.shippingCost),
      profitMargin: getVal(cat, 'profitMargin', cat.profitMargin),
      avoidanceZoneMin: getVal(cat, 'avoidanceZoneMin', cat.avoidanceZoneMin),
      avoidanceZoneMax: getVal(cat, 'avoidanceZoneMax', cat.avoidanceZoneMax),
      avoidanceZoneThreshold: getVal(cat, 'avoidanceZoneThreshold', cat.avoidanceZoneThreshold),
      smallPriceCap: getVal(cat, 'smallPriceCap', cat.smallPriceCap),
      minGapSmallMedium: getVal(cat, 'minGapSmallMedium', cat.minGapSmallMedium),
      minGapMediumLarge: getVal(cat, 'minGapMediumLarge', cat.minGapMediumLarge),
      multicolorSmallPriceCap: getVal(cat, 'multicolorSmallPriceCap', cat.multicolorSmallPriceCap),
      multicolorSmallPriceMin: getVal(cat, 'multicolorSmallPriceMin', cat.multicolorSmallPriceMin),
    )).toList();

    context.read<DataBloc>().add(RecalculateAllPrices(
      settings: newSettings,
      categories: updatedCategories,
    ));

    setState(() => _settingsModified = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved & all prices recalculated!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ── compact text field for global settings ──────────────────────────────
  Widget _globalField(TextEditingController ctrl, String label, {double width = 140}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  // ── compact text field for category table cells ──────────────────────────
  Widget _catField(TextEditingController ctrl, {double width = 82}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          border: OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget _colHeader(String text, double width) => SizedBox(
        width: width,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spreadsheet View'),
        actions: [
          if (_settingsModified)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.amber),
                label: const Text('Apply', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                onPressed: _applyAndRecalculate,
              ),
            ),
        ],
      ),
      body: BlocBuilder<DataBloc, DataState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGlobalSettingsCard(state),
              const SizedBox(height: 16),
              _buildCategorySettingsCard(state),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _settingsModified
                    ? SizedBox(
                        key: const ValueKey('applyBtn'),
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_filled),
                          label: const Text(
                            'Apply Changes & Recalculate All Prices',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _applyAndRecalculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700],
                            foregroundColor: Colors.black,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('noBtn')),
              ),
              const SizedBox(height: 16),
              _buildProductTable(state),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlobalSettingsCard(DataState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Global Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  '— applied to all categories',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _globalField(_electricityController, 'Electricity \$/kWh'),
                _globalField(_etsyFeesController, 'Etsy Fees %'),
                _globalField(_etsyListingFeeController, 'Listing Fee \$'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySettingsCard(DataState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Per-Category Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  'scroll →',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      _colHeader('Category', 148),
                      _colHeader('Fil/kg \$', 82),
                      const SizedBox(width: 4),
                      _colHeader('Labor \$', 82),
                      const SizedBox(width: 4),
                      _colHeader('License \$', 82),
                      const SizedBox(width: 4),
                      _colHeader('Shipping \$', 82),
                      const SizedBox(width: 4),
                      _colHeader('Margin %', 82),
                      const SizedBox(width: 4),
                      _colHeader('Avoid Min', 82),
                      const SizedBox(width: 4),
                      _colHeader('Avoid Max', 82),
                      const SizedBox(width: 4),
                      _colHeader('Avoid Th.', 82),
                      const SizedBox(width: 4),
                      _colHeader('Sm Cap \$', 82),
                      const SizedBox(width: 4),
                      _colHeader('MC Cap \$', 82),
                      const SizedBox(width: 4),
                      _colHeader('MC Min \$', 82),
                      const SizedBox(width: 4),
                      _colHeader('Gap S-M \$', 88),
                      const SizedBox(width: 4),
                      _colHeader('Gap M-L \$', 88),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...state.categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Category name + edit link
                        SizedBox(
                          width: 148,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CategoryEditPage(category: cat)),
                                ),
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(Icons.open_in_new, size: 14, color: Colors.grey[500]),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                        _catField(_catCtrl(cat.id, 'filamentCostPerKg', cat.filamentCostPerKg)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'laborCost', cat.laborCost)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'licenseFee', cat.licenseFee)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'shippingCost', cat.shippingCost)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'profitMargin', cat.profitMargin)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'avoidanceZoneMin', cat.avoidanceZoneMin)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'avoidanceZoneMax', cat.avoidanceZoneMax)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'avoidanceZoneThreshold', cat.avoidanceZoneThreshold)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'smallPriceCap', cat.smallPriceCap)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'multicolorSmallPriceCap', cat.multicolorSmallPriceCap)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'multicolorSmallPriceMin', cat.multicolorSmallPriceMin)),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'minGapSmallMedium', cat.minGapSmallMedium), width: 88),
                        const SizedBox(width: 4),
                        _catField(_catCtrl(cat.id, 'minGapMediumLarge', cat.minGapMediumLarge), width: 88),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable(DataState state) {
    if (state.products.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.table_chart_outlined, size: 52, color: Colors.grey[600]),
                const SizedBox(height: 12),
                Text('No products yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                const SizedBox(height: 4),
                Text('Add products from the Products tab', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    }

    final catNames = {for (final c in state.categories) c.id: c.name};

    String priceStr(double p) => p > 0 ? '\$${p.toStringAsFixed(0)}' : '–';
    String profitStr(double p) => p > 0 ? '\$${p.toStringAsFixed(2)}' : '–';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Product Pricing Overview',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '${state.products.length} product${state.products.length == 1 ? '' : 's'}  •  scroll →',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 38,
                dataRowMaxHeight: 52,
                columnSpacing: 10,
                horizontalMargin: 6,
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.grey[300],
                ),
                dataTextStyle: const TextStyle(fontSize: 12),
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('S. Price'), numeric: true),
                  DataColumn(label: Text('S. Profit'), numeric: true),
                  DataColumn(label: Text('M. Price'), numeric: true),
                  DataColumn(label: Text('M. Profit'), numeric: true),
                  DataColumn(label: Text('L. Price'), numeric: true),
                  DataColumn(label: Text('L. Profit'), numeric: true),
                  DataColumn(label: Text('MC-S'), numeric: true),
                  DataColumn(label: Text('MC-M'), numeric: true),
                  DataColumn(label: Text('MC-L'), numeric: true),
                  DataColumn(label: Text('Sales'), numeric: true),
                  DataColumn(label: Text('Revenue'), numeric: true),
                ],
                rows: state.products.map((product) {
                  final catName = catNames[product.categoryId] ?? '–';
                  final primary = Theme.of(context).colorScheme.secondary;

                  DataCell priceCell(double price) => DataCell(Text(
                    priceStr(price),
                    style: TextStyle(
                      color: price > 0 ? primary : Colors.grey,
                      fontWeight: price > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ));
                  DataCell profitCell(double profit) => DataCell(Text(
                    profitStr(profit),
                    style: TextStyle(
                      color: profit > 0 ? Colors.greenAccent : Colors.grey,
                    ),
                  ));

                  return DataRow(
                    onSelectChanged: (_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                      );
                    },
                    cells: [
                      DataCell(SizedBox(
                        width: 150,
                        child: Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 100,
                        child: Text(catName, overflow: TextOverflow.ellipsis),
                      )),
                      priceCell(product.smallVariation.etsyPrice),
                      profitCell(product.smallVariation.profit),
                      priceCell(product.mediumVariation.etsyPrice),
                      profitCell(product.mediumVariation.profit),
                      priceCell(product.largeVariation.etsyPrice),
                      profitCell(product.largeVariation.profit),
                      priceCell(product.smallMulticolorVariation?.etsyPrice ?? 0),
                      priceCell(product.mediumMulticolorVariation?.etsyPrice ?? 0),
                      priceCell(product.largeMulticolorVariation?.etsyPrice ?? 0),
                      DataCell(Text('${product.totalSales}')),
                      DataCell(Text(
                        '\$${product.totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.amber),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double cost;
  final double profit;
  final double price;
  final double? suggestedPrice;
  final double? originalPrice;
  final double? totalPrice;
  final double? numberOfModels;
  final double? totalCost;
  final double? totalProfit;

  const _ResultRow(this.label, this.cost, this.profit, this.price, this.suggestedPrice, this.originalPrice, this.totalPrice, this.numberOfModels, this.totalCost, this.totalProfit);

  @override
  Widget build(BuildContext context) {
    final salePrice15 = price * 0.85;
    final salePrice25 = price * 0.75;
    final wasAdjusted = originalPrice != null && originalPrice! > 0 && originalPrice! != price;
    final isMulticolor = totalPrice != null && numberOfModels != null && numberOfModels! > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 50, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isMulticolor && totalCost != null) ...[
                  Text('\$${cost.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  Text('(Total: \$${totalCost!.toStringAsFixed(2)})', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                ] else ...[
                  Text('\$${cost.toStringAsFixed(2)}', textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isMulticolor && totalProfit != null) ...[
                  Text('\$${profit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12), textAlign: TextAlign.center),
                  Text('(Total: \$${totalProfit!.toStringAsFixed(2)})', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                ] else ...[
                  Text('\$${profit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isMulticolor) ...[
                  Text(
                    '\$${price.toStringAsFixed(0)} each',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(${numberOfModels!.toInt()} models)',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: \$${totalPrice!.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 11, color: Colors.amber[300]),
                  ),
                ] else ...[
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                  ),
                ],
                if (wasAdjusted) ...[
                  const SizedBox(height: 2),
                  Text(
                    '(was \$${originalPrice!.toStringAsFixed(0)})',
                    style: TextStyle(fontSize: 10, color: Colors.amber[300], fontStyle: FontStyle.italic),
                  ),
                ],
                if (price > 0 && !isMulticolor) ...[
                  const SizedBox(height: 4),
                  Text(
                    '15%: \$${salePrice15.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  Text(
                    '25%: \$${salePrice25.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

