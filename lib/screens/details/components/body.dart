import 'package:flutter/material.dart';
import 'package:plant_app/constant.dart';
import 'package:plant_app/screens/details/components/image_and_icons.dart';
import 'package:plant_app/screens/details/components/title_and_price.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ImageAndIcons(size: size),
          TitleAndPrice(title: "Angelica", country: "Russia", price: 440),
          SizedBox(height: kDefaultPadding),
          Row(
            children: <Widget>[
              SizedBox(
                width: size.width / 2,
                height: 75,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white, // Warna teks
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          20,
                        ), // Rounded hanya di kanan atas
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Text("Buy Now", style: TextStyle(fontSize: 16.0)),
                ),
              ),
              Expanded(
                child: TextButton(onPressed: () {}, child: Text("Description")),
              ),
            ],
          ),
           SizedBox(height: kDefaultPadding * 1),
        ],
      ),
    );
  }
}
