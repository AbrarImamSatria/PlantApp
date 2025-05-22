import 'package:flutter/material.dart';
import 'package:plant_app/constant.dart';

class IconCard extends StatelessWidget {
  const IconCard({super.key, required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.03),
      padding: EdgeInsets.all(kDefaultPadding / 2),
      height: 62,
      width: 62,
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 15),
            blurRadius: 22,
            color: kPrimaryColor.withOpacity(0.22),
          ), // BoxShadow
          BoxShadow(
            offset: Offset(-15, -15),
            blurRadius: 20,
            color: Colors.white,
          ), // BoxShadow
        ],
      ),
      child: Image.asset(
        icon, // ganti sesuai path gambarmu
        width: 24, // atur sesuai ukuran yang diinginkan
        height: 24,
        color:
            kPrimaryColor, // jika ingin warnai PNG transparan dengan satu warna
      ),
    );
  }
}
