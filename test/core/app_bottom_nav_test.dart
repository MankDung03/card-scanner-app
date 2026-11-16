import 'package:app_scanner_card/core/constants/app_colors.dart';
import 'package:app_scanner_card/core/theme/app_theme.dart';
import 'package:app_scanner_card/core/widgets/app_shell/app_bottom_nav.dart';
import 'package:app_scanner_card/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Nhãn tab chỉ tô màu navy khi tab đó đang được chọn — kể cả nhãn "Danh thiếp" dưới nút tròn giữa.
void main() {
  Future<Map<String, Color?>> labelColors(WidgetTester tester, int selected) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(bottomNavigationBar: AppBottomNav(selectedIndex: selected, onTap: (_) {})),
    ));
    Color? colorOf(String label) => tester.widget<Text>(find.text(label)).style?.color;
    return {
      'home': colorOf('Trang chủ'),
      'cards': colorOf('Danh thiếp'),
      'settings': colorOf('Cài đặt'),
    };
  }

  testWidgets('chỉ tab đang chọn có màu navy', (tester) async {
    for (final (index, key) in [(0, 'home'), (1, 'cards'), (2, 'settings'), (-1, null)]) {
      final colors = await labelColors(tester, index);
      for (final entry in colors.entries) {
        expect(
          entry.value,
          entry.key == key ? AppColors.navy : AppColors.textMuted,
          reason: 'selected=$index, label=${entry.key}',
        );
      }
    }
  });
}
