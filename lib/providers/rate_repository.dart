import 'package:currency_converter/providers/rate_provider.dart';
import 'package:currency_converter/interfaces/rate_repository.dart';
import 'package:hive/hive.dart';

class RateRepository implements IRateRepository {
  final _baseCurrency = {'RUB': 1.0};

  @override
  final RateProvider provider = RateProvider();
  final Future<Box> _box;

  late RateData _selectedCurrencies = _baseCurrency;
  late RateData _rates = _baseCurrency;

  RateRepository() : _box = Hive.openBox('currencyBox');

  @override
  Future<RateData> addCurrency(String code) async {
    if (!_selectedCurrencies.containsKey(code)) {
      _selectedCurrencies[code] = 0.0;
      await _saveSelectedCurrencies();
    }
    return Map.from(_selectedCurrencies);
  }

  @override
  Future<RateData> removeCurrency(String code) async {
    if (_selectedCurrencies.isNotEmpty &&
        _selectedCurrencies.containsKey(code)) {
      _selectedCurrencies.remove(code);
      await _saveSelectedCurrencies();
    }
    return Map.from(_selectedCurrencies);
  }

  @override
  Future<RateData> updateAmount(String code, double amount) async {
    if (_selectedCurrencies.containsKey(code)) {
      _selectedCurrencies[code] = amount;
      await _saveSelectedCurrencies();
    }
    return Map.from(_selectedCurrencies);
  }

  @override
  Future<RateData> getRates() async {
    try {
      final fetchedRates = await provider.fetchRates();
      _rates = fetchedRates.isNotEmpty ? fetchedRates : _baseCurrency;
    } catch (e) {
      _rates = _baseCurrency;
    }
    return Map.from(_rates);
  }

  @override
  Future<RateData> getSelectedCurrencies() async {
    var box = await Hive.openBox('currencyBox');
    var savedCurrencies =
        box.get('selectedCurrencies') as Map<dynamic, dynamic>?;
    if (savedCurrencies != null && savedCurrencies.isNotEmpty) {
      _selectedCurrencies = savedCurrencies.map(
        (key, value) => MapEntry(key.toString(), value.toDouble()),
      );
    } else if (_selectedCurrencies.isEmpty) {
      _selectedCurrencies = _baseCurrency;
    }
    return Map.from(_selectedCurrencies);
  }

  Future<void> _saveSelectedCurrencies() async {
    final box = await _box;
    await box.put('selectedCurrencies', _selectedCurrencies);
  }
}
