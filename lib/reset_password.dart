import 'package:connectivity/connectivity.dart%20%20';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:pyramids_developments/Models/basic_model.dart';
import 'package:pyramids_developments/screens/main_page.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/localization/language_constants.dart';

import 'Models/User.dart';
import 'Models/model_verification_code.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.title});

  final String title;

  static const String routeName = '/reset'; // Define a route name

  @override
  State<ResetPasswordPage> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  String TAG = "ResetPasswordPageState";
  int currentStep = 0;
  String verificationCode = "";
  String vCodee = "";
  User usr = User(
    userId: "",
    first_name: "",
    last_name: "",
    phoneNumber: "",
    email: "",
    userPhoto: "",
    role: "",
    userStatus: "",
    message: "",
    info: "",
    created_at: "",
    status: "",
    vCode: "",
  );

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String phoneNumberError = "";
  String passwordError = "";
  String confirmPasswordError = "";
  String codeError = "";
  String retrieved_userId = "";
  String retrieved_role = "";
  bool isWaiting = false;


  Future<void> validatePhoneSendCode() async {
    String getUnitsUrl =
        "https://sourcezone2.com/public/00.AccessControl/forgot_password_mail_check_code_send.php";

    setState(() {
      isWaiting = true;
    });

    try {
      final response = await http.post(
        Uri.parse(getUnitsUrl),
        headers: <String, String>{
          // 'Content-Type': 'application/json; charset=UTF-8',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          'email': _phoneNumberController.text,
          'language' : _getCurrentLang(),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isWaiting = false;
        });

        dev.log(TAG, name: "validatePhoneSendCode", error: response.body);

        usr =
        User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

        if (usr.status == "OK") {
            setState(() {
              vCodee = usr.vCode;
              retrieved_userId = usr.userId;
              retrieved_role = usr.role;

              currentStep += 1;
            });
        } else {
          dev.log(TAG,
              error: "validatePhoneSendCode API status Error: $response");
          showToast(usr.info);
        }
      } else {
        dev.log(TAG,
            error: "validatePhoneSendCode API request Error: $response");
        showToast(
            User.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
                .info);

        setState(() {
          isWaiting = false;
        });
      }
    } catch (e) {
      dev.log(TAG, error: "validatePhoneSendCode ExceptionError : $e");
      showToast(getTranslated(context, "somethingWrong")!);
      setState(() {
        isWaiting = false;
      });
    }
  }

  Future<void> checkVerificationCode() async {
    if(vCodee == verificationCode) {

      setState(() {
        currentStep += 1;
      });

    }else{
      showToast(getTranslated(context, "notValidVerificationCode")!);
    }
    // String getUnitsUrl =
    //     "https://groupheroesegypt.com/00.AccessControl/forgot_password_update_new_pass.php";
    //
    // setState(() {
    //   isWaiting = true;
    // });
    //
    // try {
    //   final response = await http.post(
    //     Uri.parse(getUnitsUrl),
    //     headers: <String, String>{
    //       // 'Content-Type': 'application/json; charset=UTF-8',
    //       'Content-Type': 'application/x-www-form-urlencoded',
    //     },
    //     body: <String, String>{
    //       'code': "usedCode",
    //     },
    //   );
    //
    //   if (response.statusCode == 200) {
    //     setState(() {
    //       isWaiting = false;
    //     });
    //
    //     dev.log(TAG, name: "getUnits", error: response.body);
    //
    //     // Units u =
    //     // Units.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    //     //
    //     // if (u.status == "OK") {
    //     //   setState(() {
    //     //     currentStep += 1;
    //     //   });
    //     // } else {
    //     //   showToast(u.info);
    //     // }
    //   } else {
    //     dev.log(TAG, error: "API sent Error: $response");
    //     // showToast(
    //     //     User.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
    //     //         .info);
    //
    //     setState(() {
    //       isWaiting = false;
    //     });
    //   }
    // } catch (e) {
    //   dev.log(TAG, error: "ExceptionError : $e");
    //   showToast(getTranslated(context, "somethingWrong")!);
    //   setState(() {
    //     isWaiting = false;
    //   });
    // }
  }

  Future<void> changePassword() async {
    String getUnitsUrl =
        "https://sourcezone2.com/public/00.AccessControl/forgot_password_update_new_pass.php";

    setState(() {
      isWaiting = true;
    });

    try {
      final response = await http.post(
        Uri.parse(getUnitsUrl),
        headers: <String, String>{
          // 'Content-Type': 'application/json; charset=UTF-8',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          'userId': retrieved_userId,
          'role': retrieved_role,
          'new_password': _passwordController.text,
          'language' : _getCurrentLang(),

        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isWaiting = false;
        });

        dev.log(TAG, name: "changePassword res: ", error: response.body);

        BasicModel u =
        BasicModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

        if (u.status == "OK") {
          showToast(u.info);
          Navigator.of(context).pop();
          //saveUserInPreferences(usr);

        } else {
          dev.log(TAG, error: "changePassword API status Error: $response");
          showToast(u.info);
        }
      } else {
        dev.log(TAG, error: "changePassword API request Error: $response");
        showToast(
            BasicModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
                .info);

        setState(() {
          isWaiting = false;
        });
      }
    } catch (e) {
      dev.log(TAG, error: "changePassword ExceptionError : $e");
      showToast(getTranslated(context, "somethingWrong")!);
      setState(() {
        isWaiting = false;
      });
    }
  }



  Future<void> saveUserInPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = user.toJson(); // Convert the User object to a JSON map
    final userString = jsonEncode(userJson); // Convert the JSON map to a string
    await prefs.setString('user_data', userString);
    // await prefs.setString('userId', user.userId);
    // await prefs.setString('first_name', user.first_name);
    // await prefs.setString('last_name', user.last_name);
    // await prefs.setString('phoneNumber', user.phoneNumber);
    // await prefs.setString('email', user.email);
    // await prefs.setString('userPhoto', user.userPhoto);
    // await prefs.setString('role', user.role);
    await prefs.setBool('isLogin', true);

    dev.log(TAG, name: "saveUserInPreferencesPrefs:: ", error: userString);
    // Navigator.of(context).pushReplacement(MaterialPageRoute(
    //     builder: (context) => MainPage(title: "Pyramids Developments")));
    Navigator.of(context).pop();
  }

  //use stepper for 3 steps
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold')),
        centerTitle: true,
      ),
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
        child: Stepper(
          stepIconBuilder: (int index, StepState stepState) {
            bool isCompleted = index < currentStep;
            bool isCurrent = index == currentStep;

            return Container(
              width: 40, // Set the width as needed
              height: 40, // Set the height as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.green
                    : isCurrent
                        ? Colors.blueGrey
                        : Colors.grey,
              ),
              child: Center(
                child: Text(
                  // Display step number
                  (index + 1).toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                  ),
                ),
              ),
            );
          },
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            return isWaiting ? Row(children: [
              Container(
                margin: EdgeInsets.only(right: 15, left: 15),
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  //change size
                  color: Colors.purple,
                ),
              ),
            ])
            : Row(
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  onPressed: details.onStepContinue,
                  child: Center(
                    child: Text(getTranslated(context, "next")!,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold')),
                  ),
                ),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(getTranslated(context, "cancel")!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily:
                              _getCurrentLang() == 'ar' ? 'arFont' : 'enBold')),
                ),
              ],
            );
          },
          type: StepperType.vertical,
          currentStep: currentStep,
          onStepContinue: () {
            if(currentStep == 2){

              if (_passwordController.text.isEmpty ||
                  !isValidPassword(_passwordController.text)) {
                setState(() {
                  passwordError = getTranslated(context,
                      "passwordEight")!; // Customize the error message
                });
                showToast(getTranslated(context, "passwordEight")!);

              } else if (_confirmPasswordController.text.isEmpty ||
                  !isValidPassword(_confirmPasswordController.text) ||
                  _confirmPasswordController.text != _passwordController.text) {
                setState(() {
                  confirmPasswordError = getTranslated(context,
                      "notValidConfirmPassword")!; // Customize the error message
                });
                showToast(getTranslated(context, "notValidConfirmPassword")!);
              } else {
                setState(() {
                  confirmPasswordError = "";
                });
                changePassword();
              }


            }else if (currentStep == 1) {
              if (verificationCode.isEmpty || !isValidCode(verificationCode)) {
                setState(() {
                  codeError = getTranslated(context,
                      "notValidVerificationCode")!; // Customize the error message
                });
                showToast(getTranslated(context, "notValidVerificationCode")!);

              } else {
                setState(() {
                  codeError = "";
                });
                checkVerificationCode();
              }

            }else{
              if(_phoneNumberController.text.isEmpty || !isValidPhoneNumber(_phoneNumberController.text)){
                setState(() {
                  phoneNumberError = getTranslated(context,
                                "notValidPhoneNumber")!;
                });
                showToast(getTranslated(context, "notValidPhoneNumber")!);

              }else{
                setState(() {
                  phoneNumberError = "";
                });
                validatePhoneSendCode();
              }
            }

          },
          onStepCancel: () {
            setState(() {
              if (currentStep == 0) {
                // Navigate back to the previous page when at the first step
                Navigator.of(context).pop();
              } else if (currentStep > 0) {
                setState(() {
                  currentStep -= 1;
                });
              }
            });
          },
          steps: <Step>[
            Step(
              title: Text(getTranslated(context, "phoneNumber")!,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily:
                          _getCurrentLang() == 'ar' ? 'arFont' : 'enBold')),
              content: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Container(
                    height: 53.0, // Adjust the height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),

                    child: TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "phoneNumber")!,
                        hintText: getTranslated(context, "enterPhoneNumber"),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
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
                        if (value.isEmpty || !isValidPhoneNumber(value)) {
                          // Input field to show error
                          setState(() {
                            phoneNumberError = getTranslated(context,
                                "notValidPhoneNumber")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            phoneNumberError = "";
                          });
                        }
                      },
                    ),
                  ),
                  Text(
                    phoneNumberError,
                    style: TextStyle(
                      fontFamily:
                          _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              isActive: currentStep >= 0,
              state: currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text(
                getTranslated(context, "verification")!,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                ),
              ),
              content: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Container(
                    height: 53.0, // Adjust the height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),

                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "verificationCode"),
                        hintText:
                            getTranslated(context, "enterVerificationCode"),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
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
                        if (value.isEmpty || !isValidCode(value)) {
                          // Input field to show error
                          setState(() {
                            codeError = getTranslated(context,
                                "notValidVerificationCode")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            codeError = "";
                            verificationCode = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text(
                    codeError,
                    style: TextStyle(
                      fontFamily:
                          _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              isActive: currentStep >= 0,
              state: currentStep >= 1 ? StepState.complete : StepState.disabled,
            ),
            Step(
              title: Text(getTranslated(context, "newPassword")!,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily:
                          _getCurrentLang() == 'ar' ? 'arFont' : 'enBold')),
              content: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Container(
                    height: 53.0, // Adjust the height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),

                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "password"),
                        hintText: getTranslated(context, "enterPassword"),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
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
                        if (value.isEmpty || !isValidPassword(value)) {
                          // Input field to show error
                          setState(() {
                            passwordError = getTranslated(context,
                                "passwordEight")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            passwordError = "";
                          });
                        }
                      },
                      obscureText: true,
                    ),
                  ),
                  Text(
                    passwordError,
                    style: TextStyle(
                      fontFamily:
                          _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 53.0, // Adjust the height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey[200],
                    ),

                    child: TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "confirmPassword"),
                        hintText:
                            getTranslated(context, "enterConfirmPassword"),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.0,
                            fontFamily: _getCurrentLang() == 'ar'
                                ? 'arFont'
                                : 'enBold'),
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
                        if (value.isEmpty ||
                            !isValidPassword(value) ||
                            value != _passwordController.text) {
                          // Input field to show error
                          setState(() {
                            confirmPasswordError = getTranslated(context,
                                "notValidConfirmPassword")!; // Customize the error message
                          });
                        } else {
                          setState(() {
                            confirmPasswordError = "";
                          });
                        }
                      },
                      obscureText: true,
                    ),
                  ),
                  Text(
                    confirmPasswordError,
                    style: TextStyle(
                      fontFamily:
                          _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              isActive: currentStep >= 0,
              state: currentStep >= 2 ? StepState.complete : StepState.disabled,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
  }

  bool isValidPhoneNumber(String phone) {
    return RegExp(r"^(010|011|012|015)[0-9]{8}$").hasMatch(phone);
  }

  bool isValidPassword(String pass) {
    return RegExp(r"^.{8,}$").hasMatch(pass);
  }

  bool isValidCode(String code) {
    //regex for 9 letters and numbers code
    return RegExp(r"^[0-9]{6}$").hasMatch(code);
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
}
