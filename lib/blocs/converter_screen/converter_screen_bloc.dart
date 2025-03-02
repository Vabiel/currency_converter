import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../interfaces/rate_repository.dart';

part 'converter_screen_event.dart';

part 'converter_screen_state.dart';

class ConverterScreenBloc
    extends Bloc<ConverterScreenEvent, ConverterScreenState> {
  final IRateRepository repository;

  ConverterScreenBloc(this.repository) : super(const ConverterScreenInitial()) {
    on<ConverterScreenShown>((event, emit) async {
      final rates = await repository.getRates();
      final availableCurrencies = rates.keys.toList();
      final selectedCurrencies = await repository.getSelectedCurrencies();

      emit(
        ConverterScreenLoadSuccess(
          rates: rates,
          selectedCurrencies: selectedCurrencies,
          currencies: availableCurrencies,
        ),
      );
    });

    on<ConverterScreenAddCurrencyPressed>((event, emit) async {
      final selectedCurrencies = await repository.addCurrency(
        event.currencyCode,
      );
      _emitState(emit, selectedCurrencies);
    });

    on<ConverterScreenRemoveCurrencyPressed>((event, emit) async {
      final selectedCurrencies = await repository.removeCurrency(
        event.currencyCode,
      );
      _emitState(emit, selectedCurrencies);
    });

    on<ConverterScreenAmountChanged>((event, emit) async {
      await repository.updateAmount(event.currencyCode, event.amount);
    });
  }

  void _emitState(
    Emitter<ConverterScreenState> emit,
    RateData selectedCurrencies,
  ) {
    final currentState = state;
    if (currentState is ConverterScreenLoadSuccess) {
      emit(currentState.copyWith(selectedCurrencies: selectedCurrencies));
    }
  }
}

extension ConverterScreenBlocExt on ConverterScreenBloc {
  void shown() => add(const ConverterScreenShown());

  void addCurrency(String currencyCode) =>
      add(ConverterScreenAddCurrencyPressed(currencyCode));

  void removeCurrency(String currencyCode) =>
      add(ConverterScreenRemoveCurrencyPressed(currencyCode));

  void changeAmount(String currencyCode, double amount) =>
      add(ConverterScreenAmountChanged(currencyCode, amount));
}

extension ContextExt on BuildContext {
  ConverterScreenBloc get converterScreenBloc => read<ConverterScreenBloc>();
}
