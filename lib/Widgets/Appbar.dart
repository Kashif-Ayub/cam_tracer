import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:cam_tracer/Constants/Constants.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _MyAppBarState createState() => _MyAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 20);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Obx(() => searchVisible.value
          ? TextField(
              decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintStyle: TextStyle(color: Colors.white)),
              onChanged: (query) async {
                if (query.isNotEmpty) {
                  var url =
                      'https://nominatim.openstreetmap.org/search?q=$query&format=json';
                  var response = await http.get(Uri.parse(url));
                  if (response.statusCode == 200) {
                    searchResults.value = jsonDecode(response.body)
                        .map((result) => {
                              'name': result['display_name'],
                              'lat': result['lat'],
                              'lon': result['lon']
                            })
                        .toList();
                  } else {
                    searchResults.value = [];
                  }
                } else {
                  searchResults.value = [];
                }
              },
            )
          : const Text('Speed Cam Tracker')),
      actions: [
        Obx(() => IconButton(
              icon: Icon(searchVisible.value ? Icons.close : Icons.search),
              onPressed: () {
                searchVisible.value = !searchVisible.value;
              },
            )),
      ],
      // bottom: searchResults.isNotEmpty
      //     ? PreferredSize(
      //         preferredSize: const Size.fromHeight(20),
      //         child: Container(
      //           height: 50,
      //           child: Obx(() => ListView.builder(
      //                 scrollDirection: Axis.horizontal,
      //                 itemCount: searchResults.length,
      //                 itemBuilder: (BuildContext context, int index) {
      //                   return GestureDetector(
      //                     onTap: () {
      //                       // handle item selection
      //                     },
      //                     child: Container(
      //                       margin: const EdgeInsets.all(8),
      //                       padding: const EdgeInsets.all(8),
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(16),
      //                         color: Colors.white,
      //                       ),
      //                       child: Text(searchResults[index]['name']),
      //                     ),
      //                   );
      //                 },
      //               )),
      //         ),
      //       )
      //     : null,
    );
  }
}
