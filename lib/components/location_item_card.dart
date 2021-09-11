import 'package:flutter/material.dart';
import 'package:fmaps_route/pages/detail_locatian_page.dart';

class LocationItemCard extends StatelessWidget {
  const LocationItemCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailLocationPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        margin: EdgeInsets.only(
          bottom: 20,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          child: Row(
            children: [
              ClipRRect(
                child: Image.asset(
                  'assets/gor_sudiang.jpg',
                  height: 60,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gor Sudiang',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Jl. Pajjaiang No.73, Sudiang Raya, Kec. Biringkanaya, Kota Makassar, Sulawesi Selatan 90241',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
