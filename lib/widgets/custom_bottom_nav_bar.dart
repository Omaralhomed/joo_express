import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        height: 65 + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _buildNavItem(
              icon: Icons.favorite_border_rounded,
              selectedIcon: Icons.favorite_rounded,
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _buildNavItem(
              icon: Icons.shopping_cart_outlined,
              selectedIcon: Icons.shopping_cart_rounded,
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? NeumorphicConstants.gradientStart.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(
            color: NeumorphicConstants.gradientStart.withOpacity(0.2),
            width: 1,
          ) : null,
        ),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? NeumorphicConstants.gradientStart : const Color(0xFF2D2D2D),
          size: 26,
        ),
      ),
    );
  }
} 