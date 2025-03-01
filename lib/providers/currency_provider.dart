import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/api_service.dart';

class CurrencyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> selectedCurrencies = [
  ];
  Map<String, double> rates = {'RUB': 1.0};

  CurrencyProvider() {
    _loadRates();
    _loadSelectedCurrencies(); // Загружаем сохранённые валюты
  }

  Future<void> _loadRates() async {
    try {
      final fetchedRates = await _apiService.fetchRates();
      rates = fetchedRates.isNotEmpty ? fetchedRates : {'RUB': 1.0};
      notifyListeners();
    } catch (e) {
      print('Error loading rates: $e');
      rates = {'RUB': 1.0};
      notifyListeners();
    }
  }

  Future<void> _loadSelectedCurrencies() async {
    var box = await Hive.openBox('currencyBox');
    var savedCurrencies = box.get('selectedCurrencies') as List<dynamic>?;
    if (savedCurrencies != null && savedCurrencies.isNotEmpty) {
      selectedCurrencies = savedCurrencies
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveSelectedCurrencies() async {
    var box = await Hive.openBox('currencyBox');
    await box.put('selectedCurrencies', selectedCurrencies);
  }

  void addCurrency(String code) {
    if (selectedCurrencies.length < 5) {
      selectedCurrencies.add({'code': code, 'amount': 0.0});
      _saveSelectedCurrencies(); // Сохраняем после добавления
      notifyListeners();
    }
  }

  void removeCurrency(int index) {
    if (selectedCurrencies.length > 1) {
      selectedCurrencies.removeAt(index);
      _saveSelectedCurrencies(); // Сохраняем после удаления
      notifyListeners();
    }
  }

  void updateAmount(int index, double amount) {
    selectedCurrencies[index]['amount'] = amount;
    _recalculateAmounts(index);
    _saveSelectedCurrencies(); // Сохраняем после изменения суммы
    notifyListeners();
  }

  void updateCode(int index, String newCode) {
    selectedCurrencies[index]['code'] = newCode;
    _recalculateAmounts(index);
    _saveSelectedCurrencies(); // Сохраняем после смены валюты
    notifyListeners();
  }

  void _recalculateAmounts(int sourceIndex) {
    final sourceAmount = selectedCurrencies[sourceIndex]['amount'] as double;
    final sourceCode = selectedCurrencies[sourceIndex]['code'] as String;
    final sourceRate = rates[sourceCode] ?? 1.0;

    for (int i = 0; i < selectedCurrencies.length; i++) {
      if (i != sourceIndex) {
        final targetCode = selectedCurrencies[i]['code'] as String;
        final targetRate = rates[targetCode] ?? 1.0;
        selectedCurrencies[i]['amount'] =
        targetRate != 0 ? (sourceAmount * sourceRate) / targetRate : 0.0;
      }
    }
  }

  List<String> getAvailableCodes() => rates.keys.toList();
}