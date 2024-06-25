import 'package:flutter/material.dart';
import 'housesCard.dart';
import '../../models/house.dart';

class HousesCardList extends StatelessWidget {
  final List<House> houses;
  final DateTimeRange? dateRange;
  final void Function(int houseId) onTap;

  HousesCardList({
    required this.houses,
    this.dateRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // Устанавливаем фиксированную высоту
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.transparent, Colors.transparent, Colors.white],
            stops: [0.0, 0.05, 0.95, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstOut,
        child: ListView.builder(
          itemCount: houses.length,
          itemBuilder: (context, index) {
            return HousesCard(
              house: houses[index],
              dateRange: dateRange,
              onTap: onTap,
            );
          },
        ),
      ),
    );
  }
}
