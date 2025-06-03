import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../models/product.dart';
import '../../screens/checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> cartItems = [];
  Map<String, List<Product>> groupedItems = {};
  String? _selectedShippingLocation;
  String? _selectedPaymentMethod;

  // --- Controllers for shipping and payment details ---
  final TextEditingController _shippingNameController = TextEditingController();
  final TextEditingController _shippingPhoneController = TextEditingController();
  final TextEditingController _shippingAddressController = TextEditingController();
  String? _shippingCity;

  String? _paymentMethod;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? cartList = prefs.getStringList('cart');
      print("CartScreen _loadCart: cartList from SharedPreferences: $cartList");

      if (cartList != null && cartList.isNotEmpty) {
        List<Product> loadedItems = [];
        for (var itemJson in cartList) {
          try {
            Map<String, dynamic> itemMap = jsonDecode(itemJson);
            print("CartScreen _loadCart: Processing item: $itemMap");
            
            // Ensure the site field exists
            if (!itemMap.containsKey('site')) {
              print("CartScreen _loadCart: Adding missing site field to item");
              itemMap['site'] = 'SHEIN'; // Default to SHEIN for existing items
            }
            
            Product product = Product.fromMap(itemMap);
            print("CartScreen _loadCart: Successfully loaded product: ${product.toMap()}");
            loadedItems.add(product);
          } catch (e) {
            print("CartScreen _loadCart: Error decoding product: $itemJson, Error: $e");
          }
        }
        
        print("CartScreen _loadCart: Total items loaded: ${loadedItems.length}");
        setState(() {
          cartItems = loadedItems;
          _groupItemsBySite();
          print("CartScreen _loadCart: Final cart state - Items: ${cartItems.length}, Groups: ${groupedItems.length}");
        });
      } else {
        print("CartScreen _loadCart: cartList is null or empty. Setting cartItems to empty list.");
        setState(() {
          cartItems = [];
          groupedItems = {};
        });
      }
    } catch (e) {
      print("CartScreen _loadCart: Error loading cart: $e");
      setState(() {
        cartItems = [];
        groupedItems = {};
      });
    }
  }

  void _groupItemsBySite() {
    groupedItems.clear();
    for (var item in cartItems) {
      if (!groupedItems.containsKey(item.site)) {
        groupedItems[item.site] = [];
      }
      groupedItems[item.site]!.add(item);
    }
  }

  double get _totalPrice {
    return cartItems.fold(0.0, (sum, item) => sum + (item.numericValue * (item.quantity ?? 1)));
  }

  Future<bool> _validateOrder() async {
    // Check if cart is empty
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('السلة فارغة')),
      );
      return false;
    }

    // Check if all items have required attributes
    for (var item in cartItems) {
      if (item.name.isEmpty || item.price.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('بعض المنتجات غير مكتملة المعلومات')),
        );
        return false;
      }

      // Check if selected options are present
      if (item.selectedOptions == null || item.selectedOptions!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى تحديد خيارات المنتج (مثل المقاس واللون)')),
        );
        return false;
      }

      // Check if quantity is valid
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى تحديد كمية صحيحة للمنتجات')),
        );
        return false;
      }
    }

    // Check if total price is valid
    if (_totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('إجمالي السلة غير صالح')),
      );
      return false;
    }

    return true;
  }

  Future<void> _checkout() async {
    // Validate order before proceeding
    if (!await _validateOrder()) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Clear the cart
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart');
      
      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اتمام الطلب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // Update UI
      setState(() {
        cartItems = [];
        groupedItems = {};
      });
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء اتمام الطلب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCheckoutStepsDialog() async {
    int step = 0;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(step == 0 ? 'تفاصيل الشحن' : 'تفاصيل الدفع'),
              content: SingleChildScrollView(
                child: step == 0
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _shippingNameController,
                          decoration: InputDecoration(labelText: 'الاسم الكامل'),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _shippingPhoneController,
                          decoration: InputDecoration(labelText: 'رقم الجوال'),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _shippingCity,
                          decoration: InputDecoration(labelText: 'المدينة'),
                          items: [
                            DropdownMenuItem(value: 'الرياض', child: Text('الرياض')),
                            DropdownMenuItem(value: 'جدة', child: Text('جدة')),
                            DropdownMenuItem(value: 'الدمام', child: Text('الدمام')),
                          ],
                          onChanged: (value) => setState(() => _shippingCity = value),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _shippingAddressController,
                          decoration: InputDecoration(labelText: 'العنوان التفصيلي'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          decoration: InputDecoration(labelText: 'طريقة الدفع'),
                          items: [
                            DropdownMenuItem(value: 'بطاقة ائتمان', child: Text('بطاقة ائتمان')),
                            DropdownMenuItem(value: 'تحويل بنكي', child: Text('تحويل بنكي')),
                          ],
                          onChanged: (value) => setState(() => _paymentMethod = value),
                        ),
                        if (_paymentMethod == 'بطاقة ائتمان') ...[
                          SizedBox(height: 8),
                          TextField(
                            controller: _cardNumberController,
                            decoration: InputDecoration(labelText: 'رقم البطاقة'),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _cardExpiryController,
                            decoration: InputDecoration(labelText: 'تاريخ الانتهاء (MM/YY)'),
                            keyboardType: TextInputType.datetime,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _cardCvvController,
                            decoration: InputDecoration(labelText: 'رمز الأمان'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        if (_paymentMethod == 'تحويل بنكي') ...[
                          SizedBox(height: 8),
                          TextField(
                            controller: _bankNameController,
                            decoration: InputDecoration(labelText: 'اسم البنك'),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _bankAccountController,
                            decoration: InputDecoration(labelText: 'رقم الحساب'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ],
                    ),
              ),
              actions: [
                if (step == 1)
                  TextButton(
                    child: Text('رجوع'),
                    onPressed: () => setState(() => step = 0),
                  ),
                TextButton(
                  child: Text(step == 0 ? 'التالي' : 'اتمام الطلب'),
                  onPressed: () async {
                    if (step == 0) {
                      // تحقق من تفاصيل الشحن
                      if (_shippingNameController.text.isEmpty ||
                          _shippingPhoneController.text.isEmpty ||
                          _shippingCity == null ||
                          _shippingAddressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('يرجى تعبئة جميع بيانات الشحن')),
                        );
                        return;
                      }
                      setState(() => step = 1);
                    } else {
                      // تحقق من تفاصيل الدفع
                      if (_paymentMethod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('يرجى اختيار طريقة الدفع')),
                        );
                        return;
                      }
                      if (_paymentMethod == 'بطاقة ائتمان' &&
                          (_cardNumberController.text.isEmpty ||
                           _cardExpiryController.text.isEmpty ||
                           _cardCvvController.text.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('يرجى تعبئة جميع بيانات البطاقة')),
                        );
                        return;
                      }
                      if (_paymentMethod == 'تحويل بنكي' &&
                          (_bankNameController.text.isEmpty ||
                           _bankAccountController.text.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('يرجى تعبئة جميع بيانات التحويل البنكي')),
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      await _checkout();
                    }
                  },
                ),
                TextButton(
                  child: Text('إلغاء'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('السلة'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'السلة فارغة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ التسوق الآن',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, siteIndex) {
                      String site = groupedItems.keys.elementAt(siteIndex);
                      List<Product> siteItems = groupedItems[site]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              site,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          ...siteItems.map((item) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: item.image.isNotEmpty && Uri.tryParse(item.image)?.hasAbsolutePath == true
                                        ? Image.network(
                                            item.image,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 80, height: 80, color: Colors.grey[200],
                                              child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[400]),
                                            ),
                                          )
                                        : Container(
                                            width: 80, height: 80, color: Colors.grey[200],
                                            child: Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400]),
                                          ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name.isNotEmpty ? item.name : "اسم غير متوفر",
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        if (item.price.isNotEmpty)
                                          Text(
                                            '${item.currencySymbol?.isNotEmpty ?? false ? item.currencySymbol : ""} ${item.numericValue.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        SizedBox(height: 6),
                                        if (item.selectedOptions != null)
                                          ...item.selectedOptions!.entries.map((option) => Text(
                                            '${option.key}: ${option.value}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
                                          )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المجموع:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${cartItems.first.currencySymbol ?? ""} ${_totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreen(cartItems: cartItems),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'اتمام الشراء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/favorites');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          }
        },
      ),
    );
  }
} 