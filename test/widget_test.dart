import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_calculator/main.dart';

void main() {
  testWidgets('BMI Calculator app loads successfully',
      (WidgetTester tester) async {
    // Open the BMI Calculator app
    await tester.pumpWidget(const BMICalculator());

    // Check that the splash screen appears
    expect(find.text('Calculate Your BMI'), findsOneWidget);

    // Remove the app before the splash timer completes
    await tester.pumpWidget(const SizedBox.shrink());

    // Complete any remaining scheduled frames
    await tester.pump();
  });
}