import 'dart:io';
import 'package:cam_tracer/Constants/Constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class MyDrawer extends StatefulWidget {
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  var accountName = "".obs;
  var accountEmail = "".obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfileImageAndUserInfo();
  }

  _getProfileImageAndUserInfo() async {
    await db1!.loadImage();
    SharedPreferences prefs = await getPrefrences();
    prefs.getString("username") != null
        ? accountName.value = prefs.getString("username")!
        : "";
    prefs.getString("useraccount") != null
        ? accountEmail.value = prefs.getString("useraccount")!
        : "";

    // Map<String, dynamic> user = await db1!.getUser();
    // accountName = user['username'];
    // accountEmail = user['email'];
  }

  Future<void> _showDialog(String field) async {
    String title = field == "accountName" ? "Account Name" : "Email";
    TextEditingController textController = TextEditingController();
    bool isValid = true;
    SharedPreferences _prefs = await getPrefrences();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              autofocus: true,
              controller: textController,
              decoration: InputDecoration(
                labelText: "Enter $title",
                errorText: isValid ? null : "Invalid email format",
              ),
              onChanged: (value) {
                if (field == "accountEmail") {
                  setState(() {
                    isValid = EmailValidator.validate(value);
                  });
                }
              },
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Save"),
                onPressed: isValid
                    ? () {
                        if (field == "accountName") {
                          accountName.value = textController.text;
                          _prefs.setString("username", textController.text);
                        } else {
                          accountEmail.value = textController.text;
                          _prefs.setString("useraccount", textController.text);
                        }
                        Navigator.pop(context);
                      }
                    : null,
              ),
            ],
          );
        });
      },
    );
  }

  // void _saveAccountName() async {
  //   // User? user = await db1!.getUser();
  //   // if (user == null) {
  //   //   await db1!.insertUser(User(accountName: accountName));
  //   // } else {
  //   //   user.accountName = accountName;
  //   //   await db1!.updateUser(user);
  //   // }
  // }

  // void _saveAccountEmail() async {
  //   // User? user = await db1!.getUser();
  //   // if (user == null) {
  //   //   await db1!.insertUser(User(accountEmail: accountEmail));
  //   // } else {
  //   //   user.accountEmail = accountEmail;
  //   //   await db1!.updateUser(user);
  //   // }
  // }
  _setmapType(String type) async {
    selectedMapType.value = type;
    SharedPreferences prefs = await getPrefrences();
    prefs.setString("MapType", type);
  }

  _setspeedUnits(String units) async {
    selectedspeedunits.value = units;
    SharedPreferences prefs = await getPrefrences();
    prefs.setString("speedunits", units);
  }

  _setVibration(String type) async {
    vibration.value = type;
    SharedPreferences prefs = await getPrefrences();
    prefs.setString("vibration", type);
  }

  _setVehicleType(String type) async {
    selectedVehicleType.value = type;
    SharedPreferences prefs = await getPrefrences();
    prefs.setString("selectedVehicleType", type);
  }

  _setwarningdistane(String d) async {
    warningdistance.value = d;
    SharedPreferences prefs = await getPrefrences();
    prefs.setString("warningdistance", d);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: InkWell(
              child: Obx(() => Text(
                  accountName.value != "" ? accountName.value : 'UserName')),
              onTap: () {
                _showDialog("accountName");
              },
            ),
            accountEmail: InkWell(
              child: Obx(() => Text(
                  accountEmail.value != "" ? accountEmail.value : 'Email')),
              onTap: () {
                _showDialog("accountEmail");
              },
            ),
            currentAccountPicture: InkWell(
              child: Obx(() => CircleAvatar(
                    backgroundImage: profileimage.value.path != ""
                        ? FileImage(File(profileimage.value.path))
                        : null,
                    foregroundImage: profileimage.value.path == ""
                        ? const AssetImage("assets/images/dp.png")
                        : null,
                  )),
              onTap: () {
                getImageFromGalleryOrCamera(context);
              },
            ),
          ),
          Obx(() => ExpansionTile(
                leading: const Icon(Icons.map),
                title: Text("Map Type: ${selectedMapType.value}"),
                children: [
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text("Normal"),
                    selected: selectedMapType.value == "Normal",
                    onTap: () {
                      _setmapType("Normal");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.satellite),
                    title: const Text("Satellite"),
                    selected: selectedMapType.value == "Satellite",
                    onTap: () {
                      _setmapType("Satellite");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.layers),
                    title: const Text("Hybrid"),
                    selected: selectedMapType.value == "Hybrid",
                    onTap: () {
                      _setmapType("Hybrid");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.terrain),
                    title: const Text("Terrain"),
                    selected: selectedMapType.value == "Terrain",
                    onTap: () {
                      _setmapType("Terrain");
                    },
                  ),
                ],
              )),
          const Divider(
              height: 1,
              thickness: 0.5,
              color: Color.fromARGB(255, 153, 212, 241)),
          Obx(() => ExpansionTile(
                leading: const Icon(Icons.car_crash),
                title: Text("Vehicle Type: ${selectedVehicleType.value}"),
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.directions_car,
                    ),
                    title: const Text("LTV"),
                    selected: selectedVehicleType.value == "LTV",
                    onTap: () {
                      _setVehicleType("LTV");
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.directions_bus,
                    ),
                    title: const Text("HTV"),
                    selected: selectedVehicleType.value == "HTV",
                    onTap: () {
                      _setVehicleType("HTV");
                    },
                  ),
                ],
              )),
          const Divider(
              height: 1,
              thickness: 0.5,
              color: Color.fromARGB(255, 153, 212, 241)),
          Obx(() => ExpansionTile(
                leading: const Icon(Icons.compare_arrows),
                title: Text("Units Speedometer: ${selectedspeedunits.value}"),
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.speed,
                    ),
                    title: const Text("km/h"),
                    selected: selectedspeedunits.value == "km/h",
                    onTap: () {
                      _setspeedUnits("km/h");
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.speed,
                    ),
                    title: const Text("m/h"),
                    selected: selectedspeedunits.value == "m/h",
                    onTap: () {
                      _setspeedUnits("m/h");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text("m/s"),
                    selected: selectedspeedunits.value == "m/s",
                    onTap: () {
                      _setspeedUnits("m/s");
                    },
                  ),
                ],
              )),
          const Divider(
              height: 1,
              thickness: 0.5,
              color: Color.fromARGB(255, 153, 212, 241)),
          Obx(() => ExpansionTile(
                leading: const Icon(Icons.vibration),
                title: Text("Vibration: ${vibration.value}"),
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.one_x_mobiledata,
                    ),
                    title: const Text("One time"),
                    selected: vibration.value == "One time",
                    onTap: () {
                      _setVibration("One time");
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.double_arrow,
                    ),
                    title: const Text("Double"),
                    selected: vibration.value == "Double",
                    onTap: () {
                      _setVibration("Double");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text("Long"),
                    selected: vibration.value == "Long",
                    onTap: () {
                      _setVibration("Long");
                    },
                  ),
                ],
              )),
          const Divider(
              height: 1,
              thickness: 0.5,
              color: Color.fromARGB(255, 153, 212, 241)),
          Obx(() => ExpansionTile(
                leading: const Icon(Icons.warning),
                title: Text("Warning Distance: ${warningdistance.value}"),
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.radar,
                    ),
                    title: const Text("Default"),
                    selected: warningdistance.value == "Default",
                    onTap: () {
                      _setwarningdistane("Default");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.radar),
                    title: const Text("1500m"),
                    selected: warningdistance.value == "1500m",
                    onTap: () {
                      _setwarningdistane("1500m");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.radar),
                    title: const Text("2000m"),
                    selected: warningdistance.value == "2000m",
                    onTap: () {
                      _setwarningdistane("2000m");
                    },
                  ),
                ],
              )),
          const Divider(
              height: 1,
              thickness: 0.5,
              color: Color.fromARGB(255, 153, 212, 241)),
          ListTile(
              title: const Text('Enable Traffic'),
              trailing: Obx(() => CupertinoSwitch(
                    dragStartBehavior: DragStartBehavior.down,
                    value: trafficenabled.value,
                    onChanged: (bool value) async {
                      trafficenabled.value = value;
                      SharedPreferences prefs = await getPrefrences();
                      prefs.setBool("trafficenabled", trafficenabled.value);
                    },
                    activeColor: const Color.fromARGB(255, 0, 255, 0),
                  ))),
          const Divider(
              height: 1,
              thickness: 0.5,
              color: Color.fromARGB(255, 153, 212, 241)),
          ListTile(
              title: const Text(
                  'Warn only if the current speed is over the speed limit'),
              trailing: Obx(() => CupertinoSwitch(
                    dragStartBehavior: DragStartBehavior.down,
                    value: speedlimitenabled.value,
                    onChanged: (bool value) async {
                      speedlimitenabled.value = value;
                      SharedPreferences prefs = await getPrefrences();
                      prefs.setBool(
                          "speedlimitenabled", speedlimitenabled.value);
                    },
                    activeColor: const Color.fromARGB(255, 0, 255, 0),
                  ))),
        ],
      ),
    );
  }
}
