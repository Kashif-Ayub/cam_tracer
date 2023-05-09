import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../Controllers/CamsController.dart';
import '../Widgets/Appbar.dart';
import 'package:http/http.dart' as http;
import '../Widgets/Drawer.dart';
import 'package:cam_tracer/Constants/Constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final _cont = Get.put<CamsController>(CamsController());
  final Completer<GoogleMapController> _controller = Completer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraanimator();
    _usermaptype();
  }

  _usermaptype() async {
    SharedPreferences prefs = await getPrefrences();
    prefs.getString("MapType") != null
        ? selectedMapType.value = prefs.getString("MapType")!
        : selectedMapType.value = "Normal";
    prefs.getBool("trafficenabled") != null
        ? trafficenabled.value = prefs.getBool("trafficenabled")!
        : trafficenabled.value = false;
  }

  Timer? _timer;
  cameraanimator() async {
    if (!(_cont.searched.value)) {
      _timer = Timer.periodic(Duration(seconds: 3), (Timer t) async {
        _cont.RequestLocationPermission().then((_) async {
          // await CachedNetworkTileProvider(
          //   baseUrl: "https://tile.openstreetmap.org",
          //   tileSize: 256,
          //   maxZoom: 18,
          // ).preloadTiles();
        });
        if (_cont.currentPos.value.latitude != 0) {
          final controller = await _controller.future;
          await _cont.moveCameraToVisibleBounds(
              controller, _cont.currentPos.value);
        }
      });
    } else {
      _timer!.cancel();
      final controller = await _controller.future;
      await _cont.moveCameraToVisibleBounds(
          controller, _cont.searchedPos.value);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: _cont.initialized
          ? Stack(
              children: [
                Obx(() => GoogleMap(
                      // onTap: (LatLng p) async {
                      //   var url =
                      //       'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${p.latitude}&lon=${p.longitude}&zoom=18&addressdetails=1';
                      //   var response = await http.get(Uri.parse(url));
                      //   if (response.statusCode == 200) {
                      //     print(response.body);
                      //     var data = jsonDecode(response.body);
                      //     var road = data['address']['road'];

                      //     var highway = data['address']['highway'];
                      //     if (road == "مری روڈ") {
                      //       print("its Muree Road");
                      //     }
                      //     if (road == "Islamabad Expressway") {
                      //       print("its Islamabad Expressway");
                      //     }
                      //     if (road == "سرینگر ہائی وے") {
                      //       print("its Srinagar Highway ");
                      //     }
                      //     if (road == "شارع دستور") {
                      //       print("its Constitution Avenue");
                      //     }
                      //     if (road == "جناح ایونیو") {
                      //       print("its Jinnah Avenue");
                      //     }
                      //     if (road == "Park Road") {
                      //       print("its Park Road");
                      //     }
                      //     if (road == "پارک روڈ") {
                      //       print("its Park Road");
                      //     }
                      //     if (road == "7th Avenue") {
                      //       print("its 7th Avenue");
                      //     }

                      //     if (road == "Lehtrar Road") {
                      //       print("its Lehtrar Road");
                      //     }

                      //     if (road == "Kahuta Road") {
                      //       print("its Kahuta Road");
                      //     }
                      //     if (road == "IJP Road") {
                      //       print("its IJP Road");
                      //     }
                      //     if (road == "Agha Shahi (9th) Avenue") {
                      //       print("its 9th Avenue");
                      //     }
                      //     if (highway != null) {
                      //       print('Road type: $highway');
                      //     } else {
                      //       print('No road type found');
                      //     }
                      //   } else {
                      //     print('Failed to get road data from OpenStreetMap');
                      //   }
                      // },
                      trafficEnabled: trafficenabled.value,
                      mapType: selectedMapType.value == "Normal"
                          ? MapType.normal
                          : selectedMapType.value == "Satellite"
                              ? MapType.satellite
                              : selectedMapType.value == "Hybrid"
                                  ? MapType.hybrid
                                  : selectedMapType.value == "Terrain"
                                      ? MapType.terrain
                                      : MapType.normal,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(33.6844, 73.0479),
                        zoom: 13.4746,
                      ),
                      markers: Set<Marker>.of(_cont.searched.value
                          ? _cont.searchedlatlong.value
                          : _cont.camslatlong.value),
                      onMapCreated: (GoogleMapController controller) async {
                        _controller.complete(controller);
                      },
                      // tileOverlays: <TileOverlay>[
                      //   TileOverlay(
                      //       tileOverlayId: TileOverlayId("cached_tiles"),
                      //       tileProvider: CachedNetworkTileProvider(
                      //           baseUrl: "https://tile.openstreetmap.org",
                      //           tileSize: 256,
                      //           maxZoom: 18),
                      //       zIndex: 1000)
                      // ].toSet(),
                    )),
                Obx(() => searchVisible.value
                    ? SizedBox(
                        height: 50.h,
                        child: Obx(() => ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: searchResults.length,
                              physics: const ScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    _cont.searchedlatlong.clear();
                                    print(
                                        'Longitudes of Selected Item :${searchResults[index]['name']}');
                                    _cont.searchedlatlong.refresh();
                                    _cont.searchedPos.value = LatLng(
                                        double.parse(
                                            searchResults[index]['lat']),
                                        double.parse(
                                            searchResults[index]['lon']));
                                    _cont.searched.value = true;

                                    _cont.searchedlatlong.add(Marker(
                                      markerId: const MarkerId("searched"),
                                      position: _cont.searchedPos.value,
                                    ));

                                    cameraanimator();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                    ),
                                    child: Text(searchResults[index]['name']),
                                  ),
                                );
                              },
                            )),
                      )
                    : Container()),
                Obx(() => _cont.searched.value
                    ? Positioned(
                        top: 60.sp,
                        right: 16.sp,
                        child: InkWell(
                          onTap: () {
                            searchVisible.value = false;
                            _cont.searched.value = false;
                            cameraanimator();
                            print("Pressed button starting again cam tracking");
                          },
                          child: Container(
                            width: 50.w,
                            height: 50.h,
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          ),
                        ))
                    : Container()),
                Positioned(
                    bottom: 60.sp,
                    left: 16.sp,
                    child: Container(
                      height: 100.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2.r,
                                blurRadius: 5.r,
                                offset: Offset(0, 3)),
                          ]),
                      child: Obx(() => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _cont.currentspeed.value.toStringAsFixed(0),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                selectedspeedunits.value.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          )),
                    )),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}

// class CachedNetworkTileProvider extends TileProvider {
//   final String baseUrl;
//   final int tileSize;
//   final int maxZoom;
//   Map<String, Uint8List> _tiles = {};

//   CachedNetworkTileProvider({
//     required this.baseUrl,
//     required this.tileSize,
//     required this.maxZoom,
//   });

//   Future<void> preloadTiles() async {
//     for (var z = 0; z <= maxZoom; z++) {
//       final tilesCount = pow(2, z);
//       for (var x = 0; x < tilesCount; x++) {
//         for (var y = 0; y < tilesCount; y++) {
//           final tileUrl = '$baseUrl/$z/$x/$y.png';
//           final file = await DefaultCacheManager().getSingleFile(tileUrl);
//           if (await file.exists()) {
//             final bytes = await file.readAsBytes();
//             _tiles[tileUrl] = bytes;
//           } else {
//             try {
//               final response = await http.get(Uri.parse(tileUrl));
//               if (response.statusCode == 200) {
//                 final bytes = response.bodyBytes;
//                 final tempFile = await File(
//                         '${(await getTemporaryDirectory()).path}/$tileUrl')
//                     .create(recursive: true);
//                 await tempFile.writeAsBytes(bytes);
//                 await DefaultCacheManager()
//                     .putFile(tileUrl, tempFile.readAsBytesSync());
//                 _tiles[tileUrl] = bytes;
//               }
//             } catch (e) {
//               print('Failed to load tile: $tileUrl, error: $e');
//             }
//           }
//         }
//       }
//     }
//   }

//   @override
//   Future<Tile> getTile(int x, int y, int? zoom) async {
//     final tileUrl = '$baseUrl/$zoom/$x/$y.png';
//     if (_tiles.containsKey(tileUrl)) {
//       return Tile(tileSize, tileSize, _tiles[tileUrl]!);
//     } else {
//       final file = await DefaultCacheManager().getSingleFile(tileUrl);
//       if (await file.exists()) {
//         final bytes = await file.readAsBytes();
//         _tiles[tileUrl] = bytes;
//         return Tile(tileSize, tileSize, bytes);
//       } else {
//         try {
//           final response = await http.get(Uri.parse(tileUrl));
//           if (response.statusCode == 200) {
//             final bytes = response.bodyBytes;
//             final tempFile =
//                 await File('${(await getTemporaryDirectory()).path}/$tileUrl')
//                     .create(recursive: true);
//             await tempFile.writeAsBytes(bytes);
//             await DefaultCacheManager()
//                 .putFile(tileUrl, tempFile.readAsBytesSync());
//             _tiles[tileUrl] = bytes;
//             return Tile(tileSize, tileSize, bytes);
//           } else {
//             return Tile(tileSize, tileSize, Uint8List.fromList([]));
//           }
//         } catch (e) {
//           print('Failed to load tile: $tileUrl, error: $e');
//           return Tile(tileSize, tileSize, Uint8List.fromList([]));
//         }
//       }
//     }
//   }
// }
