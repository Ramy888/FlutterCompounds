class OneTime{

  final String status;
  final String message;
  final String info;
  final String qrcode;

  OneTime({
    required this.status,
    required this.message,
    required this.info,
    required this.qrcode,
  });

  factory OneTime.fromJson(Map<String, dynamic> json) {
    return OneTime(
      status: json['status'] as String,
      message: json['message'] as String,
      info: json['info'] as String,
      qrcode: json['qrcode'] as String,
    );
  }
}