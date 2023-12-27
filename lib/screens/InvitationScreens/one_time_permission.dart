import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyramids_developments/Models/createOneTime.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../widgets/Loading_dialog.dart';

class OneTimePermission extends StatefulWidget {
  static const String routeName = 'main/oneTime'; // Define a route name

  @override
  _OneTimePermissionState createState() => _OneTimePermissionState();
}

class _OneTimePermissionState extends State<OneTimePermission> {
  String TAG = "OneTimePermission";
  String desc = "";
  String descError = "";
  String guestName = "";
  String guestNameError = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New One Time Permission'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            // Add background image here
            image: DecorationImage(
              image: AssetImage('assets/splash/white_bg.png'),
              // Replace with your image asset
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[200],
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Guest Name',
                      hintText: 'Enter Guest Name',
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 14.0),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 13.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onChanged: (value) {
                      // Add your onChanged logic here
                      if (value.isEmpty) {
                        // Input field to show error
                        setState(() {
                          guestNameError =
                              'Must not be Empty'; // Customize the error message
                        });
                      } else {
                        setState(() {
                          guestNameError = "";
                          guestName = value;
                        });
                      }
                    },
                  ),
                ),
                Text(
                  guestNameError,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[200],
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add Description',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 13.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    maxLines: 5,
                    onChanged: (value) {
                      // Add your onChanged logic here
                      if (value.isEmpty) {
                        // Input field to show error
                        setState(() {
                          descError =
                              'Must not be Empty'; // Customize the error message
                        });
                      } else {
                        setState(() {
                          descError = "";
                          desc = value;
                        });
                      }
                    },
                  ),
                ),
                Text(
                  descError,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                //button with background image
                InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    if (guestName.isEmpty) {
                      setState(() {
                        guestNameError = 'Must not be Empty';
                      });
                    } else if (desc.isEmpty) {
                      setState(() {
                        descError = 'Must not be Empty';
                      });
                    } else
                      createOneTimePermission();
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/button/button_bg.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, 'save')!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createOneTimePermission() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/create_one_time_pass.php";

      LoadingDialog.show(context);

      try {
        final response = await http.post(
          Uri.parse(getUnitsUrl),
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'userId': '29',
            'role': 'owner',
            'language': '',
            'guest_name': guestName,
            'guest_ride': desc,
          },
        );

        if (response.statusCode == 200) {
          dev.log(TAG, name: "createGatePermission: ", error: response.body);

          OneTime gateResponse = OneTime.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (gateResponse.status == "OK") {
            showToast(gateResponse.info);
            LoadingDialog.hide(context);
            Navigator.pop(context, true);
          } else {
            dev.log(TAG,
                error: "createGatePermission API statusError: $response");

            showToast(gateResponse.info);
            LoadingDialog.hide(context);
          }
        } else {
          dev.log(TAG, error: "createGatePermission API sent Error: $response");
          LoadingDialog.hide(context);
          showToast(OneTime.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .info);
        }
      } catch (e) {
        dev.log(TAG, error: "createGatePermission ExceptionError : $e");
        LoadingDialog.hide(context);
        showToast(getTranslated(context, "somethingWrong")!);
      }
    } else {
      //no internet connection
      LoadingDialog.hide(context);
      showToast(getTranslated(context, "noInternetConnection")!);
    }
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
}
