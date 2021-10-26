import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fmaps_route/models/graph_model.dart';
import 'package:fmaps_route/providers/graph_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({Key key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  // inisialisasi posisi kamera maps pada kota makassar
  CameraPosition _initialLocation = CameraPosition(
    target: LatLng(-5.1111323, 119.2625381),
  );

  // untuk mengontrol tammpilan pada map
  GoogleMapController mapController;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  String startAddress = '';
  String destinationAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String placeDistance;

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  GraphModel selectedValue;

  List<LatLng> latlngSegment = [];
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  _calculateDistance() async {
    try {
      print('start address distance $startAddress');
      print('destination $destinationAddress');

      List<Location> startPlacemark = await locationFromAddress(startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(destinationAddress);

      double startLatitude = startPlacemark[0].latitude;
      double startLongtitude = startPlacemark[0].longitude;
      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongtitude = destinationPlacemark[0].longitude;

      String startCoordinateString = '$startLatitude,$startLongtitude';
      String destinationCordinateString =
          '$destinationLatitude,$destinationLongtitude';

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
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      );

      markers.add(startMarker);
      markers.add(destinationMarker);

      for (var route in selectedValue.routes) {
        latlngSegment.add(LatLng(route.lat, route.lng));

        Marker mark = Marker(
          markerId: MarkerId(route.name),
          position: LatLng(route.lat, route.lng),
          infoWindow: InfoWindow(
            title: route.name,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );

        markers.add(mark);
      }

      Polyline polyline = Polyline(
        polylineId: PolylineId("poly-1"),
        points: latlngSegment,
        width: 4,
        color: Colors.yellow,
      );

      polylines.add(polyline);

      await _createPolylines(startLatitude, startLongtitude,
          destinationLatitude, destinationLongtitude, TravelMode.transit);

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(startLatitude, startLongtitude),
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      print('errors $e');
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

    if (result.points.isNotEmpty && travelMode == TravelMode.transit) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      print('polyline coordinates 1 ${polylineCoordinates.length}');
    }

    Polyline polyline1 = Polyline(
      polylineId: PolylineId('poly-2'),
      color: Colors.blue,
      points: polylineCoordinates,
      width: 7,
    );

    polylines.add(polyline1);
  }

  Widget mapView() {
    return GoogleMap(
      initialCameraPosition: _initialLocation,
      myLocationEnabled: false,
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
                child: Column(
                  children: [
                    Text(
                      'Jarak $placeDistance Km',
                      style: TextStyle(
                        color: Colors.blue.shade500,
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
                    if (polylineCoordinates.isNotEmpty)
                      polylineCoordinates.clear();
                  });
                  await _calculateDistance();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropdownButton() {
    GraphProvider locationsProvider =
        Provider.of<GraphProvider>(context, listen: false);

    print(locationsProvider.locations.length);
    print(locationsProvider.locations[0].routes.length);

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
        items: locationsProvider.locations.map((GraphModel map) {
          return DropdownMenuItem(
            child: Text(
              map.name,
              overflow: TextOverflow.ellipsis,
            ),
            value: map,
          );
        }).toList(),
        onChanged: (GraphModel value) {
          setState(() {
            print('value $value');
            destinationAddress = value.name;
            selectedValue = value;
          });
        },
      ),
    );
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
            inputField(),
          ],
        ),
      ),
    );
  }
}
