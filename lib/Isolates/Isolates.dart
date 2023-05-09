// import 'dart:isolate';

// import 'package:cam_tracer/Constants/Constants.dart';
// import 'package:cam_tracer/Repository/Dbhandler.dart';
// import 'package:flutter_isolate/flutter_isolate.dart';

// @pragma('vm:entry-point')
// void InitializeDbInBackGround(SendPort port) async {
//   DbHandler? db;
//   db = await DbHandler.getInstance();
//   await db.getCamsCoordinates();
 // port.send("executed");
// }
