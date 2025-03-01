import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/currency.dart';
import 'providers/currency_provider.dart';
import 'screens/converter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CurrencyAdapter());
  await Hive.openBox('currencyBox'); // Открываем бокс заранее
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrencyProvider(),
      child: MaterialApp(
        home: ConverterScreen(),
      ),
    );
  }
}