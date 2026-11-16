/// Trường do người dùng tự đặt tên, cho thông tin nằm ngoài 12 trường chuẩn
/// (VD: "LINE: abc123", "資格: 一級建築士\n宅地建物取引士").
///
/// [value] có thể nhiều dòng.
class CustomField {
  final String label;
  final String value;

  const CustomField({required this.label, required this.value});

  CustomField copyWith({String? label, String? value}) =>
      CustomField(label: label ?? this.label, value: value ?? this.value);

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  /// Trả về null nếu dữ liệu hỏng / rỗng.
  static CustomField? fromJson(Object? json) {
    if (json is! Map) return null;
    final label = (json['label'] as Object?)?.toString().trim() ?? '';
    final value = (json['value'] as Object?)?.toString().trim() ?? '';
    if (label.isEmpty || value.isEmpty) return null;
    return CustomField(label: label, value: value);
  }

  static List<CustomField> listFromJson(Object? json) =>
      json is List ? json.map(fromJson).whereType<CustomField>().toList() : const [];

  /// "LINE: abc" — giá trị nhiều dòng được nối bằng [lineSeparator].
  String format({String lineSeparator = '\n'}) => '$label: ${value.split('\n').join(lineSeparator)}';

  @override
  bool operator ==(Object other) => other is CustomField && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);

  @override
  String toString() => 'CustomField($label: $value)';
}
