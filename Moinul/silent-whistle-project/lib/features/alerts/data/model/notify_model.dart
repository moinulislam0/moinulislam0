class NotificationModel {
  final String id;
  final DateTime createdAt;
  final String? readAt;
  final String type;
  final String text;
  final String senderName;
  final String? senderAvatar;
  final String entityId;

  NotificationModel({
    required this.id,
    required this.createdAt,
    this.readAt,
    required this.type,
    required this.text,
    required this.senderName,
    this.senderAvatar,
    required this.entityId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final event = json['notification_event'] ?? {};
    final sender = json['sender'] ?? {};
    return NotificationModel(
      id: json['id'] ?? '',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      readAt: json['read_at'],
      type: event['type'] ?? 'general',
      text: event['text'] ?? '',
      senderName: sender['name'] ?? 'Someone',
      senderAvatar: sender['avatar'],
      entityId: json['entity_id'] ?? '',
    );
  }
}