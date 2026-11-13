import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/saved_card.dart';
import '../../domain/services/card_export.dart';

enum SaveImageResult { saved, permissionDenied, failed }

/// Các thao tác xuất / chia sẻ dùng plugin. Mọi file đều tạo trong thư mục tạm của app,
/// người dùng tự chọn nơi lưu qua menu chia sẻ của hệ thống — không gửi lên server.
class CardShareService {
  CardShareService._();

  /// Ghi vCard ra file tạm rồi mở menu chia sẻ.
  static Future<void> shareVCard(SavedCard card) async {
    final file = await _writeTemp(CardExport.vCardFileName(card), CardExport.toVCard(card));
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'text/x-vcard')],
      subject: card.displayName,
    ));
  }

  /// Ghi CSV ra file tạm rồi mở menu chia sẻ.
  static Future<void> shareCsv(String csv, String fileName) async {
    final file = await _writeTemp(fileName, csv);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'text/csv')],
      subject: fileName,
    ));
  }

  /// Mở màn "Tạo liên hệ" của hệ thống với dữ liệu điền sẵn.
  /// Không cần quyền danh bạ: người dùng xem lại và tự bấm lưu trong app Danh bạ.
  static Future<void> openContactCreator(SavedCard card) async {
    final (family, given) = _split(card.name);
    final (phoneticFamily, phoneticGiven) = _split(card.furigana);
    final note = card.note?.trim();

    await fc.FlutterContacts.native.showCreator(
      contact: fc.Contact(
        name: fc.Name(
          last: family,
          first: given,
          phoneticLast: phoneticFamily,
          phoneticFirst: phoneticGiven,
        ),
        phones: [
          if (card.mobile != null) fc.Phone(number: card.mobile!, label: const fc.Label(fc.PhoneLabel.mobile)),
          if (card.phone != null) fc.Phone(number: card.phone!, label: const fc.Label(fc.PhoneLabel.work)),
          if (card.fax != null) fc.Phone(number: card.fax!, label: const fc.Label(fc.PhoneLabel.workFax)),
        ],
        emails: [
          if (card.email != null) fc.Email(address: card.email!, label: const fc.Label(fc.EmailLabel.work)),
        ],
        organizations: [
          if (card.company != null || card.jobTitle != null || card.department != null)
            fc.Organization(name: card.company, jobTitle: card.jobTitle, departmentName: card.department),
        ],
        addresses: [
          if (card.fullAddress != null)
            fc.Address(
              formatted: card.fullAddress,
              street: card.address,
              postalCode: card.postalCode?.replaceFirst('〒', '').trim(),
              label: const fc.Label(fc.AddressLabel.work),
            ),
        ],
        websites: [if (card.website != null) fc.Website(url: card.website!)],
        notes: [if (note != null && note.isNotEmpty) fc.Note(note: note)],
      ),
    );
  }

  /// Lưu ảnh vào thư viện ảnh, xoay theo [quarterTurns] (mỗi lần 90° theo chiều kim đồng hồ).
  static Future<SaveImageResult> saveImageToGallery(String path, {int quarterTurns = 0}) async {
    try {
      if (!await Gal.hasPermission() && !await Gal.requestPermission()) {
        return SaveImageResult.permissionDenied;
      }
      final turns = quarterTurns % 4;
      if (turns == 0) {
        await Gal.putImage(path);
      } else {
        final bytes = await compute(_rotateJpg, (path, turns * 90));
        await Gal.putImageBytes(bytes, name: 'meishi_${DateTime.now().millisecondsSinceEpoch}');
      }
      return SaveImageResult.saved;
    } on GalException catch (e) {
      debugPrint('Save image failed: ${e.type}');
      return e.type == GalExceptionType.permissionDenied ? SaveImageResult.permissionDenied : SaveImageResult.failed;
    } catch (e) {
      debugPrint('Save image failed: $e');
      return SaveImageResult.failed;
    }
  }

  static Uint8List _rotateJpg((String, int) args) {
    final decoded = img.decodeImage(File(args.$1).readAsBytesSync());
    if (decoded == null) throw const FormatException('Cannot decode image');
    return img.encodeJpg(img.copyRotate(decoded, angle: args.$2), quality: 92);
  }

  static Future<File> _writeTemp(String fileName, String content) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/share');
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content, flush: true);
    return file;
  }

  static (String, String) _split(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ('', '');
    final parts = v.split(RegExp(r'[\s　]+'));
    return parts.length == 1 ? (parts.first, '') : (parts.first, parts.sublist(1).join(' '));
  }
}
