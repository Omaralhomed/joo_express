import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildMenuSection(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/favorites');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/cart');
                break;
            }
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NeumorphicConstants.gradientStart,
                  NeumorphicConstants.gradientEnd,
                ],
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل الدخول للوصول إلى جميع المميزات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'طلباتي',
        'subtitle': 'تتبع طلباتك وسجل المشتريات',
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'عناويني',
        'subtitle': 'إدارة عناوين التوصيل',
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'طرق الدفع',
        'subtitle': 'إدارة بطاقات الدفع والمحفظة',
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'الإعدادات',
        'subtitle': 'تخصيص التطبيق وإعدادات الحساب',
      },
      {
        'icon': Icons.help_outline,
        'title': 'المساعدة',
        'subtitle': 'الأسئلة الشائعة والدعم',
      },
    ];

    return Column(
      children: menuItems.map((item) => _buildMenuItem(item)).toList(),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NeumorphicConstants.gradientStart.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item['icon'] as IconData,
            color: NeumorphicConstants.gradientStart,
          ),
        ),
        title: Text(
          item['title'] as String,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          item['subtitle'] as String,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
} 