/// Chuẩn hoá chữ tiếng Việt từ OCR.
///
/// ML Kit đôi khi trả chữ có dấu ở dạng TỔ HỢP (Unicode NFD): "ố" = "o" + U+0302 (mũ) + U+0301 (sắc).
/// Trên màn hình trông gần giống (dấu thường bị vẽ lệch), nhưng so chuỗi với từ khoá dựng sẵn
/// ("giám đốc") thì KHÔNG khớp → chức vụ / công ty / địa chỉ bị trượt sang "Dòng chưa gán".
///
/// [compose] ghép chữ cái + dấu rời về ký tự dựng sẵn (NFC) cho toàn bộ bảng chữ tiếng Việt,
/// kể cả khi thứ tự dấu không chuẩn (sắc trước mũ, nặng trước móc…) hoặc chữ đã có sẵn một phần dấu
/// ("ô" + sắc → "ố"). Tổ hợp không có trong tiếng Việt thì giữ nguyên.
///
/// [stripDiacritics] bỏ hết dấu (đ → d) — dùng cho so khớp không dấu khi OCR làm mất dấu.
class VietnameseUnicode {
  const VietnameseUnicode._();

  // Mỗi hàng: [không dấu, huyền, sắc, hỏi, ngã, nặng]
  static const _rows = <String, String>{
    'a': 'aàáảãạ', 'ă': 'ăằắẳẵặ', 'â': 'âầấẩẫậ',
    'e': 'eèéẻẽẹ', 'ê': 'êềếểễệ',
    'i': 'iìíỉĩị',
    'o': 'oòóỏõọ', 'ô': 'ôồốổỗộ', 'ơ': 'ơờớởỡợ',
    'u': 'uùúủũụ', 'ư': 'ưừứửữự',
    'y': 'yỳýỷỹỵ',
    'A': 'AÀÁẢÃẠ', 'Ă': 'ĂẰẮẲẴẶ', 'Â': 'ÂẦẤẨẪẬ',
    'E': 'EÈÉẺẼẸ', 'Ê': 'ÊỀẾỂỄỆ',
    'I': 'IÌÍỈĨỊ',
    'O': 'OÒÓỎÕỌ', 'Ô': 'ÔỒỐỔỖỘ', 'Ơ': 'ƠỜỚỞỠỢ',
    'U': 'UÙÚỦŨỤ', 'Ư': 'ƯỪỨỬỮỰ',
    'Y': 'YỲÝỶỸỴ',
  };

  /// Dấu thanh tổ hợp → chỉ số cột trong [_rows]
  static const _toneMarks = {
    0x0300: 1, 0x0340: 1, // huyền
    0x0301: 2, 0x0341: 2, // sắc
    0x0309: 3, // hỏi
    0x0303: 4, // ngã
    0x0323: 5, // nặng
  };

  // Dấu phụ của nguyên âm
  static const _circumflex = 0x0302;
  static const _breve = 0x0306;
  static const _horn = 0x031B;

  /// ký tự có dấu → (nguyên âm gốc kèm dấu phụ, thanh)
  static final Map<int, (String, int)> _decompose = {
    for (final e in _rows.entries)
      for (var i = 0; i < e.value.runes.length; i++) e.value.runes.elementAt(i): (e.key, i),
  };

  /// Nguyên âm gốc (không thanh) + dấu phụ → nguyên âm có dấu phụ
  static const _withModifier = {
    ('a', _circumflex): 'â', ('e', _circumflex): 'ê', ('o', _circumflex): 'ô',
    ('a', _breve): 'ă',
    ('o', _horn): 'ơ', ('u', _horn): 'ư',
    ('A', _circumflex): 'Â', ('E', _circumflex): 'Ê', ('O', _circumflex): 'Ô',
    ('A', _breve): 'Ă',
    ('O', _horn): 'Ơ', ('U', _horn): 'Ư',
  };

  static bool _isCombining(int r) => r >= 0x0300 && r <= 0x036F;

  /// Ghép dấu rời về ký tự dựng sẵn. Chuỗi không có dấu tổ hợp được trả về nguyên vẹn.
  static String compose(String input) {
    if (!input.runes.any(_isCombining)) return input;

    final runes = input.runes.toList();
    final out = StringBuffer();
    var i = 0;
    while (i < runes.length) {
      final base = runes[i];
      var j = i + 1;
      while (j < runes.length && _isCombining(runes[j])) {
        j++;
      }
      if (j == i + 1) {
        out.writeCharCode(base);
        i++;
        continue;
      }

      final composed = _composeCluster(base, runes.sublist(i + 1, j));
      if (composed != null) {
        out.write(composed);
      } else {
        // Không phải tổ hợp tiếng Việt → giữ nguyên
        for (var k = i; k < j; k++) {
          out.writeCharCode(runes[k]);
        }
      }
      i = j;
    }
    return out.toString();
  }

  static String? _composeCluster(int base, List<int> marks) {
    final known = _decompose[base];
    String? vowel = known?.$1;
    var tone = known?.$2 ?? 0;
    if (vowel == null) {
      // "đ" / "Đ" không nằm trong bảng nguyên âm; ký tự khác không ghép
      return null;
    }

    for (final m in marks) {
      final t = _toneMarks[m];
      if (t != null) {
        if (tone != 0 && tone != t) return null; // hai dấu thanh khác nhau → không hợp lệ
        tone = t;
        continue;
      }
      if (m == _circumflex || m == _breve || m == _horn) {
        final next = _withModifier[(vowel!, m)];
        if (next == null) {
          // Đã có đúng dấu phụ này rồi (vd. "ô" + mũ) thì bỏ qua, còn lại → không hợp lệ
          if (_withModifier.entries.any((e) => e.value == vowel && e.key.$2 == m)) continue;
          return null;
        }
        vowel = next;
        continue;
      }
      return null; // dấu tổ hợp không dùng trong tiếng Việt
    }

    final row = _rows[vowel!];
    if (row == null) return null;
    return String.fromCharCode(row.runes.elementAt(tone));
  }

  /// Bỏ dấu tiếng Việt (kể cả dạng tổ hợp), đ → d. Giữ nguyên hoa / thường.
  static String stripDiacritics(String input) {
    final s = compose(input);
    final out = StringBuffer();
    for (final r in s.runes) {
      if (_isCombining(r)) continue;
      if (r == 0x0111) {
        out.write('d');
        continue;
      }
      if (r == 0x0110) {
        out.write('D');
        continue;
      }
      final known = _decompose[r];
      if (known == null) {
        out.writeCharCode(r);
        continue;
      }
      out.write(_plain[known.$1] ?? known.$1);
    }
    return out.toString();
  }

  static const _plain = {
    'ă': 'a', 'â': 'a', 'ê': 'e', 'ô': 'o', 'ơ': 'o', 'ư': 'u',
    'Ă': 'A', 'Â': 'A', 'Ê': 'E', 'Ô': 'O', 'Ơ': 'O', 'Ư': 'U',
  };
}
