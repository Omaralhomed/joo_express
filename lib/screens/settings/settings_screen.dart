import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: NeumorphicConstants.gradientStart,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('تخصيص التطبيق'),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: 'اللغة',
              subtitle: 'العربية',
            ),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              subtitle: 'تخصيص إعدادات الإشعارات',
            ),
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'المظهر',
              subtitle: 'فاتح',
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('الحساب والأمان'),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'كلمة المرور',
              subtitle: 'تغيير كلمة المرور',
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'الخصوصية',
              subtitle: 'إعدادات الخصوصية والأمان',
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('عن التطبيق'),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'معلومات التطبيق',
              subtitle: 'الإصدار 1.0.0',
            ),
            _buildSettingItem(
              icon: Icons.policy_outlined,
              title: 'سياسة الخصوصية',
              subtitle: 'قراءة سياسة الخصوصية',
            ),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'شروط الاستخدام',
              subtitle: 'قراءة شروط الاستخدام',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
            icon,
            color: NeumorphicConstants.gradientStart,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
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