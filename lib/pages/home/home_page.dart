import 'package:flutter/material.dart';
import 'package:fmaps_route/components/location_card_tile.dart';
import 'package:fmaps_route/models/category_model.dart';
import 'package:fmaps_route/models/location_model.dart';
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

  List<Marker> listMarkers = [];
  List<Marker> listAllMarkers = [];

  GoogleMapController mapController;

  List<CategoryModel> _categories = [
    CategoryModel("Joging", Colors.blue, false),
    CategoryModel("Futsal", Colors.blue, false),
    CategoryModel("Badminton", Colors.blue, false),
    CategoryModel("Senam", Colors.blue, false),
    CategoryModel("Sepakbola", Colors.blue, false),
    CategoryModel("Bersepeda", Colors.blue, false),
    CategoryModel("Basket", Colors.blue, false),
  ];

  List<LocationModel> locationFromCategory = [];

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
    LocationsProvider locationsProvider =
        Provider.of<LocationsProvider>(context, listen: false);

    if (locationFromCategory.isEmpty || locationFromCategory.length <= 0) {
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
        listAllMarkers.add(marker);
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(listAllMarkers);

      mapController = controller;
    });
  }

  _drawMarkers() async {
    for (final sport in locationFromCategory) {
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
    });
  }

  Widget categories() {
    LocationsProvider locationsProvider =
        Provider.of<LocationsProvider>(context, listen: false);

    return Container(
      margin: EdgeInsets.only(
        top: 70,
        left: 20,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories
              .map(
                (category) => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: FilterChip(
                    label: Text(category.name),
                    labelStyle: TextStyle(color: Colors.white),
                    backgroundColor: category.color,
                    selected: category.isSelected,
                    onSelected: (bool val) {
                      setState(() {
                        category.isSelected = val;

                        if (category.isSelected) {
                          locationFromCategory.clear();
                          listMarkers.clear();

                          locationsProvider.locations.forEach((location) {
                            if (location.facility
                                .toLowerCase()
                                .contains(category.name.toLowerCase())) {
                              locationFromCategory.add(location);
                            }
                          });

                          _drawMarkers();
                        } else {
                          locationFromCategory.clear();
                          print(locationFromCategory.length);
                          _markers.clear();
                          _markers.addAll(listAllMarkers);
                        }
                      });
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
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
      automaticallyImplyLeading: false,
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
          children: locationFromCategory.isEmpty ||
                  locationFromCategory.length < 0
              ? locationsProvider.locations
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
                  .toList()
              : locationFromCategory
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
                categories(),
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
