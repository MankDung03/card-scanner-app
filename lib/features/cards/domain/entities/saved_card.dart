import '../../../scan/domain/entities/business_card_info.dart';

/// Giá trị mặc định cho [SavedCard.copyWith] để phân biệt "không đổi" với "xoá về null".
const Object _unset = Object();

/// Danh thiếp đã được người dùng lưu (lưu hoàn toàn trên máy).
class SavedCard {
  final String id;
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

  /// Ghi chú "gặp ở đâu" (nội dung tự do)
  final String? note;

  /// Ngày gặp
  final DateTime? metAt;

  /// Nơi gặp (VD: "Triển lãm IT, Tokyo")
  final String? metPlace;

  /// Nhãn phân loại (VD: "Khách hàng", "Sự kiện")
  final List<String> tags;

  /// Đường dẫn ảnh đã được copy vào thư mục dữ liệu của app
  final String? frontImagePath;
  final String? backImagePath;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Có thể trùng người với danh thiếp có id này (gắn khi khôi phục bản sao lưu ở chế độ Gộp).
  /// null = không bị nghi trùng. Thẻ được trỏ tới đã bị xoá thì coi như không còn trùng.
  final String? duplicateOf;

  const SavedCard({
    required this.id,
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
    this.note,
    this.metAt,
    this.metPlace,
    this.tags = const [],
    this.frontImagePath,
    this.backImagePath,
    required this.createdAt,
    required this.updatedAt,
    this.duplicateOf,
  });

  factory SavedCard.fromCardInfo(
    BusinessCardInfo info, {
    required String id,
    required DateTime now,
    String? frontImagePath,
    String? backImagePath,
  }) {
    return SavedCard(
      id: id,
      name: clean(info.name),
      furigana: clean(info.furigana),
      jobTitle: clean(info.jobTitle),
      company: clean(info.company),
      department: clean(info.department),
      phone: clean(info.phone),
      mobile: clean(info.mobile),
      fax: clean(info.fax),
      email: clean(info.email),
      website: clean(info.website),
      address: clean(info.address),
      postalCode: clean(info.postalCode),
      frontImagePath: frontImagePath,
      backImagePath: backImagePath,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Tên hiển thị: ưu tiên họ tên, sau đó công ty, email.
  String? get displayName => name ?? company ?? email;

  /// Dòng phụ: "Phòng ban Chức vụ · Công ty" (như thiết kế)
  String get subtitle {
    final role = [department, jobTitle].whereType<String>().join(' ');
    final parts = <String>[
      if (role.isNotEmpty) role,
      if (company != null && company != displayName) company!,
    ];
    return parts.join(' · ');
  }

  /// Ký tự đại diện cho avatar
  String get avatarChar {
    final source = (displayName ?? '').trim();
    if (source.isEmpty) return '?';
    return String.fromCharCode(source.runes.first).toUpperCase();
  }

  /// Địa chỉ đầy đủ kèm mã bưu chính (nếu có)
  String? get fullAddress {
    if (address == null && postalCode == null) return null;
    final zip = postalCode == null
        ? null
        : (postalCode!.startsWith('〒') ? postalCode! : '〒$postalCode');
    if (address == null) return zip;
    if (zip == null || address!.contains(postalCode!)) return address;
    return '$zip $address';
  }

  bool get hasMeetingInfo =>
      metAt != null || metPlace != null || (note?.trim().isNotEmpty ?? false) || tags.isNotEmpty;

  /// Truyền `null` cho trường nullable để xoá giá trị; bỏ qua tham số để giữ nguyên.
  SavedCard copyWith({
    Object? name = _unset,
    Object? furigana = _unset,
    Object? jobTitle = _unset,
    Object? company = _unset,
    Object? department = _unset,
    Object? phone = _unset,
    Object? mobile = _unset,
    Object? fax = _unset,
    Object? email = _unset,
    Object? website = _unset,
    Object? address = _unset,
    Object? postalCode = _unset,
    Object? note = _unset,
    Object? metAt = _unset,
    Object? metPlace = _unset,
    List<String>? tags,
    Object? frontImagePath = _unset,
    Object? backImagePath = _unset,
    DateTime? updatedAt,
    Object? duplicateOf = _unset,
  }) {
    T? pick<T>(Object? value, T? current) => identical(value, _unset) ? current : value as T?;

    return SavedCard(
      id: id,
      name: pick(name, this.name),
      furigana: pick(furigana, this.furigana),
      jobTitle: pick(jobTitle, this.jobTitle),
      company: pick(company, this.company),
      department: pick(department, this.department),
      phone: pick(phone, this.phone),
      mobile: pick(mobile, this.mobile),
      fax: pick(fax, this.fax),
      email: pick(email, this.email),
      website: pick(website, this.website),
      address: pick(address, this.address),
      postalCode: pick(postalCode, this.postalCode),
      note: pick(note, this.note),
      metAt: pick(metAt, this.metAt),
      metPlace: pick(metPlace, this.metPlace),
      tags: tags ?? this.tags,
      frontImagePath: pick(frontImagePath, this.frontImagePath),
      backImagePath: pick(backImagePath, this.backImagePath),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      duplicateOf: pick(duplicateOf, this.duplicateOf),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'furigana': furigana,
        'jobTitle': jobTitle,
        'company': company,
        'department': department,
        'phone': phone,
        'mobile': mobile,
        'fax': fax,
        'email': email,
        'website': website,
        'address': address,
        'postalCode': postalCode,
        'note': note,
        'metAt': metAt?.toIso8601String(),
        'metPlace': metPlace,
        'tags': tags,
        'frontImagePath': frontImagePath,
        'backImagePath': backImagePath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (duplicateOf != null) 'duplicateOf': duplicateOf,
      };

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    return SavedCard(
      id: json['id'] as String,
      name: json['name'] as String?,
      furigana: json['furigana'] as String?,
      jobTitle: json['jobTitle'] as String?,
      company: json['company'] as String?,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      fax: json['fax'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      postalCode: json['postalCode'] as String?,
      note: json['note'] as String?,
      metAt: DateTime.tryParse(json['metAt'] as String? ?? ''),
      metPlace: json['metPlace'] as String?,
      tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      createdAt: created,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? created,
      duplicateOf: json['duplicateOf'] as String?,
    );
  }

  /// Chuẩn hoá chuỗi nhập: trim, chuỗi rỗng → null.
  static String? clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
