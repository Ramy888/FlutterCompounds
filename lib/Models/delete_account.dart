class DeleteAccount {
  final String message;
  final String status;

  DeleteAccount({required this.message, required this.status});

  factory DeleteAccount.fromJson(Map<String, dynamic> json) {
    return DeleteAccount(
      message: json['message'] as String,
      status: json['status'] as String,
    );
  }
}