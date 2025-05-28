import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': '1',
      'type': 'بطاقة فيزا',
      'number': '**** **** **** 1234',
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'isDefault': true,
      'expiryDate': '12/25',
      'cardholderName': 'أحمد محمد',
    },
    {
      'id': '2',
      'type': 'بطاقة ماستركارد',
      'number': '**** **** **** 5678',
      'icon': Icons.credit_card,
      'color': Colors.orange,
      'isDefault': false,
      'expiryDate': '09/24',
      'cardholderName': 'أحمد محمد',
    },
    {
      'id': '3',
      'type': 'محفظة إلكترونية',
      'number': 'محفظة جوال',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'isDefault': false,
      'balance': '500 ريال',
    },
  ];

  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddPaymentButton(context),
          const SizedBox(height: 20),
          _paymentMethods.isEmpty ? _buildEmptyState() : _buildPaymentMethodsList(),
        ],
      ),
    );
  }

  Widget _buildAddPaymentButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAddPaymentDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('إضافة طريقة دفع جديدة'),
      style: ElevatedButton.styleFrom(
        backgroundColor: NeumorphicConstants.gradientStart,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طرق دفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة طريقة دفع لتسهيل عملية الشراء',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: _paymentMethods.map((method) => _buildPaymentMethodCard(method)).toList(),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: method['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    method['icon'],
                    color: method['color'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            method['type'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (method['isDefault']) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'افتراضي',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method['number'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (method['type'] != 'محفظة إلكترونية') ...[
                        const SizedBox(height: 4),
                        Text(
                          'تنتهي في ${method['expiryDate']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (method['type'] == 'محفظة إلكترونية') ...[
                        const SizedBox(height: 4),
                        Text(
                          method['balance'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: method['isDefault'],
                  onChanged: (value) => _setDefaultPaymentMethod(method),
                  activeColor: NeumorphicConstants.gradientStart,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditPaymentDialog(context, method),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('تعديل'),
                ),
                TextButton.icon(
                  onPressed: () => _deletePaymentMethod(method),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('حذف'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    _cardholderNameController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة طريقة دفع جديدة'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'رقم البطاقة',
                    hintText: '1234 5678 9012 3456',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم البطاقة';
                    }
                    if (!RegExp(r'^\d{16}$').hasMatch(value.replaceAll(' ', ''))) {
                      return 'الرجاء إدخال رقم بطاقة صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الانتهاء',
                          hintText: 'MM/YY',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال تاريخ الانتهاء';
                          }
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'الرجاء إدخال تاريخ صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال CVV';
                          }
                          if (!RegExp(r'^\d{3}$').hasMatch(value)) {
                            return 'الرجاء إدخال CVV صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cardholderNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم حامل البطاقة',
                    hintText: 'كما يظهر على البطاقة',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم حامل البطاقة';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _paymentMethods.add({
                    'id': DateTime.now().toString(),
                    'type': 'بطاقة فيزا',
                    'number': '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}',
                    'icon': Icons.credit_card,
                    'color': Colors.blue,
                    'isDefault': _paymentMethods.isEmpty,
                    'expiryDate': _expiryDateController.text,
                    'cardholderName': _cardholderNameController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeumorphicConstants.gradientStart,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, Map<String, dynamic> method) {
    if (method['type'] == 'محفظة إلكترونية') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن تعديل المحفظة الإلكترونية'),
        ),
      );
      return;
    }

    _cardNumberController.text = method['number'].replaceAll('*', '').trim();
    _expiryDateController.text = method['expiryDate'];
    _cardholderNameController.text = method['cardholderName'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل طريقة الدفع'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'رقم البطاقة',
                    hintText: '1234 5678 9012 3456',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم البطاقة';
                    }
                    if (!RegExp(r'^\d{16}$').hasMatch(value.replaceAll(' ', ''))) {
                      return 'الرجاء إدخال رقم بطاقة صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _expiryDateController,
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الانتهاء',
                    hintText: 'MM/YY',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال تاريخ الانتهاء';
                    }
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                      return 'الرجاء إدخال تاريخ صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cardholderNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم حامل البطاقة',
                    hintText: 'كما يظهر على البطاقة',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم حامل البطاقة';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  final index = _paymentMethods.indexWhere((m) => m['id'] == method['id']);
                  if (index != -1) {
                    _paymentMethods[index] = {
                      ...method,
                      'number': '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}',
                      'expiryDate': _expiryDateController.text,
                      'cardholderName': _cardholderNameController.text,
                    };
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeumorphicConstants.gradientStart,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _setDefaultPaymentMethod(Map<String, dynamic> method) {
    setState(() {
      for (var m in _paymentMethods) {
        m['isDefault'] = m['id'] == method['id'];
      }
    });
  }

  void _deletePaymentMethod(Map<String, dynamic> method) {
    if (method['isDefault']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن حذف طريقة الدفع الافتراضية'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف طريقة الدفع'),
        content: const Text('هل أنت متأكد من حذف طريقة الدفع هذه؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((m) => m['id'] == method['id']);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
} 