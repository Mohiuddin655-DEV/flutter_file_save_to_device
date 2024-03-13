import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Folder Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  Future<bool> saveVideo(String url, String fileName) async {

    try {
      // if (Platform.isAndroid) {
      //   if (await _requestPermission(Permission.storage)) {
      //     directory = await getApplicationDocumentsDirectory();
      //     directory = Directory("${directory.path}/RPSApp");
      //     log("DIRECTORY: $directory");
      //   } else {
      //     return false;
      //   }
      // } else {
      //   if (await _requestPermission(Permission.photos)) {
      //     directory = await getTemporaryDirectory();
      //   } else {
      //     return false;
      //   }
      // }
      String folder = 'JAWLINE';
      String location = '/storage/emulated/0/$folder';

      Directory directory = Directory(location);
      final isExists = directory.existsSync();
      if (!isExists) {
        directory.createSync();
      }
      if (!isExists) {
        directory.createSync();
      }
      // directory = Directory("${directory.path}/RPSApp");
      log("DIRECTORY: $directory");
      File saveFile = File("${directory.path}/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded = await saveVideo(
        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
        "video.mp4");
    if (downloaded) {
      if (kDebugMode) {
        print("File Downloaded");
      }
    } else {
      if (kDebugMode) {
        print("Problem Downloading File");
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progress,
                ),
              )
            : ElevatedButton.icon(
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                ),
                onPressed: downloadFile,
                label: const Text(
                  "Download Video",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
      ),
    );
  }
}
