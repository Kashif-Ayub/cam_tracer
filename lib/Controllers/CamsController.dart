import 'dart:async';
import 'dart:convert';
import 'package:cam_tracer/Repository/Dbhandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/Constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

class CamsController extends GetxController {
  late StreamSubscription<Position> _positionStreamSubscription;
  // late StreamSubscription<GyroscopeEvent> _gyrostream;
  var currentspeed = 0.0.obs;
  double thresholdDistance = 1000;
  double speedtocompare = 0.0;
  DbHandler? db;
  var camslatlong = List<Marker>.empty().obs;
  var searchedlatlong = List<Marker>.empty().obs;
  var currentPos = const LatLng(0, 0).obs;
  var searchedPos = const LatLng(0, 0).obs;
  int indx = 0;
  var mapRotation = 0.0.obs;
  var searched = false.obs;
  int first_call = 0;
  bool _user = true;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _initializeDb();
    _assignvals();
    _fetchSpeed();
    // _maporiantation();
    // _getCamsCoordinates();
  }

  // _maporiantation() {
  //   _gyrostream = gyroscopeEvents.listen((event) {});
  //   _gyrostream.onData((data) {
  //     mapRotation.value -= data.z * 0.05;
  //     print("Map Rotated Data :${mapRotation.value}");
  //   });
  // }

  @override
  void onClose() {
    _positionStreamSubscription.cancel();
    // _gyrostream.cancel();
    super.onClose();
  }

  _initializeDb() async {
    db = await DbHandler.getInstance();
    db1 = db;
    camslatlong.value = await db!.getCamsCoordinates();
  }

  _assignvals() async {
    SharedPreferences prefs = await getPrefrences();
    prefs.getString("speedunits") != null
        ? selectedspeedunits.value = prefs.getString("speedunits")!
        : selectedspeedunits.value = "m/s";
    prefs.getString("vibration") != null
        ? vibration.value = prefs.getString("vibration")!
        : vibration.value = "One time";
    prefs.getString("selectedVehicleType") != null
        ? selectedVehicleType.value = prefs.getString("selectedVehicleType")!
        : selectedVehicleType.value = "LTV";
    prefs.getString("warningdistance") != null
        ? warningdistance.value = prefs.getString("warningdistance")!
        : warningdistance.value = "Default";
    prefs.getBool("speedlimitenabled") != null
        ? speedlimitenabled.value = prefs.getBool("speedlimitenabled")!
        : speedlimitenabled.value = false;
  }

  _fetchSpeed() async {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      currentspeed.value = selectedspeedunits.value == "km/h"
          ? position.speed * 3.6
          : selectedspeedunits.value == "m/h"
              ? position.speed * 2.23694
              : position.speed;
      speedtocompare = position.speed * 3.6;
    });
  }

  Future<void> RequestLocationPermission() async {
    //one Time
    // await Vibration.vibrate();
    // //Double
    // await Vibration.vibrate(pattern: [100, 500, 100, 500]);
    // //Long
    // await Vibration.vibrate(duration: 1000);
    bool serviceEnabled;
    PermissionStatus permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, open location settings
      await Geolocator.openLocationSettings();
    }

    // Check if we have permission to access location
    permission = await Permission.locationWhenInUse.status;
    if (permission == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
    if (permission == PermissionStatus.granted) {
      await _setCurrentPos();
    }
    if (permission == PermissionStatus.denied ||
        permission == PermissionStatus.permanentlyDenied) {
      permission = await Permission.locationWhenInUse.request();
      if (permission == PermissionStatus.granted) {
        permission = await Permission.locationAlways.request();
        await _setCurrentPos();
      }
      if (permission == PermissionStatus.denied) {
        await openAppSettings();
      }
      await _setCurrentPos();
    }
  }

  _setCurrentPos() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentPos.value = LatLng(position.latitude, position.longitude);
    currentPos.refresh();
    await _DistanceFilter(currentPos.value);
  }

  Future<bool> checkspeedlimit(LatLng p) async {
    if (speedlimitenabled.value) {
      var url =
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${p.latitude}&lon=${p.longitude}&zoom=18&addressdetails=1';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(response.body);
        var data = jsonDecode(response.body);
        var road = data['address']['road'];
        var highway = data['address']['highway'];
        if (road == "مری روڈ" ||
            road == "سرینگر ہائی وے" ||
            road == "Islamabad Expressway") {
          if (selectedVehicleType.value == "LTV") {
            if (speedtocompare <= 80) {
              return false;
            } else {
              return true;
            }
          } else if (selectedVehicleType.value == "HTV") {
            if (speedtocompare <= 65) {
              return false;
            } else {
              return true;
            }
          }
        }

        if (road == "شارع دستور" ||
            road == "Park Road" ||
            road == "جناح ایونیو" ||
            road == "پارک روڈ" ||
            road == "Faisal Avenue" ||
            road == "7th Avenue" ||
            road == "Agha Shahi (9th) Avenue") {
          if (selectedVehicleType.value == "LTV") {
            if (speedtocompare <= 70) {
              return false;
            } else {
              return true;
            }
          } else if (selectedVehicleType.value == "HTV") {
            if (speedtocompare <= 65) {
              return false;
            } else {
              return true;
            }
          }
        }

        if (road == "Lehtrar Road") {
          if (selectedVehicleType.value == "LTV") {
            if (speedtocompare <= 40) {
              return false;
            } else {
              return true;
            }
          } else if (selectedVehicleType.value == "HTV") {
            if (speedtocompare <= 40) {
              return false;
            } else {
              return true;
            }
          }
        }

        if (road == "Kahuta Road" || road == "IJP Road") {
          if (selectedVehicleType.value == "LTV") {
            if (speedtocompare <= 60) {
              return false;
            } else {
              return true;
            }
          } else if (selectedVehicleType.value == "HTV") {
            if (speedtocompare <= 60) {
              return false;
            } else {
              return true;
            }
          }
        }
        var type = data['type'];
        if (type == "residential") {
          if (selectedVehicleType.value == "LTV") {
            if (speedtocompare <= 30) {
              return false;
            } else {
              return true;
            }
          } else if (selectedVehicleType.value == "HTV") {
            if (speedtocompare <= 25) {
              return false;
            } else {
              return true;
            }
          }
        }
        if (type == "unclassified" || type == "trunk") {
          if (selectedVehicleType.value == "LTV") {
            if (speedtocompare <= 50) {
              return false;
            } else {
              return true;
            }
          } else if (selectedVehicleType.value == "HTV") {
            if (speedtocompare <= 50) {
              return false;
            } else {
              return true;
            }
          }
        }
        if (selectedVehicleType.value == "LTV") {
          if (speedtocompare <= 60) {
            return false;
          } else {
            return true;
          }
        } else if (selectedVehicleType.value == "HTV") {
          if (speedtocompare <= 40) {
            return false;
          } else {
            return true;
          }
        }
      } else {
        print('Failed to get road data from OpenStreetMap');
      }
    }
    return true;
  }

  _DistanceFilter(LatLng currentPosition) async {
    final Uint8List user_marker =
        await getBytesFromAssets("assets/images/user.png", 150);
    final Uint8List speedcam_marker =
        await getBytesFromAssets("assets/images/inradar.png", 150);
    final Uint8List speedcam_marker1 =
        await getBytesFromAssets("assets/images/speedcam1.png", 150);
    if (currentPosition.latitude != 0) {
      // Calculate the distance between the user's current position and the other locations
      for (int i = 0; i < camslatlong.length; i++) {
        if (camslatlong[i].markerId.value != "user") {
          double distanceInMeters = await Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            camslatlong[i].position.latitude,
            camslatlong[i].position.longitude,
          );
          warningdistance.value == "1500m"
              ? thresholdDistance = 1500
              : warningdistance.value == "2000m"
                  ? thresholdDistance = 2000
                  : thresholdDistance = 1000;
          if (distanceInMeters > thresholdDistance) {
            // print(
            //     'The user is more than 1km ahead of the other location.${distanceInMeters}');
          } else {
            // Check if the user is on the same way as the other location
            double bearing = await Geolocator.bearingBetween(
              currentPosition.latitude,
              currentPosition.longitude,
              camslatlong[i].position.latitude,
              camslatlong[i].position.longitude,
            );
            double userBearing = currentPosition.latitude;
            // print(
            //     'The user is less than 1km ahead and on the same way as the other location.${distanceInMeters} ID ${camslatlong[i].markerId.value} Angle ${(bearing - userBearing).abs()} Current Position lat: ${currentPosition.latitude} long :${currentPosition.longitude}');
            if ((bearing - userBearing).abs() < 45 &&
                await checkspeedlimit(currentPosition)) {
              // Add the marker for the location if it's within 1
              vibration.value == "One time"
                  ? await Vibration.vibrate()
                  : vibration.value == "Double"
                      ? await Vibration.vibrate(pattern: [100, 500, 100, 500])
                      : await Vibration.vibrate(duration: 1000);
              Get.snackbar("Speed Cam Detected",
                  "Speed Cam is ${distanceInMeters.toStringAsFixed(2)} Meters away from you ",
                  snackPosition: SnackPosition.TOP,
                  padding: const EdgeInsets.all(20),
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 15, right: 15),
                  backgroundColor: const Color.fromARGB(255, 250, 190, 172));
// kilometer and on the same way as the user
              // print(
              //     'The user is less than 1km ahead and on the same way as the other location.${distanceInMeters}');

              if (indx != i) {
                camslatlong[indx] = camslatlong[indx].copyWith(
                  iconParam: BitmapDescriptor.fromBytes(speedcam_marker1),
                );
              }
              camslatlong[i] = camslatlong[i].copyWith(
                iconParam: BitmapDescriptor.fromBytes(speedcam_marker),
              );
              camslatlong.refresh();

              indx = i;
            }
          }
        } else {
          _user = false;
          // double bearing = LatLng(camslatlong[i].position.latitude,
          //             camslatlong[i].position.longitude) ==
          //         null
          //     ? 0
          //     : Geolocator.bearingBetween(
          //         camslatlong[i].position.latitude,
          //         camslatlong[i].position.longitude,
          //         currentPosition.latitude,
          //         currentPosition.longitude);

          camslatlong.removeAt(i);
          camslatlong.value.add(Marker(
            markerId: const MarkerId("user"),
            position:
                LatLng(currentPosition.latitude, currentPosition.longitude),
            infoWindow: const InfoWindow(title: "user"),
            icon: BitmapDescriptor.fromBytes(user_marker),
            // rotation: bearing,
          ));
        }
      }
      if (_user) {
        camslatlong.value.add(Marker(
          markerId: const MarkerId("user"),
          position: LatLng(currentPosition.latitude, currentPosition.longitude),
          infoWindow: const InfoWindow(title: "user"),
          icon: BitmapDescriptor.fromBytes(user_marker),
        ));
      }
    }
  }

//For Cam Animation
  Future<void> moveCameraToVisibleBounds(
      GoogleMapController controller, LatLng currentLocation) async {
    if (controller.isBlank != null) {
      LatLngBounds currentBounds = await controller.getVisibleRegion();
      if (!currentBounds.contains(currentLocation)) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: 14.0,
            ),
          ),
        );
      } else {
        print("ITS  IN THE VISIBLE REGION");
        // controller.animateCamera(
        //   CameraUpdate.newCameraPosition(
        //     CameraPosition(
        //       target: currentLocation,
        //       zoom: 14.0,
        //     ),
        //   ),
        // );
      }
    }
  }
}
