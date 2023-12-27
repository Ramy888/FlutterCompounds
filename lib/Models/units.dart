
class Units{
  String status, message, info;
  List<OneUnit> units;

  Units({required this.units, required this.status, required this.message, required this.info});

  factory Units.fromJson(Map<String, dynamic> json) {

    var unitsList = json['units'] as List<dynamic>;
    List<OneUnit> units = unitsList.map((unitJson) {
      return OneUnit.fromJson(unitJson as Map<String, dynamic>);
    }).toList();

    return Units(
      status: json['status'] as String,
      message: json['message'] as String,
      info: json['info'] as String,
      units: units,

    );
  }
}

class OneUnit {
  String unitId, unit;

  OneUnit({required this.unitId, required this.unit});

  factory OneUnit.fromJson(Map<String, dynamic> json) {
    return OneUnit(
      unitId: json['unitId'] as String,
      unit: json['unit'] as String,
    );
  }
}