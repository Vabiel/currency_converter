import 'package:hive/hive.dart';

part 'currency.g.dart';

@HiveType(typeId: 0)
class Currency {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final double rate;

  Currency({required this.code, required this.rate});
}