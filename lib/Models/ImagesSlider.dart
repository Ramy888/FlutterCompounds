
class Images {
  final String status;
  final String message;
  final String info;
  // final List<OneImage> data;
  final List<OneImage> adsList;
  final List<OneImage> newsList;
  final List<OneImage> mediaList;

  Images(this.adsList,
  this.newsList,
     this.mediaList,
     this.status,
     this.message,
     this.info,
  );

  factory Images.fromJson(Map<String, dynamic> json) {
    // var list = json['data'] as List?;
    // List<OneImage> imageList = list?.map((i) => OneImage.fromJson(i)).toList() ?? [];
    var adsListJson = json['data']['ads'] as List<dynamic>?;
    var newsListJson = json['data']['news'] as List<dynamic>?;
    var mediaListJson = json['data']['media'] as List<dynamic>?;

    List<OneImage> adsList = adsListJson?.map((i) => OneImage.fromJson(i)).toList() ?? [];
    List<OneImage> newsList = newsListJson?.map((i) => OneImage.fromJson(i)).toList() ?? [];
    List<OneImage> mediaList = mediaListJson?.map((i) => OneImage.fromJson(i)).toList() ?? [];

    return Images(
      adsList,
      newsList,
      mediaList,
      json['status'] as String,
      json['message'] as String,
      json['info'] as String,
    );

    // return Images(
    //   imageList,
    //   json['status'] as String,
    //   json['message'] as String,
    //   json['info'] as String,
    // );
  }

}

class OneImage{
  final String itemId ;
  final String itemType;
  final String itemPhotoUrl;
  final String itemTitle;
  final String itemDescription;
  final String validFrom;
  final String validTo;
  final String itemStatus;
  final String creatorId;
  final String created_at;
  final String updated_at;

  OneImage(this.itemId,
      this.itemType,
      this.itemPhotoUrl,
      this.itemTitle,
      this.itemDescription,
      this.validFrom,
      this.validTo,
      this.itemStatus,
      this.creatorId,
      this.created_at,
      this.updated_at
      );

  factory OneImage.fromJson(Map<String, dynamic> json) {
    return OneImage(
      json['itemId'] as String,
      json['itemType'] as String,
      json['itemPhotoUrl'] as String,
      json['itemTitle'] as String,
      json['itemDescription'] as String,
      json['validFrom'] as String,
      json['validTo'] as String,
      json['itemStatus'] as String,
      json['creatorId'] as String,
      json['created_at'] as String,
      json['updated_at'] as String,
    );
  }
}

