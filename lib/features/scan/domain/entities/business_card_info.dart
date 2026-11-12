import 'business_card_result.dart';
import 'ocr_model.dart';

/// Entity đại diện cho các trường thông tin danh thiếp đã được bóc tách
class BusinessCardInfo {
  final String? name;
  final String? furigana;
  final String? jobTitle;
  final String? company;
  final String? department;
  final String? phone;
  final String? mobile;
  final String? fax;
  final String? email;
  final String? website;
  final String? address;
  final String? postalCode;

  /// Map lưu trữ cờ "Kiểm tra lại" (needsReview) cho từng trường
  /// key: 'name', 'furigana', 'jobTitle', 'company', 'department', 'phone', 'mobile', 'fax', 'email', 'website', 'address'
  final Map<String, bool> reviewFlags;

  /// Danh sách các giá trị gợi ý thay thế cho mỗi trường
  final Map<String, List<String>> alternatives;

  /// Danh sách các dòng văn bản OCR chưa được gán vào trường nào
  final List<OcrLine> unmappedLines;

  const BusinessCardInfo({
    this.name,
    this.furigana,
    this.jobTitle,
    this.company,
    this.department,
    this.phone,
    this.mobile,
    this.fax,
    this.email,
    this.website,
    this.address,
    this.postalCode,
    this.reviewFlags = const {},
    this.alternatives = const {},
    this.unmappedLines = const [],
  });

  /// Factory chuyển đổi từ BusinessCardResult sang BusinessCardInfo
  factory BusinessCardInfo.fromResult(BusinessCardResult result) {
    final flags = <String, bool>{};
    final alts = <String, List<String>>{};

    if (result.name != null) {
      if (result.name!.needsReview) flags['name'] = true;
      if (result.name!.alternatives.isNotEmpty) {
        alts['name'] = result.name!.alternatives;
      }
    }
    if (result.furigana != null && result.furigana!.needsReview) {
      flags['furigana'] = true;
    }
    if (result.title != null) {
      if (result.title!.needsReview) flags['jobTitle'] = true;
      if (result.title!.alternatives.isNotEmpty) {
        alts['jobTitle'] = result.title!.alternatives;
      }
    }
    if (result.company != null) {
      if (result.company!.needsReview) flags['company'] = true;
      if (result.company!.alternatives.isNotEmpty) {
        alts['company'] = result.company!.alternatives;
      }
    }
    if (result.department != null) {
      if (result.department!.needsReview) flags['department'] = true;
      if (result.department!.alternatives.isNotEmpty) {
        alts['department'] = result.department!.alternatives;
      }
    }
    if (result.address != null) {
      if (result.address!.needsReview) flags['address'] = true;
      if (result.address!.alternatives.isNotEmpty) {
        alts['address'] = result.address!.alternatives;
      }
    }
    if (result.website != null) {
      if (result.website!.needsReview) flags['website'] = true;
      if (result.website!.alternatives.isNotEmpty) {
        alts['website'] = result.website!.alternatives;
      }
    }

    final office = result.officePhone;
    final mobile = result.mobilePhone;
    final fax = result.faxNumber;
    final primaryEmail = result.primaryEmail;

    if (office != null) {
      final p = result.phones.firstWhere((e) => e.type == PhoneType.office);
      if (p.confidence < 0.7) flags['phone'] = true;
    }
    if (mobile != null) {
      final p = result.phones.firstWhere((e) => e.type == PhoneType.mobile);
      if (p.confidence < 0.7) flags['mobile'] = true;
    }
    if (fax != null) {
      final p = result.phones.firstWhere((e) => e.type == PhoneType.fax);
      if (p.confidence < 0.7) flags['fax'] = true;
    }
    if (primaryEmail != null && result.emails.isNotEmpty) {
      if (result.emails.first.confidence < 0.7) flags['email'] = true;
    }

    return BusinessCardInfo(
      name: result.name?.value,
      furigana: result.furigana?.value,
      jobTitle: result.title?.value,
      company: result.company?.value,
      department: result.department?.value,
      phone: office,
      mobile: mobile,
      fax: fax,
      email: primaryEmail,
      website: result.website?.value,
      address: result.address?.value,
      postalCode: result.zipcode?.value,
      reviewFlags: flags,
      alternatives: alts,
      unmappedLines: result.unmappedLines,
    );
  }

  /// Tổng số trường đã nhận diện được dữ liệu thực tế (Dynamic X)
  int get recognizedCount {
    int count = 0;
    if (_has(name)) count++;
    if (_has(furigana)) count++;
    if (_has(jobTitle)) count++;
    if (_has(company)) count++;
    if (_has(department)) count++;
    if (_has(phone)) count++;
    if (_has(mobile)) count++;
    if (_has(fax)) count++;
    if (_has(email)) count++;
    if (_has(address) || _has(postalCode)) count++;
    if (_has(website)) count++;
    return count;
  }

  /// Số lượng mục nghi ngờ cần người dùng kiểm tra lại (Dynamic Y)
  int get reviewNeededCount {
    return reviewFlags.values.where((flag) => flag == true).length;
  }

  bool isFieldNeedsReview(String fieldKey) => reviewFlags[fieldKey] == true;

  bool _has(String? val) => val != null && val.trim().isNotEmpty;

  BusinessCardInfo copyWith({
    String? name,
    String? furigana,
    String? jobTitle,
    String? company,
    String? department,
    String? phone,
    String? mobile,
    String? fax,
    String? email,
    String? website,
    String? address,
    String? postalCode,
    Map<String, bool>? reviewFlags,
    Map<String, List<String>>? alternatives,
    List<OcrLine>? unmappedLines,
  }) {
    return BusinessCardInfo(
      name: name ?? this.name,
      furigana: furigana ?? this.furigana,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      fax: fax ?? this.fax,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      reviewFlags: reviewFlags ?? this.reviewFlags,
      alternatives: alternatives ?? this.alternatives,
      unmappedLines: unmappedLines ?? this.unmappedLines,
    );
  }

  BusinessCardInfo updateField(String fieldKey, String? newValue) {
    final updatedFlags = Map<String, bool>.from(reviewFlags);
    // Khi người dùng đã tự tay sửa một trường, trường đó coi như đã được kiểm tra (tắt cờ review)
    updatedFlags[fieldKey] = false;

    switch (fieldKey) {
      case 'name':
        return copyWith(name: newValue, reviewFlags: updatedFlags);
      case 'furigana':
        return copyWith(furigana: newValue, reviewFlags: updatedFlags);
      case 'jobTitle':
        return copyWith(jobTitle: newValue, reviewFlags: updatedFlags);
      case 'company':
        return copyWith(company: newValue, reviewFlags: updatedFlags);
      case 'department':
        return copyWith(department: newValue, reviewFlags: updatedFlags);
      case 'phone':
        return copyWith(phone: newValue, reviewFlags: updatedFlags);
      case 'mobile':
        return copyWith(mobile: newValue, reviewFlags: updatedFlags);
      case 'fax':
        return copyWith(fax: newValue, reviewFlags: updatedFlags);
      case 'email':
        return copyWith(email: newValue, reviewFlags: updatedFlags);
      case 'website':
        return copyWith(website: newValue, reviewFlags: updatedFlags);
      case 'address':
        return copyWith(address: newValue, reviewFlags: updatedFlags);
      case 'postalCode':
        return copyWith(postalCode: newValue, reviewFlags: updatedFlags);
      default:
        return this;
    }
  }

  /// Gán một dòng chưa gán vào một trường cụ thể
  BusinessCardInfo assignUnmappedLine(OcrLine line, String targetFieldKey) {
    final remainingUnmapped = unmappedLines.where((l) => l.id != line.id).toList();
    final updatedInfo = updateField(targetFieldKey, line.text);
    return updatedInfo.copyWith(unmappedLines: remainingUnmapped);
  }

  /// Các trường có thể gán, theo thứ tự hiển thị trên form
  static const fieldKeys = [
    'name',
    'furigana',
    'jobTitle',
    'department',
    'company',
    'phone',
    'mobile',
    'fax',
    'email',
    'website',
    'postalCode',
    'address',
  ];

  /// Giá trị hiện tại của một trường theo key
  String? fieldValue(String key) => switch (key) {
        'name' => name,
        'furigana' => furigana,
        'jobTitle' => jobTitle,
        'company' => company,
        'department' => department,
        'phone' => phone,
        'mobile' => mobile,
        'fax' => fax,
        'email' => email,
        'website' => website,
        'address' => address,
        'postalCode' => postalCode,
        _ => null,
      };

  /// Gán [text] (ghép từ các dòng OCR người dùng chọn trên ảnh) vào [fieldKey].
  ///
  /// - [append] = true và trường đã có giá trị → nối thêm phía sau (cách 1 dấu cách).
  /// - Ngược lại → thay thế.
  /// - Cờ "Kiểm tra lại" của trường được tắt (người dùng đã tự xác nhận).
  /// - Các dòng chưa gán có text trùng [consumedLineTexts] được bỏ khỏi danh sách.
  BusinessCardInfo assignText(
    String fieldKey,
    String text, {
    bool append = false,
    Iterable<String> consumedLineTexts = const [],
  }) {
    final value = text.trim();
    if (value.isEmpty || !fieldKeys.contains(fieldKey)) return this;

    final current = fieldValue(fieldKey)?.trim();
    final newValue = (append && current != null && current.isNotEmpty) ? '$current $value' : value;

    final consumed = consumedLineTexts.map((t) => t.trim()).toSet();
    return updateField(fieldKey, newValue).copyWith(
      unmappedLines: unmappedLines.where((l) => !consumed.contains(l.text.trim())).toList(),
    );
  }
}
