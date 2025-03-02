import 'package:currency_converter/blocs/converter_screen/converter_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_ext/list_ext.dart';

import '../interfaces/rate_repository.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  static const _zero = 0.0;
  static const _defaultRate = 1.0;

  final Map<String, TextEditingController> _controllers = {};

  RateData _rates = {};
  RateData _selectedCurrencies = {};

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _recalculateAmounts(String sourceCode) {
    final sourceAmount = _selectedCurrencies[sourceCode] ?? _zero;
    final sourceRate = _rates[sourceCode] ?? _defaultRate;

    _selectedCurrencies.forEach((targetCode, _) {
      if (targetCode != sourceCode) {
        final targetRate = _rates[targetCode] ?? _defaultRate;
        _selectedCurrencies[targetCode] =
            targetRate != _zero
                ? (sourceAmount * sourceRate) / targetRate
                : _zero;
        _controllers[targetCode]?.text = _selectedCurrencies[targetCode]!
            .toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency converter')),
      body: BlocConsumer<ConverterScreenBloc, ConverterScreenState>(
        listener: (context, state) {
          if (state is ConverterScreenLoadSuccess) {
            _rates = state.rates;
            _selectedCurrencies = Map.from(state.selectedCurrencies);

            _selectedCurrencies.forEach((code, amount) {
              if (!_controllers.containsKey(code)) {
                _controllers[code] = TextEditingController(
                  text: amount.toStringAsFixed(2),
                );
              } else {
                _controllers[code]?.text = amount.toStringAsFixed(2);
              }
            });
            _controllers.removeWhere(
              (code, _) => !_selectedCurrencies.containsKey(code),
            );
          }
        },
        builder: (context, state) {
          if (state is ConverterScreenLoadSuccess) {
            return _buildBody(context, availableCurrencies: state.currencies);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<String> availableCurrencies,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: ListView(
                children:
                    _selectedCurrencies.entries.map((entry) {
                      return _buildCurrency(
                        context,
                        currencyCode: entry.key,
                        availableCurrencies: availableCurrencies,
                      );
                    }).toList(),
              ),
            ),
          ),
          if (availableCurrencies.length != _selectedCurrencies.length)
            _buildAddButton(context, availableCurrencies: availableCurrencies),
        ],
      ),
    );
  }

  Widget _buildCurrency(
    BuildContext context, {
    required String currencyCode,
    required List<String> availableCurrencies,
  }) {
    final bloc = context.converterScreenBloc;

    return Row(
      key: ValueKey(currencyCode),
      children: [
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(),
            controller: _controllers[currencyCode],
            onChanged: (value) {
              final amount = double.tryParse(value) ?? _zero;
              _selectedCurrencies[currencyCode] = amount;
              _recalculateAmounts(currencyCode);
              bloc.changeAmount(currencyCode, amount);
            },
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: currencyCode,
          items: [
            for (final currency in availableCurrencies)
              DropdownMenuItem(value: currency, child: Text(currency)),
          ],
          onChanged: (newCode) {
            if (newCode != null && newCode != currencyCode) {
              final amount = _selectedCurrencies[currencyCode] ?? _zero;
              bloc.removeCurrency(currencyCode);
              bloc.addCurrency(newCode);
              _selectedCurrencies.remove(currencyCode);
              _selectedCurrencies[newCode] = amount;
              _controllers[newCode] = TextEditingController(
                text: amount.toStringAsFixed(2),
              );
              _controllers.remove(currencyCode);
            }
          },
        ),
        _buildRemoveButton(bloc, currencyCode),
      ],
    );
  }

  Widget _buildRemoveButton(ConverterScreenBloc bloc, String currencyCode) {
    return IconButton(
      onPressed: () {
        bloc.removeCurrency(currencyCode);
        _selectedCurrencies.remove(currencyCode);
        _controllers.remove(currencyCode);
      },
      icon: const Icon(Icons.delete),
    );
  }

  Widget _buildAddButton(
    BuildContext context, {
    required List<String> availableCurrencies,
  }) {
    final bloc = context.converterScreenBloc;

    return FloatingActionButton(
      onPressed: () {
        final newCurrency = availableCurrencies.firstWhereOrNull(
          (code) => !_selectedCurrencies.containsKey(code),
        );
        if (newCurrency != null) {
          bloc.addCurrency(newCurrency);
          _selectedCurrencies[newCurrency] = _zero;
          _controllers[newCurrency] = TextEditingController(text: '0.00');
        }
      },
      child: Icon(Icons.add),
    );
  }
}
