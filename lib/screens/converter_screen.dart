import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CurrencyProvider>(context, listen: false);
    controllers =
        provider.selectedCurrencies
            .map(
              (currency) => TextEditingController(
                text: currency['amount'].toStringAsFixed(2),
              ),
            )
            .toList();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Конвертер валют')),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, child) {
          if (provider.rates.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          // Синхронизируем количество контроллеров с валютами
          while (controllers.length < provider.selectedCurrencies.length) {
            controllers.add(
              TextEditingController(
                text: provider.selectedCurrencies[controllers.length]['amount']
                    .toStringAsFixed(2),
              ),
            );
          }
          while (controllers.length > provider.selectedCurrencies.length) {
            controllers.removeLast().dispose();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.selectedCurrencies.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'Сумма'),
                              controller: controllers[index],
                              onChanged: (value) {
                                provider.updateAmount(
                                  index,
                                  double.tryParse(value) ?? 0.0,
                                );
                                // Обновляем остальные контроллеры
                                for (
                                  int i = 0;
                                  i < provider.selectedCurrencies.length;
                                  i++
                                ) {
                                  if (i != index) {
                                    controllers[i].text = provider
                                        .selectedCurrencies[i]['amount']
                                        .toStringAsFixed(2);
                                  }
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: provider.selectedCurrencies[index]['code'],
                            items:
                                provider
                                    .getAvailableCodes()
                                    .map(
                                      (code) => DropdownMenuItem(
                                        value: code,
                                        child: Text(code),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (newCode) {
                              if (newCode != null) {
                                provider.updateCode(index, newCode);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => provider.removeCurrency(index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (provider.selectedCurrencies.length < 5)
                  ElevatedButton(
                    onPressed: () {
                      provider.addCurrency(provider.getAvailableCodes()[0]);
                    },
                    child: Text('+ Добавить валюту'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
