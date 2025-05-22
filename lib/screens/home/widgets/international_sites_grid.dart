import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class InternationalSitesGrid extends StatelessWidget {
  const InternationalSitesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sites = [
      {
        'name': 'SHEIN',
        'icon': Icons.shopping_bag_outlined,
        'description': 'أزياء عصرية بأسعار مناسبة',
        'route': '/shein',
        'backgroundColor': const Color(0xFF000000),
        'textColor': const Color(0xFFFFFFFF),
        'hoverBackgroundColor': const Color(0xFF333333),
        'hoverTextColor': const Color(0xFFFFFFFF),
      },
      {
        'name': 'AliExpress',
        'icon': Icons.shopping_cart_outlined,
        'description': 'كل ما تحتاجه في مكان واحد',
        'route': '/aliexpress',
        'backgroundColor': const Color(0xFFD31836),
        'textColor': const Color(0xFFFFFFFF),
        'hoverBackgroundColor': const Color(0xFFB31229),
        'hoverTextColor': const Color(0xFFFFFFFF),
      },
      {
        'name': 'Alibaba',
        'icon': Icons.business_outlined,
        'description': 'تجارة عالمية وفرص استثمارية',
        'route': '/alibaba',
        'backgroundColor': const Color(0xFFFF6A00),
        'textColor': const Color(0xFFFFFFFF),
        'hoverBackgroundColor': const Color(0xFFE65C00),
        'hoverTextColor': const Color(0xFFFFFFFF),
      },
      {
        'name': 'Amazon',
        'icon': Icons.local_mall_outlined,
        'description': 'تسوق عالمي موثوق',
        'route': '/amazon',
        'backgroundColor': const Color(0xFF232F3E),
        'textColor': const Color(0xFFFFFFFF),
        'hoverBackgroundColor': const Color(0xFF131921),
        'hoverTextColor': const Color(0xFFFF9900),
      },
      {
        'name': 'eBay',
        'icon': Icons.store_outlined,
        'description': 'مزادات ومنتجات فريدة',
        'route': '/ebay',
        'backgroundColor': const Color(0xFF0063D1),
        'textColor': const Color(0xFFFFFFFF),
        'hoverBackgroundColor': const Color(0xFF004C9E),
        'hoverTextColor': const Color(0xFFFFFFFF),
      },
      {
        'name': 'Noon',
        'icon': Icons.shopping_basket_outlined,
        'description': 'تسوق محلي سريع وموثوق',
        'route': '/noon',
        'backgroundColor': const Color(0xFF404553),
        'textColor': const Color(0xFFFFFFFF),
        'hoverBackgroundColor': const Color(0xFF2D3139),
        'hoverTextColor': const Color(0xFFFFB800),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3.2,
        mainAxisSpacing: 16,
      ),
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        return StatefulBuilder(
          builder: (context, setState) {
            bool isHovered = false;
            return MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isHovered 
                    ? site['hoverBackgroundColor'] as Color 
                    : site['backgroundColor'] as Color,
                  boxShadow: [
                    BoxShadow(
                      color: (isHovered 
                        ? site['hoverBackgroundColor'] as Color 
                        : site['backgroundColor'] as Color).withOpacity(0.3),
                      blurRadius: isHovered ? 12 : 8,
                      offset: isHovered 
                        ? const Offset(0, 6) 
                        : const Offset(0, 4),
                      spreadRadius: isHovered ? 1 : 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, site['route'] as String),
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            site['icon'] as IconData,
                            size: 120,
                            color: (isHovered 
                              ? site['hoverTextColor'] as Color 
                              : site['textColor'] as Color).withOpacity(0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  site['icon'] as IconData,
                                  size: 28,
                                  color: isHovered 
                                    ? site['hoverTextColor'] as Color 
                                    : site['textColor'] as Color,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      site['name'] as String,
                                      style: TextStyle(
                                        color: isHovered 
                                          ? site['hoverTextColor'] as Color 
                                          : site['textColor'] as Color,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      site['description'] as String,
                                      style: TextStyle(
                                        color: (isHovered 
                                          ? site['hoverTextColor'] as Color 
                                          : site['textColor'] as Color).withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: (isHovered 
                                  ? site['hoverTextColor'] as Color 
                                  : site['textColor'] as Color).withOpacity(0.5),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 