part of 'converter_screen_bloc.dart';

sealed class ConverterScreenEvent extends Equatable {
  const ConverterScreenEvent();
}

final class ConverterScreenShown extends ConverterScreenEvent {
  const ConverterScreenShown();

  @override
  List<Object> get props => const [];
}

final class ConverterScreenAddCurrencyPressed extends ConverterScreenEvent {
  final String currencyCode;
  const ConverterScreenAddCurrencyPressed(this.currencyCode);

  @override
  List<Object> get props => [currencyCode];
}

final class ConverterScreenRemoveCurrencyPressed extends ConverterScreenEvent {
  final String currencyCode;
  const ConverterScreenRemoveCurrencyPressed(this.currencyCode);

  @override
  List<Object> get props => [currencyCode];
}

final class ConverterScreenAmountChanged extends ConverterScreenEvent {
  final String currencyCode;
  final double amount;
  const ConverterScreenAmountChanged(this.currencyCode, this.amount);

  @override
  List<Object> get props => [currencyCode, amount];
}