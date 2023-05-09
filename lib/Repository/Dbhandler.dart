import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Models/SpeedCams.dart';
import 'package:flutter/services.dart';
import 'package:cam_tracer/Constants/Constants.dart';

class DbHandler {
  Database? _db;
  static DbHandler? _obj = null;
  int _dbversion = 2;

  DbHandler._Init();

  static Future<DbHandler> getInstance() async {
    if (_obj == null) {
      _obj = await DbHandler._Init();
      await _obj!._initialize();
    }
    return _obj!;
  }

  Future<void> _initialize() async {
    await _createDb();
  }

  Future<void> _createDb() async {
    Directory dbDir = await getApplicationDocumentsDirectory();
    String dbPath = '${dbDir.path}/CamTracer.db';
    _db = await openDatabase(dbPath, version: _dbversion,
        onCreate: (Database db, int version) async {
      String camsinfo = '''
      CREATE TABLE SpeedCams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lat DOUBLE NOT NULL,
        lng DOUBLE NOT NULL
      )
    ''';

      await db.execute(camsinfo);
      await db.execute(
        'CREATE TABLE IF NOT EXISTS profile_images (id INTEGER PRIMARY KEY  , image_path TEXT)',
      );
      // await db.execute('''
      //     CREATE TABLE user (
      //       Id INTEGER PRIMARY KEY,
      //       Username TEXT,
      //       Email TEXT
      //     )
      //     ''');
      // Check if the table is empty
      var count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM SpeedCams'));
      if (count == 0) {
        // Insert the data only if the table is empty
        await db.insert('SpeedCams', {'lat': 26.770000, 'lng': 82.150002});
        await db.insert('SpeedCams', {'lat': 33.7062, 'lng': 73.0320});
        await db.insert('SpeedCams', {'lat': 33.702663, 'lng': 73.126106});
        await db.insert('SpeedCams', {'lat': 33.6693, 'lng': 73.1062});
        await db.insert('SpeedCams', {'lat': 33.6867, 'lng': 73.1187});
        await db.insert('SpeedCams', {'lat': 33.7154, 'lng': 73.1019});
        await db.insert('SpeedCams', {'lat': 33.6900, 'lng': 73.1180});
        await db.insert('SpeedCams', {'lat': 33.6858, 'lng': 73.1294});
        await db.insert('SpeedCams', {'lat': 33.6800, 'lng': 73.1482});
        await db.insert('SpeedCams', {'lat': 33.738045, 'lng': 73.084488});
        await db.insert('SpeedCams', {'lat': 33.7130, 'lng': 73.1615});
        await db.insert(
            'SpeedCams', {'lat': 33.65912045898088, 'lng': 73.09891109280046});
        await db.insert(
            'SpeedCams', {'lat': 33.674443453051694, 'lng': 73.09387230395079});
        await db.insert(
            'SpeedCams', {'lat': 33.68128085507492, 'lng': 73.10036686669949});
        await db.insert(
            'SpeedCams', {'lat': 33.65953035589999, 'lng': 73.07729719927954});
        await db.insert(
            'SpeedCams', {'lat': 33.65469616471537, 'lng': 73.06874690296306});
        await db.insert('SpeedCams', {'lat': 33.6898673, 'lng': 73.1325473});
        await db.insert('SpeedCams', {'lat': 33.6855673, 'lng': 73.1325673});
        // Insert the rest of the data here
      }
    });
  }

  Future<List<Marker>> getCamsCoordinates() async {
    SpeedCams sc;
    List<Marker> markers = [];
    print("called");
    var clist = await _db?.rawQuery("select * from SpeedCams");

    // Load the PNG image from assets
    final Uint8List speedcam_marker =
        await getBytesFromAssets("assets/images/speedcam1.png", 150);
    clist?.forEach((element) {
      sc = SpeedCams.fromMap(element);

      // Create the Marker with a custom BitmapDescriptor
      markers.add(Marker(
        markerId: MarkerId(sc.id.toString()),
        position: LatLng(sc.lat, sc.lng),
        infoWindow: InfoWindow(title: sc.id.toString()),
        icon: BitmapDescriptor.fromBytes(speedcam_marker),
      ));
    });
    return markers;
  }

  Future<void> loadImage() async {
    final images = await _db?.query('profile_images', limit: 1);
    if (images != null && images.isNotEmpty) {
      final imagePath = images.first['image_path'];

      profileimage.value = File(imagePath as String);
    }
  }

  Future<void> saveProfileImage(File imageFile) async {
    final imageName = path.basename(imageFile.path);
    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = await imageFile.copy('${appDir.path}/$imageName');

    await _db?.delete('profile_images');
    await _db?.insert('profile_images', {'image_path': savedImage.path});
  }

  // Future<int> saveUser(String username, String email) async {
  //   Map<String, dynamic> row = {
  //     'Username': username,
  //     'Email': email,
  //   };
  //   int id = 1;
  //   var result = await _db?.insert("user", row,
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  //   return id;
  // }

  // Future<Map<String, dynamic>> getUser() async {
  //   List<Map<String, dynamic>>? maps =
  //       await _db?.rawQuery('SELECT * FROM user WHERE Id = 1');
  //   if (maps?.length == 0) {
  //     return {'username': '', 'email': ''};
  //   }
  //   return maps!.first;
  // }
}
