import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildNavItem(BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;
    final Color activeColor = Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? Theme.of(context).colorScheme.primary;
    final Color inactiveColor = Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final Color itemColor = isActive ? activeColor : inactiveColor;

    final TextStyle? activeLabelStyle = Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle;
    final TextStyle? inactiveLabelStyle = Theme.of(context).bottomNavigationBarTheme.unselectedLabelStyle;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isActive ? activeIcon : icon, color: itemColor, size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: (isActive ? activeLabelStyle : inactiveLabelStyle)?.copyWith(
                  color: itemColor,
                  fontSize: 11,
                ) ?? TextStyle(
                  color: itemColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            height: kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkThemePrimaryBase.withOpacity(0.85),
                  AppTheme.darkThemeGradientAccent.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'الرئيسية',
                  index: 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'السلة',
                  index: 1,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.list_alt_outlined,
                  activeIcon: Icons.list_alt,
                  label: 'الطلبات',
                  index: 2,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'الحساب',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 