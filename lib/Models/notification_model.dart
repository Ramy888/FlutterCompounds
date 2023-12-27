//NotificationModel.dart
class NotificationModel {

  final String message;
  final String status;
  final String info;
  final List<OneNotification> notifList;

  NotificationModel({
    required this.message,
    required this.status,
    required this.info,
    required this.notifList,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // List<OneNotification> notifList = json['data'] != null
    //     ? json['data'].map((i) => OneNotification.fromJson(i as Map<String, dynamic>)).toList()
    //     : [];

    final List<dynamic>? list = json['data'] as List<dynamic>?;

    // If the key exists and the list is not null, parse it; otherwise, set an empty list
    List<OneNotification> notifList = list != null
        ? list.map((i) => OneNotification.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return NotificationModel(
      status: json['status'] as String,
      info: json['info'] as String,
      message: json['message'] as String,
      notifList: notifList,
    );
  }
}

class OneNotification {
  final String notificationId;
  final String title;
  final String body;
  final String photoUrl;
  final String created_at;
  final String notificationTo;
  final String data;
  final String notificationType;
  final String role;

  OneNotification({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.photoUrl,
    required this.created_at,
    required this.notificationTo,
    required this.data,
    required this.notificationType,
    required this.role,
  });

  factory OneNotification.fromJson(Map<String, dynamic> json) {
    return OneNotification(
      notificationId: json['notifId'] as String,
      notificationTo: json['notification_to'] as String,
      title: json['notificationTitle'] as String,
      body: json['notificationBody'] as String,
      photoUrl: json['notificationPhotoUrl'] as String,
      created_at: json['notificationDateTime'] as String,
      data: json['data'] as String,
      notificationType: json['notificationType'] as String,
      role: json['role'] as String,
    );
  }
}