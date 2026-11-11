import 'ocr_model.dart';

/// Giá trị trích xuất của một trường với độ tin cậy và danh sách gợi ý thay thế
class FieldValue {
  final String value;
  final double confidence; // 0.0 - 1.0
  final List<String> sourceLineIds;
  final List<String> alternatives;

  const FieldValue({
    required this.value,
    this.confidence = 1.0,
    this.sourceLineIds = const [],
    this.alternatives = const [],
  });

  FieldValue copyWith({
    String? value,
    double? confidence,
    List<String>? sourceLineIds,
    List<String>? alternatives,
  }) {
    return FieldValue(
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
      sourceLineIds: sourceLineIds ?? this.sourceLineIds,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  bool get needsReview => confidence < 0.7;

  Map<String, dynamic> toJson() => {
    'value': value,
    'confidence': confidence,
    'sourceLineIds': sourceLineIds,
    'alternatives': alternatives,
  };
}

/// Loại số điện thoại
enum PhoneType {
  office,
  mobile,
  fax,
}

/// Thông tin số điện thoại chi tiết
class PhoneEntry {
  final String number;
  final PhoneType type;
  final double confidence;
  final List<String> sourceLineIds;
  final String? rawPrefix;

  const PhoneEntry({
    required this.number,
    required this.type,
    this.confidence = 1.0,
    this.sourceLineIds = const [],
    this.rawPrefix,
  });

  Map<String, dynamic> toJson() => {
    'number': number,
    'type': type.name,
    'confidence': confidence,
    'sourceLineIds': sourceLineIds,
    'rawPrefix': rawPrefix,
  };
}

/// Kết quả bóc tách tổng thể danh thiếp (Decoupled Output Model)
class BusinessCardResult {
  final FieldValue? name;
  final FieldValue? furigana;
  final FieldValue? title;
  final FieldValue? company;
  final FieldValue? department;
  final List<PhoneEntry> phones;
  final List<FieldValue> emails;
  final FieldValue? website;
  final FieldValue? zipcode;
  final FieldValue? address;
  final List<OcrLine> unmappedLines;
  final List<OcrLine> allLines;

  const BusinessCardResult({
    this.name,
    this.furigana,
    this.title,
    this.company,
    this.department,
    this.phones = const [],
    this.emails = const [],
    this.website,
    this.zipcode,
    this.address,
    this.unmappedLines = const [],
    this.allLines = const [],
  });

  // Helpers trích xuất tiện lợi cho Phone / Mobile / Fax
  String? get officePhone =>
      phones.where((p) => p.type == PhoneType.office).map((p) => p.number).firstOrNull;

  String? get mobilePhone =>
      phones.where((p) => p.type == PhoneType.mobile).map((p) => p.number).firstOrNull;

  String? get faxNumber =>
      phones.where((p) => p.type == PhoneType.fax).map((p) => p.number).firstOrNull;

  String? get primaryEmail => emails.firstOrNull?.value;

  BusinessCardResult copyWith({
    FieldValue? name,
    FieldValue? furigana,
    FieldValue? title,
    FieldValue? company,
    FieldValue? department,
    List<PhoneEntry>? phones,
    List<FieldValue>? emails,
    FieldValue? website,
    FieldValue? zipcode,
    FieldValue? address,
    List<OcrLine>? unmappedLines,
    List<OcrLine>? allLines,
  }) {
    return BusinessCardResult(
      name: name ?? this.name,
      furigana: furigana ?? this.furigana,
      title: title ?? this.title,
      company: company ?? this.company,
      department: department ?? this.department,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      website: website ?? this.website,
      zipcode: zipcode ?? this.zipcode,
      address: address ?? this.address,
      unmappedLines: unmappedLines ?? this.unmappedLines,
      allLines: allLines ?? this.allLines,
    );
  }
}
