import 'package:dio/dio.dart';

class CurrencyService {
  final Dio _dio = Dio();
  final String _apiUrl = "https://api.exchangerate-api.com/v4/latest/USD";

  Future<double> convertCurrency(String from, String to, double amount) async {
    final response = await _dio.get(_apiUrl);
    final rates = response.data['rates'];

    if (!rates.containsKey(from) || !rates.containsKey(to)) {
      throw Exception("Invalid currency code");
    }

    final fromRate = rates[from];
    final toRate = rates[to];

    return (amount / fromRate) * toRate;
  }
}
