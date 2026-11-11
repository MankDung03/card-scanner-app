import 'dart:math';
import '../entities/business_card_result.dart';
import '../entities/ocr_model.dart';

/// Chấm điểm và phân tách các trường theo Heuristic thông minh
class HeuristicFieldScorer {
  // Từ khóa Công ty / Ngân hàng / Tập đoàn (VN, JP, EN)
  static final List<String> _companyKeywords = [
    'ngân hàng', 'bank', 'công ty', 'tnhh', 'cổ phần', 'jsc', 'tập đoàn', 'group',
    'co., ltd', 'co.,ltd', 'ltd', 'inc', 'corp', 'corporation',
    'engineering', 'technology', 'technologies', 'solutions', 'consulting',
    'holdings', 'services', 'systems', 'ventures',
    '株式会社', '（株）', '(株)', '有限会社', '合同会社', '企業',
  ];

  // Các thương hiệu / chữ viết tắt ngân hàng lớn phổ biến
  static final List<String> _bankBrands = [
    'vib', 'vcb', 'vietcombank', 'techcombank', 'mbbank', 'mb', 'bidv', 'agribank',
    'vpbank', 'tpbank', 'acb', 'shb', 'hdbank', 'sacombank', 'msb', 'ocb',
  ];

  // Từ khóa Chức vụ
  static final List<String> _titleKeywords = [
    'quản lý khách hàng', 'quản lý', 'chuyên viên khách hàng', 'chuyên viên tư vấn',
    'chuyên viên', 'giám đốc', 'phó giám đốc', 'trưởng phòng', 'phó phòng',
    'trưởng nhóm', 'nhân viên', 'kế toán', 'kỹ sư', 'luật sư',
    'manager', 'ceo', 'cto', 'cfo', 'director', 'general director',
    'team leader', 'leader', 'consultant', 'engineer', 'supervisor',
    '代表取締役社長', '代表取締役会長', '代表取締役', '取締役', '社長', '副社長',
    '専務取締役', '常務取締役', '専務', '常務', '部長', '次長', '課長',
    '係長', '主任', 'リーダー', 'マネージャー', '支店長',
  ];

  // Từ khóa Phòng ban / Chi nhánh
  static final List<String> _departmentKeywords = [
    'chi nhánh', 'phòng giao dịch', 'trung tâm', 'phòng kinh doanh', 'ban', 'khối',
    'văn phòng', 'phòng', 'branch', 'department', 'division', 'office',
    '営業部', '総務部', '開発部', '人事部', '経理部', '企画部', '本部', '営業所',
  ];

  // Từ khóa Địa chỉ
  static final List<String> _addressKeywords = [
    'số', 'lô', 'phố', 'đường', 'khu đtm', 'khu', 'ngõ', 'ngách', 'quận', 'huyện',
    'phường', 'thị xã', 'tỉnh', 'thành phố', 'hà nội', 'tp.hcm', 'hồ chí minh',
    'đà nẵng', 'hải phòng', 'cần thơ', 'building', 'tòa nhà', 'tầng', 'floor',
    '東京都', '大阪府', '京都府', '北海道', '県', '市', '区', '町', '丁目', '番地', 'ビル',
  ];

  // Họ người Việt phổ biến
  static final List<String> _vietnameseSurnames = [
    'nguyễn', 'trần', 'lê', 'phạm', 'hoàng', 'huỳnh', 'phan', 'vũ', 'võ',
    'đặng', 'bùi', 'đỗ', 'hồ', 'ngô', 'dương', 'lý', 'đinh', 'đoàn',
  ];

  // Họ người Nhật phổ biến
  static final List<String> _japaneseSurnames = [
    '佐藤', '鈴木', '高橋', '田中', '渡辺', '伊藤', '山本', '中村', '小林', '加藤',
    '吉田', '山田', '佐々木', '山口', '松本', '井上', '木村', '林', '斎藤', '清水',
  ];

  /// Thực hiện chấm điểm heuristic trên các dòng còn lại chưa được gán
  static Map<String, dynamic> scoreAndAssign({
    required List<OcrLine> allLines,
    required double cardWidth,
    required double cardHeight,
  }) {
    FieldValue? name;
    FieldValue? furigana;
    FieldValue? title;
    FieldValue? company;
    FieldValue? department;
    FieldValue? address;

    // Lọc các dòng chưa bị Regex sử dụng
    final availableLines = allLines.where((l) => !l.isConsumed).toList();
    if (availableLines.isEmpty) {
      return {
        'name': null,
        'furigana': null,
        'title': null,
        'company': null,
        'department': null,
        'address': null,
        'unmappedLines': <OcrLine>[],
      };
    }

    // 1. CHẤM ĐIỂM CHỨC VỤ (TITLE)
    OcrLine? bestTitleLine;
    double maxTitleScore = 0;
    for (final line in availableLines) {
      final lower = line.normalizedText.toLowerCase();
      double score = 0;
      for (final kw in _titleKeywords) {
        if (lower.contains(kw)) {
          score += (kw.length >= 5) ? 60 : 40;
          if (lower == kw) score += 30; // Trùng khít hoàn toàn
          break;
        }
      }
      if (score > maxTitleScore && score >= 40) {
        maxTitleScore = score;
        bestTitleLine = line;
      }
    }

    if (bestTitleLine != null) {
      title = FieldValue(
        value: bestTitleLine.text.trim(),
        confidence: maxTitleScore >= 60 ? 0.95 : 0.80,
        sourceLineIds: [bestTitleLine.id],
      );
      bestTitleLine.isConsumed = true;
    }

    // 2. CHẤM ĐIỂM CÔNG TY (COMPANY)
    // Hỗ trợ kết hợp: Tên viết tắt (ví dụ VIB) + Tên ngân hàng/công ty (ví dụ Ngân hàng Quốc Tế)
    OcrLine? bestCompanyLine;
    OcrLine? brandLine;
    double maxCompanyScore = 0;
    final companyAlternatives = <String>[];

    for (final line in availableLines) {
      if (line.isConsumed) continue;
      final lower = line.normalizedText.toLowerCase();

      // Kiểm tra xem dòng có phải brand ngân hàng viết tắt (chỉ riêng tên thương hiệu, ví dụ "VIB", "ACB")
      for (final brand in _bankBrands) {
        if (lower == brand) {
          brandLine = line;
          break;
        }
      }

      double score = 0;
      for (final kw in _companyKeywords) {
        if (lower.contains(kw)) {
          score += 50;
          if (lower.startsWith(kw) || lower.endsWith(kw)) score += 20;
          break;
        }
      }

      if (score > maxCompanyScore && score >= 40) {
        maxCompanyScore = score;
        bestCompanyLine = line;
      }
    }

    if (bestCompanyLine != null) {
      var companyName = bestCompanyLine.text.trim();
      companyAlternatives.add(companyName);

      // Nếu có dòng brand (ví dụ VIB) ở gần, kết hợp thành "Ngân hàng Quốc Tế VIB"
      if (brandLine != null && brandLine != bestCompanyLine) {
        final brandText = brandLine.text.trim();
        companyAlternatives.add(brandText);
        if (!companyName.toLowerCase().contains(brandText.toLowerCase())) {
          companyName = '$companyName $brandText';
        }
        brandLine.isConsumed = true;
      }

      company = FieldValue(
        value: companyName,
        confidence: 0.95,
        sourceLineIds: [bestCompanyLine.id, if (brandLine != null) brandLine.id],
        alternatives: companyAlternatives,
      );
      bestCompanyLine.isConsumed = true;
    }

    // 3. CHẤM ĐIỂM PHÒNG BAN / CHI NHÁNH (DEPARTMENT)
    OcrLine? bestDeptLine;
    double maxDeptScore = 0;
    final deptAlternatives = <String>[];

    for (final line in availableLines) {
      if (line.isConsumed) continue;
      final lower = line.normalizedText.toLowerCase();

      double score = 0;
      for (final kw in _departmentKeywords) {
        if (lower.contains(kw)) {
          score += 50;
          break;
        }
      }

      // Nhận diện kiểu "<Brand> <Tên chi nhánh>" (ví dụ "VIB Trung Yên")
      for (final brand in _bankBrands) {
        if (lower.startsWith('$brand ')) {
          score += 45;
          break;
        }
      }

      if (score > maxDeptScore && score >= 40) {
        maxDeptScore = score;
        bestDeptLine = line;
      }
    }

    if (bestDeptLine != null) {
      deptAlternatives.add(bestDeptLine.text.trim());
      department = FieldValue(
        value: bestDeptLine.text.trim(),
        confidence: 0.90,
        sourceLineIds: [bestDeptLine.id],
        alternatives: deptAlternatives,
      );
      bestDeptLine.isConsumed = true;
    }

    // 4. CHẤM ĐIỂM ĐỊA CHỈ (ADDRESS) - Ghép nối các dòng địa chỉ liền kề
    final addressLines = <OcrLine>[];
    for (final line in availableLines) {
      if (line.isConsumed) continue;
      final lower = line.normalizedText.toLowerCase();

      bool hasAddrKeyword = false;
      for (final kw in _addressKeywords) {
        if (lower.contains(kw)) {
          hasAddrKeyword = true;
          break;
        }
      }

      if (hasAddrKeyword || (addressLines.isNotEmpty && line.normalizedText.length > 10)) {
        addressLines.add(line);
        line.isConsumed = true;
      }
    }

    if (addressLines.isNotEmpty) {
      final combinedAddress = addressLines.map((l) => l.text.trim()).join(', ');
      address = FieldValue(
        value: combinedAddress,
        confidence: 0.92,
        sourceLineIds: addressLines.map((l) => l.id).toList(),
      );
    }

    // 5. CHẤM ĐIỂM HỌ TÊN (NAME) - Composite Scoring
    // Tính median font height
    final lineHeights = availableLines.map((l) => l.boundingBox.height).toList();
    lineHeights.sort();
    final medianHeight = lineHeights.isNotEmpty ? lineHeights[lineHeights.length ~/ 2] : 20.0;

    OcrLine? bestNameLine;
    double maxNameScore = -999;
    final nameAlternatives = <String>[];

    for (final line in availableLines) {
      if (line.isConsumed) continue;
      final text = line.normalizedText;
      final lower = text.toLowerCase();
      final words = text.split(RegExp(r'\s+'));

      // Phạt nặng nếu chứa số, ký tự đặc biệt, hoặc từ khóa công ty/địa chỉ
      if (RegExp(r'\d').hasMatch(text)) continue;
      if (text.length < 2 || text.length > 30) continue;

      double score = 0;

      // Cộng điểm font to
      final fontRatio = line.boundingBox.height / max(1.0, medianHeight);
      if (fontRatio >= 1.2) score += 30;
      if (fontRatio >= 1.5) score += 20;

      // Cộng điểm vị trí ở nửa trên của thẻ
      if (cardHeight > 0 && line.boundingBox.top < cardHeight * 0.55) {
        score += 20;
      }

      // Cộng điểm nếu gần dòng Chức vụ
      if (title != null && bestTitleLine != null) {
        final distY = (line.boundingBox.top - bestTitleLine.boundingBox.top).abs();
        if (distY < medianHeight * 3.5) {
          score += 35;
        }
      }

      // Cộng điểm họ phổ biến
      final firstWord = words.first.toLowerCase();
      if (_vietnameseSurnames.contains(firstWord)) {
        score += 40;
      }
      for (final jpSur in _japaneseSurnames) {
        if (text.startsWith(jpSur)) {
          score += 45;
          break;
        }
      }

      // Kiểm tra độ dài từ người Việt (2 - 4 từ)
      if (words.length >= 2 && words.length <= 4) {
        score += 15;
      }

      // Tên thuần chữ Hán Kanji (2-6 ký tự)
      if (RegExp(r'^[\u4E00-\u9FFF\s]+$').hasMatch(text) &&
          text.replaceAll(RegExp(r'\s+'), '').length >= 2 &&
          text.replaceAll(RegExp(r'\s+'), '').length <= 6) {
        score += 25;
      }

      // Trừ điểm nặng nếu dính từ khóa công ty hoặc địa chỉ
      for (final kw in _companyKeywords) {
        if (lower.contains(kw)) score -= 100;
      }
      for (final kw in _addressKeywords) {
        if (lower.contains(kw)) score -= 100;
      }

      if (score > 30) {
        nameAlternatives.add(line.text.trim());
      }

      if (score > maxNameScore && score >= 40) {
        maxNameScore = score;
        bestNameLine = line;
      }
    }

    if (bestNameLine != null) {
      name = FieldValue(
        value: bestNameLine.text.trim(),
        confidence: maxNameScore >= 70 ? 0.95 : 0.75,
        sourceLineIds: [bestNameLine.id],
        alternatives: nameAlternatives.where((n) => n != bestNameLine!.text.trim()).toList(),
      );
      bestNameLine.isConsumed = true;
    }

    // 6. TÌM FURIGANA (Dành cho danh thiếp Nhật - dòng Hiragana ngay trên/dưới Tên)
    if (name != null && bestNameLine != null) {
      for (final line in availableLines) {
        if (line.isConsumed) continue;
        final text = line.normalizedText;
        // Chỉ gồm Hiragana hoặc Katakana và khoảng cách
        if (RegExp(r'^[\u3040-\u309F\u30A0-\u30FF\s]+$').hasMatch(text)) {
          final distY = (line.boundingBox.top - bestNameLine.boundingBox.top).abs();
          if (distY < medianHeight * 2.5) {
            furigana = FieldValue(
              value: text.trim(),
              confidence: 0.90,
              sourceLineIds: [line.id],
            );
            line.isConsumed = true;
            break;
          }
        }
      }
    }

    // 7. CÁC DÒNG CÒN THỪA (UNMAPPED LINES)
    final unmapped = allLines.where((l) => !l.isConsumed).toList();

    return {
      'name': name,
      'furigana': furigana,
      'title': title,
      'company': company,
      'department': department,
      'address': address,
      'unmappedLines': unmapped,
    };
  }
}
