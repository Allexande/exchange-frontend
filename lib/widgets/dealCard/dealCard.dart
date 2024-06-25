import 'package:flutter/material.dart';
import '../../styles/theme.dart';

class DealCard extends StatelessWidget {
  final Map<String, dynamic> deal;
  final void Function() onTap;

  DealCard({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: AppColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal["givenHouse"]["city"],
                      style: TextStyles.subHeadline.copyWith(color: AppColors.background, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${deal["givenHouse"]["user"]["name"]} ${deal["givenHouse"]["user"]["surname"]}',
                      style: TextStyles.mainText.copyWith(color: AppColors.background, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.swap_horiz, color: AppColors.background, size: 30),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      deal["receivedHouse"]["city"],
                      style: TextStyles.subHeadline.copyWith(color: AppColors.background, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${deal["receivedHouse"]["user"]["name"]} ${deal["receivedHouse"]["user"]["surname"]}',
                      style: TextStyles.mainText.copyWith(color: AppColors.background, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
