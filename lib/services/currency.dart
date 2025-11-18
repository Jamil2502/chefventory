import 'package:intl/intl.dart';

class CurrencyService {
  CurrencyService._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  // Simple configurable USD->INR conversion. Adjust as needed or fetch from API.
  static double usdToInrRate = 83.0;

  static String formatInr(num amount) {
    return _inrFormat.format(amount);
  }

  static String formatUsdAsInr(num usdAmount) {
    final inr = usdAmount * usdToInrRate;
    return formatInr(inr);
  }
}




