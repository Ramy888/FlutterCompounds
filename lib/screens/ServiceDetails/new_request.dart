import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/User.dart';
import '../../localization/language_constants.dart';
import '../../widgets/ripple_effect.dart';

class NewRequest extends StatefulWidget {
  const NewRequest({Key? key}) : super(key: key);

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
        date = formatDate(picked);
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
          getTranslated(context, "newRequest")!,
          style: TextStyle(
            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
          ),
        ),
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
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    dropdownColor: Colors.grey[200],
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    underline: Container(),
                    // This line removes the underline
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: <String>[
                      'Plumbing',
                      'Carpenter',
                      'Electrician',
                      'Others'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value)),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectFromDate(context),
                  splashColor: Colors.black,
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      color: Colors.grey[100],
                    ),
                    child: TextFormField(
                        controller: fromDateController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, "date"),
                          hintText: getTranslated(context, "enterDate"),
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                          ),
                        ),
                        enabled: false,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              dateError = getTranslated(context, "notValidDate")!;
                            });
                          } else {
                            setState(() {
                              dateError = "";
                            });
                          }
                        },
                    ),
                  ),
                ),
                Text(
                  dateError,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  ),
                ),
                SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(15),
              ),
              child:TextFormField(
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
                    ),

                  ),
                ),
            ),
                SizedBox(height: 16),
                RippleInkWell(
                  onTap: () {},
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
                        getTranslated(context, 'submit')!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
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

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    fromDateController.dispose();

    super.dispose();
  }
}
