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
  List<Service> requestsList = [];
  List<Service> filteredRequests = [];


  // List servicesList = [
  //   {
  //     "serviceId": "1",
  //     "serviceTitle": "Service Title",
  //     "serviceDescription": "Service Description",
  //     "serviceDateTime": "Service Date Time",
  //     "serviceStatus": "Service Status",
  //     "servicePrice": "Service Price",
  //   },
  //   {
  //     "serviceId": "2",
  //     "serviceTitle": "Service Title",
  //     "serviceDescription": "Service Description",
  //     "serviceDateTime": "Service Date Time",
  //     "serviceStatus": "Service Status",
  //     "servicePrice": "Service Price",
  //   },
  //   {
  //     "serviceId": "3",
  //     "serviceTitle": "Service Title",
  //     "serviceDescription": "Service Description",
  //     "serviceDateTime": "Service Date Time",
  //     "serviceStatus": "Service Status",
  //     "servicePrice": "Service Price",
  //   },
  //   {
  //     "serviceId": "4",
  //     "serviceTitle": "Service Title",
  //     "serviceDescription": "Service Description",
  //     "serviceDateTime": "Service Date Time",
  //     "serviceStatus": "Service Status",
  //     "servicePrice": "Service Price",
  //   },
  //   {
  //     "serviceId": "5",
  //     "serviceTitle": "Service Title",
  //     "serviceDescription": "Service Description",
  //     "serviceDateTime": "Service Date Time",
  //     "serviceStatus": "Service Status",
  //     "servicePrice": "Service Price",
  //   },
  //   {
  //     "serviceId": "6",
  //     "serviceTitle": "Service Title",
  //     "serviceDescription": "Service Description",
  //     "serviceDateTime": "Service Date Time",
  //     "serviceStatus": "Service Status",
  //     "servicePrice": "Service Price",
  //   },
  // ];


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
    if (bt_id == 0)
      _selectedButton = "pending";
    else if (bt_id == 1) _selectedButton = "resolved";

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
                    final Animation<double> animation =
                        Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                                parent: animationController!,
                                curve: Interval((1 / count) * index, 1.0,
                                    curve: Curves.fastOutSlowIn)));
                    animationController?.forward();
                    return ServiceListView(
                      callback: () {
                        Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => NewRequest(),
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
                            getSearchBarUI(),
                            Expanded(
                              child: Container(
                                child: RefreshIndicator(
                                  onRefresh: _refreshData,
                                  child: servicesList.isEmpty
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
                                        ))
                                      : ListView.builder(
                                          itemCount: servicesList.length,
                                          itemBuilder: (context, index) {
                                            return RippleInkWell(
                                              onTap: () {
                                                //navigate to service details passing service id
                                                Navigator.pushNamed(context,
                                                    RequestDetails.routeName,
                                                    arguments:
                                                    requestsList[index].services![index].serviceId);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            requestsList[index]
                                                                .services![index]
                                                                .serviceTitle,
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  _getCurrentLang() ==
                                                                          "ar"
                                                                      ? 'arFont'
                                                                      : 'enBold',
                                                            ),
                                                          ),
                                                          Text(
                                                            requestsList[index]
                                                                .services![index]
                                                                .serviceDateTime,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.black,
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
                                                            requestsList[index]
                                                                .services![index]
                                                                .serviceDescription,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  _getCurrentLang() ==
                                                                          "ar"
                                                                      ? 'arFont'
                                                                      : 'enBold',
                                                            ),
                                                          ),
                                                          Text(
                                                            requestsList[index]
                                                                .services![index]
                                                                .serviceStatus,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
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
                        // servicesList = FeedListData.hotelList
                        //     .where((element) =>
                        // element.titleTxt
                        //     .toLowerCase()
                        //     .contains(txt.toLowerCase()) ||
                        //     element.postText
                        //         .toLowerCase()
                        //         .contains(txt.toLowerCase()))
                        //     .toList();
                      });
                    },
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    cursorColor: AppTheme.buildLightTheme().primaryColor,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Parking...',
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: AppTheme.buildLightTheme().primaryColor,
          //     borderRadius: const BorderRadius.all(
          //       Radius.circular(38.0),
          //     ),
          //     boxShadow: <BoxShadow>[
          //       BoxShadow(
          //           color: Colors.grey.withOpacity(0.4),
          //           offset: const Offset(0, 2),
          //           blurRadius: 8.0),
          //     ],
          //   ),
          //   child: Material(
          //     color: Colors.transparent,
          //     child: InkWell(
          //       borderRadius: const BorderRadius.all(
          //         Radius.circular(32.0),
          //       ),
          //       onTap: () {
          //         FocusScope.of(context).requestFocus(FocusNode());
          //       },
          //       child: Padding(
          //         padding: const EdgeInsets.all(16.0),
          //         child: Icon(FontAwesomeIcons.magnifyingGlass,
          //             size: 20,
          //             color: AppTheme.buildLightTheme().backgroundColor),
          //       ),
          //     ),
          //   ),
          // ),
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
      //loop through all services list to search for the query

    });
  }

  @override
  void initState() {
    // getServices("pending");
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}
