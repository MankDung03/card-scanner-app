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
class LocalCardRepository implements CardRepository {
  final Future<Directory> Function() _baseDirProvider;

  List<SavedCard>? _cache;
  Future<void> _writeQueue = Future.value();

  LocalCardRepository({Future<Directory> Function()? baseDirProvider})
      : _baseDirProvider = baseDirProvider ?? getApplicationDocumentsDirectory;

  Future<Directory> _cardsDir() async {
    final base = await _baseDirProvider();
    final dir = Directory('${base.path}/cards');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _dataFile() async => File('${(await _cardsDir()).path}/cards.json');

  Future<Directory> _imagesDir() async {
    final dir = Directory('${(await _cardsDir()).path}/images');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<SavedCard>> _load() async {
    if (_cache != null) return _cache!;
    final file = await _dataFile();
    if (!await file.exists()) return _cache = [];
    try {
      final raw = jsonDecode(await file.readAsString());
      final list = (raw is Map ? raw['cards'] : raw) as List;
      _cache = list.map((e) => SavedCard.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      debugPrint('LocalCardRepository: cannot read cards.json: $e');
      _cache = [];
    }
    return _cache!;
  }

  Future<void> _persist(List<SavedCard> cards) {
    // Ghi tuần tự để tránh 2 lần ghi chồng lên nhau
    // (lỗi của lần ghi trước không được chặn các lần ghi sau)
    final op = _writeQueue.catchError((_) {}).then((_) async {
      final file = await _dataFile();
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(
        jsonEncode({'version': 1, 'cards': cards.map((c) => c.toJson()).toList()}),
        flush: true,
      );
      await tmp.rename(file.path);
    });
    _writeQueue = op;
    return op;
  }

  List<SavedCard> _sorted(List<SavedCard> cards) =>
      [...cards]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

  Future<void> _deleteFile(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
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

  Future<String?> _copyImage(String? sourcePath, String baseName) async {
    if (sourcePath == null) return null;
    final source = File(sourcePath);
    if (!await source.exists()) return null;
    final dot = sourcePath.lastIndexOf('.');
    final ext = dot != -1 && dot > sourcePath.lastIndexOf('/') ? sourcePath.substring(dot) : '.jpg';
    final target = '${(await _imagesDir()).path}/$baseName$ext';
    await source.copy(target);
    return target;
  }
}
