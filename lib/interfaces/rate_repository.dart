import 'package:currency_converter/interfaces/rate_provider.dart';

typedef RateData = Map<String, double>;

abstract interface class IRateRepository {
  IRateProvider get provider;

  Future<RateData> addCurrency(String code);

  Future<RateData> removeCurrency(String code);

  Future<RateData> updateAmount(String code, double amount);

  Future<RateData> getRates();

  Future<RateData> getSelectedCurrencies();

}
