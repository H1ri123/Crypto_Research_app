class Formatters {
  /// Format currency with comma separation and dynamic precision
  static String formatCurrency(double amount, {int? forcedDecimals}) {
    if (amount == 0) return '\$0.00';

    int decimals = forcedDecimals ?? (amount < 1.0 ? 4 : 2);
    String fixedStr = amount.abs().toStringAsFixed(decimals);
    List<String> parts = fixedStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Insert commas
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    integerPart = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');

    String sign = amount < 0 ? '-' : '';
    return '$sign\$$integerPart$decimalPart';
  }

  /// Format compact numbers (e.g. $1.25T, $84.2B, $450.5M)
  static String formatCompact(double number, {String prefix = '\$'}) {
    if (number.abs() >= 1e12) {
      return '$prefix${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number.abs() >= 1e9) {
      return '$prefix${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number.abs() >= 1e6) {
      return '$prefix${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number.abs() >= 1e3) {
      return '$prefix${(number / 1e3).toStringAsFixed(2)}K';
    }
    return '$prefix${number.toStringAsFixed(2)}';
  }

  /// Format percentage with + / - sign
  static String formatPercentage(double percent) {
    String sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  /// Format plain numbers with commas (e.g. supply)
  static String formatNumber(double number, {int decimals = 0}) {
    String fixed = number.toStringAsFixed(decimals);
    List<String> parts = fixed.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    integerPart = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');

    return '$integerPart$decimalPart';
  }
}
