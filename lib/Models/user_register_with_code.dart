class RenterRegisterWithCode {
  String? first_name;
  String? last_name;
  String? phone;
  String? national_id;
  String? token;
  String? deviceId;
  String? project;
  String? unit;
  String? ownerId;
  String? email;
  String? password;
  String? code;
  String? role;

  //userphoto file path
  String? userPhoto;

  final String message;
  final String info;
  final String status;

  RenterRegisterWithCode({
    this.email,
    this.password,
    this.phone,
    this.code,
    required this.message,
    required this.info,
    required this.status,
    this.role,
    this.userPhoto,
    this.unit,
    this.first_name,
    this.last_name,
    this.national_id,
    this.token,
    this.deviceId,
    this.project,
    this.ownerId,
  });

  factory RenterRegisterWithCode.fromJson(Map<String, dynamic> json) {
    return RenterRegisterWithCode(
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone: json['phone'],
      national_id: json['national_id'],
      token: json['token'],
      deviceId: json['deviceId'],
      project: json['project'],
      unit: json['unit'],
      ownerId: json['ownerId'],
      email: json['email'],
      password: json['password'],
      code: json['code'],
      role: json['role'],
      userPhoto: json['userPhoto'],
      message: json['message'],
      info: json['info'],
      status: json['status'],
    );
  }
}
