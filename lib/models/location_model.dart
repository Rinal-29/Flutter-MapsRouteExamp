import 'package:fmaps_route/models/gallery_model.dart';

class LocationModel {
  int id;
  String name;
  double lat;
  double lng;
  String address;
  String description;
  String facility;
  String openTime;
  List<GalleryModel> galleries;

  LocationModel({
    this.id,
    this.name,
    this.lat,
    this.lng,
    this.address,
    this.description,
    this.facility,
    this.openTime,
    this.galleries,
  });

  LocationModel.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lat = double.parse(json['latitude']);
    lng = double.parse(json['longitude']);
    address = json['address'];
    description = json['description'];
    facility = json['facility'];
    openTime = json['open_time'];
    galleries = json['galleries']
        .map<GalleryModel>((gallery) => GalleryModel.fromJson(gallery))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'address': address,
      'description': description,
      'facility': facility,
      'open_time': openTime,
      'galleries': galleries.map((gallery) => gallery.toJson()).toList(),
    };
  }
}
