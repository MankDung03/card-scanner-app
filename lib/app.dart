import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cubits/app_locale_cubit.dart';
import 'core/cubits/app_theme_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'features/scan/presentation/cubit/scan_cubit.dart';
import 'l10n/app_localizations.dart';

class BusinessCardScannerApp extends StatelessWidget {
  const BusinessCardScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppThemeCubit()),
        BlocProvider(create: (_) => AppLocaleCubit()),
        BlocProvider(create: (_) => ScanCubit()),
        BlocProvider(create: (_) => SavedCardsCubit()..load()),
      ],
      child: BlocBuilder<AppThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<AppLocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'Scan Danh Thiếp',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                routerConfig: AppRouter.router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}
