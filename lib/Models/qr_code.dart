class QrCode {
  final String status;
  final String message;
  final String info;
  final QrCodeData data;

  QrCode({
    required this.status,
    required this.message,
    required this.info,
    required this.data,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      info: json['info'] ?? '',
      data: QrCodeData.fromJson(json['data'] ?? {}),
    );
  }
}

class QrCodeData {
  final String qrcode;
  final String firstName;
  final String lastName;
  final String userStatus;
  final String project;
  final String unit;

  QrCodeData({
    required this.qrcode,
    required this.firstName,
    required this.lastName,
    required this.userStatus,
    required this.project,
    required this.unit,
  });

  factory QrCodeData.fromJson(Map<String, dynamic> json) {
    return QrCodeData(
      qrcode: json['qrcode'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userStatus: json['userStatus'] ?? '',
      project: json['project'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}
