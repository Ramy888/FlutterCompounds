import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/User.dart';
import '../../localization/language_constants.dart';

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
        title: Text('New Service Request'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
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
                  underline: Container(), // This line removes the underline
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
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
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
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontFamily:
                            _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      ),
                      // labelStyle: TextStyle(color: Colors.black),
                    ),
                    enabled: false,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        // Input field to show error
                        setState(() {
                          dateError = getTranslated(context,
                              "notValidDate")!; // Customize the error message
                        });
                      } else {
                        setState(() {
                          dateError = "";
                          //dateFrom = value;
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
              TextField(
                controller: descriptionController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Describe the issue...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Implement your submit logic here
                  print('Category: $selectedCategory');
                  print('Date: $selectedDate');
                  print('Time: $selectedTime');
                  print('Description: ${descriptionController.text}');
                },
                child: Text('Submit'),
              ),
            ],
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
  void dispose() {
    descriptionController.dispose();
    fromDateController.dispose();

    super.dispose();
  }
}
