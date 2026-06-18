class Setting {
  final String key;
  final String value;

  Setting({
    required this.key,
    required this.value,
  });

  factory Setting.fromMap(Map<String, dynamic> map) => Setting(
        key: map['key'] as String,
        value: map['value'] as String,
      );

  Map<String, dynamic> toMap() => {
        'key': key,
        'value': value,
      };

  Setting copyWith({
    String? key,
    String? value,
  }) =>
      Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
}
