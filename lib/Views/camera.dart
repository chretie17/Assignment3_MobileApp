import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Obtain a list of available cameras
    final cameras = await availableCameras();
    // Get the first camera from the list
    final firstCamera = cameras.first;

    // Initialize the camera controller
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    // Initialize the camera controller asynchronously
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  void _captureImage() async {
    try {
      // Ensure that the camera is initialized
      await _initializeControllerFuture;

      // Capture the image and save it
      final XFile? imageFile = await _controller.takePicture();

      // Save the image to the gallery using image_gallery_saver package
      // Add your code here to save the image to the gallery

      // Show a message to indicate that the image was captured and saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to ${imageFile?.path ?? 'Unknown path'}'),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console
      print('Error capturing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the camera preview
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initializeControllerFuture != null ? _captureImage : null,
        child: Icon(Icons.camera),
      ),
    );
  }
}
