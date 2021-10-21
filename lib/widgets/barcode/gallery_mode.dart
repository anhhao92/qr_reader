import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryMode extends StatefulWidget {
  final Function(InputImage inputImage) processImage;

  @override
  State<GalleryMode> createState() => _GalleryModeState();

  const GalleryMode({
    Key? key,
    required this.processImage,
  }) : super(key: key);
}

class _GalleryModeState extends State<GalleryMode> {
  File? _image;
  final ImagePicker _imagePicker = ImagePicker();

  void _processPickedFile(XFile pickedFile) {
    final inputImage = InputImage.fromFilePath(pickedFile.path);
    widget.processImage(inputImage);
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('No image selected.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: [
      if (_image != null)
        SizedBox(
          height: 400,
          width: 400,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.file(_image!),
            ],
          ),
        )
      else
        const Icon(
          Icons.image,
          size: 200,
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
    ]);
  }
}
