import 'dart:io';
import 'package:flutter/painting.dart';

class FeedListData {
  FeedListData({
    this.id = '',
    this.imagePath = '',
    this.titleTxt = '',
    this.postText = "",
    this.dist = 1.8,
    this.reviews = 80,
    this.rating = 4.5,
    this.perNight = 180,
    this.userName = '',
    this.userImage = '',
    this.date = '',
    this.postType = 'Type 1',
  });

  String imagePath;
  String titleTxt;
  String postText;
  double dist;
  double rating;
  int reviews;
  int perNight;
  String id;
  String userName;
  String userImage;
  String date;
  String postType;

  static List<FeedListData> hotelList = <FeedListData>[
    FeedListData(
      id: '1',
      imagePath: ('assets/hotel/hotel_1.png'),
      titleTxt: 'Grand Royal Hotel',
      postText: 'problem in the road to building number 243',
      dist: 2.0,
      reviews: 80,
      rating: 2.4,
      perNight: 180,
      userName: 'Taylor Watson',
      userImage: 'assets/userImage/userImage.jpg',
      date: '12 Dec',
      postType: 'Type 1',
    ),
    FeedListData(
      id: '2',
      imagePath: ('assets/hotel/hotel_2.png'),
      titleTxt: 'Queen Hotel',
      postText: 'Wembley, London',
      dist: 4.0,
      reviews: 74,
      rating: 4.5,
      perNight: 200,
      userName: 'Jack Black',
      userImage: 'assets/userImage/userImage.jpg',
      date: '12 Dec',
      postType: 'Type 2',
    ),
    FeedListData(
      id: '3',
      imagePath: ('assets/hotel/hotel_3.png'),
      titleTxt: 'Grand Royal Hotel',
      postText: 'Wembley, London',
      dist: 3.0,
      reviews: 62,
      rating: 4.0,
      perNight: 60,
      userName: 'Adam Sandler',
      userImage: 'assets/userImage/userImage.jpg',
      date: '12 Dec',
      postType: 'Type 3',
    ),
    FeedListData(
      id: '4',
      imagePath: ('assets/hotel/hotel_4.png'),
      titleTxt: 'Queen Hotel',
      postText: 'Wembley, London',
      dist: 7.0,
      reviews: 90,
      rating: 4.4,
      perNight: 170,
      userName: 'Kate Upton',
      userImage: 'assets/userImage/userImage.jpg',
      date: '12 Dec',
      postType: 'Type 4',
    ),
    FeedListData(
      id: '5',
      imagePath: ('assets/hotel/hotel_5.png'),
      titleTxt: 'Grand Royal Hotel',
      postText: 'Wembley, London',
      dist: 2.0,
      reviews: 240,
      rating: 4.5,
      perNight: 200,
      userName: 'Jessica Simpson',
      userImage: 'assets/userImage/userImage.jpg',
      date: '12 Dec',
      postType: 'Type 5',
    ),
  ];
}