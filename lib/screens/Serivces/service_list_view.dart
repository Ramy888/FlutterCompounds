import 'package:flutter/material.dart';
import '../../app_theme.dart';

class ServiceListView extends StatelessWidget {
  const ServiceListView({
    Key? key,
    this.serviceData,
    this.animationController,
    this.animation,
    this.callback,
  }) : super(key: key);

  final VoidCallback? callback;
  final ServiceData? serviceData; // Assuming you have a ServiceData model
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: callback,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        offset: const Offset(4, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          serviceData!.icon, // Assuming your ServiceData has an icon field
                          size: 60.0,
                          color: AppTheme.nearlyBlue,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            serviceData!.serviceName, // Assuming your ServiceData has a serviceName field
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Assuming you have a ServiceData model class
class ServiceData {
  final IconData icon;
  final String serviceName;

  ServiceData({required this.icon, required this.serviceName});

  static List <ServiceData> servicesList =<ServiceData> [
    ServiceData(
      icon: Icons.home,
      serviceName: 'Home',
    ),
    ServiceData(
      icon: Icons.work,
      serviceName: 'Work',
    ),
    ServiceData(
      icon: Icons.shopping_cart,
      serviceName: 'Shopping',
    ),
    ServiceData(
      icon: Icons.local_hospital,
      serviceName: 'Health',
    ),
    ServiceData(
      icon: Icons.local_offer,
      serviceName: 'Offers',
    ),
    ServiceData(
      icon: Icons.local_taxi,
      serviceName: 'Taxi',
    ),
    ServiceData(
      icon: Icons.local_laundry_service,
      serviceName: 'Laundry',
    ),
    ServiceData(
      icon: Icons.local_hotel,
      serviceName: 'Hotel',
    ),
    ServiceData(
      icon: Icons.local_gas_station,
      serviceName: 'Gas',
    ),
    ServiceData(
      icon: Icons.local_atm,
      serviceName: 'ATM',
    ),
    ServiceData(
      icon: Icons.local_pharmacy,
      serviceName: 'Pharmacy',
    ),
    ServiceData(
      icon: Icons.local_parking,
      serviceName: 'Parking',
    ),
    ServiceData(
      icon: Icons.local_post_office,
      serviceName: 'Post Office',
    ),
    ServiceData(
      icon: Icons.local_shipping,
      serviceName: 'Shipping',
    ),
    ServiceData(
      icon: Icons.local_printshop,
      serviceName: 'Print Shop',
    ),
    ServiceData(
      icon: Icons.local_florist,
      serviceName: 'Florist',
    ),
    ServiceData(
      icon: Icons.local_grocery_store,
      serviceName: 'Grocery',
    ),
    ServiceData(
      icon: Icons.local_dining,
      serviceName: 'Dining',
    ),
    ServiceData(
      icon: Icons.local_cafe,
      serviceName: 'Cafe',
    ),
    ServiceData(
      icon: Icons.local_bar,
      serviceName: 'Bar',
    ),
    ServiceData(
      icon: Icons.local_library,
      serviceName: 'Library',
    ),
    ServiceData(
      icon: Icons.local_movies,
      serviceName: 'Movies',
    ),
    ServiceData(
      icon: Icons.local_activity,
      serviceName: 'Activity',
    ),
    ServiceData(
      icon: Icons.local_airport,
      serviceName: 'Airport',
    ),
  ];

  static List<ServiceData> getServicesList() {
    return servicesList;
  }

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      icon: json['icon'],
      serviceName: json['serviceName'],
    );
  }
}
