import 'package:flutter/material.dart';
import 'package:plant_app/constant.dart';
import 'package:plant_app/screens/home/components/header_with_searchbox.dart';
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
          // it will cover 40% of our total height
          RecomendPlantCard(size: size),
        ],
      ),
    );
  }
}

class RecomendPlantCard extends StatelessWidget {
  const RecomendPlantCard({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: kDefaultPadding,
        top: kDefaultPadding / 2,
        bottom: kDefaultPadding * 2.5,
      ),
      width: size.width * 0.4,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              "assets/images/kaktus.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(kDefaultPadding / 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 50,
                  color: kPrimaryColor.withOpacity(0.23),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Samantha\n".toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      TextSpan(
                        text: "Russia".toUpperCase(),
                        style: TextStyle(
                          color: kPrimaryColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  '\$440',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: kPrimaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
