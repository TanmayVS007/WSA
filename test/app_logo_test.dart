import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_band/core/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo renders default, circle, and badge variants without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppLogo(size: 64),
              AppLogo.circle(size: 48),
              AppLogo.badge(size: 32),
            ],
          ),
        ),
      ),
    );

    // Verify all 3 instances of AppLogo are in the widget tree
    expect(find.byType(AppLogo), findsNWidgets(3));
  });
}
