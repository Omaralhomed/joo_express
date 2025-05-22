import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joo_express/models/product.dart';

// صفحة عرض السلة
class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // تحميل المنتجات من SharedPreferences عند فتح صفحة السلة
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? cartList = prefs.getStringList('cart');
      print("_loadCart: cartList from SharedPreferences: $cartList"); // طباعة القائمة الخام

      if (cartList != null) {
        List<Product> loadedItems = [];
        for (var itemJson in cartList) {
          try {
            Map<String, dynamic> itemMap = jsonDecode(itemJson);
            print("_loadCart: Decoded itemMap: $itemMap"); // طباعة الخريطة بعد فك الترميز
            loadedItems.add(Product.fromMap(itemMap));
          } catch (e) {
            print("خطأ في فك ترميز منتج من السلة: $itemJson, الخطأ: $e");
            // يمكنك اختيار إضافة منتج خطأ أو تجاهله
            // loadedItems.add(Product(name: "خطأ بالمنتج", price: "", image: "", size: "", color: ""));
          }
        }
        setState(() {
          cartItems = loadedItems;
          print("_loadCart: cartItems after processing: ${cartItems.map((p) => p.toMap()).toList()}"); // طباعة المنتجات المحملة
        });
      } else {
        print("_loadCart: cartList is null or empty. Setting cartItems to empty list.");
        setState(() {
          cartItems = []; // تأكد من إفراغ القائمة إذا كانت فارغة في SharedPreferences
        });
      }
    } catch (e) {
      print("خطأ أثناء تحميل السلة: $e");
    }
  }

  // إزالة منتج من السلة وتحديث التخزين
  Future<void> _removeFromCart(int index) async {
    if (index < 0 || index >= cartItems.length) {
      print("_removeFromCart: Invalid index $index");
      return;
    }
    final removedItemName = cartItems[index].name;
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        cartItems.removeAt(index);
      });
      List<String> updatedList = cartItems.map((p) => jsonEncode(p.toMap())).toList();
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
      List<String> updatedList = cartItems.map((p) => jsonEncode(p.toMap())).toList();
      await prefs.setStringList('cart', updatedList);
      print("تم حفظ تغييرات السلة في SharedPreferences.");
    } catch (e) {
      print("خطأ أثناء حفظ تغييرات السلة: $e");
    }
  }

  void _incrementQuantity(int index) {
    if (index < 0 || index >= cartItems.length) return;
    setState(() {
      cartItems[index].quantity++;
    });
    _saveCartChanges();
  }

  void _decrementQuantity(int index) {
    if (index < 0 || index >= cartItems.length) return;
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
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
    for (var item in cartItems) {
      total += (item.numericValue * item.quantity);
    }
    return total;
  }

  // الحصول على رمز العملة (نفترض أن جميع المنتجات بنفس العملة)
  String _getCartCurrencySymbol() {
    if (cartItems.isEmpty) return '';
    // بما أن العملة موحدة على مستوى الموقع، ابحث عن أول منتج له رمز عملة.
    // يجب أن تشترك جميع المنتجات الأخرى في هذا الرمز أو يكون رمزها فارغًا.
    for (var item in cartItems) {
      if (item.currencySymbol.isNotEmpty) {
        return item.currencySymbol; // إرجاع أول رمز عملة غير فارغ يتم العثور عليه
      }
    }
    return ''; // إذا لم يكن لأي منتج في السلة رمز عملة
  }
  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotalPrice();
    String currencySymbol = _getCartCurrencySymbol();

    return Scaffold(
      appBar: AppBar(
        title: Text('السلة'), // Style from AppBarTheme
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined, // More relevant icon
                      size: 100,
                      color: Colors.grey[350],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'سلتك فارغة!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'أضف بعض المنتجات الرائعة لتراها هنا.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ) // عرض رسالة إذا كانت السلة بلا منتجات
          : ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card( // Theme will apply shape and elevation
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
                                  '${item.currencySymbol.isNotEmpty ? item.currencySymbol : ""} ${item.numericValue.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              SizedBox(height: 6),
                              if (item.size.isNotEmpty)
                                Text('المقاس: ${item.size}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
                              if (item.color.isNotEmpty)
                                Text('اللون: ${item.color}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                              onPressed: () => _removeFromCart(index),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _decrementQuantity(index),
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0), // زيادة مساحة اللمس
                                    child: Icon(Icons.remove_circle_outline, size: 22, color: Theme.of(context).colorScheme.secondary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                InkWell(
                                  onTap: () => _incrementQuantity(index),
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0), // زيادة مساحة اللمس
                                    child: Icon(Icons.add_circle_outline, size: 22, color: Theme.of(context).colorScheme.secondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? BottomAppBar(
              height: 102.0, // زيادة الارتفاع لاستيعاب التجاوز الحالي (78 + 24 = 102)
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // يمكن تقليل الحشوة العمودية قليلًا إذا أردت ارتفاعًا أقل للشريط
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإجمالي:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${currencySymbol.isNotEmpty ? currencySymbol + " " : ""}${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.payment_outlined, color: Colors.white, size: 20),
                      label: Text('إتمام الشراء', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary, // Amber
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // الحشوة الداخلية للزر
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خاصية إتمام الشراء غير مفعّلة بعد.')),
                        );
                      },
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }
  }
  