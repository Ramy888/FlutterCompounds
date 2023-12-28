import 'package:connectivity/connectivity.dart%20%20';
import 'package:flutter/material.dart';
import 'package:pyramids_developments/Helpers/ImageHelper.dart';
import 'package:pyramids_developments/Models/User.dart';
import 'package:pyramids_developments/Models/units.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  final String title;
  static const String routeName = '/register'; // Define a route name

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  String TAG = "RegisterPage";
  int currentStep = 0;
  bool isLoading = false;
  bool isGettingUnits = false;
  String photoPath = "";

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nationalIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String firstNameError = "";
  String lastNameError = "";
  String phoneNumberError = "";
  String emailError = "";
  String nationalIdError = "";
  String passwordError = "";
  String confirmPasswordError = "";

  List<String> projectNames = [
    'Sky City',
  ];
  List<String> units = [];

  String selectedUnit = "";

  String nationalId = "";
  String selectedProject = "";

  Future<void> getUnits() async {
    String getUnitsUrl =
        "https://sourcezone2.com/public/00.AccessControl/get_units.php";

    setState(() {
      isGettingUnits = true;
    });

    try {
      final response = await http.get(
        Uri.parse(getUnitsUrl),
        headers: <String, String>{
          // 'Content-Type': 'application/json; charset=UTF-8',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isGettingUnits = false;
        });

        dev.log(TAG, name: "getUnits", error: response.body);

        Units u =
            Units.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (u.status == "OK") {
          units.clear();
          for (int i = 0; i < u.units.length; i++) {
            units.add(u.units[i].unit);
          }
        } else {
          showToast(u.info);
        }
      } else {
        dev.log(TAG, error: "API sent Error: $response");
        showToast(
            User.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
                .info);

        setState(() {
          isGettingUnits = false;
        });
      }
    } catch (e) {
      dev.log(TAG, error: "ExceptionError : $e");
      showToast(getTranslated(context, "somethingWrong")!);
      setState(() {
        isGettingUnits = false;
      });
    }
  }

  Future<void> validateOwner() async {
    setState(() {
      isLoading = true;
    });

    String currentLanguage = Localizations.localeOf(context).languageCode;

    String getUnitsUrl =
        "https://sourcezone2.com/public/00.AccessControl/validate_new_owner.php";

    try {
      final response = await http.post(
        Uri.parse(getUnitsUrl),
        headers: <String, String>{
          // 'Content-Type': 'application/json; charset=UTF-8',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          'national_id': nationalId,
          'language': currentLanguage,
          'unit': selectedUnit,
        },
      );

      // Close the dialog

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });

        String status = jsonDecode(response.body)['status'];
        if (status == ("OK")) {
          //go to next step Account information
          setState(() {
            currentStep += 1;
          });
        } else {
          showToast(jsonDecode(response.body)['info']);
        }
        dev.log(TAG, name: "validateOwneributton", error: response.body);
      } else {
        setState(() {
          isLoading = false;
        });

        dev.log(TAG, error: "API sent Error: $response");
        showToast(jsonDecode(response.body)['info']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      }); // Close the dialog

      dev.log(TAG, error: "ExceptionError : $e");
      showToast(getTranslated(context, "somethingWrong")!);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> registerUser(
    String firstName,
    String lastName,
    String phoneNumber,
    String email,
    String password,
    String confirmPassword,
    String photoPath, // Path to the selected photo
  ) async {
    String url =
        "https://sourcezone2.com/public/00.AccessControl/register_owner.php"; // Replace with your actual URL

    setState(() {
      isLoading = true;
    });

    String deviceId = generateUniqueCode(phoneNumber, email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', deviceId);

    String? token = await getDeviceToken();

    String currentLanguage = Localizations.localeOf(context).languageCode;

    if (token == null) {
      dev.log(TAG, error: "Device Token is null.");
    }

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(<String, String>{
        // 'Content-Type': 'application/json; charset=UTF-8',
        'Content-Type': 'application/x-www-form-urlencoded',
      });

      // Add form fields (parameters)
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone'] = phoneNumber;
      request.fields['email'] = email;
      request.fields['national_id'] = nationalId;
      request.fields['password'] = password;
      request.fields['token'] = token!;
      request.fields['deviceId'] = deviceId;
      request.fields['project'] = selectedProject;
      request.fields['unit'] = selectedUnit;
      request.fields['language'] = currentLanguage;
      request.fields['role'] = "owner";

      if (photoPath.isNotEmpty) {
        // Add the photo as a file to the request
        request.files
            .add(await http.MultipartFile.fromPath('userPhoto', photoPath));
      }

      // Send the request
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      dev.log(TAG, error: "registerUser response: $responseString");

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        var theUser =
            User.fromJson(jsonDecode(responseString) as Map<String, dynamic>);
        if (theUser.status == "OK") {
          //saveUserInPreferences(theUser);
          // Registration was successful, handle the response

          showToast(theUser.info);
          Navigator.pushReplacementNamed(context, LoginPage.routeName);
        } else {
          showToast(theUser.info);
        }
      } else {
        dev.log(TAG, error: "API sent Error");

        setState(() {
          isLoading = false;
        });
        // Registration failed, handle the error
        showToast(User.fromJson(
                jsonDecode(response as String) as Map<String, dynamic>)
            .info);
      }
    } catch (e) {
      dev.log(TAG, error: "ExceptionError: $e");

      setState(() {
        isLoading = false;
      });
      showToast(getTranslated(context, "somethingWrong")!);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToLoginPage() {
    Navigator.pushNamed(context, LoginPage.routeName);
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidVersion = Platform.version;
      final androidVersionComponents = androidVersion.split(' ');
      if (androidVersionComponents.length >= 3) {
        final androidApiVersion = int.tryParse(androidVersionComponents[2]);
        if (androidApiVersion != null && androidApiVersion < 33) {
          // Request storage permission for Android versions below API 33
          final status = await Permission.storage.request();
          if (status.isDenied) {
            // Handle permission denied
            showDialogPermissionRequired();
          } else if (status.isGranted) {
            selectPhotoFromGallery();
          }
        } else {
          // Request photo library permission for Android versions API 33 and above
          final status = await Permission.photos.request();
          if (status.isDenied) {
            // Handle permission denied
            showDialogPermissionRequired();
          } else if (status.isGranted) {
            selectPhotoFromGallery();
          }
        }
      }
    } else if (Platform.isIOS) {
      // Request both photo library and storage permissions for iOS
      final statuses = await [
        Permission.photos,
        Permission.storage,
      ].request();

      if (statuses[Permission.photos]?.isDenied == true ||
          statuses[Permission.storage]?.isDenied == true) {
        // Handle permission denied
        showDialogPermissionRequired();
      } else if (statuses[Permission.photos]?.isGranted == true ||
          statuses[Permission.storage]?.isGranted == true) {
        selectPhotoFromGallery();
      }
    }
  }

  void showDialogPermissionRequired() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslated(context, "permissionRequired")!,
              style: TextStyle(
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
              )),
          content: Text(getTranslated(context, "whyPermission")!,
              style: TextStyle(
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                requestPermissions(); // Request permission again
              },
              child: Text(getTranslated(context, "ok")!,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                  )),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectPhotoFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      //photoPath = pickedFile.path;
      final image = File(pickedFile.path);

      final _sizeInKbBefore = image.lengthSync() / 1024;
      print('Before Compress $_sizeInKbBefore kb');
      var _compressedImage = await ImageHelper.compress(image: image);
      final _sizeInKbAfter = _compressedImage.lengthSync() / 1024;
      print('After Compress $_sizeInKbAfter kb');
      var _croppedImage = await ImageHelper.cropImage(_compressedImage, context);
      if (_croppedImage == null) {
        return;
      }
      photoPath = _croppedImage.path;

      setState(() {
        photoPath = photoPath;
      });
    } else {
      // Handle the case where the user did not select a photo
      showToast(getTranslated(context, "noPhotoSelected")!);
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

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  bool isValidPhoneNumber(String phone) {
    return RegExp(r"^(010|011|012|015)[0-9]{8}$").hasMatch(phone);
  }

  bool isValidNationalId(String id) {
    return RegExp(r"^[0-9]{14}$").hasMatch(id);
  }

  bool isValidPassword(String pass) {
    return RegExp(r"^.{8,}$").hasMatch(pass);
  }

  String generateUniqueCode(String phoneNumber, String email) {
    // Create a unique hash code based on phone number and email
    String inputString = '$phoneNumber$email${DateTime.now()}';
    var bytes = utf8.encode(inputString);
    var digest = sha256.convert(bytes);
    String hash = digest.toString();

    // Add hyphens to format the code
    String formattedCode =
        '${hash.substring(0, 8)}-${hash.substring(8, 18)}-${hash.substring(18, 27)}-${hash.substring(27)}';

    return formattedCode;
  }

  Future<String?> getDeviceToken() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, "registerWord")!,
            style: TextStyle(
              fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
            )),
        toolbarHeight: 50.0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              // Add background image here
              image: DecorationImage(
                image: AssetImage('assets/splash/white_bg.png'),
                // Replace with your image asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          isGettingUnits
              ? const CircularProgressIndicator() // Show the loading indicator
              : Stepper(
                  elevation: 0,
                  connectorColor: MaterialStateProperty.all(Colors.purple),
                  // physics: const BouncingScrollPhysics(),
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
                            fontFamily:
                                _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                          ),
                        ),
                      ),
                    );
                  },
                  controlsBuilder:
                      (BuildContext context, ControlsDetails details) {
                    return isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: Text(getTranslated(context, "cancel")!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: _getCurrentLang() == 'ar'
                                            ? 'arFont'
                                            : 'enBold')),
                              ),
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
                            ],
                          );
                  },
                  type: StepperType.horizontal,
                  currentStep: currentStep,
                  onStepCancel: () {
                    if (currentStep == 0) {
                      // Navigate back to the previous page when at the first step
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        currentStep -= 1;
                      });
                    }
                  },
                  onStepContinue: () {
                    if (currentStep == 1) {
                      if (_firstNameController.text.isEmpty ||
                          _lastNameController.text.isEmpty ||
                          _phoneNumberController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        showToast(getTranslated(context, "fillAllFields")!);
                      } else if (!isValidPhoneNumber(
                          _phoneNumberController.text)) {
                        showToast(
                            getTranslated(context, "notValidPhoneNumber")!);
                      } else if (!isValidEmail(_emailController.text)) {
                        showToast(getTranslated(context, "notValidEmail")!);
                      } else if (!isValidPassword(_passwordController.text)) {
                        showToast(getTranslated(context, "passwordEight")!);
                      } else if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        showToast(
                            getTranslated(context, "notValidConfirmPassword")!);
                        // }
                        // else if(photoPath.isEmpty) {
                        //   showToast("Please select your photo");
                      } else {
                        registerUser(
                            _firstNameController.text,
                            _lastNameController.text,
                            _phoneNumberController.text,
                            _emailController.text,
                            _passwordController.text,
                            _confirmPasswordController.text,
                            photoPath);
                      }
                    } else {
                      if (selectedProject.isEmpty) {
                        showToast(getTranslated(context, "selectProject")!);
                      } else if (selectedUnit.isEmpty) {
                        showToast(getTranslated(context, "selectUnit")!);
                      } else if (!isValidNationalId(nationalId)) {
                        showToast(
                            getTranslated(context, "notValidNationalId")!);
                      } else {
                        validateOwner();
                      }
                    }
                  },
                  steps: [
                    Step(
                      title: const Text(""),
                      isActive: currentStep >= 0,
                      state: currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 60.0, // Adjust the height as needed
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.grey[200],
                            ),

                            child: DropdownSearch<String>(
                              items: projectNames,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return getTranslated(
                                      context, "selectProject")!;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                selectedProject = value!;
                              },
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText:
                                      getTranslated(context, "projectName")!,
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontFamily: _getCurrentLang() == 'ar'
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                  hintText:
                                      getTranslated(context, "selectAProject"),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                    fontFamily: _getCurrentLang() == 'ar'
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              popupProps: const PopupProps.menu(
                                showSearchBox: false,
                                fit: FlexFit.loose,
                                constraints: BoxConstraints.tightFor(
                                  width: 300,
                                  height: 100,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            height: 60.0, // Adjust the height as needed
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.grey[200],
                            ),

                            child: DropdownSearch<String>(
                              items: units,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return getTranslated(context, "selectUnit");
                                }
                                return null;
                              },
                              selectedItem: selectedUnit,
                              onChanged: (value) {
                                selectedUnit = value!;
                              },
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: getTranslated(context, "unit"),
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintText:
                                      getTranslated(context, "selectAUnit"),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                    fontFamily: _getCurrentLang() == 'ar'
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    labelText:
                                        getTranslated(context, "searchUnit"),
                                    labelStyle: TextStyle(color: Colors.black),
                                    hintText:
                                        getTranslated(context, "searchUnit"),
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.0,
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                // title: Text('Select Project'),
                                fit: FlexFit.loose,
                                constraints: BoxConstraints.tightFor(
                                  width: 300,
                                  height: 300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // National ID input field
                          Column(
                            children: [
                              Container(
                                height: 53.0, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.grey[200],
                                ),

                                child: TextFormField(
                                  controller: _nationalIdController,
                                  decoration: InputDecoration(
                                    labelText:
                                        getTranslated(context, "nationalId"),
                                    hintText: getTranslated(
                                        context, "enterNationalId"),
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.0,
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.0),
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.0),
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    // Add your onChanged logic here
                                    if (value.isEmpty ||
                                        !isValidNationalId(value)) {
                                      // Input field to show error
                                      setState(() {
                                        nationalIdError = getTranslated(context,
                                            "notValidNationalId")!; // Customize the error message
                                      });
                                    } else {
                                      setState(() {
                                        nationalIdError = "";
                                        nationalId = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Text(
                                nationalIdError,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                  fontFamily: _getCurrentLang() == 'ar'
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text(""),
                      isActive: currentStep >= 1,
                      state: currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      content: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Circular image with edit button
                              Container(
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 70,
                                      backgroundImage: Image(
                                        image: File(photoPath)
                                                .existsSync() // Check if the file exists
                                            ? FileImage(File(
                                                photoPath)) // Load the image from the file
                                            : const AssetImage(
                                                    'assets/images/pyrnewsplash.png')
                                                as ImageProvider,
                                        // Load the default image from assets
                                        fit: BoxFit.cover,
                                      ).image,
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape
                                            .circle, // To make it circular
                                        color: Colors
                                            .black26, // Set your desired background color
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors
                                              .white, // Set the icon color
                                        ),
                                        onPressed: () {
                                          requestPermissions();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // First name input field
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          height:
                                              53.0, // Adjust the height as needed
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Colors.grey[200],
                                          ),

                                          child: TextFormField(
                                            controller: _firstNameController,
                                            decoration: InputDecoration(
                                              labelText: getTranslated(
                                                  context, "firstName"),
                                              hintText: getTranslated(
                                                  context, "enterFirstName"),
                                              labelStyle: TextStyle(
                                                color: Colors.black,
                                                fontFamily:
                                                    _getCurrentLang() == 'ar'
                                                        ? 'arFont'
                                                        : 'enBold',
                                              ),
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13.0,
                                                fontFamily:
                                                    _getCurrentLang() == 'ar'
                                                        ? 'arFont'
                                                        : 'enBold',
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              // Add your onChanged logic here
                                              if (value.isEmpty) {
                                                // Input field to show error
                                                setState(() {
                                                  firstNameError = getTranslated(
                                                      context,
                                                      "notValidFirstName")!; // Customize the error message
                                                });
                                              } else {
                                                setState(() {
                                                  firstNameError = "";
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        Text(
                                          firstNameError,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.0,
                                            fontFamily:
                                                _getCurrentLang() == 'ar'
                                                    ? 'arFont'
                                                    : 'enBold',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Last name input field
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          height:
                                              53.0, // Adjust the height as needed
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Colors.grey[200],
                                          ),

                                          child: TextFormField(
                                            controller: _lastNameController,
                                            decoration: InputDecoration(
                                              labelText: getTranslated(
                                                  context, "lastName"),
                                              hintText: getTranslated(
                                                  context, "enterLastName"),
                                              labelStyle: TextStyle(
                                                color: Colors.black,
                                                fontFamily:
                                                    _getCurrentLang() == 'ar'
                                                        ? 'arFont'
                                                        : 'enBold',
                                              ),
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13.0,
                                                fontFamily:
                                                    _getCurrentLang() == 'ar'
                                                        ? 'arFont'
                                                        : 'enBold',
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              // Add your onChanged logic here
                                              if (value.isEmpty) {
                                                // Input field to show error
                                                setState(() {
                                                  lastNameError = getTranslated(
                                                      context,
                                                      "notValidLastName")!; // Customize the error message
                                                });
                                              } else {
                                                setState(() {
                                                  lastNameError = "";
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        Text(
                                          lastNameError,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.0,
                                            fontFamily:
                                                _getCurrentLang() == 'ar'
                                                    ? 'arFont'
                                                    : 'enBold',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),

                              // Phone number input field
                              Column(
                                children: [
                                  Container(
                                    height: 53.0, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.grey[200],
                                    ),

                                    child: TextFormField(
                                      controller: _phoneNumberController,
                                      decoration: InputDecoration(
                                        labelText: getTranslated(
                                            context, "phoneNumber"),
                                        hintText: getTranslated(
                                            context, "enterPhoneNumber"),
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.0,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        // Add your onChanged logic here
                                        if (value.isEmpty ||
                                            !isValidPhoneNumber(value)) {
                                          // Input field to show error
                                          setState(() {
                                            phoneNumberError = getTranslated(
                                                context,
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
                                      color: Colors.red,
                                      fontSize: 12.0,
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              // Email input field
                              Column(
                                children: [
                                  Container(
                                    height: 53.0, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.grey[200],
                                    ),

                                    child: TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText:
                                            getTranslated(context, "email"),
                                        hintText: getTranslated(
                                            context, "enterEmail"),
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.0,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        // Add your onChanged logic here
                                        if (value.isEmpty ||
                                            !isValidEmail(value)) {
                                          // Input field to show error
                                          setState(() {
                                            emailError = getTranslated(context,
                                                "notValidEmail")!; // Customize the error message
                                          });
                                        } else {
                                          setState(() {
                                            emailError = "";
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Text(
                                    emailError,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.0,
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 7),
                              // Password input field
                              Column(
                                children: [
                                  Container(
                                    height: 53.0, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.grey[200],
                                    ),

                                    child: TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText:
                                            getTranslated(context, "password"),
                                        hintText: getTranslated(
                                            context, "enterPassword"),
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.0,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        // Add your onChanged logic here
                                        if (value.isEmpty ||
                                            !isValidPassword(value)) {
                                          // Input field to show error
                                          setState(() {
                                            passwordError = getTranslated(
                                                context,
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
                                      color: Colors.red,
                                      fontSize: 12.0,
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              // Confirm password input field
                              Column(
                                children: [
                                  Container(
                                    height: 53.0, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.grey[200],
                                    ),

                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      decoration: InputDecoration(
                                        labelText: getTranslated(
                                            context, "confirmPassword"),
                                        hintText: getTranslated(
                                            context, "enterConfirmPassword"),
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.0,
                                          fontFamily: _getCurrentLang() == 'ar'
                                              ? 'arFont'
                                              : 'enBold',
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        // Add your onChanged logic here
                                        if (value.isEmpty ||
                                            !isValidPassword(value) ||
                                            value != _passwordController.text) {
                                          // Input field to show error
                                          setState(() {
                                            confirmPasswordError = getTranslated(
                                                context,
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
                                      color: Colors.red,
                                      fontSize: 12.0,
                                      fontFamily: _getCurrentLang() == 'ar'
                                          ? 'arFont'
                                          : 'enBold',
                                    ),
                                  ),
                                ],
                              ),

                              // const SizedBox(height: 12),
                              // Register button
                              // SizedBox(
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(5.0),
                              //     child: Visibility(
                              //       visible: !isLoading,
                              //       replacement: const SizedBox(
                              //         width: 20.0,
                              //         height: 20.0,
                              //         child: CircularProgressIndicator(
                              //           valueColor:
                              //               AlwaysStoppedAnimation<Color>(Colors.black),
                              //           strokeAlign: 2,
                              //           strokeWidth: 2.0,
                              //         ),
                              //       ), // Show the button when not loading
                              //       child: SizedBox(
                              //         width: double.infinity,
                              //         child: ElevatedButton(
                              //           onPressed: () {
                              //             //login(_userNamecontroller.text, _passController.text);
                              //             if (_firstNameController.text.isEmpty ||
                              //                 _lastNameController.text.isEmpty ||
                              //                 _phoneNumberController.text.isEmpty ||
                              //                 _emailController.text.isEmpty ||
                              //                 _passwordController.text.isEmpty ||
                              //                 _confirmPasswordController.text.isEmpty) {
                              //               showToast("Please fill all fields");
                              //             } else if (!isValidPhoneNumber(
                              //                 _phoneNumberController.text)) {
                              //               showToast(
                              //                   "Please enter valid phone number");
                              //             } else if (!isValidEmail(
                              //                 _emailController.text)) {
                              //               showToast("Please enter valid Email");
                              //             } else if (!isValidNationalId(nationalId)) {
                              //               showToast("Please enter valid national id");
                              //             } else if (!isValidPassword(
                              //                 _passwordController.text)) {
                              //               showToast(
                              //                   "Password must be at least 8 characters");
                              //             } else if (_passwordController.text !=
                              //                 _confirmPasswordController.text) {
                              //               showToast("Password does not match");
                              //               // }
                              //               // else if(photoPath.isEmpty) {
                              //               //   showToast("Please select your photo");
                              //             } else {
                              //               registerUser(
                              //                   _firstNameController.text,
                              //                   _lastNameController.text,
                              //                   _phoneNumberController.text,
                              //                   _emailController.text,
                              //                   _passwordController.text,
                              //                   _confirmPasswordController.text,
                              //                   photoPath);
                              //             }
                              //           },
                              //           style: ElevatedButton.styleFrom(
                              //             backgroundColor: Colors
                              //                 .black, // Change the background color
                              //           ),
                              //           child: const Text(
                              //             'Register',
                              //             style: TextStyle(
                              //                 fontSize: 16.0, color: Colors.white),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
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

  @override
  void initState() {
    getUnits();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
