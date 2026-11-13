import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cubits/app_locale_cubit.dart';
import 'core/cubits/app_theme_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/cubits/ocr_language_cubit.dart';
import 'core/widgets/capture_fab/capture_fab_cubit.dart';
import 'features/cards/presentation/cubit/backup_cubit.dart';
import 'core/services/app_settings_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/cards/presentation/cubit/card_sort_cubit.dart';
import 'features/cards/presentation/cubit/saved_cards_cubit.dart';
import 'features/scan/presentation/cubit/scan_cubit.dart';
import 'l10n/app_localizations.dart';

class BusinessCardScannerApp extends StatelessWidget {
  /// Cài đặt đã lưu (giao diện, ngôn ngữ). `null` → không lưu (test).
  final AppSettingsStorage? settings;

  const BusinessCardScannerApp({super.key, this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppThemeCubit(storage: settings)),
        BlocProvider(create: (_) => AppLocaleCubit(storage: settings)),
        BlocProvider(create: (_) => OcrLanguageCubit(storage: settings)),
        BlocProvider(create: (_) => CaptureFabCubit(storage: settings)),
        BlocProvider(create: (_) => BackupCubit(storage: settings)),
        BlocProvider(create: (ctx) => ScanCubit(languageMode: () => ctx.read<OcrLanguageCubit>().state)),
        BlocProvider(create: (_) => SavedCardsCubit()..load()),
        BlocProvider(create: (_) => CardSortCubit(storage: settings)),
      ],
      child: BlocBuilder<AppThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<AppLocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context)?.appName ?? 'Scan Danh Thiếp',
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
