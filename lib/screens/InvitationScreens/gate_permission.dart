import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
        title: Text('New Gate Permission'),
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
                              labelText: 'Visit From',
                              hintText: 'Select Date From',
                              hintStyle: TextStyle(color: Colors.black),
                              // labelStyle: TextStyle(color: Colors.black),
                            ),
                            enabled: false,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                // Input field to show error
                                setState(() {
                                  fromError =
                                      'Must not be Empty'; // Customize the error message
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
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
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
                              labelText: 'Visit To',
                              hintText: 'Select Date To',
                            ),
                            enabled: false,
                            onChanged: (value) {
                              // Add your onChanged logic here
                              if (value.isEmpty) {
                                // Input field to show error
                                setState(() {
                                  toError =
                                      'Must not be Empty'; // Customize the error message
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
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
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
                        guestNameError = 'Must not be Empty';
                      });
                    } else if (desc.isEmpty) {
                      setState(() {
                        descError = 'Must not be Empty';
                      });
                    } else if (dateFrom.isEmpty) {
                      setState(() {
                        fromError = 'Must not be Empty';
                      });
                    } else if (dateTo.isEmpty) {
                      setState(() {
                        toError = 'Must not be Empty';
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
            'userId': '29',
            'role': 'owner',
            'language': '',
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

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }
}
