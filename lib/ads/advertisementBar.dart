import 'package:flutter/material.dart';

class AdvertisementBar extends StatelessWidget {
  const AdvertisementBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      height: 60, 
      child: Center(child: Text('Ad Banner')),
    );
  }
}

