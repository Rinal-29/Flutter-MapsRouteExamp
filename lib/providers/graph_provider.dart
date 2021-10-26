import 'package:flutter/material.dart';
import 'package:fmaps_route/models/graph_model.dart';
import 'package:fmaps_route/services/graph_service.dart';

class GraphProvider with ChangeNotifier {
  List<GraphModel> _locations = [];

  List<GraphModel> get locations => _locations;

  set locations(List<GraphModel> locations) {
    _locations = locations;
    notifyListeners();
  }

  Future<void> getLocationsManually() async {
    try {
      List<GraphModel> locations = await GraphService().getManuallyLocation();
      _locations = locations;
    } catch (e) {
      print('errors $e');
    }
  }
}
