class SpeedCams {
  var id;
  var lat;
  var lng;
  SpeedCams({required this.id, required this.lat, required this.lng});
  SpeedCams.fromMap(Map<String, dynamic> mp) {
    id = mp["id"];
    lat = mp["lat"];
    lng = mp["lng"];
  }
}
