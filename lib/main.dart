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

  ProductVariation({
    this.printTimeHours = 0.0,
    this.filamentGrams = 0.0,
    this.etsyPrice = 0.0,
    this.profit = 0.0,
  });
  
  // For JSON serialization
  Map<String, dynamic> toJson() => {
    'printTimeHours': printTimeHours,
    'filamentGrams': filamentGrams,
    'etsyPrice': etsyPrice,
    'profit': profit,
  };

  factory ProductVariation.fromJson(Map<String, dynamic> json) => ProductVariation(
    printTimeHours: (json['printTimeHours'] as num).toDouble(),
    filamentGrams: (json['filamentGrams'] as num).toDouble(),
    etsyPrice: (json['etsyPrice'] as num? ?? 0.0).toDouble(), // Handle legacy data
    profit: (json['profit'] as num? ?? 0.0).toDouble(), // Handle legacy data
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

  Product({
    required this.id,
    required this.name,
    required this.smallVariation,
    required this.mediumVariation,
    required this.largeVariation,
    this.imageUrl,
    this.listingUrl,
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
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    smallVariation: ProductVariation.fromJson(json['smallVariation']),
    mediumVariation: ProductVariation.fromJson(json['mediumVariation']),
    largeVariation: ProductVariation.fromJson(json['largeVariation']),
    imageUrl: json['imageUrl'] as String?,
    listingUrl: json['listingUrl'] as String?,
  );
}

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  late double filamentCostPerKg;
  @HiveField(1)
  late double electricityCostKwh;
  @HiveField(2)
  late double laborCost;
  @HiveField(3)
  late double licenseFee;
  @HiveField(4)
  late double shippingCost;
  @HiveField(5)
  late double etsyFeesPercent;
  @HiveField(6)
  late double etsyListingFee;
  @HiveField(7)
  late double profitMargin;

  Settings.defaults() {
    filamentCostPerKg = 17.50;
    electricityCostKwh = 0.15;
    laborCost = 3.00;
    licenseFee = 2.00;
    shippingCost = 2.00;
    etsyFeesPercent = 9.5;
    etsyListingFee = 0.20;
    profitMargin = 40.0;
  }
  
  // For JSON serialization
  Map<String, dynamic> toJson() => {
    'filamentCostPerKg': filamentCostPerKg,
    'electricityCostKwh': electricityCostKwh,
    'laborCost': laborCost,
    'licenseFee': licenseFee,
    'shippingCost': shippingCost,
    'etsyFeesPercent': etsyFeesPercent,
    'etsyListingFee': etsyListingFee,
    'profitMargin': profitMargin,
  };

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings.defaults()
      ..filamentCostPerKg = (json['filamentCostPerKg'] as num).toDouble()
      ..electricityCostKwh = (json['electricityCostKwh'] as num).toDouble()
      ..laborCost = (json['laborCost'] as num).toDouble()
      ..licenseFee = (json['licenseFee'] as num).toDouble()
      ..shippingCost = (json['shippingCost'] as num).toDouble()
      ..etsyFeesPercent = (json['etsyFeesPercent'] as num).toDouble()
      ..etsyListingFee = (json['etsyListingFee'] as num).toDouble()
      ..profitMargin = (json['profitMargin'] as num).toDouble();
  }
}

// --- Part 2: Manual Hive Type Adapters ---

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
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.printTimeHours)
      ..writeByte(1)
      ..write(obj.filamentGrams)
      ..writeByte(2)
      ..write(obj.etsyPrice)
      ..writeByte(3)
      ..write(obj.profit);
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
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.listingUrl);
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
      ..filamentCostPerKg = fields[0] as double
      ..electricityCostKwh = fields[1] as double
      ..laborCost = fields[2] as double
      ..licenseFee = fields[3] as double
      ..shippingCost = fields[4] as double
      ..etsyFeesPercent = fields[5] as double
      ..etsyListingFee = fields[6] as double
      ..profitMargin = fields[7] as double;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.filamentCostPerKg)
      ..writeByte(1)
      ..write(obj.electricityCostKwh)
      ..writeByte(2)
      ..write(obj.laborCost)
      ..writeByte(3)
      ..write(obj.licenseFee)
      ..writeByte(4)
      ..write(obj.shippingCost)
      ..writeByte(5)
      ..write(obj.etsyFeesPercent)
      ..writeByte(6)
      ..write(obj.etsyListingFee)
      ..writeByte(7)
      ..write(obj.profitMargin);
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
class RestoreData extends DataEvent {
  final String jsonData;
  RestoreData(this.jsonData);
}

class DataState {
  final List<Product> products;
  final Settings settings;
  DataState({required this.products, required this.settings});
}

class DataBloc extends Bloc<DataEvent, DataState> {
  final Box<Product> productBox;
  final Box<Settings> settingsBox;

  DataBloc(this.productBox, this.settingsBox) : super(DataState(products: [], settings: Settings.defaults())) {
    on<LoadData>(_onLoadData);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<UpdateSettings>(_onUpdateSettings);
    on<RestoreData>(_onRestoreData);
  }

  void _onLoadData(LoadData event, Emitter<DataState> emit) {
    final products = productBox.values.toList();
    products.sort((a, b) => a.name.compareTo(b.name));
    final settings = settingsBox.get('main', defaultValue: Settings.defaults())!;
    emit(DataState(products: products, settings: settings));
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

  Future<void> _onRestoreData(RestoreData event, Emitter<DataState> emit) async {
    try {
      final data = jsonDecode(event.jsonData) as Map<String, dynamic>;
      
      // Restore Settings - Checks for the new 'alteredSettings' key first for new backups,
      // but falls back to the old 'settings' key for backwards compatibility.
      final settingsData = data['alteredSettings'] ?? data['settings'] as Map<String, dynamic>;
      final newSettings = Settings.fromJson(settingsData);
      await settingsBox.put('main', newSettings);

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
}

// --- Main App Entry Point ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(ProductVariationAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SettingsAdapter());

  final productBox = await Hive.openBox<Product>('products');
  final settingsBox = await Hive.openBox<Settings>('settings');
  
  runApp(MyApp(productBox: productBox, settingsBox: settingsBox));
}

class MyApp extends StatelessWidget {
  final Box<Product> productBox;
  final Box<Settings> settingsBox;

  const MyApp({super.key, required this.productBox, required this.settingsBox});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataBloc(productBox, settingsBox)..add(LoadData()),
      child: MaterialApp(
        title: 'Etsy Pricing Calculator',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.tealAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 1,
          ),
          cardColor: const Color(0xFF1E1E1E),
        ),
        home: const HomePage(),
      ),
    );
  }
}

// --- Part 4: UI Screens ---

// --- Home Page ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _launchURL(String? urlString) async {
    if (urlString != null && urlString.isNotEmpty) {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }
  
  String _formatPrices(Product product) {
    final parts = <String>[];
    if (product.smallVariation.etsyPrice > 0) {
      parts.add('S: \$${product.smallVariation.etsyPrice.toStringAsFixed(0)} (\$${product.smallVariation.profit.toStringAsFixed(2)})');
    }
    if (product.mediumVariation.etsyPrice > 0) {
      parts.add('M: \$${product.mediumVariation.etsyPrice.toStringAsFixed(0)} (\$${product.mediumVariation.profit.toStringAsFixed(2)})');
    }
    if (product.largeVariation.etsyPrice > 0) {
      parts.add('L: \$${product.largeVariation.etsyPrice.toStringAsFixed(0)} (\$${product.largeVariation.profit.toStringAsFixed(2)})');
    }
    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Priced Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: BlocBuilder<DataBloc, DataState>(
        builder: (context, state) {
          if (state.products.isEmpty) {
            return const Center(child: Text('No products yet. Add one!'));
          }
          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
              final hasListing = product.listingUrl != null && product.listingUrl!.isNotEmpty;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: hasImage
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                        )
                      : const Icon(Icons.widgets, size: 40),
                  title: Text(product.name),
                  subtitle: Text(_formatPrices(product)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(hasListing)
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _launchURL(product.listingUrl),
                          tooltip: 'Open Etsy Listing',
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailPage()));
        },
      ),
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
      'filamentCostPerKg': TextEditingController(text: settings.filamentCostPerKg.toString()),
      'electricityCostKwh': TextEditingController(text: settings.electricityCostKwh.toString()),
      'laborCost': TextEditingController(text: settings.laborCost.toString()),
      'licenseFee': TextEditingController(text: settings.licenseFee.toString()),
      'shippingCost': TextEditingController(text: settings.shippingCost.toString()),
      'etsyFeesPercent': TextEditingController(text: settings.etsyFeesPercent.toString()),
      'etsyListingFee': TextEditingController(text: settings.etsyListingFee.toString()),
      'profitMargin': TextEditingController(text: settings.profitMargin.toString()),
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
        const SnackBar(content: Text('Settings Saved!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _backupData() async {
    final dataState = context.read<DataBloc>().state;
    final backupData = {
      'alteredSettings': dataState.settings.toJson(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Calculation Settings', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildTextField('filamentCostPerKg', 'Filament Cost (\$/kg)'),
            _buildTextField('electricityCostKwh', 'Electricity Cost (\$/kWh)'),
            _buildTextField('laborCost', 'Labor & Handling (\$)'),
            _buildTextField('licenseFee', 'License Fee (\$)'),
            _buildTextField('shippingCost', 'Shipping & Packaging (\$)'),
            _buildTextField('etsyFeesPercent', 'Etsy Fees (%)'),
            _buildTextField('etsyListingFee', 'Etsy Listing Fee (\$)'),
            _buildTextField('profitMargin', 'Desired Profit Margin (%)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
            const SizedBox(height: 30),
            Text('Data Management', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              label: const Text('Backup Data'),
              onPressed: _backupData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('Restore Data'),
              onPressed: _restoreData,
               style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
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
  late TabController _tabController;
  
  late TextEditingController _nameController, _imageUrlController, _listingUrlController;
  late TextEditingController _sTimeController, _sGramController;
  late TextEditingController _mTimeController, _mGramController;
  late TextEditingController _lTimeController, _lGramController;
  
  Map<String, Map<String, double>> _pricingResult = {};

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _listingUrlController = TextEditingController(text: widget.product?.listingUrl ?? '');

    _sTimeController = TextEditingController(text: widget.product?.smallVariation.printTimeHours.toString() ?? '0');
    _sGramController = TextEditingController(text: widget.product?.smallVariation.filamentGrams.toString() ?? '0');
    _mTimeController = TextEditingController(text: widget.product?.mediumVariation.printTimeHours.toString() ?? '0');
    _mGramController = TextEditingController(text: widget.product?.mediumVariation.filamentGrams.toString() ?? '0');
    _lTimeController = TextEditingController(text: widget.product?.largeVariation.printTimeHours.toString() ?? '0');
    _lGramController = TextEditingController(text: widget.product?.largeVariation.filamentGrams.toString() ?? '0');

    // If editing, show existing prices immediately
    if (_isEditing) {
      _showExistingPrices();
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _imageUrlController.dispose();
    _listingUrlController.dispose();
    _sTimeController.dispose();
    _sGramController.dispose();
    _mTimeController.dispose();
    _mGramController.dispose();
    _lTimeController.dispose();
    _lGramController.dispose();
    super.dispose();
  }
  
  void _showExistingPrices() {
      final settings = context.read<DataBloc>().state.settings;
      final product = widget.product!;
      final variations = {
        'Small': product.smallVariation,
        'Medium': product.mediumVariation,
        'Large': product.largeVariation,
      };

      Map<String, Map<String, double>> newResults = {};
      
      variations.forEach((key, variation) {
        if (variation.etsyPrice > 0) {
            final filamentCostPerGram = settings.filamentCostPerKg / 1000;
            final calculatedFilamentCost = variation.filamentGrams * filamentCostPerGram;
            final calculatedElectricityCost = variation.printTimeHours * settings.electricityCostKwh;
            final totalProductionCost = calculatedFilamentCost + calculatedElectricityCost + settings.laborCost + settings.licenseFee;

            newResults[key] = {
              'totalProductionCost': totalProductionCost,
              'etsyPrice': variation.etsyPrice,
              'profit': variation.profit,
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

  void _calculateAndSave() {
    if (_formKey.currentState!.validate()) {
      final settings = context.read<DataBloc>().state.settings;
      
      final variationsData = {
        'Small': {'time': double.tryParse(_sTimeController.text) ?? 0, 'grams': double.tryParse(_sGramController.text) ?? 0},
        'Medium': {'time': double.tryParse(_mTimeController.text) ?? 0, 'grams': double.tryParse(_mGramController.text) ?? 0},
        'Large': {'time': double.tryParse(_lTimeController.text) ?? 0, 'grams': double.tryParse(_lGramController.text) ?? 0},
      };

      Map<String, Map<String, double>> newResults = {};
      final newVariations = <String, ProductVariation>{};
      
      variationsData.forEach((key, value) {
        final printTime = value['time']!;
        final filamentGrams = value['grams']!;
        double calculatedPrice = 0;
        double profitAmount = 0;
        
        if (printTime > 0 && filamentGrams > 0) {
            final filamentCostPerGram = settings.filamentCostPerKg / 1000;
            final calculatedFilamentCost = filamentGrams * filamentCostPerGram;
            final calculatedElectricityCost = printTime * settings.electricityCostKwh;
            
            final totalProductionCost = calculatedFilamentCost + calculatedElectricityCost + settings.laborCost + settings.licenseFee;
            profitAmount = totalProductionCost * (settings.profitMargin / 100);
            final targetAmount = totalProductionCost + profitAmount + settings.shippingCost;
            final etsyPrice = (targetAmount + settings.etsyListingFee) / (1 - (settings.etsyFeesPercent / 100));
            calculatedPrice = _roundToNearestEven(etsyPrice);

            newResults[key] = {
              'totalProductionCost': totalProductionCost,
              'etsyPrice': calculatedPrice,
              'profit': profitAmount,
            };
        }
        newVariations[key] = ProductVariation(
          printTimeHours: printTime, 
          filamentGrams: filamentGrams, 
          etsyPrice: calculatedPrice,
          profit: profitAmount
        );
      });

      setState(() {
         _pricingResult = newResults;
      });

      final product = Product(
        id: _isEditing ? widget.product!.id : const Uuid().v4(),
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        listingUrl: _listingUrlController.text,
        smallVariation: newVariations['Small']!,
        mediumVariation: newVariations['Medium']!,
        largeVariation: newVariations['Large']!,
      );
      
      if (_isEditing) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                   _buildTextField(_nameController, 'Product Name'),
                   const SizedBox(height: 12),
                   _buildTextField(_imageUrlController, 'Image URL (Optional)', isRequired: false),
                   const SizedBox(height: 12),
                   _buildTextField(_listingUrlController, 'Etsy Listing URL (Optional)', isRequired: false),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Small'),
                Tab(text: 'Medium'),
                Tab(text: 'Large'),
              ],
            ),
            SizedBox(
              height: 150,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVariationTab(_sTimeController, _sGramController),
                  _buildVariationTab(_mTimeController, _mGramController),
                  _buildVariationTab(_lTimeController, _lGramController),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _calculateAndSave,
              child: Text(_isEditing ? 'Recalculate & Save' : 'Recalculate & Save'),
            ),
            const SizedBox(height: 20),
            if (_pricingResult.isNotEmpty)
              _buildResultsCard()
          ],
        ),
      ),
    );
  }

  Widget _buildVariationTab(TextEditingController timeController, TextEditingController gramController) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            _buildTextField(timeController, 'Print Time (hours)'),
            const SizedBox(height: 12),
            _buildTextField(gramController, 'Filament Used (grams)'),
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
          if (keyboardType != TextInputType.text && double.tryParse(value ?? '0') == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      );
  }
  
  Widget _buildResultsCard() {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text('Pricing Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        SizedBox(width: 50, child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(width: 60, child: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        SizedBox(width: 60, child: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        SizedBox(width: 80, child: Text('Etsy Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                      ],
                    ),
                    const Divider(),
                    ..._pricingResult.entries.map((entry) {
                      return _ResultRow(
                          entry.key,
                          entry.value['totalProductionCost']!,
                          entry.value['profit']!,
                          entry.value['etsyPrice']!
                      );
                    }).toList(),
                ],
            )
        )
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double cost;
  final double profit;
  final double price;

  const _ResultRow(this.label, this.cost, this.profit, this.price);

  @override
  Widget build(BuildContext context) {
    final salePrice15 = price * 0.85;
    final salePrice25 = price * 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 50, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 60, child: Text('\$${cost.toStringAsFixed(2)}', textAlign: TextAlign.center)),
          SizedBox(width: 60, child: Text('\$${profit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent), textAlign: TextAlign.center)),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                ),
                if (price > 0) ...[
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

