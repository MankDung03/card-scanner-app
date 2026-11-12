import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mở ứng dụng ngoài: gọi điện, soạn email, bản đồ, website.
/// Trả về `false` nếu máy không có ứng dụng phù hợp.
class ContactLauncher {
  const ContactLauncher._();

  /// Giữ lại số, dấu + ở đầu; bỏ khoảng trắng, gạch, ngoặc, "Ext." …
  static String normalizePhone(String raw) {
    // Cắt phần máy lẻ (ext / 内線 / máy lẻ) nếu có
    final main = raw.split(RegExp(r'(ext\.?|内線|máy lẻ|x\s*\d)', caseSensitive: false)).first;
    final digits = main.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return digits;
    return digits[0] + digits.substring(1).replaceAll('+', '');
  }

  static Uri phoneUri(String raw) => Uri(scheme: 'tel', path: normalizePhone(raw));

  static Uri emailUri(String email) => Uri(scheme: 'mailto', path: email.trim());

  static Uri mapUri(String address, {bool? isIOS}) {
    final query = address.replaceAll('\n', ' ').trim();
    if (isIOS ?? (!kIsWeb && Platform.isIOS)) {
      return Uri.https('maps.apple.com', '/', {'q': query});
    }
    return Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});
  }

  static Uri websiteUri(String website) {
    final trimmed = website.trim();
    final withScheme = RegExp(r'^https?://', caseSensitive: false).hasMatch(trimmed)
        ? trimmed
        : 'https://$trimmed';
    return Uri.parse(withScheme);
  }

  static Future<bool> call(String phone) => _open(phoneUri(phone));
  static Future<bool> email(String email) => _open(emailUri(email));
  static Future<bool> map(String address) => _open(mapUri(address));
  static Future<bool> website(String website) => _open(websiteUri(website));

  static Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('ContactLauncher: cannot open $uri: $e');
      return false;
    }
  }
}
