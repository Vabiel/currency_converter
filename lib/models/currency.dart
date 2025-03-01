import 'package:hive/hive.dart';

part 'currency.g.dart'; // Для генерации адаптера Hive

@HiveType(typeId: 0)
class Currency {
  @HiveField(0)
  final String code; // Например, "USD", "RUB"

  @HiveField(1)
  final double rate; // Курс относительно USD

  Currency({required this.code, required this.rate});
}