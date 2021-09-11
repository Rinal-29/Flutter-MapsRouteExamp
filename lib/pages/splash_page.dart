import 'package:flutter/material.dart';
import 'package:fmaps_route/providers/location_provider.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    getInit();

    super.initState();
  }

  getInit() async {
    await Provider.of<LocationsProvider>(context, listen: false).getLocations();
    Navigator.pushNamed(context, '/main-page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('Splash'),
      ),
    );
  }
}
