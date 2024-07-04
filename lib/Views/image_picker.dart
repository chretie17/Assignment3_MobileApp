import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!)
                : Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                requestPermission();
              },
              child: Text('Request Permission'),
            ),
            ElevatedButton(
              onPressed: () {
                pickImage();
              },
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermission() async {
    if (await Permission.photos.request().isGranted) {
      // Permission is granted, proceed to access the gallery
      print('Permission granted');
    } else {
      // Permission is not granted, show a message or handle it accordingly
      print('Permission not granted');
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Use the picked image, for example, display it in an Image widget
      // You can also save the image to a file, upload it to a server, etc.
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      // User canceled the image picking
      print('Image picking canceled');
    }
  }
}
