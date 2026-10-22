import 'package:flutter_test/flutter_test.dart';

import 'package:scientific_calculator/calculator.dart';
import 'package:scientific_calculator/main.dart';

void main() {
  group('expression evaluator', () {
    double eval(String input, {bool degrees = true}) =>
        ExpressionEvaluator(input, degrees: degrees).evaluate();

    test('respects operator precedence', () {
      expect(eval('2+3*4'), 14);
      expect(eval('(2+3)*4'), 20);
    });

    test('supports powers and roots', () {
      expect(eval('2^10'), 1024);
      expect(eval('sqrt(9)'), 3);
      expect(eval('√(3^2+4^2)'), 5);
    });

    test('supports percentages', () {
      expect(eval('50%'), 0.5);
      expect(eval('200*10%'), 20);
    });

    test('supports trigonometry in degrees and radians', () {
      expect(eval('sin(30)'), closeTo(0.5, 1e-9));
      expect(eval('cos(60)'), closeTo(0.5, 1e-9));
      expect(eval('sin(π/2)', degrees: false), closeTo(1, 1e-9));
    });

    test('supports implicit multiplication and constants', () {
      expect(eval('2π'), closeTo(6.283185307, 1e-6));
      expect(eval('3(4+1)'), 15);
    });

    test('rejects invalid input', () {
      expect(() => eval('1/0'), throwsFormatException);
      expect(() => eval('2+'), throwsFormatException);
      expect(() => eval('sin('), throwsFormatException);
    });

    test('formats numbers', () {
      expect(formatNumber(3), '3');
      expect(formatNumber(0.5), '0.5');
      expect(formatNumber(1024), '1024');
    });
  });

  testWidgets('shows the calculator display and keys', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('Scientific Calculator'), findsOneWidget);
    expect(find.text('DEG'), findsOneWidget);
    expect(find.text('RAD'), findsOneWidget);
    expect(find.text('AC'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
  });
}
