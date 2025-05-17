class Product {
  String name;
  String price;
  String image;
  String size;
  String color;
  String currencySymbol;
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

  factory Product.fromMap(Map<String, dynamic> map) {
    String name = map['name']?.toString() ?? 'اسم غير متوفر';
    String? rawPriceFromMap = map['price']?.toString();
    String priceVal = (rawPriceFromMap == null || rawPriceFromMap.isEmpty || rawPriceFromMap.trim().isEmpty) ? '0' : rawPriceFromMap;

    String image = map['image']?.toString() ?? '';
    String size = map['size']?.toString() ?? '';
    String color = map['color']?.toString() ?? '';
    String currency = map['currencySymbol']?.toString() ?? '';
    int quantity = map['quantity'] as int? ?? 1;

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

  double get numericValue {
    if (price.isEmpty) return 0.0;

    String westernPrice = price.replaceAllMapped(RegExp(r'[٠١٢٣٤٥٦٧٨٩]'), (match) {
      return (match.group(0)!.codeUnitAt(0) - 1632).toString();
    }).replaceAllMapped(RegExp(r'[۰۱۲۳۴۵۶۷۸۹]'), (match) {
      return (match.group(0)!.codeUnitAt(0) - 1776).toString();
    });

    String parsablePrice = westernPrice.replaceAll(',', '.');
    return double.tryParse(parsablePrice) ?? 0.0;
  }
} 