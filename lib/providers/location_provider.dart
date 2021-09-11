import 'package:flutter/material.dart';
import 'package:fmaps_route/models/location_model.dart';
import 'package:fmaps_route/services/location_service.dart';

class LocationsProvider with ChangeNotifier {
  List<LocationModel> _locations = [];

  List<LocationModel> get locations => _locations;

  set locations(List<LocationModel> locations) {
    _locations = locations;
    notifyListeners();
  }

  Future<void> getLocations() async {
    try {
      List<LocationModel> locations = await LocationService().getLocations();
      _locations = locations;
    } catch (e) {
      print('errors $e');
    }
  }
}
