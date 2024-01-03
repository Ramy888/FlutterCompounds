import 'package:flutter/material.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pyramids_developments/screens/ServiceDetails/new_request.dart';
import 'package:pyramids_developments/screens/ServiceDetails/request_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';

import '../Models/User.dart';
import '../Models/model_service.dart';
import '../widgets/FillableOutlinedButton.dart';
import '../widgets/ripple_effect.dart';

class Support extends StatefulWidget {
  const Support({super.key, required this.title});

  final String title;
  static const String routeName = 'support'; // Define a route name

  @override
  State<Support> createState() => SupportState();
}

class SupportState extends State<Support> {
  String TAG = "Support";
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;
  bool isLoading = false;
  List<bool> buttonStates = [true, false];
  String _selectedButton = 'pending';

  TextEditingController searchController = TextEditingController();
  List filteredServicesList = [];

  List servicesList = [
    {
      "serviceId": "1",
      "serviceTitle": "Service Title",
      "serviceDescription": "Service Description",
      "serviceDateTime": "Service Date Time",
      "serviceStatus": "Service Status",
      "servicePrice": "Service Price",
    },
    {
      "serviceId": "2",
      "serviceTitle": "Service Title",
      "serviceDescription": "Service Description",
      "serviceDateTime": "Service Date Time",
      "serviceStatus": "Service Status",
      "servicePrice": "Service Price",
    },
    {
      "serviceId": "3",
      "serviceTitle": "Service Title",
      "serviceDescription": "Service Description",
      "serviceDateTime": "Service Date Time",
      "serviceStatus": "Service Status",
      "servicePrice": "Service Price",
    },
    {
      "serviceId": "4",
      "serviceTitle": "Service Title",
      "serviceDescription": "Service Description",
      "serviceDateTime": "Service Date Time",
      "serviceStatus": "Service Status",
      "servicePrice": "Service Price",
    },
    {
      "serviceId": "5",
      "serviceTitle": "Service Title",
      "serviceDescription": "Service Description",
      "serviceDateTime": "Service Date Time",
      "serviceStatus": "Service Status",
      "servicePrice": "Service Price",
    },
    {
      "serviceId": "6",
      "serviceTitle": "Service Title",
      "serviceDescription": "Service Description",
      "serviceDateTime": "Service Date Time",
      "serviceStatus": "Service Status",
      "servicePrice": "Service Price",
    },
  ];

  Future<void> getServices(String selected) async {
    getUserDataFromPreferences();

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/user_identity.php";

      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(getUnitsUrl),
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'userId': userId,
            'role': role,
            'language': _getCurrentLang(),
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });

          dev.log(TAG, name: "getServices:: ", error: response.body);

          Service services = Service.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (services.status == "OK") {
            setState(() {
              // servicesList = services.services!;
            });
          } else {
            showToast(services.info);
          }
        } else {
          dev.log(TAG, error: "getServices API status Error: $response");
          showToast(Service.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .info);

          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "getServices ExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      //no internet connection
      setState(() {
        isLoading = false;
      });
      showToast(getTranslated(context, "noInternetConnection")!);
    }
  }

  Future<void> _refreshData() async {
    int bt_id = buttonStates.indexOf(true);
    if (bt_id == 0)
      _selectedButton = "pending";
    else if (bt_id == 1) _selectedButton = "resolved";

    getServices(_selectedButton);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 4.0,
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            filterServices(value);
                          },
                          decoration: InputDecoration(
                            hintText: getTranslated(context, "search")!,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: _getCurrentLang() == "ar"
                                  ? 'arFont'
                                  : 'enBold',
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: servicesList.length == 0
                            ? Center(
                                child: Text(
                                getTranslated(context, "noRequests")!,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: _getCurrentLang() == "ar"
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              ))
                            : ListView.builder(
                                itemCount: servicesList.length,
                                itemBuilder: (context, index) {
                                  return RippleInkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RequestDetails.routeName);
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
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  servicesList[index]
                                                      ["serviceTitle"],
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        _getCurrentLang() ==
                                                                "ar"
                                                            ? 'arFont'
                                                            : 'enBold',
                                                  ),
                                                ),
                                                Text(
                                                  servicesList[index]
                                                      ["serviceDateTime"],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        _getCurrentLang() ==
                                                                "ar"
                                                            ? 'arFont'
                                                            : 'enBold',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  servicesList[index]
                                                      ["serviceDescription"],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        _getCurrentLang() ==
                                                                "ar"
                                                            ? 'arFont'
                                                            : 'enBold',
                                                  ),
                                                ),
                                                Text(
                                                  servicesList[index]
                                                      ["serviceStatus"],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        _getCurrentLang() ==
                                                                "ar"
                                                            ? 'arFont'
                                                            : 'enBold',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 30.0, // Adjust the bottom position as needed
            right: 5.0,
            width: MediaQuery.of(context).size.width * 0.35,
            child: FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 10,
              onPressed: () {
                Navigator.pushNamed(context, NewRequest.routeName);
              },
              label: Text(
                getTranslated(context, "newRequest")!,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                ),
              ),
              icon: Icon(Icons.add_business_rounded, color: Colors.white),
              backgroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  void _updateButtonState(int index) {
    setState(() {
      buttonStates = List.generate(2, (i) => i == index);
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
      filteredServicesList = servicesList
          .where((service) =>
              service["serviceTitle"]
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              service["serviceDescription"]
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              service["serviceStatus"]
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              service["servicePrice"]
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    getServices("pending");
    filteredServicesList = servicesList;
    super.initState();
  }
}
