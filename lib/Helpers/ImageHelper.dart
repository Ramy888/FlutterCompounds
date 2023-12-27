import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageHelper {
  static Future<CroppedFile?> cropImage(File? imageFile) async {
    var _croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile!.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop Photo',
        ),
      ],
    );

    return _croppedFile;
  }

  static Future<File> compress({
    required File image,
    int quality = 80,
    int percentage = 30,
  }) async {
    var path = await FlutterNativeImage.compressImage(image.absolute.path,
        quality: quality, percentage: percentage);
    return path;
  }
}
