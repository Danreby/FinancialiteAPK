extension JsonMapHelpers on Map<String, dynamic> {
  DateTime? dateTime(String key) {
    final v = this[key];
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  double toDouble(String key, [double fallback = 0.0]) {
    final v = this[key];
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  int toInt(String key, [int fallback = 0]) {
    final v = this[key];
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  bool toBool(String key, [bool fallback = false]) {
    final v = this[key];
    if (v == null) return fallback;
    if (v is bool) return v;
    return v == 1 || v == '1' || v == true;
  }

  String? nested(List<String> path) {
    dynamic current = this;
    for (final key in path) {
      if (current is! Map) return null;
      current = current[key];
    }
    return current?.toString();
  }

  String? nestedOr(List<String> primary, String fallbackKey) {
    return nested(primary) ?? this[fallbackKey] as String?;
  }
}
