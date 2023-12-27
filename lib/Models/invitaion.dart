class Invitation {
  final String status;
  final String info;
  final String message;
  final List<OneInvitation> invitationList;

  Invitation({
    required this.status,
    required this.info,
    required this.message,
    required this.invitationList,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    // Check if 'invitationList' key exists in the JSON map
    final List<dynamic>? list = json['data'] as List<dynamic>?;

    // If the key exists and the list is not null, parse it; otherwise, set an empty list
    List<OneInvitation> ivList = list != null
        ? list.map((i) => OneInvitation.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return Invitation(
      status: json['status'] as String,
      info: json['info'] as String,
      message: json['message'] as String,
      invitationList: ivList,
    );
  }
}

class OneInvitation {
  final String invitationId;
  final String? code;
  final String invitationType;
  final String? from;
  final String? to;
   String invitationStatus;
  final String? guestName;
  final String? description;
  final String created_at;
  final String creatorId;
  final String? guest_ride;
  final String? qrcode;

  OneInvitation({
    required this.invitationId,
    this.code,
    required this.invitationType,
     this.from,
     this.to,
    required this.created_at,
    required this.invitationStatus,
    this.guestName,
    this.description,
    this.guest_ride,
    this.qrcode,
    required this.creatorId,
  });

  factory OneInvitation.fromJson(Map<String, dynamic> json) {
    return OneInvitation(
      invitationId: json['invitationId'] as String,
      creatorId: json['invitationOwnerId'] as String,
      code: json['code'] as String?,
      invitationType: json['codeType'] as String,
      from: json['from'] as String?,
      to: json['to'] as String?,
      created_at: json['generated_at'] as String,
      invitationStatus: json['codeStatus'] as String,
      guestName: json['guest_name'] as String?,
      description: json['description'] as String?,
      guest_ride: json['guest_ride'] as String?,
      qrcode: json['qrcode'] as String?,
    );
  }
}
