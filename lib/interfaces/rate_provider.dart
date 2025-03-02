import 'package:currency_converter/models/currency.dart';
import 'package:currency_converter/interfaces/rate_repository.dart';

abstract interface class IRateProvider {
  String get apiUrl;
  Duration get cacheDuration;

  Future<RateData> fetchRates();
  Future<List<Currency>> getCurrencies();
}