import 'package:flutter/material.dart';
import 'package:fmaps_route/pages/home/home_page.dart';
import 'package:fmaps_route/pages/home/routes_page.dart';

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
              Icons.place,
            ),
            label: 'Sport Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.alt_route,
            ),
            label: 'Find Route',
          ),
        ],
      ),
    );
  }

  Widget body() {
    switch (_currentIndex) {
      case 0:
        return HomePage();
        break;
      case 1:
        return RoutesPage();
      default:
        return HomePage();
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
