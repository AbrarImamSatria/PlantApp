import 'package:flutter/material.dart';
import 'package:plant_app/constant.dart';
import 'package:plant_app/screens/home/components/featurred_plants.dart';
import 'package:plant_app/screens/home/components/header_with_searchbox.dart';
import 'package:plant_app/screens/home/components/recomend_plants.dart';
import 'package:plant_app/screens/home/components/tittle_with_more_bbtn.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    // It will provie us total height and width of our screen
    Size size = MediaQuery.of(context).size;
    // it enable scrolling on small devices
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          HeaderWithSearchBox(size: size),
          TittleWithMoreBtn(title: "Recommended", press: () {}),
          RecomendsPlants(),
          TittleWithMoreBtn(title: "Featured Plants", press: () {}),
          FeaturedPlants(),
          SizedBox(height: kDefaultPadding),
        ],
      ),
    );
  }
}

