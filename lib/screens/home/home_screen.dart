import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'widgets/advertising_banners.dart';
import 'widgets/international_sites_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const Center(child: Text('صفحة السلة', style: TextStyle(fontSize: 24))),
    const Center(child: Text('صفحة الطلبات', style: TextStyle(fontSize: 24))),
    const Center(child: Text('صفحة الحساب', style: TextStyle(fontSize: 24))),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: FlutterLogo(size: 30),
        ),
        title: const Text('joo express'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'خدمة العملاء',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'الإشعارات',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'الضبط',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const AdvertisingBanners(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'اطلب من المواقع العالمية',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.85),
                ),
          ),
        ),
        const SizedBox(height: 16),
        const InternationalSitesGrid(),
        const SizedBox(height: 24),
      ],
    );
  }
} 