import 'package:flutter/material.dart';
import 'dealCard.dart';

class DealCardList extends StatelessWidget {
  final List<Map<String, dynamic>> deals;
  final void Function(int receivedHouseId, int givenHouseId) onTap;

  DealCardList({required this.deals, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: deals.length,
      itemBuilder: (context, index) {
        var deal = deals[index];
        return DealCard(
          deal: deal,
          onTap: () => onTap(deal['receivedHouse']['id'], deal['givenHouse']['id']),
        );
      },
    );
  }
}
