import 'package:flutter/material.dart';
import 'package:fmaps_route/entity/sports_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

class DetailRoutePage extends StatefulWidget {
  final SportsLocation location;

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

  String placeDistance;

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
          title: '$startLatitude, $startLongitude',
          snippet: startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId(sportLocation.id),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: sportLocation.name,
          snippet: sportLocation.address,
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      );

      List<LatLng> listCoordinates = [];
      LatLng startCoordinatePoly = LatLng(startLatitude, startLongitude);
      LatLng destinationCoordinatePoly =
          LatLng(destinationLatitude, destinationLongitude);

      listCoordinates.add(startCoordinatePoly);
      listCoordinates.add(destinationCoordinatePoly);

      Polyline poly = Polyline(
        polylineId: PolylineId('poly'),
        points: listCoordinates,
        width: 4,
        visible: true,
        color: Colors.red,
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

      for (var i = 0; i < listCoordinates.length - 1; i++) {
        totalDistance += calculateDistance(
            listCoordinates[i].latitude,
            listCoordinates[i].longitude,
            listCoordinates[i + 1].latitude,
            listCoordinates[i + 1].longitude);
      }

      setState(() {
        markers.clear();
        polylines.clear();

        markers.add(startMarker);
        markers.add(destinationMarker);

        polylines.add(poly);

        placeDistance = totalDistance.toStringAsFixed(2);
        print('tot jarak $totalDistance.');
      });
    } catch (e) {
      print('errors $e');
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
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
          decoration: BoxDecoration(
            color: Colors.yellow.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: Text(
              'Jarak $placeDistance Km',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
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
                placeDistance == null ? SizedBox() : distanceView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
