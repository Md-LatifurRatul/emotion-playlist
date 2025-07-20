import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerProvider extends ChangeNotifier {
  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  File? get image => _image;

  Future<void> pickImage() async {
    try {
      final XFile? selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (selectedImage != null) {
        _image = File(selectedImage.path);
        notifyListeners();
      }
    } catch (e) {
      log("Error picking image: $e");
    }
  }

  Future<void> captureCameraImage() async {
    try {
      final XFile? capturedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,

        imageQuality: 80,
        maxWidth: 1000,
      );

      if (capturedImage != null) {
        _image = File(capturedImage.path);
        notifyListeners();
      }
    } catch (e) {
      log("Error capturing image with camera: $e");
    }
  }
}
