import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/saved_card.dart';

enum BackupError {
  /// Không phải file sao lưu của app (thiếu manifest / sai định dạng)
  notABackup,

  /// Bản sao lưu tạo bởi phiên bản app mới hơn
  unsupportedVersion,

  /// File hỏng / không đọc được
  corrupted,
}

class BackupException implements Exception {
  final BackupError error;
  final Object? cause;

  const BackupException(this.error, [this.cause]);

  @override
  String toString() => 'BackupException($error${cause != null ? ': $cause' : ''})';
}

class BackupManifest {
  final int version;
  final DateTime createdAt;
  final int cardCount;
  final String? appVersion;

  const BackupManifest({required this.version, required this.createdAt, required this.cardCount, this.appVersion});
}

/// Nội dung đã giải nén: ảnh của [cards] trỏ tới file trong [extractDir] (xoá sau khi khôi phục xong).
class BackupContents {
  final BackupManifest manifest;
  final List<SavedCard> cards;
  final Directory extractDir;

  const BackupContents({required this.manifest, required this.cards, required this.extractDir});

  Future<void> dispose() async {
    try {
      if (await extractDir.exists()) await extractDir.delete(recursive: true);
    } catch (_) {}
  }
}

/// Sao lưu / đọc bản sao lưu dạng .zip:
///
/// ```
/// meishi_backup_20261113_1530.zip
/// ├── manifest.json   {"format":"meishi-backup","version":1,"createdAt":…,"cardCount":…,"appVersion":…}
/// ├── cards.json      [ SavedCard.toJson(), … ]  (đường dẫn ảnh dạng "images/<tên file>")
/// └── images/…        ảnh mặt trước / sau
/// ```
///
/// Nén / giải nén chạy trong isolate riêng để không giật giao diện khi có nhiều ảnh.
class CardBackupService {
  CardBackupService._();

  static const String format = 'meishi-backup';
  static const int version = 1;

  static String fileName(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'meishi_backup_${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}.zip';
  }

  /// Tạo file .zip trong [outDir]. Ảnh không còn tồn tại thì bỏ qua (thẻ vẫn được sao lưu).
  static Future<File> createBackup({
    required List<SavedCard> cards,
    required Directory outDir,
    String? appVersion,
    DateTime? now,
  }) async {
    final created = now ?? DateTime.now();
    await outDir.create(recursive: true);
    final zipPath = '${outDir.path}/${fileName(created)}';

    // Gán tên ảnh duy nhất trong zip, ghi lại đường dẫn tương đối vào cards.json
    final images = <String, String>{}; // tên trong zip → đường dẫn nguồn
    String? entryFor(String? path) {
      if (path == null || !File(path).existsSync()) return null;
      final base = path.replaceAll('\\', '/').split('/').last;
      var name = 'images/$base';
      for (var i = 1; images.containsKey(name) && images[name] != path; i++) {
        name = 'images/${i}_$base';
      }
      images[name] = path;
      return name;
    }

    final cardsJson = [
      for (final c in cards)
        c.copyWith(frontImagePath: entryFor(c.frontImagePath), backImagePath: entryFor(c.backImagePath)).toJson(),
    ];
    final manifest = {
      'format': format,
      'version': version,
      'createdAt': created.toIso8601String(),
      'cardCount': cards.length,
      if (appVersion != null) 'appVersion': appVersion,
    };

    await compute(_writeZip, (zipPath, jsonEncode(manifest), jsonEncode(cardsJson), images));
    return File(zipPath);
  }

  static Future<void> _writeZip((String, String, String, Map<String, String>) args) async {
    final (zipPath, manifest, cards, images) = args;
    final encoder = ZipFileEncoder()..create(zipPath);
    try {
      encoder.addArchiveFile(ArchiveFile.string('manifest.json', manifest));
      encoder.addArchiveFile(ArchiveFile.string('cards.json', cards));
      for (final entry in images.entries) {
        // Ảnh JPEG đã nén sẵn → lưu thẳng (level 0) cho nhanh
        await encoder.addFile(File(entry.value), entry.key, 0);
      }
    } finally {
      await encoder.close();
    }
  }

  /// Đọc và giải nén [zipPath] vào một thư mục mới trong [workDir].
  /// Ném [BackupException] nếu file không hợp lệ.
  static Future<BackupContents> readBackup(String zipPath, {required Directory workDir}) async {
    final extractDir = Directory('${workDir.path}/restore_${DateTime.now().microsecondsSinceEpoch}');
    await extractDir.create(recursive: true);
    try {
      final (manifestJson, cardsJson) = await compute(_readZip, (zipPath, extractDir.path));
      final manifest = _parseManifest(manifestJson);
      final cards = _parseCards(cardsJson, extractDir.path);
      return BackupContents(manifest: manifest, cards: cards, extractDir: extractDir);
    } catch (e) {
      try {
        await extractDir.delete(recursive: true);
      } catch (_) {}
      if (e is BackupException) rethrow;
      throw BackupException(BackupError.corrupted, e);
    }
  }

  /// Tên mục hợp lệ: "manifest.json", "cards.json", "images/<tên file>" (không có thư mục con, không "..").
  @visibleForTesting
  static String? safeEntryName(String raw) {
    final name = raw.replaceAll('\\', '/');
    if (name == 'manifest.json' || name == 'cards.json') return name;
    if (!name.startsWith('images/')) return null;
    final file = name.substring('images/'.length);
    if (file.isEmpty || file.contains('/') || file == '.' || file == '..' || file.contains(':')) return null;
    return name;
  }

  static Future<(String?, String?)> _readZip((String, String) args) async {
    final (zipPath, outDir) = args;
    Directory('$outDir/images').createSync(recursive: true);
    final input = InputFileStream(zipPath);
    String? manifest;
    String? cards;
    try {
      final archive = ZipDecoder().decodeStream(input);
      for (final file in archive) {
        if (!file.isFile) continue;
        final name = safeEntryName(file.name);
        if (name == null) continue; // bỏ qua mục lạ / nguy hiểm (zip-slip)
        if (name == 'manifest.json') {
          manifest = utf8.decode(file.content);
        } else if (name == 'cards.json') {
          cards = utf8.decode(file.content);
        } else {
          final out = OutputFileStream('$outDir/$name');
          file.writeContent(out);
          await out.close();
        }
      }
    } finally {
      await input.close();
    }
    return (manifest, cards);
  }

  static BackupManifest _parseManifest(String? json) {
    if (json == null) throw const BackupException(BackupError.notABackup);
    final Map<String, dynamic> m;
    try {
      m = Map<String, dynamic>.from(jsonDecode(json) as Map);
    } catch (e) {
      throw BackupException(BackupError.notABackup, e);
    }
    if (m['format'] != format) throw const BackupException(BackupError.notABackup);
    final v = m['version'];
    if (v is! int) throw const BackupException(BackupError.notABackup);
    if (v > version) throw const BackupException(BackupError.unsupportedVersion);
    return BackupManifest(
      version: v,
      createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      cardCount: (m['cardCount'] as num?)?.toInt() ?? 0,
      appVersion: m['appVersion'] as String?,
    );
  }

  static List<SavedCard> _parseCards(String? json, String extractDir) {
    if (json == null) throw const BackupException(BackupError.corrupted);
    final list = jsonDecode(json);
    if (list is! List) throw const BackupException(BackupError.corrupted);

    String? resolve(String? entry) {
      if (entry == null || safeEntryName(entry) == null || !entry.startsWith('images/')) return null;
      final path = '$extractDir/$entry';
      return File(path).existsSync() ? path : null;
    }

    return [
      for (final e in list)
        if (e is Map)
          () {
            final card = SavedCard.fromJson(Map<String, dynamic>.from(e));
            return card.copyWith(
              frontImagePath: resolve(card.frontImagePath),
              backImagePath: resolve(card.backImagePath),
            );
          }(),
    ];
  }
}
