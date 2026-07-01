class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isOnline,
    this.lastLoginAt,
    this.lastSeenAt,
    this.totalPredictions = 0,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final bool isOnline;
  final DateTime? lastLoginAt;
  final DateTime? lastSeenAt;
  final int totalPredictions;

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      role: json['role']?.toString() ?? 'user',
      isActive: _toBool(json['is_active'] ?? json['isActive']),
      isOnline: _toBool(json['is_online'] ?? json['isOnline']),
      lastLoginAt: _parseDate(json['last_login_at'] ?? json['lastLoginAt']),
      lastSeenAt: _parseDate(json['last_seen_at'] ?? json['lastSeenAt']),
      totalPredictions: _toInt(
        json['total_predictions'] ?? json['totalPredictions'],
      ),
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
