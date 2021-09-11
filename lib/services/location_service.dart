import 'dart:convert';

import 'package:fmaps_route/models/location_model.dart';
import 'package:http/http.dart' as http;

class LocationService {
  String baseURL = 'https://pso-maps.000webhostapp.com/api';

  Future<List<LocationModel>> getLocations() async {
    var url = Uri.parse('$baseURL/locations');

    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      print('masuk get locations services');
      List data = jsonDecode(response.body)['data']['data'];
      List<LocationModel> locations = [];

      print('data $data');
      print(data[0]['galleries']);
      print(data.length);

      for (var item in data) {
        locations.add(LocationModel.fromJSON(item));
      }

      return locations;
    } else {
      throw Exception('Gagal mendapatkan lokasi');
    }
  }
}
