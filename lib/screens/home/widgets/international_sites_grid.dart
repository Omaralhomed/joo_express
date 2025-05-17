import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../theme/app_theme.dart';

class InternationalSitesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> internationalSites = const [
    {'name': 'Shein', 'icon': Icons.shopping_bag, 'color': Color(0xFFFCE4EC)},
    {'name': 'Alibaba', 'icon': Icons.store, 'color': Color(0xFFFFE0B2)},
    {'name': 'AliExpress', 'icon': Icons.local_shipping, 'color': Color(0xFFFFCDD2)},
    {'name': 'Amazon', 'icon': Icons.add_shopping_cart, 'color': Color(0xFFFFF9C4)},
    {'name': 'eBay', 'icon': Icons.shop_two, 'color': Color(0xFFD1C4E9)},
  ];

  const InternationalSitesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: internationalSites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final site = internationalSites[index];
        final cardBorderRadius = BorderRadius.circular(12.0);

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: cardBorderRadius,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkThemeSlidesBackground.withOpacity(0.75),
                      AppTheme.darkThemeSlidesBackground.withOpacity(0.55),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    if (site['name'] == 'Shein') {
                      Navigator.pushNamed(context, '/shein');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('سيتم فتح ${site['name']} لاحقًا')),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          site['icon'],
                          size: 40,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          site['name'],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 