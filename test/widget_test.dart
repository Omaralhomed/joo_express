import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:joo_express/app.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // فقط تحقق أن MyApp موجودة
    expect(find.byType(MyApp), findsOneWidget);
  });
}
