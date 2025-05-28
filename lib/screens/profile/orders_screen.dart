import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatus = 'الكل';

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '12345',
      'status': 'قيد الشحن',
      'date': '15 مارس 2024',
      'items': 3,
      'total': 150.0,
      'products': [
        {'name': 'منتج 1', 'price': 50.0, 'quantity': 1},
        {'name': 'منتج 2', 'price': 75.0, 'quantity': 1},
        {'name': 'منتج 3', 'price': 25.0, 'quantity': 1},
      ],
      'shippingAddress': 'شارع الملك فهد، حي النزهة، الرياض',
      'paymentMethod': 'بطاقة فيزا',
    },
    {
      'id': '12346',
      'status': 'قيد المعالجة',
      'date': '14 مارس 2024',
      'items': 2,
      'total': 200.0,
      'products': [
        {'name': 'منتج 4', 'price': 150.0, 'quantity': 1},
        {'name': 'منتج 5', 'price': 50.0, 'quantity': 1},
      ],
      'shippingAddress': 'شارع العليا، حي السفارات، الرياض',
      'paymentMethod': 'محفظة إلكترونية',
    },
    {
      'id': '12347',
      'status': 'مكتملة',
      'date': '10 مارس 2024',
      'items': 1,
      'total': 100.0,
      'products': [
        {'name': 'منتج 6', 'price': 100.0, 'quantity': 1},
      ],
      'shippingAddress': 'شارع التحلية، حي الروضة، جدة',
      'paymentMethod': 'بطاقة ماستركارد',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedStatus == 'الكل') return _orders;
    return _orders.where((order) => order['status'] == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('طلباتي'),
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
          _buildOrderStatusTabs(),
          const SizedBox(height: 20),
          _filteredOrders.isEmpty
              ? _buildEmptyState()
              : _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildOrderStatusTabs() {
    final List<String> statuses = ['الكل', 'قيد المعالجة', 'قيد الشحن', 'مكتملة'];
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: statuses.map((status) => _buildStatusTab(status)).toList(),
      ),
    );
  }

  Widget _buildStatusTab(String title) {
    final bool isSelected = _selectedStatus == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = title),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? NeumorphicConstants.gradientStart : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
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
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتصفح المتجر وإضافة منتجات إلى سلة المشتريات',
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

  Widget _buildOrdersList() {
    return Column(
      children: _filteredOrders.map((order) => _buildOrderCard(order)).toList(),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order['id']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      color: _getStatusColor(order['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.shopping_bag_outlined, size: 40),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order['items']} منتجات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تم الطلب في ${order['date']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order['total']} ريال',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicConstants.gradientStart,
                        ),
                      ),
                    ],
                  ),
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
                TextButton(
                  onPressed: () => _showOrderDetails(order),
                  child: const Text('عرض التفاصيل'),
                ),
                ElevatedButton(
                  onPressed: () => _trackOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeumorphicConstants.gradientStart,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('تتبع الطلب'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'قيد المعالجة':
        return Colors.orange;
      case 'قيد الشحن':
        return Colors.blue;
      case 'مكتملة':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'تفاصيل الطلب #${order['id']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailItem('الحالة', order['status']),
                _buildDetailItem('تاريخ الطلب', order['date']),
                _buildDetailItem('عنوان التوصيل', order['shippingAddress']),
                _buildDetailItem('طريقة الدفع', order['paymentMethod']),
                const SizedBox(height: 20),
                const Text(
                  'المنتجات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...order['products'].map<Widget>((product) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${product['name']} (${product['quantity']})',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${product['price']} ريال',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${order['total']} ريال',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicConstants.gradientStart,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _trackOrder(Map<String, dynamic> order) {
    // TODO: Implement order tracking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة خاصية تتبع الطلب قريباً'),
      ),
    );
  }
} 