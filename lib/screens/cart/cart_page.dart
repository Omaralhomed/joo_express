import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joo_express/models/product.dart';

// صفحة عرض السلة
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> _cartItems = [];
  double _total = 0.0;
  bool _isLoading = true;
  bool _isCheckoutInProgress = false;
  String? _selectedShippingLocation;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // تحميل المنتجات من SharedPreferences عند فتح صفحة السلة
  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> cartList = prefs.getStringList('cart') ?? [];
      
      _cartItems = cartList.map((jsonStr) {
        try {
          return Product.fromMap(jsonDecode(jsonStr));
        } catch (e) {
          print("Error decoding product: $jsonStr, Error: $e");
          return null;
        }
      }).where((p) => p != null).cast<Product>().toList();

      _calculateTotal();
    } catch (e) {
      print("Error loading cart: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotal() {
    _total = _cartItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item.price) ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  // إزالة منتج من السلة وتحديث التخزين
  Future<void> _removeFromCart(int index) async {
    if (index < 0 || index >= _cartItems.length) {
      print("_removeFromCart: Invalid index $index");
      return;
    }
    final removedItemName = _cartItems[index].name;
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _cartItems.removeAt(index);
      });
      List<String> updatedList = _cartItems.map((p) => jsonEncode(p.toMap())).toList();
      await prefs.setStringList('cart', updatedList);
      print("تم حذف المنتج '$removedItemName' من السلة وتحديث SharedPreferences.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف المنتج من السلة'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      print("خطأ أثناء حذف عنصر: $e");
    }
  }

  // حفظ التغييرات في السلة إلى SharedPreferences
  Future<void> _saveCartChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> updatedList = _cartItems.map((p) => jsonEncode(p.toMap())).toList();
      await prefs.setStringList('cart', updatedList);
      print("تم حفظ تغييرات السلة في SharedPreferences.");
    } catch (e) {
      print("خطأ أثناء حفظ تغييرات السلة: $e");
    }
  }

  void _incrementQuantity(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    setState(() {
      _cartItems[index].quantity++;
    });
    _saveCartChanges();
  }

  void _decrementQuantity(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
        _saveCartChanges();
      } else {
        // إذا كانت الكمية 1، فسيؤدي النقصان إلى حذف العنصر
        // استدعاء _removeFromCart الذي يتعامل مع الحذف من القائمة والتخزين
        _removeFromCart(index); 
      }
    });
    // لا حاجة لاستدعاء _saveCartChanges() هنا إذا تم استدعاء _removeFromCart
    // لأنه يقوم بالحفظ بالفعل.
  }

  // حساب السعر الإجمالي
  double _calculateTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      total += (item.numericValue * item.quantity);
    }
    return total;
  }

  // الحصول على رمز العملة (نفترض أن جميع المنتجات بنفس العملة)
  String _getCartCurrencySymbol() {
    if (_cartItems.isEmpty) return '';
    for (var item in _cartItems) {
      if (item.currencySymbol?.isNotEmpty ?? false) {
        return item.currencySymbol!;
      }
    }
    return '';
  }

  void _startCheckout() {
    if (_isCheckoutInProgress) return;
    
    setState(() {
      _isCheckoutInProgress = true;
      _selectedShippingLocation = null;
      _selectedPaymentMethod = null;
    });

    _showShippingLocationDialog();
  }

  void _showShippingLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر موقع الشحن'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('الرياض'),
                  subtitle: Text('المنطقة الوسطى'),
                  onTap: () {
                    setState(() {
                      _selectedShippingLocation = 'الرياض';
                    });
                    Navigator.of(context).pop();
                    _showPaymentMethodDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('جدة'),
                  subtitle: Text('المنطقة الغربية'),
                  onTap: () {
                    setState(() {
                      _selectedShippingLocation = 'جدة';
                    });
                    Navigator.of(context).pop();
                    _showPaymentMethodDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('الدمام'),
                  subtitle: Text('المنطقة الشرقية'),
                  onTap: () {
                    setState(() {
                      _selectedShippingLocation = 'الدمام';
                    });
                    Navigator.of(context).pop();
                    _showPaymentMethodDialog();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                setState(() {
                  _isCheckoutInProgress = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentMethodDialog() {
    if (_selectedShippingLocation == null) {
      setState(() {
        _isCheckoutInProgress = false;
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر طريقة الدفع'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text('بطاقة ائتمان'),
                  subtitle: Text('Visa, Mastercard, etc.'),
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'بطاقة ائتمان';
                    });
                    Navigator.of(context).pop();
                    _showPaymentDetails();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_balance),
                  title: Text('تحويل بنكي'),
                  subtitle: Text('تحويل مباشر'),
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'تحويل بنكي';
                    });
                    Navigator.of(context).pop();
                    _showPaymentDetails();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('رجوع'),
              onPressed: () {
                Navigator.of(context).pop();
                _showShippingLocationDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDetails() {
    if (_selectedPaymentMethod == null) {
      setState(() {
        _isCheckoutInProgress = false;
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تفاصيل الدفع'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('موقع الشحن: $_selectedShippingLocation'),
                Text('طريقة الدفع: $_selectedPaymentMethod'),
                SizedBox(height: 16),
                Text('المبلغ الإجمالي: ${_total.toStringAsFixed(2)} ${_cartItems.isNotEmpty ? _cartItems[0].currencySymbol : ""}'),
                SizedBox(height: 16),
                Text('هل تريد المتابعة؟'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('رجوع'),
              onPressed: () {
                Navigator.of(context).pop();
                _showPaymentMethodDialog();
              },
            ),
            ElevatedButton(
              child: Text('تأكيد الدفع'),
              onPressed: () {
                Navigator.of(context).pop();
                _processPayment();
              },
            ),
          ],
        );
      },
    );
  }

  void _processPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('جاري معالجة الدفع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('يرجى الانتظار...'),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
      _showOrderConfirmation();
    });
  }

  void _showOrderConfirmation() {
    if (_selectedShippingLocation == null || _selectedPaymentMethod == null) {
      setState(() {
        _isCheckoutInProgress = false;
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تم تأكيد الطلب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              SizedBox(height: 16),
              Text('تم استلام طلبك بنجاح!'),
              SizedBox(height: 8),
              Text('موقع الشحن: $_selectedShippingLocation'),
              Text('طريقة الدفع: $_selectedPaymentMethod'),
              SizedBox(height: 8),
              Text('سيتم إرسال تفاصيل الطلب إلى بريدك الإلكتروني'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('حسناً'),
              onPressed: () {
                setState(() {
                  _isCheckoutInProgress = false;
                  _selectedShippingLocation = null;
                  _selectedPaymentMethod = null;
                });
                Navigator.of(context).pop();
                _clearCart();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cart', []);
    setState(() {
      _cartItems = [];
      _total = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('السلة'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('السلة'),
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'السلة فارغة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: item.image.isNotEmpty
                              ? Image.network(
                                  item.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported);
                                  },
                                )
                              : Icon(Icons.image_not_supported),
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.selectedOptions != null)
                                ...item.selectedOptions!.entries.map(
                                  (e) => Text('${e.key}: ${e.value}'),
                                ),
                              Text(
                                '${item.price} ${item.currencySymbol}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                    } else {
                                      _cartItems.removeAt(index);
                                    }
                                    _saveCartChanges();
                                  });
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    item.quantity++;
                                    _saveCartChanges();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
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
                            '${_total.toStringAsFixed(2)} ${_cartItems.isNotEmpty ? _cartItems[0].currencySymbol : ""}',
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
                          onPressed: _startCheckout,
                          child: Text('إتمام الشراء'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
  