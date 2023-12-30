import 'package:flutter/material.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';

import '../Models/User.dart';
import '../widgets/FillableOutlinedButton.dart';

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
  late List<bool> buttonStates;
  String _selectedButton = 'Tenant';
  List servicesList = [];

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
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });

          dev.log(TAG, name: "getQrCode", error: response.body);

          // QrCode qrcodeResponse = QrCode.fromJson(
          //     jsonDecode(response.body) as Map<String, dynamic>);

          // if (qrcodeResponse.status == "OK") {
          //   //show image from base64 string QrCode.qrCode
          //   qrCode = qrcodeResponse.data.qrcode;
          //   userName = qrcodeResponse.data.firstName +
          //       " " +
          //       qrcodeResponse.data.lastName;
          //   userUnit = qrcodeResponse.data.unit;
          // } else {
          //   showToast(qrcodeResponse.info);
          // }
        } else {
          dev.log(TAG, error: "API sent Error: $response");
          // showToast(
          //     QrCode.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
          //         .info);

          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "ExceptionError : $e");
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
                  SingleChildScrollView(
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
                  Flexible(
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
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(),
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
                // _showBottomSheet(context);
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
}
