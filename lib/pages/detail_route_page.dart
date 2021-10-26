import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fmaps_route/models/location_model.dart';
import 'package:fmaps_route/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

class DetailRoutePage extends StatefulWidget {
  final LocationModel location;

  DetailRoutePage({
    Key key,
    this.location,
  }) : super(key: key);

  @override
  _DetailRoutePageState createState() => _DetailRoutePageState();
}

class _DetailRoutePageState extends State<DetailRoutePage> {
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-5.1428481, 119.4355728),
    zoom: 12,
  );

  Position _currentPosition;
  String _currentAddress;

  String startAddress;
  String destinationAddress;

  GoogleMapController mapController;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  List<LatLng> polylineCoordinates1 = [];
  List<LatLng> polylineCoordinates2 = [];

  PolylinePoints polylinePoints;

  String placeDistance1;
  String placeDistance2;

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      setState(() {
        try {
          _currentPosition = position;

          print('check current pos $_currentPosition');
        } catch (e) {
          print('error $e');
        }
      });

      _getAddress();
    });
  }

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            '${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}';

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
              zoom: 15,
            ),
          ),
        );
        startAddress = _currentAddress;

        _getRouteAndDistance();
      });
    } catch (e) {
      print('errors $e');
    }
  }

  _getRouteAndDistance() async {
    try {
      final sportLocation = widget.location;
      destinationAddress = sportLocation.name;

      print('destination address $destinationAddress');
      print('start address $startAddress');

      List<Location> startPlacemark = await locationFromAddress(startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(destinationAddress);

      double startLatitude =
          startPlacemark[0].latitude == _currentPosition.latitude
              ? startPlacemark[0].latitude
              : _currentPosition.latitude;
      double startLongitude =
          startPlacemark[0].longitude == _currentPosition.longitude
              ? startPlacemark[0].longitude
              : _currentPosition.longitude;
      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      Marker startMarker = Marker(
        markerId: MarkerId(startAddress),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startLatitude, $startLongitude',
          snippet: startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId(sportLocation.name),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination ${sportLocation.name}',
          snippet: sportLocation.address,
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      );

      markers.add(startMarker);
      markers.add(destinationMarker);

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude, TravelMode.driving);

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude, TravelMode.transit);

      double totalDistance1 = 0.0;
      double totalDistance2 = 0.0;

      double calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var c = cos;
        var a = 0.5 -
            c((lat2 - lat1) * p) / 2 +
            c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
        return 12742 * asin(sqrt(a));
      }

      for (var i = 0; i < polylineCoordinates1.length - 1; i++) {
        totalDistance1 += calculateDistance(
            polylineCoordinates1[i].latitude,
            polylineCoordinates1[i].longitude,
            polylineCoordinates1[i + 1].latitude,
            polylineCoordinates1[i + 1].longitude);
      }

      for (var i = 0; i < polylineCoordinates2.length - 1; i++) {
        totalDistance2 += calculateDistance(
            polylineCoordinates2[i].latitude,
            polylineCoordinates2[i].longitude,
            polylineCoordinates2[i + 1].latitude,
            polylineCoordinates2[i + 1].longitude);
      }

      setState(() {
        placeDistance1 = totalDistance1.toStringAsFixed(2);
        print('tot jarak $totalDistance1.');

        placeDistance2 = totalDistance2.toStringAsFixed(2);
        print('tot jarak $totalDistance1.');
      });
    } catch (e) {
      print('errors $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menampilkan data, coba lagi'),
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
      travelMode: travelMode,
    );

    if (result.points.isNotEmpty && travelMode == TravelMode.transit) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates1.add(LatLng(point.latitude, point.longitude));
      });

      print('polyline coordinates 1 ${polylineCoordinates1.length}');
    }

    if (result.points.isNotEmpty && travelMode == TravelMode.driving) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates2.add(LatLng(point.latitude, point.longitude));
      });

      print('polyline coordinates 2 ${polylineCoordinates2.length}');
    }

    Polyline polyline1 = Polyline(
      polylineId: PolylineId('poly-1'),
      color: Colors.blue,
      points: polylineCoordinates1,
      width: 7,
    );

    Polyline polyline2 = Polyline(
      polylineId: PolylineId('poly-2'),
      color: Colors.red,
      points: polylineCoordinates2,
      width: 7,
    );

    polylines.add(polyline1);
    polylines.add(polyline2);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      if (markers.isNotEmpty) markers.clear();
      if (polylines.isNotEmpty) polylines.clear();

      _getCurrentLocation();
      mapController = controller;
    });
  }

  Widget header() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: Text(
        'Rute',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
        ),
      ),
      elevation: 0,
    );
  }

  Widget mapView() {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      zoomGesturesEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      mapType: MapType.normal,
      markers: markers,
      polylines: polylines,
      compassEnabled: false,
      onMapCreated: _onMapCreated,
    );
  }

  Widget distanceView() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Text(
                        'Jarak $placeDistance1 Km',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Text(
                        'Jarak $placeDistance2 Km',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: header(),
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                mapView(),
                placeDistance1 == null ? SizedBox() : distanceView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
