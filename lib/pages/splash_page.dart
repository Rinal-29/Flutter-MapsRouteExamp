import 'package:flutter/material.dart';
import 'package:fmaps_route/providers/graph_provider.dart';
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
    try {
      await Provider.of<LocationsProvider>(context, listen: false)
          .getLocations();

      await Provider.of<GraphProvider>(context, listen: false)
          .getLocationsManually();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menampilkan data, periksa jaringan'),
        ),
      );
    }
    Navigator.pushNamed(context, '/main-page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8FAFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fmaps_logo_apps.png'),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Aplikasi Pemetaan Sarana Olahraga',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
