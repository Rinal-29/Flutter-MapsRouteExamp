import 'package:flutter/material.dart';

class ImageCardTile extends StatelessWidget {
  const ImageCardTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/gor_sudiang.jpg',
          width: 140,
          height: 125,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
