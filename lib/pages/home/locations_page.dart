import 'package:flutter/material.dart';
import 'package:fmaps_route/components/location_item_card.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return AppBar(
        title: Text(
          'Daftar Lokasi',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      );
    }

    Widget content() {
      return Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          width: double.infinity,
          child: ListView(
            children: [
              LocationItemCard(),
              LocationItemCard(),
              LocationItemCard(),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Color(0xffF8FAFD),
      child: Column(
        children: [
          header(),
          content(),
        ],
      ),
    );
  }
}
