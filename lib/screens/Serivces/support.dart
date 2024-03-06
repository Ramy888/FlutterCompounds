import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pyramids_developments/screens/Serivces/service_list_view.dart';
import 'package:pyramids_developments/screens/ServiceDetails/new_request.dart';
import 'package:pyramids_developments/screens/ServiceDetails/request_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';

import '../../Models/User.dart';
import '../../Models/model_service.dart';
import '../../app_theme.dart';
import '../../widgets/FillableOutlinedButton.dart';
import '../../widgets/ripple_effect.dart';

class Support extends StatefulWidget {
  const Support({super.key, required this.title});

  final String title;
  static const String routeName = 'support'; // Define a route name

  @override
  State<Support> createState() => SupportState();
}

class SupportState extends State<Support> with TickerProviderStateMixin {
  String TAG = "Support";
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;
  bool isLoading = false;
  List<bool> buttonStates = [true, false];
  String _selectedButton = 'pending';

  AnimationController? animationController;
  List<ServiceData> servicesList = ServiceData.servicesList;
  TextEditingController searchController = TextEditingController();
  List<ServiceData> filteredServicesList = ServiceData.servicesList;

  List<OneService> requestsList = <OneService>[
    OneService(
      serviceId: "1",
      serviceTitle: "Plumbing",
      serviceDescription: "problem in the road to building number 243",
      serviceDateTime: "12 Dec",
      serviceStatus: "pending",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "2",
      serviceTitle: "Carpenter",
      serviceDescription: "Wembley, London",
      serviceDateTime: "12 Dec",
      serviceStatus: "resolved",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "3",
      serviceTitle: "Electricity",
      serviceDescription: "problem in the corredoor of building number 243",
      serviceDateTime: "12 Dec",
      serviceStatus: "pending",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "4",
      serviceTitle: "Cleaning",
      serviceDescription: "Wembley, London",
      serviceDateTime: "12 Dec",
      serviceStatus: "resolved",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "5",
      serviceTitle: "Internet",
      serviceDescription: "problem in the road to building number 243",
      serviceDateTime: "12 Dec",
      serviceStatus: "pending",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "6",
      serviceTitle: "TV",
      serviceDescription: "Wembley, London",
      serviceDateTime: "12 Dec",
      serviceStatus: "resolved",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "7",
      serviceTitle: "Gas",
      serviceDescription: "problem with water heater",
      serviceDateTime: "12 Dec",
      serviceStatus: "pending",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "8",
      serviceTitle: "Electricity",
      serviceDescription: "Wembley, London",
      serviceDateTime: "12 Dec",
      serviceStatus: "resolved",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "9",
      serviceTitle: "Plumbing",
      serviceDescription: "problem in the road to building number 243",
      serviceDateTime: "12 Dec",
      serviceStatus: "pending",
      servicePrice: '100',
    ),
    OneService(
      serviceId: "10",
      serviceTitle: "Car",
      serviceDescription: "Wembley, London",
      serviceDateTime: "12 Dec",
      serviceStatus: "resolved",
      servicePrice: '100',
    ),
  ];

  List<OneService> filteredRequests = [];

  void _fillFilteredRequestsList() {
    filteredRequests = requestsList
        .where((element) => element.serviceStatus == "pending")
        .toList();
  }

  // Future<void> getServices(String selected) async {
  //   getUserDataFromPreferences();
  //
  //   bool isConnected = await checkInternetConnection();
  //   if (isConnected) {
  //     String getUnitsUrl =
  //         "https://sourcezone2.com/public/00.AccessControl/user_identity.php";
  //
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     try {
  //       final response = await http.post(
  //         Uri.parse(getUnitsUrl),
  //         headers: <String, String>{
  //           // 'Content-Type': 'application/json; charset=UTF-8',
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: <String, String>{
  //           'userId': userId,
  //           'role': role,
  //           'language': _getCurrentLang(),
  //         },
  //       );
  //
  //       if (response.statusCode == 200) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //
  //         dev.log(TAG, name: "getServices:: ", error: response.body);
  //
  //         Service services = Service.fromJson(
  //             jsonDecode(response.body) as Map<String, dynamic>);
  //
  //         if (services.status == "OK") {
  //           setState(() {
  //             servicesList = services.services!;
  //           });
  //         } else {
  //           showToast(services.info);
  //         }
  //       } else {
  //         dev.log(TAG, error: "getServices API status Error: $response");
  //         showToast(Service.fromJson(
  //                 jsonDecode(response.body) as Map<String, dynamic>)
  //             .info);
  //
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     } catch (e) {
  //       dev.log(TAG, error: "getServices ExceptionError : $e");
  //       showToast(getTranslated(context, "somethingWrong")!);
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } else {
  //     //no internet connection
  //     setState(() {
  //       isLoading = false;
  //     });
  //     showToast(getTranslated(context, "noInternetConnection")!);
  //   }
  // }

  Future<void> _refreshData() async {
    int bt_id = buttonStates.indexOf(true);
    if (bt_id == 0) {
      _selectedButton = "pending";
      filteredRequests = requestsList
          .where((element) => element.serviceStatus == "pending")
          .toList();
    } else if (bt_id == 1) {
      _selectedButton = "resolved";
      filteredRequests = requestsList
          .where((element) => element.serviceStatus == "resolved")
          .toList();
    }

    // getServices(_selectedButton);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Theme(
        data: AppTheme.buildLightTheme(),
        child: Container(
          margin: EdgeInsets.only(top: 65),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.nearlyDarkBlue,
              bottom: TabBar(
                tabs: [
                  Tab(text: getTranslated(context, "newService")),
                  Tab(text: getTranslated(context, "myRequests")),
                ],
              ),
              title: Text('Services'),
            ),
            body: TabBarView(
              children: [
                // Services Tab
                GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    // 3 items per row
                    crossAxisSpacing: 8.0,
                    // Space between the items horizontally
                    mainAxisSpacing: 8.0, // Space between the items vertically
                  ),
                  itemCount: servicesList.length, // Fixed number of squares
                  itemBuilder: (context, index) {
                    final int count =
                        servicesList.length > 10 ? 10 : servicesList.length;

                    animationController = AnimationController(
                      duration: const Duration(milliseconds: 1000),
                      vsync:
                          this, // Assuming this is a StatefulWidget that includes the TickerProviderStateMixin
                    );
                    animationController?.forward();

                    final Animation<double> animation =
                        Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animationController!,
                        curve: Curves.easeInOut,
                      ),
                    );
                    return ServiceListView(
                      callback: () {
                        //path serviceName to newRequest
                        Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => NewRequest(
                              // Assuming you have a NewRequest widget
                              serviceName: servicesList[index].serviceName,
                              onNewRequestAdded: (newRequest) {
                                setState(() {
                                  filteredRequests.add(newRequest);
                                });
                              },
                              //to add to list after last index
                              listIndex: filteredRequests.length,
                            ),
                          ),
                        );
                      },
                      animation: animation,
                      serviceData: servicesList[index],
                      animationController: animationController!,
                    );
                  },
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                            strokeWidth: 4.0,
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(height: 10),
                            Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FillableOutlinedButton(
                                      text: getTranslated(context, "pending")!,
                                      isActive: buttonStates[0],
                                      onPressed: () async {
                                        _updateButtonState(0);
                                      },
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FillableOutlinedButton(
                                      text: getTranslated(context, "resolved")!,
                                      isActive: buttonStates[1],
                                      onPressed: () {
                                        _updateButtonState(1);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            getSearchBarUI(),
                            //my requests tab
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _refreshData,
                                child: filteredRequests.isEmpty
                                    ? Center(
                                        child: Text(
                                          getTranslated(context, "noRequests")!,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontFamily:
                                                _getCurrentLang() == "ar"
                                                    ? 'arFont'
                                                    : 'enBold',
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredRequests.length,
                                        itemBuilder: (context, index) {
                                          return _buildRequestListItem(
                                              context, index, _selectedButton);
                                        },
                                      ),
                              ),
                            )
                          ],
                        ),
                ),
              ],
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     Navigator.push<dynamic>(
            //       context,
            //       MaterialPageRoute<dynamic>(
            //         builder: (BuildContext context) => NewRequest(),
            //       ),
            //     );
            //   },
            //   // child: Icon(FontAwesomeIcons.chat),
            //   child: Icon(Icons.chat_bubble_outlined,
            //       size: 25, color: AppTheme.white),
            //   backgroundColor: AppTheme.nearlyBlue,
            // ),
          ),
        ),
      ),
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.buildLightTheme().backgroundColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(38.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 4, bottom: 4),
                  child: TextField(
                    onChanged: (String txt) {
                      setState(() {
                        filterServices(txt);
                      });
                    },
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    cursorColor: AppTheme.buildLightTheme().primaryColor,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search...',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString()
        .padLeft(2, '0')}-${date.year}";
  }

  Widget _buildRequestListItem(BuildContext context, int index, String status) {
    return InkWell(
      onTap: () {
        if (filteredRequests[index].serviceStatus == "resolved") {
          // showToast(getTranslated(context, "requestResolved")!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                getTranslated(context, "requestResolved")!,
                style: TextStyle(
                  fontFamily: _getCurrentLang() == "ar"
                      ? 'arFont'
                      : 'enBold',
                ),
              ),
            ),
          );
          return;
        }else
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => RequestDetails(
                requestId: filteredRequests[index].serviceId,
                serviceType: filteredRequests[index].serviceTitle,
                serviceDesc: filteredRequests[index].serviceDescription,
                // dateTime: formatDate(filteredRequests[index].serviceDateTime),
                dateTime: filteredRequests[index].serviceDateTime,
              ),
            ),
          );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                filteredRequests[index].serviceDateTime,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8), // Add some vertical spacing
            Text(
              filteredRequests[index].serviceTitle,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8), // Add some vertical spacing
            Text(
              filteredRequests[index].serviceDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12), // Add some vertical spacing before the status
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                filteredRequests[index].serviceStatus,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateButtonState(int index) {
    setState(() {
      buttonStates = List.generate(2, (i) => i == index);
      if (index == 0) {
        _selectedButton = "pending";
        filteredRequests = requestsList
            .where((element) => element.serviceStatus == "pending")
            .toList();
        dev.log(TAG,
            name: "updatebutton:: ", error: requestsList.length.toString());
      } else {
        _selectedButton = "resolved";
        filteredRequests = requestsList
            .where((element) => element.serviceStatus == "resolved")
            .toList();
      }
    });
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      // Toast duration (SHORT or LONG)
      gravity: ToastGravity.BOTTOM,
      // Toast gravity (TOP, CENTER, or BOTTOM)
      timeInSecForIosWeb: 1,
      // Duration in seconds for iOS and web
      backgroundColor: Colors.black,
      // Background color
      textColor: Colors.white,
      // Text color
      fontSize: 16.0, // Text font size
    );
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }

  Future<void> getUserDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');
    if (userString != null) {
      final userJson = jsonDecode(userString);
      userId = User.fromMap(userJson).userId;
      if (userId.isNotEmpty) {
        isLogged = prefs.getBool("isLogin")!;
        email = User.fromMap(userJson).email;
        role = User.fromMap(userJson).role;
      }
    }
  }

  void filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRequests = requestsList
            .where((element) => element.serviceStatus == _selectedButton)
            .toList();
        return;
      } else {
        if (_selectedButton == "pending") {
          filteredRequests = requestsList
              .where((service) =>
                  (service.serviceTitle
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      service.serviceDescription
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      service.serviceDateTime
                          .toLowerCase()
                          .contains(query.toLowerCase())) &&
                  service.serviceStatus.toLowerCase() ==
                      "pending") // Additional check for pending status
              .toList();
        } else {
          filteredRequests = requestsList
              .where((service) =>
                  (service.serviceTitle
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      service.serviceDescription
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      service.serviceDateTime
                          .toLowerCase()
                          .contains(query.toLowerCase())) &&
                  service.serviceStatus.toLowerCase() ==
                      "resolved") // Additional check for pending status
              .toList();
        }
      }
    });
  }

  @override
  void initState() {
    // getServices("pending");
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animationController?.forward();

    _fillFilteredRequestsList();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}
