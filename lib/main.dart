import 'package:currency_converter/blocs/converter_screen/converter_screen_bloc.dart';
import 'package:currency_converter/providers/rate_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'interfaces/rate_repository.dart';
import 'models/currency.dart';
import 'screens/converter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CurrencyAdapter());
  await Hive.openBox('currencyBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RepositoryProvider<IRateRepository>(
        create: (context) => RateRepository(),
        child: BlocProvider(
          create: (context) => ConverterScreenBloc(context.read())..shown(),
          child: ConverterScreen(),
        ),
      ),
    );
  }
}
