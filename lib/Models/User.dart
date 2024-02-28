class User {
  final String userId;
  final String sessionId;
  final String first_name;
  final String last_name;
  final String phoneNumber;
  final String email;
  final String userPhoto;
  final String role;
  final String userStatus;
  final String message;
  final String info;
  final String created_at;
  final String status;
  final String vCode;

  const User({
    required this.userId,
    required this.sessionId,
    required this.first_name,
    required this.last_name,
    required this.phoneNumber,
    required this.email,
    required this.userPhoto,
    required this.role,
    required this.userStatus,
    required this.message,
    required this.info,
    required this.created_at,
    required this.status,
    required this.vCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      first_name: json['first_name'] as String? ?? '',
      last_name: json['last_name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      userPhoto: json['userPhoto'] as String? ?? '',
      role: json['role'] as String? ?? '',
      userStatus: json['userStatus'] as String? ?? '',
      message: json['message'] as String? ?? '',
      info: json['info'] as String? ?? '',
      created_at: json['created_at'] as String? ?? '',
      status: json['status'] as String? ?? '',
      vCode: json['v_code'] as String? ?? '',
    );
  }

  // Convert the User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'first_name': first_name,
      'last_name': last_name,
      'phoneNumber': phoneNumber,
      'email': email,
      'userPhoto': userPhoto,
      'role': role,
      'userStatus': userStatus,
      'message': message,
      'info': info,
      'created_at': created_at,
      'status': status,
      // Include other keys here if needed
    };
  }

  // Factory constructor to create a User object from a JSON map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      first_name: map['first_name'] ?? '',
      last_name: map['last_name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      userPhoto: map['userPhoto'] ?? '',
      role: map['role'] ?? '',
      userStatus: map['userStatus'] ?? '',
      message: map['message'] ?? '',
      info: map['info'] ?? '',
      created_at: map['created_at'] ?? '',
      status: map['status'] ?? '',
      vCode: map['v_code'] ?? '',
    );
  }
}
