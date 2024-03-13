import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    galleryPermission();
  }

  void galleryPermission() async {
    try {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      await Permission.photos.request();
    } catch (_){

    }
  }

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _saveToGallery() async {
    if (_image != null) {
      log("IMAGE_PATH: ${_image?.path}");
      _saveImageToGallery(_image?.path);
      // await GallerySaver.saveImage(_image!.path, albumName: 'YourAlbumName');
    }
  }

  Future<void> _saveImageToGallery(String? path) async {
    if (path == null) return;
    try {
      String folder = 'JAWLINE';
      String location = '/storage/emulated/0/$folder';

      final directory = Directory(location);
      final isExists = directory.existsSync();
      if (!isExists) {
        directory.createSync();
      }

      final isSaved = await GallerySaver.saveImage(path, albumName: folder);

      if (isSaved ?? false) {
        log('Image saved to gallery folder ${directory.path}');
        log('Image saved to gallery path $path');
      } else {
        log('Failed to save image');
      }
    } catch (e) {
      log('Error saving image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery Example'),
      ),
      body: Center(
        child: Image.file(File("/storage/emulated/0/JAWLINE/ramadan-calender-2024-1 (1).jpg")),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            tooltip: 'Pick Image',
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: _saveToGallery,
            tooltip: 'Save to Gallery',
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}
