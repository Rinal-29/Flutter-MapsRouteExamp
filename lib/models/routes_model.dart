class RoutesModel {
  int id;
  String name;
  double lat;
  double lng;

  RoutesModel({
    this.id,
    this.name,
    this.lat,
    this.lng,
  });

  RoutesModel.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lat = double.parse(json['lat']);
    lng = double.parse(json['lng']);
  }
}
