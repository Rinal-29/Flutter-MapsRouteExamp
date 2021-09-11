import 'package:flutter/material.dart';
import 'package:fmaps_route/pages/detail_locatian_page.dart';
import 'package:fmaps_route/pages/detail_route_page.dart';
import 'package:fmaps_route/pages/home/main_page.dart';
import 'package:fmaps_route/providers/location_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationsProvider(),
        ),
      ],
      child: MaterialApp(
        routes: {
          '/': (context) => MainPage(),
          '/main-page': (context) => MainPage(),
          '/detail-route': (context) => DetailRoutePage(),
          '/detail-location': (context) => DetailLocationPage(),
        },
      ),
    );
  }
}
