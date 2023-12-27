class BasicModel{
  final String info;
  final String message;
  final String status;

  BasicModel ({
    required this.info,
    required this.message,
    required this.status,
  });

  factory BasicModel.fromJson(Map<String, dynamic> json) {
    return BasicModel(
      info: json['info'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
    );
  }

}