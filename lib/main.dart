import 'package:flutter/material.dart';
import 'package:fmaps_route/pages/detail_locatian_page.dart';
import 'package:fmaps_route/pages/detail_route_page.dart';
import 'package:fmaps_route/pages/home/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => MainPage(),
        '/detail-route': (context) => DetailRoutePage(),
        '/detail-location': (context) => DetailLocationPage(),
      },
    );
  }
}
