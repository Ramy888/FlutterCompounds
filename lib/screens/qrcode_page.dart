import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/Models/qr_code.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key, required this.title});

  final String title;
  static const String routeName = 'qrcode'; // Define a route name

  @override
  State<QrCodePage> createState() => QrCodePageState();
}

class QrCodePageState extends State<QrCodePage> {
  String TAG = "QrCodePage";
  bool isGettingQrCode = true;
  String qrCode = "";
  String userName = "";
  String userUnit = "";
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;

  Future<void> getQrCodeForUser() async {
    getUserDataFromPreferences();

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/user_identity.php";

      setState(() {
        isGettingQrCode = true;
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
            isGettingQrCode = false;
          });

          dev.log(TAG, name: "getQrCode", error: response.body);

          QrCode qrcodeResponse = QrCode.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (qrcodeResponse.status == "OK") {
            //show image from base64 string QrCode.qrCode
            qrCode = qrcodeResponse.data.qrcode;
            userName = qrcodeResponse.data.firstName +
                " " +
                qrcodeResponse.data.lastName;
            userUnit = qrcodeResponse.data.unit;
          } else {
            showToast(qrcodeResponse.info);
          }
        } else {
          dev.log(TAG, error: "API sent Error: $response");
          showToast(
              QrCode.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
                  .info);

          setState(() {
            isGettingQrCode = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "ExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isGettingQrCode = false;
        });
      }
    } else {
      //no internet connection
      setState(() {
        isGettingQrCode = false;
      });
      showToast(getTranslated(context, "noInternetConnection")!);
    }
  }

  Future<void> _refreshData() async {
    // Implement your refresh logic here
    getQrCodeForUser();
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

  Future<void> preventScreenshots(bool prevent) async {
    const platform = MethodChannel('no_snaps_allowed');

    try {
      await platform.invokeMethod('preventScreenshots', {'prevent': prevent});
    } catch (e) {
      print('Error invoking preventScreenshots method: $e');
    }
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 65),
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/splash/white_bg.png'),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: isGettingQrCode
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 4.0,
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshData,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        // Image.asset(
                        //   "assets/appicon/appIcon.png",
                        //   width: 100,
                        //   height: 100,
                        // ),
                        // SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                fontFamily: _getCurrentLang() == "ar"
                                    ? 'arFont'
                                    : 'enBold',
                              ),
                            ),
                            SizedBox(width: 80),
                            Text(
                              userUnit,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: _getCurrentLang() == "ar"
                                    ? 'arFont'
                                    : 'enBold',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 100),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: qrCode.isEmpty
                              ? Center(
                                  child: Text(
                                  getTranslated(context, "noQrCode")!,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: _getCurrentLang() == "ar"
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                ))
                              : Center(
                                  child: Image.memory(
                                    base64Decode(qrCode),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
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

  @override
  void initState() {
    preventScreenshots(true);
    getQrCodeForUser();
    super.initState();
  }

  // remove Prevent screenshots when this widget is not active
  @override
  void dispose() {
    preventScreenshots(false);
    super.dispose();
  }
}
