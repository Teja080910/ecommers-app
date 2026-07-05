class AppConstants {
  static const String baseUrl = "https://ecommers-app-a6b8.onrender.com/Backend/app/api.php";
  static const String imageUrl = "https://ecommers-app-a6b8.onrender.com/Backend/app/";

  /// Formats any numeric/price value into a consistent
  /// "₹12,499" style string (Indian digit grouping, no decimals).
  static String formatPrice(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? "") ?? 0;
    final isNegative = amount < 0;
    final rounded = amount.abs().round();
    final digits = rounded.toString();

    String result;

    if (digits.length <= 3) {
      result = digits;
    } else {
      final lastThree = digits.substring(digits.length - 3);
      final rest = digits.substring(0, digits.length - 3);
      final buffer = StringBuffer();

      for (int i = 0; i < rest.length; i++) {
        final posFromEnd = rest.length - i;
        buffer.write(rest[i]);

        if (posFromEnd > 1 && posFromEnd % 2 == 1) {
          buffer.write(',');
        }
      }

      result = "${buffer.toString()},$lastThree";
    }

    return "${isNegative ? '-' : ''}₹$result";
  }
}