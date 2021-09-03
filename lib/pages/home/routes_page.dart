import 'package:flutter/material.dart';
import 'package:fmaps_route/entity/sports_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

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
  String placeDistance;

  //mendapatkan alamat user
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  List<SportsLocation> sportsLocation = [
    SportsLocation(
      id: 'Unhas',
      address:
          'VF7P+7V6, Tamalanrea Indah, Kec. Tamalanrea, Kota Makassar, Sulawesi Selatan 90245',
      lat: -5.1354947,
      lng: 119.4859224,
      name: 'Lapangan olahraga unhas',
    ),
    SportsLocation(
      id: 'Lapangan Tala',
      address:
          'VG66+PP2, Tamalanrea, Kec. Tamalanrea, Kota Makassar, Sulawesi Selatan 90245',
      lat: -5.1388747,
      lng: 119.5103926,
      name: 'Lapangan Tala',
    ),
    SportsLocation(
      id: 'Gor Sudiang',
      address:
          'Jl. Pajjaiang No.73, Sudiang Raya, Kec. Biringkanaya, Kota Makassar, Sulawesi Selatan 90241',
      lat: -5.1059063,
      lng: 119.5245166,
      name: 'Gor Sudiang',
    )
  ];

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        try {
          _currentPosition = position;

          print('Current Pos $_currentPosition');
        } catch (e) {
          print(e);
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
    }
  }

  _calculateDistance() async {
    try {
      print('start address distance $startAddress');
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

      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinateString),
        position: LatLng(startLatitude, startLongtitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinateString',
          snippet: startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCordinateString),
        position: LatLng(destinationLatitude, destinationLongtitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCordinateString',
          snippet: destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongtitude <= destinationLongtitude)
          ? startLongtitude
          : destinationLongtitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongtitude <= destinationLongtitude)
          ? destinationLongtitude
          : startLongtitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      List<LatLng> listCordinate = [];
      LatLng startCordinatePoly = LatLng(startLatitude, startLongtitude);
      LatLng destinationCordinatePoly =
          LatLng(destinationLatitude, destinationLongtitude);
      listCordinate.add(startCordinatePoly);
      listCordinate.add(destinationCordinatePoly);

      print('list cordinates : ${listCordinate[0].latitude}');

      Polyline plyline = Polyline(
        polylineId: PolylineId('poly1'),
        visible: true,
        points: listCordinate,
        width: 2,
        color: Colors.blue,
      );

      double totalDistance = 0.0;

      double calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var c = cos;
        var a = 0.5 -
            c((lat2 - lat1) * p) / 2 +
            c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
        return 12742 * asin(sqrt(a));
      }

      for (var i = 0; i < listCordinate.length - 1; i++) {
        totalDistance += calculateDistance(
            listCordinate[i].latitude,
            listCordinate[i].longitude,
            listCordinate[i + 1].latitude,
            listCordinate[i + 1].longitude);
      }

      setState(() {
        markers.clear();
        polylines.clear();

        markers.add(startMarker);
        markers.add(destinationMarker);

        polylines.add(plyline);

        placeDistance = totalDistance.toStringAsFixed(2);
        print('Distance $placeDistance km');
      });
    } catch (e) {
      print('error $e');
    }
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
        items: sportsLocation.map((SportsLocation map) {
          return DropdownMenuItem(
            child: Text(
              map.id,
              overflow: TextOverflow.ellipsis,
            ),
            value: map.name,
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            print('value $value');
            destinationAddress = value;
            print('destination $destinationAddress');
          });
        },
      ),
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
          top: 75,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              dropdownButton(),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: placeDistance == null ? false : true,
                child: Text(
                  'Jarak $placeDistance Km',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                  await _calculateDistance();
                },
              ),
            ],
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
