import 'package:flutter/material.dart';
import '../../models/product.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Product> cartItems;
  const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;

  // Shipping controllers
  final _shippingNameController = TextEditingController();
  final _shippingPhoneController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  String? _shippingCity;

  // Payment controllers
  String? _paymentMethod;
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();

  bool _isPlacingOrder = false;
  bool _orderSuccess = false;

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate shipping
      if (_shippingNameController.text.isEmpty ||
          _shippingPhoneController.text.isEmpty ||
          _shippingCity == null ||
          _shippingAddressController.text.isEmpty) {
        _showError('يرجى تعبئة جميع بيانات الشحن');
        return;
      }
    }
    if (_currentStep == 1) {
      // Validate payment
      if (_paymentMethod == null) {
        _showError('يرجى اختيار طريقة الدفع');
        return;
      }
      if (_paymentMethod == 'بطاقة ائتمان' &&
          (_cardNumberController.text.isEmpty ||
           _cardExpiryController.text.isEmpty ||
           _cardCvvController.text.isEmpty)) {
        _showError('يرجى تعبئة جميع بيانات البطاقة');
        return;
      }
      if (_paymentMethod == 'تحويل بنكي' &&
          (_bankNameController.text.isEmpty ||
           _bankAccountController.text.isEmpty)) {
        _showError('يرجى تعبئة جميع بيانات التحويل البنكي');
        return;
      }
    }
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isPlacingOrder = false;
      _orderSuccess = true;
    });
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          _buildStepCircle(0, 'الشحن'),
          _buildStepLine(),
          _buildStepCircle(1, 'الدفع'),
          _buildStepLine(),
          _buildStepCircle(2, 'مراجعة'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isCompleted
              ? Colors.green
              : isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white)
              : Text('${step + 1}', style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildShippingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _shippingNameController,
          decoration: InputDecoration(labelText: 'الاسم الكامل'),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _shippingPhoneController,
          decoration: InputDecoration(labelText: 'رقم الجوال'),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 12),
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
        SizedBox(height: 12),
        TextField(
          controller: _shippingAddressController,
          decoration: InputDecoration(labelText: 'العنوان التفصيلي'),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(height: 12),
          TextField(
            controller: _cardNumberController,
            decoration: InputDecoration(labelText: 'رقم البطاقة'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _cardExpiryController,
            decoration: InputDecoration(labelText: 'تاريخ الانتهاء (MM/YY)'),
            keyboardType: TextInputType.datetime,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _cardCvvController,
            decoration: InputDecoration(labelText: 'رمز الأمان'),
            keyboardType: TextInputType.number,
          ),
        ],
        if (_paymentMethod == 'تحويل بنكي') ...[
          SizedBox(height: 12),
          TextField(
            controller: _bankNameController,
            decoration: InputDecoration(labelText: 'اسم البنك'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _bankAccountController,
            decoration: InputDecoration(labelText: 'رقم الحساب'),
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('معلومات الشحن:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('الاسم: ${_shippingNameController.text}'),
        Text('الجوال: ${_shippingPhoneController.text}'),
        Text('المدينة: ${_shippingCity ?? ''}'),
        Text('العنوان: ${_shippingAddressController.text}'),
        SizedBox(height: 16),
        Text('معلومات الدفع:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('طريقة الدفع: ${_paymentMethod ?? ''}'),
        if (_paymentMethod == 'بطاقة ائتمان') ...[
          Text('رقم البطاقة: ${_cardNumberController.text}'),
        ],
        if (_paymentMethod == 'تحويل بنكي') ...[
          Text('اسم البنك: ${_bankNameController.text}'),
          Text('رقم الحساب: ${_bankAccountController.text}'),
        ],
        SizedBox(height: 16),
        Text('محتويات السلة:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...widget.cartItems.map((item) => Text('${item.name} × ${item.quantity}')).toList(),
        SizedBox(height: 12),
        Text('الإجمالي: ${widget.cartItems.isNotEmpty ? widget.cartItems.first.currencySymbol : ''} '
            '${widget.cartItems.fold(0.0, (sum, item) => sum + (item.numericValue * (item.quantity ?? 1))).toStringAsFixed(2)}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إتمام الشراء'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: _orderSuccess
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 16),
                  Text('تم إتمام الطلب بنجاح!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: Text('العودة للرئيسية'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProgressBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: [
                        _buildShippingStep(),
                        _buildPaymentStep(),
                        _buildReviewStep(),
                      ][_currentStep],
                    ),
                  ),
                  if (!_orderSuccess)
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _prevStep,
                              child: Text('السابق'),
                            ),
                          ),
                        if (_currentStep > 0) SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentStep == 2
                                ? (_isPlacingOrder ? null : _placeOrder)
                                : _nextStep,
                            child: _isPlacingOrder
                                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(_currentStep == 2 ? 'تأكيد الطلب' : 'التالي'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
} 