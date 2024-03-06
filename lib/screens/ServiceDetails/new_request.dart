import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:pyramids_developments/widgets/Button/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/User.dart';
import '../../Models/model_service.dart';
import '../../app_theme.dart';
import '../../localization/language_constants.dart';
import '../../widgets/ripple_effect.dart';

class NewRequest extends StatefulWidget {
  final String serviceName;
  final int listIndex;
  final Function(OneService) onNewRequestAdded;


  const NewRequest({Key? key, required this.serviceName,
    required this.onNewRequestAdded, required this.listIndex}) : super(key: key);

  static const routeName = 'support/new-request';

  @override
  _NewRequestState createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  String selectedCategory = 'Plumbing';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController descriptionController = TextEditingController();
  String userId = "";
  bool isLogged = false;
  String email = "";
  String role = "";

  TextEditingController fromDateController = TextEditingController();
  DateTime? fromDate;
  final DateTime now = DateTime.now();
  String date = "";
  String dateError = "";


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
        setState(() {
          date = formatDate(picked);
        });
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString()
        .padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslated(context, "newRequest")!,
          style: TextStyle(
            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
          ),
        ),
      ),
      body: Theme(
        data: AppTheme.buildLightTheme(),
        child: Container(
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage('assets/splash/white_bg.png'),
            //   fit: BoxFit.cover,
            // ),
          ),
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Container(
                height: 50,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  widget.serviceName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  ),
                ),
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectFromDate(context),
                splashColor: Colors.black,
                child: Container(
                    height: 50,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      date.isEmpty ? getTranslated(context, "enterDate")! : date,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: date.isEmpty ? Colors.grey : Colors.black,
                        fontFamily: _getCurrentLang() == "ar"
                            ? 'arFont'
                            : 'enBold',
                      ),
                    ),
                  ),
              ),

                SizedBox(height: 16),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    controller: descriptionController,
                    maxLines: 10,
                    textAlign: TextAlign.center, // This line centers the text
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.grey[100],
                      hintText: getTranslated(context, "desc"),
                      hintStyle: TextStyle(
                        fontFamily:
                        _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                        color:  Colors.grey
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        descriptionController.text = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                GradientButton(
                  onPressed: () {
                    if (descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            getTranslated(context, "descEmpty")!,
                            style: TextStyle(
                              fontFamily: _getCurrentLang() == "ar"
                                  ? 'arFont'
                                  : 'enBold',
                            ),
                          ),
                        ),
                      );
                    } else if (date.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            getTranslated(context, "dateEmpty")!,
                            style: TextStyle(
                              fontFamily: _getCurrentLang() == "ar"
                                  ? 'arFont'
                                  : 'enBold',
                            ),
                          ),
                        ),
                      );
                    } else {
                      checkInternetConnection().then((value) {
                        if (value) {
                          getUserDataFromPreferences().then((value) {
                            if (isLogged) {
                              //update List<OneService> requestsList in support.dart file
                              OneService newRequest = OneService(
                                serviceTitle: widget.serviceName,
                                serviceDescription: descriptionController.text,
                                serviceDateTime: date,
                                serviceStatus: "pending",
                                serviceId: (widget.listIndex).toString(),
                                servicePrice: '90', // or whatever the initial status should be
                              );

// Call                         //the callback function
                              widget.onNewRequestAdded(newRequest);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    getTranslated(context, "loginFirst")!,
                                    style: TextStyle(
                                      fontFamily: _getCurrentLang() == "ar"
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                  ),
                                ),
                              );
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                getTranslated(context, "noInternet")!,
                                style: TextStyle(
                                  fontFamily: _getCurrentLang() == "ar"
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              ),
                            ),
                          );
                        }
                      });
                    }
                  },
                  text: getTranslated(context, 'submit')!,
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentLang() {
    return Localizations
        .localeOf(context)
        .languageCode;
  }

  Future<void> getUserDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');
    if (userString != null) {
      final userJson = jsonDecode(userString);
      userId = User
          .fromMap(userJson)
          .userId;
      if (userId.isNotEmpty) {
        isLogged = prefs.getBool("isLogin")!;
        email = User
            .fromMap(userJson)
            .email;
        role = User
            .fromMap(userJson)
            .role;
      }
    }
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    fromDateController.dispose();

    super.dispose();
  }
}
