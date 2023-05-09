import 'dart:async';
import 'package:cam_tracer/Views/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Controllers/CamsController.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //  final _cont1 = Get.put<CamsController>(CamsController());
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (cntext) => const Maps()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[500],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/speedcam.png',
              height: 250.h,
            ),
            SizedBox(height: 20.h),
            Text(
              "SPEED CAM TRACKER",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontSize: 25.sp),
            ),
            SizedBox(height: 30.w),
            SpinKitChasingDots(
              color: Colors.white,
              size: 50.r,
            ),
          ],
        ),
      ),
    );
  }
}
