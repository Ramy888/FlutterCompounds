class UserInfo {
  final String status;
  final String message;
  final String info;
  final UserData? data;
  final RelatedData? relatedData;

  UserInfo({
    required this.status,
    required this.message,
    required this.info,
    required this.data,
    required this.relatedData,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      status: json['status'] as String,
      message: json['message'] as String,
      info: json['info'] as String,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      relatedData:
      json['relatedData'] != null ? RelatedData.fromJson(json['relatedData']) : null,
    );
  }
}

class UserData {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userPhoto;
  final String project;
  final String unit;

  UserData({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userPhoto,
    required this.project,
    required this.unit,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      userPhoto: json['userPhoto'] as String,
      project: json['project'] as String,
      unit: json['unit'] as String,
    );
  }
}

class RelatedData {
  final List<MemberData>? family;
  final List<MemberData>? renter;

  RelatedData({
    required this.family,
    required this.renter,
  });

  factory RelatedData.fromJson(Map<String, dynamic> json) {
    return RelatedData(
      family: (json['family'] as List?)
          ?.map((familyJson) => MemberData.fromJson(familyJson as Map<String, dynamic>))
          .toList(),
      renter: (json['renter'] as List?)
          ?.map((renterJson) => MemberData.fromJson(renterJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

// class FamilyData {
//   final String source;
//   final String role;
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String phoneNumber;
//   final String userPhoto;
//   final String project;
//   final String unit;
//   final String userStatus;
//
//   FamilyData({
//     required this.source,
//     required this.role,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phoneNumber,
//     required this.userPhoto,
//     required this.project,
//     required this.unit,
//     required this.userStatus,
//   });
//
//   factory FamilyData.fromJson(Map<String, dynamic> json) {
//     return FamilyData(
//       source: json['source'] as String,
//       role: json['role'] as String,
//       firstName: json['first_name'] as String,
//       lastName: json['last_name'] as String,
//       email: json['email'] as String,
//       phoneNumber: json['phoneNumber'] as String,
//       userPhoto: json['userPhoto'] as String,
//       project: json['project'] as String,
//       unit: json['unit'] as String,
//       userStatus: json['userStatus'] as String,
//     );
//   }
// }
//
// class RenterData {
//   final String source;
//   final String role;
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String phoneNumber;
//   final String userPhoto;
//   final String project;
//   final String unit;
//   final String userStatus;
//
//   RenterData({
//     required this.source,
//     required this.role,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phoneNumber,
//     required this.userPhoto,
//     required this.project,
//     required this.unit,
//     required this.userStatus,
//   });
//
//   factory RenterData.fromJson(Map<String, dynamic> json) {
//     return RenterData(
//       source: json['source'] as String,
//       role: json['role'] as String,
//       firstName: json['first_name'] as String,
//       lastName: json['last_name'] as String,
//       email: json['email'] as String,
//       phoneNumber: json['phoneNumber'] as String,
//       userPhoto: json['userPhoto'] as String,
//       project: json['project'] as String,
//       unit: json['unit'] as String,
//       userStatus: json['userStatus'] as String,
//     );
//   }
// }

class MemberData {
  final String source;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userPhoto;
  final String project;
  final String unit;
  final String userStatus;

  MemberData({
    required this.source,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userPhoto,
    required this.project,
    required this.unit,
    required this.userStatus,
  });

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      source: json['source'] as String,
      role: json['role'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      userPhoto: json['userPhoto'] as String,
      project: json['project'] as String,
      unit: json['unit'] as String,
      userStatus: json['userstatus'] as String,
    );
  }
}
