import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'dart:convert';
import '../../models/product.dart';

class SheinScreen extends StatefulWidget {
  const SheinScreen({super.key});

  @override
  State<SheinScreen> createState() => _SheinScreenState();
}

class _SheinScreenState extends State<SheinScreen> {
  late InAppWebViewController webViewController;
  bool _canGoBack = false;
  bool _canGoForward = false;
  int _cartItemCount = 0;
  bool _isProductPage = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];
    if (mounted) {
      setState(() {
        _cartItemCount = cartList.length;
      });
    }
  }

  Future<void> _extractAndAddToCart() async {
    try {
      // تنفيذ JavaScript لاستخراج بيانات المنتج
      String? result = await webViewController.evaluateJavascript(source: '''
        function extractProductData() {
          try {
            // استخراج اسم المنتج
            const nameElement = document.querySelector('.product-intro__head-name');
            const name = nameElement ? nameElement.textContent.trim() : '';
            
            // استخراج السعر
            const priceElement = document.querySelector('.from span.normal-price-ctn__sale-price');
            const price = priceElement ? priceElement.textContent.trim() : '';
            
            // استخراج الصورة
            const imageElement = document.querySelector('.product-intro__head-gallery img');
            const image = imageElement ? imageElement.src : '';
            
            // استخراج المقاس المحدد
            const sizeElement = document.querySelector('.product-intro__size-radio-inner--selected');
            const size = sizeElement ? sizeElement.textContent.trim() : '';
            
            // استخراج اللون المحدد
            const colorElement = document.querySelector('.product-intro__color-radio--selected img');
            const color = colorElement ? colorElement.alt : '';

            return JSON.stringify({
              name: name,
              price: price,
              image: image,
              size: size,
              color: color,
              currencySymbol: 'SAR'
            });
          } catch (error) {
            return null;
          }
        }
        extractProductData();
      ''');

      if (result != 'null' && result != null) {
        Map<String, dynamic> productData = json.decode(result);
        
        // إنشاء كائن Product جديد
        Product product = Product(
          name: productData['name'] ?? 'اسم غير متوفر',
          price: productData['price'] ?? '0',
          image: productData['image'] ?? '',
          size: productData['size'] ?? '',
          color: productData['color'] ?? '',
          currencySymbol: productData['currencySymbol'] ?? 'SAR',
        );

        // حفظ المنتج في السلة
        final prefs = await SharedPreferences.getInstance();
        List<String> cartList = prefs.getStringList('cart') ?? [];
        cartList.add(json.encode(product.toMap()));
        await prefs.setStringList('cart', cartList);

        // تحديث عدد العناصر في السلة
        setState(() {
          _cartItemCount = cartList.length;
        });

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إضافة المنتج إلى السلة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('لم يتم العثور على بيانات المنتج');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء إضافة المنتج إلى السلة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSheinCart() {
    webViewController.loadUrl(
      urlRequest: URLRequest(url: WebUri('https://ar.shein.com/cart')),
    );
  }

  Future<void> _shareCurrentPage() async {
    WebUri? webUrl = await webViewController.getUrl();
    if (webUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مشاركة: ${webUrl.toString()}')),
      );
    }
  }

  void _showSearchByLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String link = '';
        return AlertDialog(
          title: const Text('البحث برابط المنتج'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'أدخل رابط المنتج هنا',
            ),
            onChanged: (value) {
              link = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('بحث'),
              onPressed: () {
                if (link.isNotEmpty) {
                  webViewController.loadUrl(
                    urlRequest: URLRequest(url: WebUri(link)),
                  );
                }
                Navigator.of(context).pop();
              },
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
        title: const Text('متصفح SHEIN'),
        actions: [
          if (_isProductPage)
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('إضافة للسلة'),
              onPressed: _extractAndAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'بحث بالرابط',
            onPressed: () => _showSearchByLinkDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة الصفحة',
            onPressed: _shareCurrentPage,
          ),
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            badgeContent: Text(
              _cartItemCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: _cartItemCount > 0,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'سلة التسوق',
              onPressed: _navigateToSheinCart,
            ),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri('https://ar.shein.com')),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          setState(() {
            _canGoBack = false;
            _canGoForward = false;
          });
        },
        onLoadStop: (controller, url) async {
          bool canGoBack = await controller.canGoBack();
          bool canGoForward = await controller.canGoForward();
          
          // التحقق مما إذا كانت الصفحة الحالية هي صفحة منتج
          String currentUrl = url?.toString() ?? '';
          bool isProductPage = currentUrl.contains('/pdsearch/') || 
                             currentUrl.contains('/product-') ||
                             currentUrl.contains('/goods-');

          if (mounted) {
            setState(() {
              _canGoBack = canGoBack;
              _canGoForward = canGoForward;
              _isProductPage = isProductPage;
            });
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _canGoBack ? () => webViewController.goBack() : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _canGoForward ? () => webViewController.goForward() : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => webViewController.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => webViewController.loadUrl(
                urlRequest: URLRequest(url: WebUri('https://ar.shein.com')),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'سلة التسوق',
              onPressed: _navigateToSheinCart,
            ),
          ],
        ),
      ),
    );
  }
}
