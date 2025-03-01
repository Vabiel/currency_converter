import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/currency.dart';

class ApiService {
  static const String apiUrl = 'https://www.cbr-xml-daily.ru/daily_json.js';
  static const Duration cacheDuration = Duration(hours: 1);

  Future<Map<String, double>> fetchRates() async {
    var box = await Hive.openBox('currencyBox');
    var lastUpdate = box.get('lastUpdate') as DateTime?;
    var cachedRates = box.get('rates') as Map?;

    if (cachedRates != null &&
        lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < cacheDuration) {
      return cachedRates.map((key, value) => MapEntry(key, value.toDouble()));
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('API Status: ${response.statusCode}');
      print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> valute = data['Valute'];

        // Создаём Map с курсами относительно RUB
        Map<String, double> rates = {'RUB': 1.0}; // Добавляем RUB как базовую валюту
        valute.forEach((key, value) {
          double nominal = value['Nominal'].toDouble();
          double rate = value['Value'].toDouble() / nominal; // Нормализуем курс
          rates[value['CharCode']] = rate;
        });

        await box.put('rates', rates);
        await box.put('lastUpdate', DateTime.now());
        return rates;
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rates: $e');
      return cachedRates?.map((key, value) => MapEntry(key, value.toDouble())) ??
          {'RUB': 1.0}; // Дефолтное значение с RUB
    }
  }

  Future<List<Currency>> getCurrencies() async {
    final rates = await fetchRates();
    return rates.entries
        .map((entry) => Currency(code: entry.key, rate: entry.value))
        .toList();
  }
}