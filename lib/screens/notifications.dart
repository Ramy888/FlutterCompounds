import 'package:connectivity/connectivity.dart%20%20';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';
import '../Models/notification_model.dart';
import '../localization/language_constants.dart';
import '../widgets/Loading_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

//notifications page
class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String TAG = "Notifications";
  bool isGettingData = false;
  bool isLogged = false;
  String userId = "";
  String email = "";
  String role = "";

  List<OneNotification> notificationList = [];

  Future<void> getNotifications() async {
    getUserDataFromPreferences();

    String adsNewsUrl =
        "https://sourcezone2.com/public/00.AccessControl/get_notifications.php";

    setState(() {
      isGettingData = true;
    });

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      try {
        final response = await http.post(
          Uri.parse(adsNewsUrl),
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
            isGettingData = false;
          });

          dev.log(TAG, name: "getNotifications", error: response.body);

          NotificationModel notif = NotificationModel.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);
          if (notif.status == "OK") {
            notificationList.clear();

            for (int i = 0; i < notif.notifList.length; i++) {
              //show notification to current user
              if (notif.notifList[i].notificationType == "toUser" &&
                  notif.notifList[i].notificationTo == "29") {
                notificationList.add(notif.notifList[i]);
                dev.log(TAG,
                    name: "getNotifications List", error: notif.notifList[i]);
              }
            }
          } else {
            dev.log(TAG, error: "getNotifications API status Error: $response");
            showToast(notif.info);
          }
        } else {
          dev.log(TAG, error: "getNotifications API request Error: $response");
          showToast(NotificationModel.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .info);

          setState(() {
            isGettingData = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "getNotifications ExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isGettingData = false;
        });
      }
    } else {
      showToast(getTranslated(context, "noInternetConnection")!);
      setState(() {
        isGettingData = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          // Add background image here
          image: DecorationImage(
            image: AssetImage('assets/splash/white_bg.png'),
            // Replace with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: isGettingData
            ? Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 4.0,
                ),
              )
            : ListView(
                children: [
                  Container(
                    //News list view
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                    // Make height fill the remaining
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: notificationList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _showNewsBottomSheet(
                                context,
                                notificationList[index].title,
                                notificationList[index].body,
                                notificationList[index].photoUrl);
                          },
                          child: Card(
                            margin: EdgeInsets.only(bottom: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Adjust the radius as needed
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image on the left
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    width: 100.0, // Adjust the width as needed
                                    height: 100.0, // Adjust the height as needed
                                    child: Image.network(
                                      notificationList[index].photoUrl,
                                      colorBlendMode: BlendMode.darken,
                                      fit: BoxFit.fill,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.black),
                                              strokeWidth: 2.0,
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Image.asset(
                                          'assets/appicon/appIcon.png',
                                          fit: BoxFit.fill,
                                          height: 100.0,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Title and Description on the right
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notificationList[index].title,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            // Make font bold
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                                          ),
                                        ),
                                        Text(
                                          // Description limited text ellipsized
                                          notificationList[index].body,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.black,
                                            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  //show news bottom sheet
  void _showNewsBottomSheet(
      BuildContext context, String title, String body, String photoUrl) {
    showModalBottomSheet(
        showDragHandle: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                        ),
                        child: Image.network(
                          photoUrl,
                          colorBlendMode: BlendMode.darken,
                          fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                  strokeWidth: 2.0,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/appicon/appIcon.png',
                              fit: BoxFit.fill,
                              height: 100.0,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(body,
                      style: TextStyle(
                        fontSize: 13.0,
                        fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      )
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 2,
                      ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
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

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }

    return input[0].toUpperCase() + input.substring(1);
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
    getNotifications();
    super.initState();
  }
}
