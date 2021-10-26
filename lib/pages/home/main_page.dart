import 'package:flutter/material.dart';
import 'package:fmaps_route/pages/home/home_page.dart';
import 'package:fmaps_route/pages/home/locations_page.dart';
import 'package:fmaps_route/pages/home/routes_page.dart';
import 'package:fmaps_route/pages/home/graph_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  Widget bottomNavbar() {
    return BottomAppBar(
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
            ),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.alt_route,
            ),
            label: 'Find Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: 'Graph',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.place,
            ),
            label: 'Maps',
          ),
        ],
      ),
    );
  }

  Widget body() {
    switch (_currentIndex) {
      case 0:
        return LocationsPage();
      case 1:
        return RoutesPage();
      case 2:
        return GraphPage();
      case 3:
        return HomePage();
      default:
        return LocationsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomNavbar(),
      body: body(),
    );
  }
}
