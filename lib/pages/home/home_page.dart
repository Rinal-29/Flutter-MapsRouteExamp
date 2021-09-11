import 'package:flutter/material.dart';
import 'package:fmaps_route/components/location_card_tile.dart';
import 'package:fmaps_route/providers/location_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-5.1428481, 119.4355728),
    zoom: 11,
  );

  Set<Marker> _markers = {};

  GoogleMapController mapController;

  Future<LatLng> _destinationLatLng(String destination) async {
    double destinationLat;
    double destinationLng;

    try {
      List<Location> destinationPlacemark =
          await locationFromAddress(destination);

      destinationLat = destinationPlacemark[0].latitude;
      destinationLng = destinationPlacemark[0].longitude;
    } catch (e) {
      print('errors $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menampilkan data, coba lagi'),
        ),
      );
    }

    return LatLng(destinationLat, destinationLng);
  }

  Future<void> _onMapcreated(GoogleMapController controller) async {
    await Provider.of<LocationsProvider>(context, listen: false).getLocations();

    LocationsProvider locationsProvider =
        Provider.of<LocationsProvider>(context, listen: false);

    List<Marker> listMarkers = [];

    for (final sport in locationsProvider.locations) {
      Marker marker = Marker(
        markerId: MarkerId(sport.name),
        position: await _destinationLatLng(sport.name),
        infoWindow: InfoWindow(
          title: sport.name,
          snippet: sport.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueMagenta,
        ),
      );

      listMarkers.add(marker);
    }

    setState(() {
      _markers.clear();
      _markers.addAll(listMarkers);

      mapController = controller;
    });
  }

  Widget header() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: Text(
        'Pemetaan Sarana Olahraga',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
      elevation: 0,
    );
  }

  Widget mapWiew() {
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      markers: _markers,
      mapToolbarEnabled: false,
      compassEnabled: false,
      onMapCreated: _onMapcreated,
    );
  }

  Widget zoomButton() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          left: 10,
          bottom: 130,
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

  Widget listLocations() {
    LocationsProvider locationsProvider =
        Provider.of<LocationsProvider>(context);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 250,
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: locationsProvider.locations
              .map(
                (location) => GestureDetector(
                  onTap: () async {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: await _destinationLatLng(location.name),
                          zoom: 15,
                          tilt: 50,
                          bearing: 45,
                        ),
                      ),
                    );
                  },
                  child: LocationCardTile(location: location),
                ),
              )
              .toList(),
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
            extendBodyBehindAppBar: true,
            appBar: header(),
            body: Stack(
              children: [
                mapWiew(),
                zoomButton(),
                listLocations(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
