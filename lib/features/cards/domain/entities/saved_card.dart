import '../../../scan/domain/entities/business_card_info.dart';

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

  /// Ghi chú "gặp ở đâu"
  final String? note;

  /// Đường dẫn ảnh đã được copy vào thư mục dữ liệu của app
  final String? frontImagePath;
  final String? backImagePath;

  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.frontImagePath,
    this.backImagePath,
    required this.createdAt,
    required this.updatedAt,
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
      name: _clean(info.name),
      furigana: _clean(info.furigana),
      jobTitle: _clean(info.jobTitle),
      company: _clean(info.company),
      department: _clean(info.department),
      phone: _clean(info.phone),
      mobile: _clean(info.mobile),
      fax: _clean(info.fax),
      email: _clean(info.email),
      website: _clean(info.website),
      address: _clean(info.address),
      postalCode: _clean(info.postalCode),
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

  SavedCard copyWith({
    String? note,
    DateTime? updatedAt,
  }) {
    return SavedCard(
      id: id,
      name: name,
      furigana: furigana,
      jobTitle: jobTitle,
      company: company,
      department: department,
      phone: phone,
      mobile: mobile,
      fax: fax,
      email: email,
      website: website,
      address: address,
      postalCode: postalCode,
      note: note ?? this.note,
      frontImagePath: frontImagePath,
      backImagePath: backImagePath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        'frontImagePath': frontImagePath,
        'backImagePath': backImagePath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
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
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      createdAt: created,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? created,
    );
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
