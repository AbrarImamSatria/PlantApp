import 'package:flutter/material.dart';
import 'package:plant_app/constant.dart';

class TittleWithMoreBtn extends StatelessWidget {
  const TittleWithMoreBtn({
    super.key,
    this.title,
    this.press
  });
  final String? title;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Row(
        children: [
          TittleWithCustomUnderline(text: title),
          Spacer(),
          SizedBox(
            width: 88,
            height: 35, 
            child: FloatingActionButton.extended(
              backgroundColor: kPrimaryColor,
              onPressed: press as void Function()?,
              label: Text("More", style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TittleWithCustomUnderline extends StatelessWidget {
  const TittleWithCustomUnderline({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: kDefaultPadding / 4),
            child: Text(
              text ?? "",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            left: 0,
            child: Container(
              margin: EdgeInsets.only(right: kDefaultPadding / 4),
              height: 7,
              color: kPrimaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
