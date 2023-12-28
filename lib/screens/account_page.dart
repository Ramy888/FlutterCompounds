import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pyramids_developments/Models/User.dart';
import 'package:pyramids_developments/Models/basic_model.dart';
import 'package:pyramids_developments/Models/delete_account.dart';
import 'package:pyramids_developments/Models/qr_code.dart';
import 'package:pyramids_developments/Models/user_account_model.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:pyramids_developments/language.dart';
import 'package:pyramids_developments/login_page.dart';
import 'package:pyramids_developments/widgets/Loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../Helpers/ImageHelper.dart';
import '../Models/invitaion.dart';
import '../main.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../widgets/dialog_change_password.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.title});

  final String title;
  static const String routeName = 'account'; // Define a route name

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  String TAG = "AccountPage";
  String photoPath = "";
  String userPhotoUrl = "";
  String uName = "Name";
  String phone = "Phone";
  String umail = "Email";
  String uunit = "Unit";
  String currentLanguage = "";
  bool hasRelatedMembers = false;
  bool hideGalleryPhoto = false;
  bool isGettingUserData = false;
  bool uploadingImage = false;
  String email = "";
  bool isLogged = false;
  String userId = "29";
  String role = "owner";
  double radius = 70.0;
  late TabController _tabController;
  int tabsNumber = 0;

  //adding one invitaions for test to be changed
  List<MemberData> familyMembers = [];
  List<MemberData> renterMembers = [];

  Future<void> getUserData() async {
    //get data from preferences
    getUserDataFromPreferences();

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/user_account_data.php";

      setState(() {
        isGettingUserData = true;
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
            'language': _getCurrentLang(),
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            isGettingUserData = false;
          });

          dev.log(TAG, name: "getUserData:: ", error: response.body);

          UserInfo invitationResponse = UserInfo.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (invitationResponse.status == "OK") {
            setState(() {
              hideGalleryPhoto = true;
              userPhotoUrl = invitationResponse.data!.userPhoto;
              uName = invitationResponse.data!.firstName +
                  " " +
                  invitationResponse.data!.lastName;
              phone = invitationResponse.data!.phoneNumber;
              umail = invitationResponse.data!.email;
              uunit = invitationResponse.data!.unit;

              if (invitationResponse.relatedData!.family!.length > 0 ||
                  invitationResponse.relatedData!.renter!.length > 0) {
                renterMembers.addAll(invitationResponse.relatedData!.renter!);
                familyMembers.addAll(invitationResponse.relatedData!.family!);

                if (familyMembers.isNotEmpty && renterMembers.isNotEmpty) {
                  tabsNumber = 2;
                } else if (familyMembers.isNotEmpty ||
                    renterMembers.isNotEmpty) {
                  tabsNumber = 1;
                } else {
                  tabsNumber = 0;
                }

                hasRelatedMembers = true;
              } else {
                hasRelatedMembers = false;
                tabsNumber = 0;
              }
            });

            dev.log(TAG,
                name: "related://  ",
                error:
                    "Family Members: ${familyMembers.toString()}\nRenter Members: ${renterMembers.toString()}\n renterLength: ${renterMembers.length}\n familyLength: ${familyMembers.length}");
          } else {
            dev.log(TAG, error: "getUserData API sent status Error: $response");

            showToast(invitationResponse.info);
          }
        } else {
          dev.log(TAG, error: "getUserData API request Error: $response");
          showToast(UserInfo.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .info);

          setState(() {
            isGettingUserData = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "ExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isGettingUserData = false;
        });
      }
    } else {
      //no internet connection
      setState(() {
        isGettingUserData = false;
      });
      showToast(getTranslated(context, "noInternetConnection")!);
    }
  }

  Future<void> changeUserPhoto() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String getUnitsUrl =
          "https://sourcezone2.com/public/00.AccessControl/user_change_photo.php";

      LoadingDialog.show(context);

      final request = http.MultipartRequest('POST', Uri.parse(getUnitsUrl));

      // Add form fields to the request
      request.fields['userId'] = userId;
      request.fields['role'] = role;
      request.fields['language'] = _getCurrentLang();

      // Add a file to the request
      // Replace 'file' with the name of the field your API expects for the file
      if (photoPath.isNotEmpty) {
        File file = File(photoPath);
        String mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        http.MultipartFile filePart = await http.MultipartFile.fromPath(
          'userPhoto', // field name for the file
          file.path,
          contentType: MediaType.parse(mimeType),
        );

        // Add the file part to the request
        request.files.add(filePart);
      }

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          LoadingDialog.hide(context);

          dev.log(TAG, name: "changePhoto: ", error: response.toString());
        } else {
          dev.log(TAG, error: "changePhoto API status Error: $response");

          LoadingDialog.hide(context);
        }
      } catch (e) {
        dev.log(TAG, error: "changePhotoExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        LoadingDialog.hide(context);
      }
    } else {
      //no internet connection
      showToast(getTranslated(context, "noInternetConnection")!);
      LoadingDialog.hide(context);
    }
  }

  Future<void> deleteAccount() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      String url =
          "https://sourcezone2.com/public/00.AccessControl/request_account_deletion.php";

      LoadingDialog.show(context);

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'email': email,
            'description': 'Delete my account',
            'language': _getCurrentLang(),
          },
        );
        dev.log(TAG, name: "DeleteAccount: ", error: response.body);

        if (response.statusCode == 200) {
          DeleteAccount delResponse = DeleteAccount.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          if (delResponse.status == "OK") {
            showToast(delResponse.message);
            LoadingDialog.hide(context);
            Navigator.of(context).pop();
          } else {
            dev.log(TAG, error: "DeleteAccount API status Error: $response");
            showToast(delResponse.message);
            LoadingDialog.hide(context);
          }
        } else {
          dev.log(TAG, error: "DeleteAccount requestFailed Error: $response");
          LoadingDialog.hide(context);
          showToast(DeleteAccount.fromJson(
                  jsonDecode(response.body) as Map<String, dynamic>)
              .message);
        }
      } catch (e) {
        dev.log(TAG, error: "changePasswordExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        LoadingDialog.hide(context);
      }
    } else {
      showToast(getTranslated(context, "noInternetConnection")!);
      LoadingDialog.hide(context);
    }
  }

  void _changeLanguage(Language language) async {
    currentLanguage = Localizations.localeOf(context).languageCode;

    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
    currentLanguage = language.languageCode;
  }

  Future<void> _refreshData() async {
    // Implement your refresh logic here
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
        child: isGettingUserData
            ? Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 4.0,
                ),
              )
            : SingleChildScrollView(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          child: DropdownButton<Language>(
                            underline: SizedBox(),
                            iconSize: 30,
                            hint: Text(
                              getTranslated(context, 'change_language')!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: _getCurrentLang() == "ar"
                                    ? 'arFont'
                                    : 'enBold',
                              ),
                            ),
                            onChanged: (Language? language) {
                              if (language != null) {
                                _changeLanguage(language);
                              }
                            },
                            items: Language.languageList()
                                .map<DropdownMenuItem<Language>>(
                                  (e) => DropdownMenuItem<Language>(
                                    value: e,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Image.asset(
                                            e.flag,
                                          ),
                                          Text(e.name),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        // Circular image with edit button
                        Container(
                          alignment: Alignment.topCenter,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: radius,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: _buildImageWidget(),
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle, // To make it circular
                                  color: Colors
                                      .black26, // Set your desired background color
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white, // Set the icon color
                                  ),
                                  onPressed: () {
                                    requestPermissions();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(uName,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: _getCurrentLang() == "ar"
                                        ? 'arFont'
                                        : 'enBold',
                                  )),
                              const SizedBox(height: 10),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontFamily: _getCurrentLang() == "ar"
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                umail,
                                style: TextStyle(
                                  fontFamily: _getCurrentLang() == "ar"
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                uunit,
                                style: TextStyle(
                                  fontFamily: _getCurrentLang() == "ar"
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: () {
                              _showBottomSheet(context);
                            },
                            child: Text(
                              getTranslated(context, "editProfile")!,
                              style: TextStyle(
                                fontFamily: _getCurrentLang() == "ar"
                                    ? 'arFont'
                                    : 'enBold',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Visibility(
                          visible: hasRelatedMembers,
                          replacement: SizedBox(height: 1),
                          child: Column(
                            children: [
                              DefaultTabController(
                                length: 2,
                                child: Column(
                                  children: [
                                    TabBar(
                                      controller: _tabController,
                                      tabs: [
                                        if (familyMembers.isNotEmpty)
                                          Tab(
                                            text: getTranslated(
                                                context, "family")!,
                                          ),
                                        if (renterMembers.isNotEmpty)
                                          Tab(
                                              text: getTranslated(
                                                  context, "tenant")!),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          // Family ListView
                                          if (familyMembers.isNotEmpty)
                                            ListView.builder(
                                              itemCount: familyMembers.length,
                                              itemBuilder: (context, index) {
                                                return buildMemberCard(
                                                    familyMembers[index]);
                                              },
                                            ),
                                          // Tenant ListView
                                          if (renterMembers.isNotEmpty)
                                            ListView.builder(
                                              itemCount: renterMembers.length,
                                              itemBuilder: (context, index) {
                                                return buildMemberCard(
                                                    renterMembers[index]);
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (photoPath != null && File(photoPath).existsSync()) {
      // Display local image
      return Image.file(
        File(photoPath),
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
      );
    } else if (userPhotoUrl != null) {
      // Display network image
      return Image.network(
        userPhotoUrl,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 2.0,
              ),
            );
          }
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return Image.asset(
            'assets/images/pyrnewsplash.png',
            // Placeholder for network image error
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
          );
        },
      );
    } else {
      // Default placeholder if both imagePath and imageUrl are null
      return Image.asset(
        'assets/images/pyrnewsplash.png',
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
      );
    }
  }

  Widget buildMemberCard(MemberData member) {
    dev.log(TAG,
        name: "related MemberCard://  ",
        error: " Members: ${member.firstName}");

    return Container(
      height: 120,
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on the left
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Container(
                  width: 100.0,
                  child: Image.network(
                    member.userPhoto,
                    colorBlendMode: BlendMode.darken,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                            strokeWidth: 2.0,
                          ),
                        );
                      }
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        'assets/images/skycitylogo.png',
                        fit: BoxFit.fill,
                        height: 100.0,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Title and Description on the right
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.firstName + " " + member.lastName,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily:
                            _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      ),
                    ),
                    Text(
                      member.role,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.black,
                        fontFamily:
                            _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      child: Text(
                        member.userStatus,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.white,
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                        ),
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
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.vpn_key),
                  title: Text(getTranslated(context, "changePass")!,
                      style: TextStyle(
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold')),
                  onTap: () {
                    // Handle option 1
                    Navigator.pop(context);
                    showPasswordDialog(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(getTranslated(context, "logout")!,
                      style: TextStyle(
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold')),
                  onTap: () {
                    // Handle option 2
                    Navigator.pop(context);
                    showLogoutDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text(getTranslated(context, "delAccount")!,
                      style: TextStyle(
                          fontFamily:
                              _getCurrentLang() == "ar" ? 'arFont' : 'enBold')),
                  onTap: () {
                    // Handle option 2
                    Navigator.pop(context);
                    showDeleteAccountDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
        hideGalleryPhoto = false;
        photoPath = photoPath;
      });

      changeUserPhoto();
    } else {
      // Handle the case where the user did not select a photo
      showToast(getTranslated(context, "noPhotoSelected")!);
      setState(() {
        hideGalleryPhoto = true;
      });
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

  // change password dialog
  void showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PasswordDialog(),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(getTranslated(context, "logout")!,
              style: TextStyle(
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
              )),
          content: Text(getTranslated(context, "sureLogout")!,
          style: TextStyle(
            fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
          )
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _logout();
              },
              child: Text(getTranslated(context, "logout")!,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                  )),
            ),
          ]),
    );
  }

  void showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(getTranslated(context, "delAccount")!,
              style: TextStyle(
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
              )),
          content: Text(getTranslated(context, "sureDelete")!,
          style: TextStyle(
            fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
          )
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(getTranslated(context, "cancel")!,
                  style: TextStyle(
                    fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
                  )),
            ),
            TextButton(
              onPressed: () {
                deleteAccount();
              },
              child: Text(getTranslated(context, "del")!,
              style: TextStyle(
                fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
              )
              ),
            ),
          ]),
    );
  }

  void _logout() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((value) => value.clear());
    prefs.then((value) => value.setString("user_data", ""));

    Navigator.of(context).pop();
    // Navigator.of(context).pushNamedAndRemoveUntil(
    //     LoginPage.routeName, (Route<dynamic> route) => false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) => LoginPage(title: getTranslated(context, "login")!),
    ));
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
    getUserData();
    super.initState();
    _tabController = TabController(length: tabsNumber, vsync: this);
  }
}
