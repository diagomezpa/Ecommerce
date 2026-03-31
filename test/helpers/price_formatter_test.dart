import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/helpers/price_formatter.dart';

void main() {
  group('PriceFormatter', () {
    group('format', () {
      test('should format whole numbers correctly', () {
        final result = PriceFormatter.format(10.0);
        expect(result, equals('\$10.00'));
      });

      test('should format decimal numbers correctly', () {
        final result = PriceFormatter.format(29.99);
        expect(result, equals('\$29.99'));
      });

      test('should format large numbers correctly', () {
        final result = PriceFormatter.format(1234.56);
        expect(result, equals('\$1234.56'));
      });

      test('should format zero correctly', () {
        final result = PriceFormatter.format(0.0);
        expect(result, equals('\$0.00'));
      });

      test('should format numbers with many decimal places', () {
        final result = PriceFormatter.format(19.999);
        expect(result, equals('\$20.00'));
      });

      test('should format very small numbers', () {
        final result = PriceFormatter.format(0.01);
        expect(result, equals('\$0.01'));
      });

      test('should round properly for edge cases', () {
        expect(PriceFormatter.format(9.994), equals('\$9.99'));
        expect(PriceFormatter.format(9.995), equals('\$9.99')); // Dart uses banker's rounding
        expect(PriceFormatter.format(9.996), equals('\$10.00'));
      });
    });

    group('formatWithDiscount', () {
      test('should show only original price when no discount', () {
        final result = PriceFormatter.formatWithDiscount(29.99, null);
        expect(result, equals('\$29.99'));
      });

      test('should show only original price when discounted price equals original', () {
        final result = PriceFormatter.formatWithDiscount(29.99, 29.99);
        expect(result, equals('\$29.99'));
      });

      test('should show only original price when discounted price is higher', () {
        final result = PriceFormatter.formatWithDiscount(29.99, 35.00);
        expect(result, equals('\$29.99'));
      });

      test('should show discount format when discounted price is lower', () {
        final result = PriceFormatter.formatWithDiscount(29.99, 19.99);
        expect(result, equals('\$19.99 (was \$29.99)'));
      });

      test('should handle zero original price', () {
        final result = PriceFormatter.formatWithDiscount(0.0, null);
        expect(result, equals('\$0.00'));
      });

      test('should handle zero discount price', () {
        final result = PriceFormatter.formatWithDiscount(10.0, 0.0);
        expect(result, equals('\$0.00 (was \$10.00)'));
      });

      test('should handle very small discounts', () {
        final result = PriceFormatter.formatWithDiscount(10.00, 9.99);
        expect(result, equals('\$9.99 (was \$10.00)'));
      });

      test('should handle large price differences', () {
        final result = PriceFormatter.formatWithDiscount(1000.00, 100.00);
        expect(result, equals('\$100.00 (was \$1000.00)'));
      });
    });

    group('formatRange', () {
      test('should show single price when min equals max', () {
        final result = PriceFormatter.formatRange(29.99, 29.99);
        expect(result, equals('\$29.99'));
      });

      test('should show range when min is less than max', () {
        final result = PriceFormatter.formatRange(15.99, 49.99);
        expect(result, equals('\$15.99 - \$49.99'));
      });

      test('should handle zero values in range', () {
        final result = PriceFormatter.formatRange(0.0, 10.0);
        expect(result, equals('\$0.00 - \$10.00'));
      });

      test('should handle both values as zero', () {
        final result = PriceFormatter.formatRange(0.0, 0.0);
        expect(result, equals('\$0.00'));
      });

      test('should handle large ranges', () {
        final result = PriceFormatter.formatRange(9.99, 999.99);
        expect(result, equals('\$9.99 - \$999.99'));
      });

      test('should handle very small differences', () {
        final result = PriceFormatter.formatRange(10.00, 10.01);
        expect(result, equals('\$10.00 - \$10.01'));
      });

      test('should handle decimal precision correctly', () {
        final result = PriceFormatter.formatRange(19.999, 20.001);
        expect(result, equals('\$20.00 - \$20.00'));
      });
    });

    group('isValidPrice', () {
      test('should return false for null price', () {
        final result = PriceFormatter.isValidPrice(null);
        expect(result, equals(false));
      });

      test('should return false for negative price', () {
        expect(PriceFormatter.isValidPrice(-1.0), equals(false));
        expect(PriceFormatter.isValidPrice(-0.01), equals(false));
        expect(PriceFormatter.isValidPrice(-999.99), equals(false));
      });

      test('should return true for zero price', () {
        final result = PriceFormatter.isValidPrice(0.0);
        expect(result, equals(true));
      });

      test('should return true for positive prices', () {
        expect(PriceFormatter.isValidPrice(0.01), equals(true));
        expect(PriceFormatter.isValidPrice(1.0), equals(true));
        expect(PriceFormatter.isValidPrice(29.99), equals(true));
        expect(PriceFormatter.isValidPrice(999.99), equals(true));
      });

      test('should return true for very small positive prices', () {
        final result = PriceFormatter.isValidPrice(0.001);
        expect(result, equals(true));
      });

      test('should return true for very large prices', () {
        final result = PriceFormatter.isValidPrice(999999.99);
        expect(result, equals(true));
      });
    });
  });
}