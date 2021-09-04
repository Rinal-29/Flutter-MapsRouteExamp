import 'package:flutter/material.dart';
import 'package:fmaps_route/components/location_card_tile.dart';
import 'package:fmaps_route/entity/sports_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  List<SportsLocation> sportsLocation = [
    SportsLocation(
        id: 'Lapangan Sepakbola Unhas',
        address:
            'Tamalanrea Indah, Kec. Tamalanrea, Kota Makassar, Sulawesi Selatan 90245',
        lat: -5.1346612,
        lng: 119.4857507,
        name: 'Lapangan Sepakbola Unhas',
        image: 'assets/lapangan_unhas.jpg'),
    SportsLocation(
      id: 'Lapangan Tala',
      address:
          'Tamalanrea, Kec. Tamalanrea, Kota Makassar, Sulawesi Selatan 90245',
      lat: -5.1383742,
      lng: 119.5095757,
      name: 'Lapangan Tala',
      image: 'assets/lapangan_tala.jpg',
    ),
    SportsLocation(
      id: 'Gor Sudiang',
      address:
          'Jl. Pajjaiang No.73, Sudiang Raya, Kec. Biringkanaya, Kota Makassar, Sulawesi Selatan 90241',
      lat: -5.1056186,
      lng: 119.5266896,
      name: 'Gor Sudiang',
      image: 'assets/gor_sudiang.jpg',
    ),
  ];

  Future<void> _onMapcreated(GoogleMapController controller) async {
    List<Marker> listMarkers = [];

    for (final sport in sportsLocation) {
      Marker marker = Marker(
        markerId: MarkerId(sport.id),
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

  Future<LatLng> _destinationLatLng(String destination) async {
    List<Location> destinationPlacemark =
        await locationFromAddress(destination);

    double destinationLat = destinationPlacemark[0].latitude;
    double destinationLng = destinationPlacemark[0].longitude;

    return LatLng(destinationLat, destinationLng);
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
          children: [
            for (var i = 0; i < sportsLocation.length; i++)
              GestureDetector(
                onTap: () async {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target:
                            await _destinationLatLng(sportsLocation[i].name),
                        zoom: 15,
                        tilt: 50,
                        bearing: 45,
                      ),
                    ),
                  );
                },
                child: LocationCardTile(location: sportsLocation[i]),
              ),
          ],
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
