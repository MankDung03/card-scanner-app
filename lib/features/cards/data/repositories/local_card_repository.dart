import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../scan/domain/entities/business_card_info.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/repositories/card_repository.dart';

/// Lưu danh thiếp hoàn toàn trên máy:
///   <app documents>/cards/cards.json  – dữ liệu các trường
///   <app documents>/cards/images/     – bản sao ảnh thẻ (ảnh scan gốc nằm ở thư mục tạm, có thể bị OS xoá)
///
/// Đường dẫn ảnh trong `cards.json` được lưu TƯƠNG ĐỐI với thư mục `cards/`
/// (VD: `images/123_front.jpg`). Lý do: đường dẫn tuyệt đối của thư mục app thay đổi
/// sau mỗi lần cập nhật trên iOS, và không dùng được khi khôi phục sang máy khác.
/// Trong bộ nhớ, [SavedCard] luôn mang đường dẫn tuyệt đối của lần chạy hiện tại
/// nên UI chỉ cần `File(card.frontImagePath!)`.
class LocalCardRepository implements CardRepository {
  /// v1: đường dẫn ảnh tuyệt đối · v2: đường dẫn ảnh tương đối với thư mục `cards/`
  static const int dataVersion = 2;
  static const String _imagesFolder = 'images';

  final Future<Directory> Function() _baseDirProvider;

  List<SavedCard>? _cache;
  Future<void> _writeQueue = Future.value();

  LocalCardRepository({Future<Directory> Function()? baseDirProvider})
      : _baseDirProvider = baseDirProvider ?? getApplicationDocumentsDirectory;

  // ───────────────────────── Thư mục ─────────────────────────

  /// Đường dẫn thư mục `cards/`, luôn dùng dấu `/`
  Future<String> _cardsDirPath() async {
    final base = await _baseDirProvider();
    final path = '${_normalize(base.path)}/cards';
    final dir = Directory(path);
    if (!await dir.exists()) await dir.create(recursive: true);
    return path;
  }

  Future<File> _dataFile() async => File('${await _cardsDirPath()}/cards.json');

  Future<String> _imagesDirPath() async {
    final path = '${await _cardsDirPath()}/$_imagesFolder';
    final dir = Directory(path);
    if (!await dir.exists()) await dir.create(recursive: true);
    return path;
  }

  // ───────────────────────── Đường dẫn ảnh ─────────────────────────

  static String _normalize(String path) => path.replaceAll('\\', '/');

  static bool _isAbsolute(String path) =>
      path.startsWith('/') || RegExp(r'^[A-Za-z]:/').hasMatch(path);

  /// Đổi đường dẫn tuyệt đối → tương đối với `cards/` để ghi xuống đĩa.
  /// - Nằm trong thư mục `cards/` hiện tại → bỏ phần đầu.
  /// - Đường dẫn cũ (v1) trỏ tới `.../cards/images/x.jpg` của một thư mục app khác
  ///   (iOS đổi container sau khi cập nhật) → `images/x.jpg`.
  /// - Ảnh nằm ngoài thư mục của app → giữ nguyên tuyệt đối.
  @visibleForTesting
  static String? toStoredPath(String? path, String cardsDir) {
    if (path == null) return null;
    final p = _normalize(path);
    if (!_isAbsolute(p)) return p;
    final prefix = '${_normalize(cardsDir)}/';
    if (p.startsWith(prefix)) return p.substring(prefix.length);
    const marker = '/cards/$_imagesFolder/';
    final i = p.lastIndexOf(marker);
    if (i != -1) return '$_imagesFolder/${p.substring(i + marker.length)}';
    return p;
  }

  /// Đổi đường dẫn đọc từ đĩa → tuyệt đối theo thư mục app của lần chạy hiện tại.
  @visibleForTesting
  static String? toRuntimePath(String? stored, String cardsDir) {
    final relative = toStoredPath(stored, cardsDir);
    if (relative == null) return null;
    return _isAbsolute(relative) ? relative : '${_normalize(cardsDir)}/$relative';
  }

  /// Đường dẫn đang lưu tuyệt đối nhưng chuyển được sang tương đối (dữ liệu v1)
  static bool _storedAsAbsolute(String? stored, String cardsDir) {
    if (stored == null || !_isAbsolute(_normalize(stored))) return false;
    final rel = toStoredPath(stored, cardsDir);
    return rel != null && !_isAbsolute(rel);
  }

  // ───────────────────────── Đọc / ghi ─────────────────────────

  Future<List<SavedCard>> _load() async {
    if (_cache != null) return _cache!;
    final file = await _dataFile();
    if (!await file.exists()) return _cache = [];

    final cardsDir = await _cardsDirPath();
    var needsMigration = false;
    try {
      final raw = jsonDecode(await file.readAsString());
      final version = raw is Map ? (raw['version'] as int? ?? 1) : 1;
      final list = (raw is Map ? raw['cards'] : raw) as List;

      _cache = list.map((e) {
        final card = SavedCard.fromJson(Map<String, dynamic>.from(e as Map));
        if (_storedAsAbsolute(card.frontImagePath, cardsDir) ||
            _storedAsAbsolute(card.backImagePath, cardsDir)) {
          needsMigration = true;
        }
        return card.copyWith(
          frontImagePath: toRuntimePath(card.frontImagePath, cardsDir),
          backImagePath: toRuntimePath(card.backImagePath, cardsDir),
        );
      }).toList();

      if (version < dataVersion) needsMigration = true;
    } catch (e) {
      debugPrint('LocalCardRepository: cannot read cards.json: $e');
      _cache = [];
      return _cache!;
    }

    // Ghi lại một lần theo định dạng mới (đường dẫn tương đối)
    if (needsMigration) {
      try {
        await _persist(_cache!);
        debugPrint('LocalCardRepository: migrated cards.json to v$dataVersion');
      } catch (e) {
        debugPrint('LocalCardRepository: migration write failed: $e');
      }
    }
    return _cache!;
  }

  Future<void> _persist(List<SavedCard> cards) {
    // Ghi tuần tự để tránh 2 lần ghi chồng lên nhau
    // (lỗi của lần ghi trước không được chặn các lần ghi sau)
    final op = _writeQueue.catchError((_) {}).then((_) async {
      final cardsDir = await _cardsDirPath();
      final file = await _dataFile();
      final tmp = File('${file.path}.tmp');
      final json = [
        for (final c in cards)
          c
              .copyWith(
                frontImagePath: toStoredPath(c.frontImagePath, cardsDir),
                backImagePath: toStoredPath(c.backImagePath, cardsDir),
              )
              .toJson(),
      ];
      await tmp.writeAsString(
        jsonEncode({'version': dataVersion, 'cards': json}),
        flush: true,
      );
      await tmp.rename(file.path);
    });
    _writeQueue = op;
    return op;
  }

  List<SavedCard> _sorted(List<SavedCard> cards) =>
      [...cards]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // ───────────────────────── API ─────────────────────────

  @override
  Future<List<SavedCard>> getAll() async => _sorted(await _load());

  @override
  Future<SavedCard> saveFromScan(
    BusinessCardInfo info, {
    String? frontImagePath,
    String? backImagePath,
  }) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final card = SavedCard.fromCardInfo(
      info,
      id: id,
      now: now,
      frontImagePath: await _copyImage(frontImagePath, '${id}_front'),
      backImagePath: await _copyImage(backImagePath, '${id}_back'),
    );
    final cards = [...await _load(), card];
    await _persist(cards);
    _cache = cards;
    return card;
  }

  @override
  Future<SavedCard> update(SavedCard card) async {
    final cards = [...await _load()];
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index == -1) throw StateError('Card ${card.id} not found');
    cards[index] = card;
    await _persist(cards);
    _cache = cards;
    return card;
  }

  @override
  Future<SavedCard> setImage(
    SavedCard card, {
    required bool isFront,
    required String sourcePath,
  }) async {
    // Tên file mới mỗi lần để Image.file không dùng lại ảnh cũ trong cache
    final side = isFront ? 'front' : 'back';
    final newPath = await _copyImage(
      sourcePath,
      '${card.id}_${side}_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (newPath == null) throw StateError('Image not found: $sourcePath');

    final oldPath = isFront ? card.frontImagePath : card.backImagePath;
    final updated = await update(
      isFront
          ? card.copyWith(frontImagePath: newPath, updatedAt: DateTime.now())
          : card.copyWith(backImagePath: newPath, updatedAt: DateTime.now()),
    );
    await _deleteFile(oldPath);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final cards = [...await _load()];
    final index = cards.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final removed = cards.removeAt(index);
    await _persist(cards);
    _cache = cards;
    await _deleteFile(removed.frontImagePath);
    await _deleteFile(removed.backImagePath);
  }

  // ───────────────────────── File ảnh ─────────────────────────

  Future<void> _deleteFile(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Copy ảnh vào `cards/images/`, trả về đường dẫn tuyệt đối (dạng `/`).
  Future<String?> _copyImage(String? sourcePath, String baseName) async {
    if (sourcePath == null) return null;
    final source = File(sourcePath);
    if (!await source.exists()) return null;
    final normalized = _normalize(sourcePath);
    final dot = normalized.lastIndexOf('.');
    final ext = dot != -1 && dot > normalized.lastIndexOf('/') ? normalized.substring(dot) : '.jpg';
    final target = '${await _imagesDirPath()}/$baseName$ext';
    await source.copy(target);
    return target;
  }
}
