
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:developer' as dev;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pyramids_developments/localization/language_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:pyramids_developments/screens/HomeDetailScreens/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';


import '../Models/ImagesSlider.dart';
import '../Models/User.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  //final String title;
  // final String currentPage;
  static const String routeName = 'home'; // Define a route name

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String TAG = "HomePage";
  int _currentIndex = 0;
  bool isGettingPhotos = false;
  String userId = "";
  String email = "";
  String role = "";
  bool isLogged = false;


  // late VideoPlayerController _videoPlayerController;
  // late ChewieController _chewieController;
  // String videoUrl = "";

  final List<OneImage> adsList = [];

  final List<OneImage> newsList = [];

  final List<OneImage> mediaList = [];

  Future<void> getAdsNews() async {
    getUserDataFromPreferences();

    String adsNewsUrl =
        "https://sourcezone2.com/public/00.AccessControl/get_home_page.php";

    setState(() {
      isGettingPhotos = true;
    });

    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      try {
        final response = await http.post(
          Uri.parse(adsNewsUrl),
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
            isGettingPhotos = false;
          });

          dev.log(TAG, name: "getAdsNews", error: response.body);

          Images imgs = Images.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);
          if (imgs.status == "OK") {
            adsList.clear();
            newsList.clear();
            mediaList.clear();

            for (int i = 0; i < imgs.adsList.length; i++) {
              if (imgs.adsList[i].itemType == "ads") {
                adsList.add(imgs.adsList[i]);
                dev.log(TAG, name: "getAds", error: imgs.adsList[i]);
              }
            }

            for (int i = 0; i < imgs.newsList.length; i++) {
              if (imgs.newsList[i].itemType == "news") {
                newsList.add(imgs.newsList[i]);
                dev.log(TAG, name: "getNews", error: imgs.newsList[i]);
              }
            }

            for (int i = 0; i < imgs.mediaList.length; i++) {
              if (imgs.mediaList[i].itemType == "media") {
                mediaList.add(imgs.mediaList[i]);
                dev.log(TAG,
                    name: "getMedia:// ", error: imgs.mediaList[i].itemPhotoUrl);
              }
            }

            // if (imgs.mediaList[0].itemPhotoUrl.isNotEmpty) {
            //   //_initializeVideo(imgs.mediaList[0].itemPhotoUrl);
            //   videoUrl = imgs.mediaList[0].itemPhotoUrl;
            // }
          } else {
            showToast(imgs.info);
          }
        } else {
          dev.log(TAG, error: "API sent Error: $response");
          showToast(
              Images.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
                  .info);

          setState(() {
            isGettingPhotos = false;
          });
        }
      } catch (e) {
        dev.log(TAG, error: "ExceptionError : $e");
        showToast(getTranslated(context, "somethingWrong")!);
        setState(() {
          isGettingPhotos = false;
        });
      }
    } else {
      showToast(getTranslated(context, "noInternetConnection")!);
      setState(() {
        isGettingPhotos = false;
      });
      return;
    }
  }

  Future<void> _refreshData() async {
    // Implement your refresh logic here
    await Future.delayed(
        Duration(seconds: 2)); // Simulating a delay for fetching new data
    setState(() {
      // Update the state with new data
    });
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          // Add background image here
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg.png'),
            // Replace with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: isGettingPhotos
            ? Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4.0,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Wrap(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200.0,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                            items: adsList.take(2).map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Handle item click here
                                      _showAdBottomSheet(
                                          context, item.itemPhotoUrl);
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                          ),
                                          child: Image.network(
                                            colorBlendMode: BlendMode.darken,
                                            item.itemPhotoUrl,
                                            fit: BoxFit.fill,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.black,
                                                    ),
                                                    strokeWidth: 2.0,
                                                  ),
                                                );
                                              }
                                            },
                                            errorBuilder: (BuildContext context,
                                                Object error,
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
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: adsList.take(2).map((url) {
                        int index = adsList.indexOf(url);
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Colors.purple
                                : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: Text(
                                  getTranslated(context, "news")!,
                                  style: TextStyle(
                                    // Make text underlined
                                    fontSize: 15.0,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.white,
                                    fontFamily: _getCurrentLang() == "ar"
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailPage(
                                              title: getTranslated(context, "news")!,
                                              isBackHome: false)));
                                },
                                child: Text(
                                  getTranslated(context, "more")!,
                                  style: TextStyle(
                                    // Make text underlined
                                    decoration: TextDecoration.underline,
                                    fontSize: 15.0,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    fontFamily: _getCurrentLang() == "ar"
                                        ? 'arFont'
                                        : 'enBold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          newsList.length == 0
                              ? Center(
                              child: Text(
                                getTranslated(context, "noNews")!,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontFamily: _getCurrentLang() == "ar"
                                      ? 'arFont'
                                      : 'enBold',
                                ),
                              )): Container(
                            //News section
                            margin: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 5.0),
                            // Make height fill the remaining
                            height: 100,
                            child: GestureDetector(
                              onTap: () {
                                _showNewsBottomSheet(
                                    context,
                                    newsList[0].itemPhotoUrl,
                                    newsList[0].itemTitle,
                                    newsList[0].itemDescription);
                              },
                              child: Card(
                                margin: EdgeInsets.only(bottom: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Adjust the radius as needed
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image on the left
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Container(
                                        width:
                                            90.0, // Adjust the width as needed
                                        height: 100,
                                        child: Image.network(
                                          newsList[0].itemPhotoUrl,
                                          colorBlendMode: BlendMode.darken,
                                          fit: BoxFit.fill,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.black),
                                                  strokeWidth: 2.0,
                                                ),
                                              );
                                            }
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object error,
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
                                    // Title and Description on the right
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              newsList[0].itemTitle,
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                // Make font bold
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontFamily: _getCurrentLang() ==
                                                        "ar"
                                                    ? 'arFont'
                                                    : 'enBold',
                                              ),
                                            ),
                                            Text(
                                              // Description limited text ellipsized
                                              newsList[0].itemDescription,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.black,
                                                fontFamily: _getCurrentLang() ==
                                                        "ar"
                                                    ? 'arFont'
                                                    : 'enBold',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: Text(
                        getTranslated(context, "media")!,
                        style: TextStyle(
                          // Make text underlined
                          fontSize: 15.0,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontFamily: _getCurrentLang() == "ar"
                              ? 'arFont'
                              : 'enBold',
                        ),
                      ),
                    ),
                    //media slider
                    VideoListWidget(
                      medList: mediaList,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }


  void _showNewsBottomSheet(
      BuildContext context, newsUrl, newsTitle, newsDescription) {
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
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: Image.network(
                        newsUrl,
                        colorBlendMode: BlendMode.darken,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
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
                SizedBox(
                  height: 10,
                ),
                Text(
                  newsTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    fontFamily: _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(newsDescription,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontFamily:
                          _getCurrentLang() == "ar" ? 'arFont' : 'enBold',
                    )
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdBottomSheet(BuildContext context, adUrl) {
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
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: Image.network(
                        adUrl,
                        colorBlendMode: BlendMode.darken,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                                strokeWidth: 2.0,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/appicon/appIcon.png',
                            fit: BoxFit.fill,
                            height: 100.0,
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
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
  void initState() {
    getAdsNews();
    super.initState();
  }

  @override
  void dispose() {
    dev.log('home page disposed');
    super.dispose();
  }
}


class VideoListWidget extends StatefulWidget {
  const VideoListWidget({super.key, required this.medList});

  final List<OneImage> medList;

  @override
  VideoListWidgetState createState() => VideoListWidgetState();
}

class VideoListWidgetState extends State<VideoListWidget> {
  List<VideoPlayerController> videoControllers = [];
  List<ChewieController?> chewieControllers = [];
  late VideoPlayerController _controller;
  int _mediaIndex = 0;

  @override
  void initState() {
    super.initState();

    videoControllers.clear();
    // Initialize video controllers
    List<Uri> videos = [];
    videos.clear();
    widget.medList.forEach((element) {
      videos.add(Uri.parse(element.itemPhotoUrl));
    });

    ///initialise multiple controllers
    videos.forEach((element) async {
      _controller = VideoPlayerController.networkUrl(element);
      videoControllers.add(_controller);
    });
    videoControllers.forEach((element) {
      element.initialize();
    });


    // for (int i = 0; i < widget.medList.length; i++) {
    //   _controller = VideoPlayerController.networkUrl(
    //       Uri.parse(widget.medList[i].itemPhotoUrl));
    //
    //   _controller.addListener(() {
    //     setState(() {});
    //   });
    //   _controller.setLooping(true);
    //
    //   // Check if the controller is already initialized before reinitializing
    //   if (!_controller.value.isInitialized) {
    //     _controller.initialize().then((_) => setState(() {}));
    //   }
    //
    //   _controller.play();
    //   videoControllers.add(_controller);
    // }
    //
    // chewieControllers.clear();
    // // Initialize chewie controllers
    // chewieControllers = videoControllers
    //     .map((controller) => ChewieController(
    //   videoPlayerController: controller,
    //   aspectRatio: 16 / 9,
    //   autoInitialize: true,
    //   looping: false,
    //   autoPlay: false,
    // ))
    //     .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              enlargeCenterPage: true,
              autoPlay: false,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                setState(() {
                  videoControllers[index].initialize();
                  _mediaIndex = index;
                });
              },
            ),
            items: widget.medList.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      // Handle item click here
                      // _showAdBottomSheet(
                      //     context, item.itemPhotoUrl);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
                          child: Stack(
                            children: [
                              VideoPlayer(videoControllers[_mediaIndex]),
                              Center(
                                child: IconButton(
                                  icon: Icon(
                                    videoControllers[_mediaIndex]
                                            .value
                                            .isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      videoControllers[_mediaIndex]
                                              .value
                                              .isPlaying
                                          ? videoControllers[_mediaIndex]
                                              .pause()
                                          : videoControllers[_mediaIndex]
                                              .play();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.medList.map((url) {
              int index = widget.medList.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mediaIndex == index ? Colors.purple : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    dev.log('video widget disposed');
    for (var controller in videoControllers) {
      controller.dispose();
    }
    for (var controller in chewieControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

}
