import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fmaps_route/models/graph_model.dart';

class GraphService {
  Future<List<GraphModel>> getManuallyLocation() async {
    String jsonString = await rootBundle.loadString('assets/locations.json');
    List data = json.decode(jsonString)['data'];

    print('data2 $data');
    print('masuk get locations manually');

    List<GraphModel> locations = [];

    for (var item in data) {
      locations.add(GraphModel.fromJSON(item));
    }

    return locations;
  }
}
