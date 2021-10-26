import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fmaps_route/models/location_model.dart';
import 'package:fmaps_route/providers/location_provider.dart';
import 'package:fmaps_route/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

import 'package:provider/provider.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({Key key}) : super(key: key);

  @override
  _RoutesPageState createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  // inisialisasi posisi kamera maps pada kota makassar
  CameraPosition _initialLocation = CameraPosition(
    target: LatLng(-5.1111323, 119.2625381),
  );

  // untuk mengontrol tammpilan pada map
  GoogleMapController mapController;

  //untuk mendapatkan posisi user dan posisi alamat
  Position _currentPosition;
  String _currentAddress;

  //untuk medapatkan posisi awal dan akhir
  String startAddress = '';
  String destinationAddress = '';
  String placeDistance1;
  String placeDistance2;

  //mendapatkan alamat user
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  List<LatLng> polylineCoordinates1 = [];
  List<LatLng> polylineCoordinates2 = [];
  PolylinePoints polylinePoints;

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  List<String> sportsLocations = [];
  List<LocationModel> locations = [];

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        try {
          _currentPosition = position;

          print('Current Pos $_currentPosition');
        } catch (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal Mendapatkan Lokasi pengguna'),
            ),
          );
        }
      });
      await _getAddress();
    });
  }

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      print('places $place');

      setState(() {
        _currentAddress =
            '${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}';

        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 11,
          ),
        ));

        startAddressController.text = _currentAddress;

        startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Mendapatkan Lokasi pengguna'),
        ),
      );
    }
  }

  _calculateDistance() async {
    try {
      print('start address distance $startAddress');
      print('destination $destinationAddress');
      List<Location> startPlacemark = await locationFromAddress(startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(destinationAddress);

      double startLatitude = startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;
      double startLongtitude = startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;
      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongtitude = destinationPlacemark[0].longitude;

      String startCoordinateString = '$startLatitude,$startLongtitude';
      String destinationCordinateString =
          '$destinationLatitude,$destinationLongtitude';

      print('current pos $startCoordinateString');

      // menampilkan titik awal pengguna
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinateString),
        position: LatLng(startLatitude, startLongtitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinateString',
          snippet: startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // menampilkan titik lokasi tujuan pengguna
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCordinateString),
        position: LatLng(destinationLatitude, destinationLongtitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCordinateString',
          snippet: destinationAddress,
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        onTap: () {
          print('tapped markers');
        },
      );

      markers.add(startMarker);
      markers.add(destinationMarker);

      await _createPolylines(startLatitude, startLongtitude,
          destinationLatitude, destinationLongtitude, TravelMode.transit);

      await _createPolylines(startLatitude, startLongtitude,
          destinationLatitude, destinationLongtitude, TravelMode.driving);

      double calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var c = cos;
        var a = 0.5 -
            c((lat2 - lat1) * p) / 2 +
            c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
        return 12742 * asin(sqrt(a));
      }

      double totalDistance1 = 0.0;
      double totalDistance2 = 0.0;

      // melakukan perulangan untuk menghitung jarak rute
      for (var i = 0; i < polylineCoordinates1.length - 1; i++) {
        totalDistance1 += calculateDistance(
            polylineCoordinates1[i].latitude,
            polylineCoordinates1[i].longitude,
            polylineCoordinates1[i + 1].latitude,
            polylineCoordinates1[i + 1].longitude);

        print('total distance1 - node $i  $totalDistance1');
      }

      // melakukan perulangan untuk menghitung jarak rute
      for (var i = 0; i < polylineCoordinates2.length - 1; i++) {
        totalDistance2 += calculateDistance(
            polylineCoordinates2[i].latitude,
            polylineCoordinates2[i].longitude,
            polylineCoordinates2[i + 1].latitude,
            polylineCoordinates2[i + 1].longitude);
      }

      // mengatur posisi kamera pada maps
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(startLatitude, startLongtitude),
            zoom: 15,
            tilt: 50,
            bearing: 45,
          ),
        ),
      );

      // menampilkan jarak untuk melakukan perbandingan
      // jarak terpendek
      setState(() {
        placeDistance1 = totalDistance1.toStringAsFixed(2);
        print('Distance $placeDistance1 km');

        placeDistance2 = totalDistance2.toStringAsFixed(2);
        print('Distance $placeDistance2 km');
      });
    } catch (e) {
      print('error $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan kalkulasi jarak'),
        ),
      );
    }
  }

  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      TravelMode travelMode) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Utils.API_KEY,
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
        travelMode: travelMode);

    // melakukan perulangan untuk pencarian jalur
    if (result.points.isNotEmpty && travelMode == TravelMode.transit) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates1.add(LatLng(point.latitude, point.longitude));
      });

      print('polyline coordinates 1 ${polylineCoordinates1.length}');
    }

    // melakukan perulangan untuk pencarian jalur
    if (result.points.isNotEmpty && travelMode == TravelMode.driving) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates2.add(LatLng(point.latitude, point.longitude));
      });

      print('polyline coordinates 2 ${polylineCoordinates2.length}');
    }

    // menggmabarkan jalur pada maps
    Polyline polyline1 = Polyline(
      polylineId: PolylineId('poly-1'),
      color: Colors.blue,
      points: polylineCoordinates1,
      width: 7,
    );

    // menggambarkan jalur pada maps
    Polyline polyline2 = Polyline(
      polylineId: PolylineId('poly-2'),
      color: Colors.red,
      points: polylineCoordinates2,
      width: 7,
    );

    polylines.add(polyline1);
    polylines.add(polyline2);
  }

  _onSearchTextChanged(String text) async {
    sportsLocations.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    locations.forEach((locationData) {
      if (locationData.name.toLowerCase().contains(text.toLowerCase())) {
        sportsLocations.add(locationData.name);
      }
    });

    setState(() {});
  }

  Widget _textField({
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) => locationCallback(value),
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  Widget dropdownButton() {
    LocationsProvider locationsProvider =
        Provider.of<LocationsProvider>(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: DropdownButtonFormField(
        focusColor: Colors.blue,
        focusNode: desrinationAddressFocusNode,
        decoration: InputDecoration(
          labelText: 'Sport Location',
          prefixIcon: Icon(Icons.looks_two),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
        ),
        isExpanded: true,
        items: locationsProvider.locations.map((map) {
          return DropdownMenuItem(
            child: Text(
              map.name,
              overflow: TextOverflow.ellipsis,
            ),
            value: map.name,
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            print('value $value');
            destinationAddress = value;
          });
        },
      ),
    );
  }

  Widget seacrhBar() {
    LocationsProvider locationsProvider =
        Provider.of<LocationsProvider>(context);
    locations = locationsProvider.locations;

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Card(
            child: ListTile(
              leading: Icon(Icons.search),
              title: TextField(
                controller: destinationAddressController,
                decoration: InputDecoration(
                  hintText: 'Search Location',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchTextChanged,
              ),
              trailing: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  destinationAddressController.clear();
                  destinationAddress = '';
                  placeDistance1 = null;
                  _onSearchTextChanged('');
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: destinationAddress == '' ? true : false,
          child: Container(
            height: 110,
            width: MediaQuery.of(context).size.width * 0.8,
            child: sportsLocations.length != 0 ||
                    destinationAddressController.text.isNotEmpty
                ? Scrollbar(
                    child: ListView.builder(
                      itemCount: sportsLocations.length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: GestureDetector(
                            child: Text(sportsLocations[i]),
                            onTap: () {
                              destinationAddress = sportsLocations[i];
                              destinationAddressController.text =
                                  sportsLocations[i];
                            },
                          ),
                        );
                      },
                    ),
                  )
                : Scrollbar(
                    child: ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: GestureDetector(
                            child: Text(locations[i].name),
                            onTap: () {
                              destinationAddress = locations[i].name;
                              destinationAddressController.text =
                                  locations[i].name;
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget mapView() {
    return GoogleMap(
      initialCameraPosition: _initialLocation,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: Set<Marker>.from(markers),
      polylines: Set<Polyline>.from(polylines),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
    );
  }

  Widget currentLocationButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(
            right: 10,
            bottom: 10,
          ),
          child: ClipOval(
            child: Material(
              color: Colors.orange.shade100,
              child: InkWell(
                splashColor: Colors.orange,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.my_location),
                ),
                onTap: () {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(_currentPosition.latitude,
                            _currentPosition.longitude),
                        zoom: 16.0,
                      ),
                    ),
                  );
                  startAddressController.text = _currentAddress;
                  startAddress = _currentAddress;
                  print('start address ${startAddressController.value.text}');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget zoomButton() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          left: 10,
          bottom: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ClipOval(
              child: Material(
                color: Colors.blue.shade100,
                child: InkWell(
                  splashColor: Colors.blue,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.add),
                  ),
                  onTap: () {
                    mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ClipOval(
              child: Material(
                color: Colors.blue.shade100,
                child: InkWell(
                  splashColor: Colors.blue,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.remove),
                  ),
                  onTap: () {
                    mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget inputField() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                color: Colors.white70, borderRadius: BorderRadius.circular(12)),
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Places',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _textField(
                  label: 'Start',
                  hint: 'Start point',
                  width: MediaQuery.of(context).size.width,
                  prefixIcon: Icon(Icons.looks_one),
                  suffixIcon: Icon(Icons.my_location),
                  controller: startAddressController,
                  focusNode: startAddressFocusNode,
                  locationCallback: (String value) {
                    startAddress = value;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 5,
                ),
                seacrhBar(),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: placeDistance1 == null ? false : true,
                  child: Column(
                    children: [
                      Text(
                        'Jarak $placeDistance1 Km',
                        style: TextStyle(
                          color: Colors.blue.shade500,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        'Jarak $placeDistance2 Km',
                        style: TextStyle(
                          color: Colors.red.shade500,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Show Route',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    startAddressFocusNode.unfocus();
                    desrinationAddressFocusNode.unfocus();
                    setState(() {
                      if (markers.isNotEmpty) markers.clear();
                      if (polylines.isNotEmpty) polylines.clear();
                      if (polylineCoordinates1.isNotEmpty)
                        polylineCoordinates1.clear();
                      if (polylineCoordinates2.isNotEmpty)
                        polylineCoordinates2.clear();
                    });
                    await _calculateDistance();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            mapView(),
            currentLocationButton(),
            zoomButton(),
            inputField(),
          ],
        ),
      ),
    );
  }
}
