class RenterLoginCode {
  final String? role;
  final String? ownerId;
  final String? userStatus;
  final String? firstName;
  final String? lastName;
  final String? userPhoto;
  final String? project;
  final String? unit;
  final String? codeType;
  final String? dateTimeFrom;
  final String? dateTimeTo;
  final String? generatedAt;
  final String? usedCode;
  final String message;
  final String info;
  final String status;

  RenterLoginCode({
    this.role,
    this.ownerId,
    this.userStatus,
    this.firstName,
    this.lastName,
    this.userPhoto,
    this.project,
    this.unit,
    this.codeType,
    this.dateTimeFrom,
    this.dateTimeTo,
    this.generatedAt,
    this.usedCode,
    required this.message,
    required this.info,
    required this.status,

  });

  // Factory constructor to create a UserResponse object from a JSON map
  factory RenterLoginCode.fromJson(Map<String, dynamic> json) {
    return RenterLoginCode(
      role: json['role'],
      ownerId: json['ownerId'],
      userStatus: json['userStatus'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      userPhoto: json['userPhoto'],
      project: json['project'],
      unit: json['unit'],
      codeType: json['codeType'],
      dateTimeFrom: json['dateTimeFrom'],
      dateTimeTo: json['dateTimeTo'],
      generatedAt: json['generated_at'],
      usedCode: json['usedCode'],
      message: json['message'],
      info: json['info'],
      status: json['status'],
    );
  }
}
