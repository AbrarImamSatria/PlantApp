import 'package:flutter/material.dart';
import 'package:plant_app/constant.dart';
import 'package:plant_app/screens/user/user_screen.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: kDefaultPadding * 2,
          right: kDefaultPadding * 2,
          top: kDefaultPadding,
          bottom: kDefaultPadding,
        ),
        height: 30 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -10),
              blurRadius: 35,
              color: kPrimaryColor.withOpacity(0.38),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Image.asset('assets/icons/home.png', width: 30),
            ),
            IconButton(
              onPressed: () {},
              icon: Image.asset('assets/icons/heart.png', width: 30),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ),
                );
              },
              icon: Image.asset('assets/icons/user.png', width: 30),
            ),
          ],
        ),
      ),
    );
  }
}
