import 'dart:convert';
import 'package:currency_converter/interfaces/rate_provider.dart';
import 'package:currency_converter/interfaces/rate_repository.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/currency.dart';

class RateProvider implements IRateProvider {
  final _baseCurrency = {'RUB': 1.0};

  @override
  String get apiUrl => 'https://www.cbr-xml-daily.ru/daily_json.js';

  @override
  Duration get cacheDuration => Duration(hours: 1);

  @override
  Future<RateData> fetchRates() async {
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> valute = data['Valute'];

        RateData rates = {..._baseCurrency};
        valute.forEach((key, value) {
          double nominal = value['Nominal'].toDouble();
          double rate = value['Value'].toDouble() / nominal;
          rates[value['CharCode']] = rate;
        });

        await box.put('rates', rates);
        await box.put('lastUpdate', DateTime.now());
        return rates;
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      return cachedRates?.map(
            (key, value) => MapEntry(key, value.toDouble()),
          ) ??
          _baseCurrency;
    }
  }

  @override
  Future<List<Currency>> getCurrencies() async {
    final rates = await fetchRates();
    return rates.entries
        .map((entry) => Currency(code: entry.key, rate: entry.value))
        .toList();
  }
}
