import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../theme/app_theme.dart';

class AdvertisingBanners extends StatelessWidget {
  const AdvertisingBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> banners = [
      {'title': 'عروض حصرية!', 'subtitle': 'تسوق الآن واستمتع بخصومات كبيرة', 'color': Colors.teal.shade100},
      {'title': 'وصل حديثًا', 'subtitle': 'أحدث المنتجات العالمية بين يديك', 'color': Colors.amber.shade100},
      {'title': 'شحن سريع', 'subtitle': 'طلباتك تصلك في أسرع وقت', 'color': Colors.lightBlue.shade100},
    ];

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          final cardBorderRadius = BorderRadius.circular(12.0);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        AppTheme.darkThemeSlidesBackground.withOpacity(0.85),
                        AppTheme.darkThemeSlidesBackground.withOpacity(0.65),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner['title'],
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.95),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner['subtitle'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 