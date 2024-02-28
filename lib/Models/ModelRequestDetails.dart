import 'package:pyramids_developments/Models/Message.dart';

class ModelRequestDetails{
  String info;
  String message;
  String status;
  List<ModelMessage>? requestDetails;

  ModelRequestDetails({
    required this.info,
    required this.message,
    required this.status,
    required this.requestDetails,
  });


  factory ModelRequestDetails.fromJson(Map<String, dynamic> json) {
    var requestDetailsList = json['requestDetails'] as List<dynamic>?; // Make servicesList nullable

    List<ModelMessage> requestDetails = requestDetailsList != null
        ? requestDetailsList.map((i) => ModelMessage.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return ModelRequestDetails(
      info: json['info'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      requestDetails: requestDetails,
    );
  }
}