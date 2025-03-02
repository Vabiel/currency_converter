part of 'converter_screen_bloc.dart';

sealed class ConverterScreenState extends Equatable {
  const ConverterScreenState();
}

final class ConverterScreenInitial extends ConverterScreenState {
  const ConverterScreenInitial();

  @override
  List<Object> get props => const [];
}

final class ConverterScreenLoadSuccess extends ConverterScreenState {
  final RateData rates;
  final RateData selectedCurrencies;
  final List<String> currencies;

  const ConverterScreenLoadSuccess({
    required this.rates,
    required this.selectedCurrencies,
    required this.currencies,
  });

  @override
  List<Object> get props => [rates, selectedCurrencies, currencies];

  ConverterScreenLoadSuccess copyWith({
    RateData? rates,
    RateData? selectedCurrencies,
    List<String>? currencies,
  }) {
    return ConverterScreenLoadSuccess(
      rates: rates ?? this.rates,
      selectedCurrencies: selectedCurrencies ?? this.selectedCurrencies,
      currencies: currencies ?? this.currencies,
    );
  }
}
