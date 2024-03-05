class Service {
  String? status, message, info;
  List<OneService>? services; // Make services nullable

  Service({
    required this.services,
     this.status,
     this.message,
     this.info,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    var servicesList = json['services'] as List<dynamic>?; // Make servicesList nullable
    // List<OneService>? services;
    //
    // if (servicesList != null) {
    //   services = servicesList.map((serviceJson) {
    //     return OneService.fromJson(serviceJson as Map<String, dynamic>);
    //   }).toList();
    // }

    List<OneService> services = servicesList != null
        ? servicesList.map((i) => OneService.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return Service(
      status: json['status'] as String,
      message: json['message'] as String,
      info: json['info'] as String,
      services: services,
    );
  }
}

class OneService {
  String serviceId,
      serviceTitle,
      serviceDescription,
      serviceDateTime,
      serviceStatus,
      servicePrice;

  OneService({
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceDescription,
    required this.serviceDateTime,
    required this.serviceStatus,
    required this.servicePrice,
  });

  factory OneService.fromJson(Map<String, dynamic> json) {
    return OneService(
      serviceId: json['serviceId'] as String,
      serviceTitle: json['serviceTitle'] as String,
      serviceDescription: json['serviceDescription'] as String,
      serviceDateTime: json['serviceDateTime'] as String,
      serviceStatus: json['serviceStatus'] as String,
      servicePrice: json['servicePrice'] as String,
    );
  }
}
