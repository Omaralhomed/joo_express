import 'dart:convert';

class Product {
  final String name;
  final String price;
  final String image;
  Map<String, String>? selectedOptions; // لاستيعاب الخيارات الديناميكية
  final String? currencySymbol; // جعله قابلاً ليكون null ليتوافق مع البيانات الجديدة
  final String site; // إضافة حقل الموقع
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.image,
    this.selectedOptions,
    this.currencySymbol,
    required this.site, // إضافة الموقع كحقل مطلوب
    this.quantity = 1,
  });

  // Convert numeric price string to double
  double get numericValue {
    if (price.isEmpty) return 0.0;

    // Convert Eastern Arabic and Persian numbers to Western numbers
    String westernPrice = price.replaceAllMapped(RegExp(r'[٠١٢٣٤٥٦٧٨٩]'), (match) {
      // Convert Eastern Arabic numbers (٠-٩) to (0-9)
      return (match.group(0)!.codeUnitAt(0) - 1632).toString();
    }).replaceAllMapped(RegExp(r'[۰۱۲۳۴۵۶۷۸۹]'), (match) {
      // Convert Persian numbers (۰-۹) to (0-9)
      return (match.group(0)!.codeUnitAt(0) - 1776).toString();
    });

    // Remove any non-numeric characters except decimal point and digits
    String cleanPrice = westernPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    
    // Handle decimal point
    cleanPrice = cleanPrice.replaceAll(',', '.');
    
    try {
      return double.parse(cleanPrice);
    } catch (e) {
      print('Error parsing price: $price (cleaned: $cleanPrice)');
      return 0.0;
    }
  }

  // Convert Product to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'selectedOptions': selectedOptions, // إضافة الخيارات الجديدة
      'currencySymbol': currencySymbol ?? '', // التعامل مع null
      'site': site, // إضافة الموقع إلى Map
      'quantity': quantity,
    };
  }

  // Create Product from Map (JSON deserialization)
  factory Product.fromMap(Map<String, dynamic> map) {
    print("Product.fromMap: Starting to parse map: $map");
    
    String name = map['name']?.toString() ?? 'اسم غير متوفر';
    String? rawPriceFromMap = map['price']?.toString();
    String priceVal = (rawPriceFromMap == null || rawPriceFromMap.isEmpty || rawPriceFromMap.trim().isEmpty) ? '0' : rawPriceFromMap;
    String image = map['image']?.toString() ?? '';
    String? currency = map['currencySymbol']?.toString();
    String site = map['site']?.toString() ?? 'SHEIN'; // Default to SHEIN if site is missing
    int quantity = map['quantity'] as int? ?? 1;

    print("Product.fromMap: Basic fields parsed - name: $name, price: $priceVal, site: $site");

    Map<String, String>? options;
    if (map['selectedOptions'] != null && map['selectedOptions'] is Map) {
      options = Map<String, String>.from(map['selectedOptions'].map(
          (key, value) => MapEntry(key.toString(), value.toString())));
      print("Product.fromMap: Loaded selectedOptions: $options");
    } else if (map['options'] != null && map['options'] is Map) {
      options = Map<String, String>.from(map['options'].map(
          (key, value) => MapEntry(key.toString(), value.toString())));
      print("Product.fromMap: Loaded options from legacy field: $options");
    }

    if (options == null && (map.containsKey('size') || map.containsKey('color'))) {
      options = {};
      if (map['size'] != null && map['size'].toString().isNotEmpty) {
        options['المقاس'] = map['size'].toString();
      }
      if (map['color'] != null && map['color'].toString().isNotEmpty) {
        options['اللون'] = map['color'].toString();
      }
      if (options.isEmpty) {
        options = null;
      }
      print("Product.fromMap: Created options from legacy size/color: $options");
    }

    Product product = Product(
      name: name,
      price: priceVal,
      image: image,
      selectedOptions: options,
      currencySymbol: currency,
      site: site,
      quantity: quantity,
    );
    
    print("Product.fromMap: Created product: ${product.toMap()}");
    return product;
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source));

  String get optionsDisplay {
    if (selectedOptions == null || selectedOptions!.isEmpty) {
      return 'لا توجد خيارات محددة';
    }
    return selectedOptions!.entries.map((e) => '${e.key}: ${e.value}').join('، ');
  }
} 