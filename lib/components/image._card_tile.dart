import 'package:flutter/material.dart';
import 'package:fmaps_route/models/gallery_model.dart';

class ImageCardTile extends StatelessWidget {
  final GalleryModel gallery;

  ImageCardTile({Key key, this.gallery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          gallery.url,
          width: 140,
          height: 125,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
