import 'dart:io';
import 'dart:ui' as ui;
import 'package:cam_tracer/Repository/Dbhandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

var profileimage = File("").obs;
var searchResults = List<dynamic>.empty().obs;
final searchVisible = false.obs;
DbHandler? db1;
Future<Uint8List> getBytesFromAssets(String path, int height) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetHeight: height);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<void> getImageFromGalleryOrCamera(BuildContext context) async {
  final permissionStatus = await Permission.camera.request();

  if (permissionStatus.isGranted) {
    final pickedImage = await showModalBottomSheet(
      context: context,
      elevation: 10.0,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    ).then((selectedSource) async {
      if (selectedSource != null) {
        final pickedImage =
            await ImagePicker().pickImage(source: selectedSource);
        if (pickedImage != null) {
          await db1?.saveProfileImage(File(pickedImage.path));
          await db1?.loadImage();
        } else {
          print('No image selected.');
        }
      } else {
        print('No image selected.');
      }
    });
  } else {
    print('Permission not granted');
  }
}

Future<SharedPreferences> getPrefrences() async {
  return await SharedPreferences.getInstance();
}

var selectedMapType = "".obs;
var selectedspeedunits = "".obs;
var selectedVehicleType = "".obs;
var vibration = "".obs;
var trafficenabled = false.obs;
var speedlimitenabled = false.obs;
var warningdistance = "".obs;
