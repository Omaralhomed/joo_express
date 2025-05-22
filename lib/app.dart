import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/shein/shein_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/coming_soon/coming_soon_screen.dart';
import 'screens/settings/settings_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'joo express',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.neumorphicTheme().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/shein': (context) => const SheinScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/cart': (context) => const CartScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        // المواقع العالمية
        '/aliexpress': (context) => const ComingSoonScreen(title: 'AliExpress'),
        '/alibaba': (context) => const ComingSoonScreen(title: 'Alibaba'),
        '/amazon': (context) => const ComingSoonScreen(title: 'Amazon'),
        '/ebay': (context) => const ComingSoonScreen(title: 'eBay'),
        '/noon': (context) => const ComingSoonScreen(title: 'Noon'),
      },
    );
  }
} 