class Product {
  final String name;
  final String price;
  final String image;
  final String size;
  final String color;
  final String currencySymbol;
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.size,
    required this.color,
    this.currencySymbol = '',
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
      'size': size,
      'color': color,
      'currencySymbol': currencySymbol,
      'quantity': quantity,
    };
  }

  // Create Product from Map (JSON deserialization)
  factory Product.fromMap(Map<String, dynamic> map) {
    print("Product.fromMap: Received map: $map");
    String name = map['name']?.toString() ?? 'اسم غير متوفر';
    String? rawPriceFromMap = map['price']?.toString();
    String priceVal = (rawPriceFromMap == null || rawPriceFromMap.isEmpty || rawPriceFromMap.trim().isEmpty) ? '0' : rawPriceFromMap;

    String image = map['image']?.toString() ?? '';
    String size = map['size']?.toString() ?? '';
    String color = map['color']?.toString() ?? '';
    String currency = map['currencySymbol']?.toString() ?? '';
    int quantity = map['quantity'] as int? ?? 1;
    print("Product.fromMap: Parsed values -> name: $name, price: $priceVal, currency: $currency, image: $image, size: $size, color: $color");

    return Product(
      name: name,
      price: priceVal,
      image: image,
      size: size,
      color: color,
      currencySymbol: currency,
      quantity: quantity,
    );
  }
} 