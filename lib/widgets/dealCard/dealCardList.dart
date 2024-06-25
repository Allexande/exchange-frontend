import 'package:flutter/material.dart';
import 'dealCard.dart';

class DealCardList extends StatelessWidget {
  final List<Map<String, dynamic>> deals;
  final void Function(int receivedHouseId, int givenHouseId) onTap;

  DealCardList({required this.deals, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, 
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
          itemCount: deals.length,
          itemBuilder: (context, index) {
            var deal = deals[index];
            return DealCard(
              deal: deal,
              onTap: () => onTap(deal['receivedHouse']['id'], deal['givenHouse']['id']),
            );
          },
        ),
      ),
    );
  }
}
