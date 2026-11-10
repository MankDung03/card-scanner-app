import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLocaleCubit extends Cubit<Locale?> {
  // null means use device system locale
  AppLocaleCubit() : super(null);

  void setLocale(Locale? locale) {
    emit(locale);
  }
}
