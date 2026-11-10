import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    emit(mode);
  }
}
