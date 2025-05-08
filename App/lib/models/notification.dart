class AppNotification {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final int userId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.userId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
    );
  }
}