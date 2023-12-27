class Gate{
  final String status;
  final String message;
  final String info;

  Gate({
    required this.status,
    required this.message,
    required this.info,});

  factory Gate.fromJson(Map<String, dynamic> json) {
    return Gate(
      status: json['status'] as String,
      message: json['message'] as String,
      info: json['info'] as String,
    );
  }
}