import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/User.dart';
import '../../Models/create_permission.dart';
import '../../Models/invitation_update.dart';
import '../../widgets/Loading_dialog.dart';

class GatePermission extends StatefulWidget {
  static const String routeName = 'main/gate'; // Define a route name

  @override
  _GatePermissionState createState() => _GatePermissionState();
}

class _GatePermissionState extends State<GatePermission> {
  String TAG = 'GatePermission';
  String desc = "";
  String descError = "";
  String guestName = "";
  String guestNameError = "";
  String dateFrom = "";
  String fromError = "";
  String dateTo = "";
  String toError = "";
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  final DateTime now = DateTime.now();

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? now,
      //prevent choosing previous that today dates
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime day) {
        // Allow selecting dates starting from today
        return day.isAfter(now.subtract(Duration(days: 1)));
      },
    );

    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
        fromDateController.text = formatDate(picked);
        dateFrom = formatDate(picked);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: DateTime(fromDate!.year, fromDate!.month, fromDate!.day),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime day) {
        // Allow selecting dates starting from today
        return day.isAfter(fromDate!.subtract(Duration(days: 1)));
      },
    );

    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
        toDateController.text = formatDate(picked);
        dateTo = formatDate(picked);
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslated(context, "newGatePerm")!,
          style: TextStyle(
            color: Colors.black,
            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
          ),
        ),
      ),
      // Body is 2 textforminput and 1 button
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
                      labelText: getTranslated(context, "guestName"),
                      hintText: getTranslated(context, "enterGuestName"),
                      labelStyle:
                           TextStyle(color: Colors.black, fontSize: 14.0,
                             fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                           ),
                      hintStyle:
                           TextStyle(color: Colors.grey, fontSize: 13.0,
                             fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                           ),
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
                          getTranslated(context, "notValidName")!; // Customize the error message
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
                  style:  TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
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
                      labelText: getTranslated(context, "desc"),
                      hintText: getTranslated(context, "enterDesc"),
                      labelStyle:  TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      ),
                      hintStyle:
                           TextStyle(color: Colors.grey, fontSize: 13.0,
                             fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                           ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                             BorderSide(color: Colors.black, width: 1.0),
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
                          getTranslated(context, "notValidDesc")!; // Customize the error message
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
                  style:  TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () => _selectFromDate(context),
                        splashColor: Colors.black,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            // Add background image here
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.black,
                              // Add your desired border color
                              width: 1.0, // Add your desired border width
                            ),
                            color: Colors.grey[200],
                          ),
                          child: TextFormField(
                            controller: fromDateController,
                            decoration: InputDecoration(
                              labelText: getTranslated(context, "visitFrom"),
                              hintText: getTranslated(context, "enterDateFrom"),
                              hintStyle: TextStyle(color: Colors.black,
                                fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                              ),
                              labelStyle: TextStyle(color: Colors.black,
                                fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                              ),
                            ),
                            enabled: false,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                // Input field to show error
                                setState(() {
                                  fromError =
                                  getTranslated(context, "notValidDate")!; // Customize the error message
                                });
                              } else {
                                setState(() {
                                  fromError = "";
                                  //dateFrom = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Text(
                        fromError,
                        style:  TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
                          fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      InkWell(
                        onTap: () => _selectToDate(context),
                        splashColor: Colors.black,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            // Add background image here
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.black,
                              // Add your desired border color
                              width: 1.0, // Add your desired border width
                            ),
                            color: Colors.grey[200],
                          ),
                          child: TextFormField(
                            controller: toDateController,
                            decoration: InputDecoration(
                              labelText: getTranslated(context, "visitTo"),
                              hintText: getTranslated(context, "enterDateTo"),
                              hintStyle: TextStyle(color: Colors.black,
                                fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                              ),
                              labelStyle: TextStyle(color: Colors.black,
                                fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                              ),
                            ),
                            enabled: false,
                            onChanged: (value) {
                              // Add your onChanged logic here
                              if (value.isEmpty) {
                                // Input field to show error
                                setState(() {
                                  toError =
                                  getTranslated(context, "notValidDate")!; // Customize the error message
                                });
                              } else {
                                setState(() {
                                  toError = "";
                                  //dateTo = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Text(
                        toError,
                        style:  TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
                          fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                        ),
                      ),
                    ],
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
                        guestNameError = getTranslated(context, "notValidName")!;
                      });
                    } else if (desc.isEmpty) {
                      setState(() {
                        descError = getTranslated(context, "notValidDesc")!;
                      });
                    } else if (dateFrom.isEmpty) {
                      setState(() {
                        fromError = getTranslated(context, "notValidDate")!;
                      });
                    } else if (dateTo.isEmpty) {
                      setState(() {
                        toError = getTranslated(context, "notValidDate")!;
                      });
                    } else
                      createGatePermission();
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
                          fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
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

  Future<void> createGatePermission() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/create_gate_permission.php";

      LoadingDialog.show(context);

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
            'guest_name': guestName,
            'description': desc,
            'date_from': dateFrom,
            'date_to': dateTo,
          },
        );

        if (response.statusCode == 200) {
          dev.log(TAG, name: "createGatePermission: ", error: response.body);

          Gate gateResponse =
              Gate.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

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
          showToast(
              Gate.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
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
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }
}
