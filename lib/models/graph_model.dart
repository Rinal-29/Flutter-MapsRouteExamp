import 'package:fmaps_route/models/routes_model.dart';

class GraphModel {
  int id;
  String name;
  double lat;
  double lng;
  String address;
  List<RoutesModel> routes;

  GraphModel({
    this.id,
    this.name,
    this.lat,
    this.lng,
    this.address,
    this.routes,
  });

  GraphModel.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lat = double.parse(json['lat']);
    lng = double.parse(json['lng']);
    address = json['address'];
    routes = json['routes']
        .map<RoutesModel>((routes) => RoutesModel.fromJSON(routes))
        .toList();
  }
}
