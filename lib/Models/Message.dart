class ModelMessage{
  String message;
  String time;
  String initiatorId;
  String messageId;

  ModelMessage({
    required this.message,
    required this.time,
    required this.initiatorId,
    required this.messageId,
  });


  factory ModelMessage.fromJson(Map<String, dynamic> json) {
    return ModelMessage(
      message: json['message'] as String,
      time: json['time'] as String,
      initiatorId: json['initiatorId'] as String,
      messageId: json['messageId'] as String,
    );
  }
}