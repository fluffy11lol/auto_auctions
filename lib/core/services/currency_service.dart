import 'package:dio/dio.dart';

class CurrencyService {
  final Dio _dio = Dio();
  final String _apiKey = '9d3d342fd7636112108d841f';

  Future<Map<String, double>> getLatestRates() async {
    try {
      final response = await _dio.get(
        'https://v6.exchangerate-api.com/v6/$_apiKey/latest/USD',
      );

      if (response.statusCode == 200) {
        final rates = response.data['conversion_rates'] as Map<String, dynamic>;

        final double usdToRub = rates['RUB'].toDouble();
        final double usdToEur = rates['EUR'].toDouble();
        final double eurToRub = usdToRub / usdToEur;

        return {
          'USD': usdToRub,
          'EUR': eurToRub,
        };
      } else {
        throw Exception('Failed to load rates');
      }
    } catch (e) {
      rethrow;
    }
  }
}