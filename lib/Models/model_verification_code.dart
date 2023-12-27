class VerificationCodeModel {
  final String? status;
  final String? vCode;
  final String? userId;
  final String? role;
  final String? ownerId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? userPhoto;
  final String? message;
  final String? info;

  VerificationCodeModel({
    this.status,
    this.vCode,
    this.userId,
    this.role,
    this.ownerId,
    this.email,
    this.firstName,
    this.lastName,
    this.userPhoto,
    this.message,
    this.info,
  });

  factory VerificationCodeModel.fromJson(Map<String, dynamic> json) {
    return VerificationCodeModel(
      status: json['status'] as String?,
      vCode: json['v_code'] as String?,
      userId: json['userId'] as String?,
      role: json['role'] as String?,
      ownerId: json['ownerId'] as String?,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      userPhoto: json['userPhoto'] as String?,
      message: json['message'] as String?,
      info: json['info'] as String?,
    );
  }
}
