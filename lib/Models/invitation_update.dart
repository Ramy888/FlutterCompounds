class InvitationUpdate {
  final String invitationId;
  final String? code;
  final String invitationType;
  final String? from;
  final String? to;
   String invitationStatus = "";
  final String? guestName;
  final String? description;
  final String created_at;
  final String creatorId;
  final String? guest_ride;
  final String? qrcode;
  final String status;
  final String info;
  final String message;

  InvitationUpdate({
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
    required this.status,
    required this.info,
    required this.message,
  });

  factory InvitationUpdate.fromJson(Map<String, dynamic> json) {
    return InvitationUpdate(
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
      status: json['status'] as String,
      info: json['info'] as String,
      message: json['message'] as String,
    );
  }
}