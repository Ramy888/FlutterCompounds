class ModelFamilyRenter{

  final String code;
  final String info;
  final String status;
  final String message;
  final String generated_at;
  final String codeType;
   String? rentFrom;
   String? rentTo;

  ModelFamilyRenter({
    required this.code,
    required this.info,
    required this.status,
    required this.message,
    required this.generated_at,
    required this.codeType,
    this.rentFrom,
    this.rentTo,
  });

  factory ModelFamilyRenter.fromJson(Map<String, dynamic> json) {
    return ModelFamilyRenter(
      code: json['code'],
      info: json['info'],
      status: json['status'],
      message: json['message'],
      generated_at: json['generated_at'],
      codeType: json['codeType'],
      rentFrom: json['rentFrom'],
      rentTo: json['rentTo'],
    );
  }
}