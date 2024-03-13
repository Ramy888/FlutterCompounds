import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pyramids_developments/app_theme.dart';
import 'package:flutter/material.dart';

import '../../Helpers/ImageHelper.dart';
import '../../localization/language_constants.dart';
import '../../widgets/ripple_effect.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'feed_list_data.dart';

class AddPost extends StatefulWidget {
  final int listIndex;
  final Function(FeedListData) onNewPostAdded;

  const AddPost({Key? key,
    required this.onNewPostAdded, required this.listIndex}) : super(key: key);


  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  String postType = 'Type 1';
  List<String> typesList = [
    'Public',
    'Friends',
  ];
  String? photoPath = null;
  String usrName = 'User Name';
  String postContent = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Post'),
          backgroundColor: AppTheme.nearlyWhite,
        ),
        // user circle photo, name, drop down to select post type and post content
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          AssetImage('assets/images/userImage.png'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      usrName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      // Assuming DropdownSearch is a custom Widget or third-party package.
                      // Ensure that it functions as intended with the rest of your UI.
                      child: DropdownSearch<String>(
                        items: typesList,
                        onChanged: (value) {
                          postType = value!;
                        },
                        dropdownDecoratorProps: buildDropDownDecoratorProps(),
                        popupProps: const PopupProps.menu(
                          showSearchBox: false,
                          fit: FlexFit.loose,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        // Add photo
                        requestPermissions();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.photo, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              if (photoPath != null)
                // Only show if photoPath is not null
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Stack(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Remove selected image
                            setState(() {
                              photoPath = null;
                            });
                          },
                          child: Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Post Content',
                  ),
                  onChanged: (value) {
                    // Update post content
                    postContent = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    // Add post to database
                    FeedListData feedListData = FeedListData(
                      id: widget.listIndex.toString(),
                      imagePath: 'assets/hotel/hotel_1.png',
                      titleTxt: usrName,
                      postText: postContent,
                      dist: 7.0,
                      reviews: 90,
                      rating: 4.4,
                      perNight: 170,
                      userName: usrName,
                      userImage: 'assets/userImage/userImage.jpg',
                      date: formatDate(DateTime.now()),
                      postType: postType,
                    );
                    widget.onNewPostAdded(feedListData);
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, 'post')!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  DropDownDecoratorProps buildDropDownDecoratorProps() {
    return DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: getTranslated(context, "postType")!,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
        ),
        hintText: getTranslated(context, "selectPostType"),
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 13.0,
          fontFamily: _getCurrentLang() == 'ar' ? 'arFont' : 'enBold',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  String _getCurrentLang() {
    return Localizations.localeOf(context).languageCode;
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
      var _croppedImage =
          await ImageHelper.cropImage(_compressedImage, context);
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

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString()
        .padLeft(2, '0')}-${date.year}";
  }
}
