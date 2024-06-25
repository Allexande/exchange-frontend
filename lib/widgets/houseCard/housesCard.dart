import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../styles/theme.dart';
import '../../models/house.dart';

class HousesCard extends StatelessWidget {
  final House house;
  final DateTimeRange? dateRange;
  final void Function(int houseId) onTap;

  HousesCard({
    required this.house,
    this.dateRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double rating = house.user.ratingSum / (house.user.totalReviews > 0 ? house.user.totalReviews : 1);
    String displayRating = rating == 0 ? '-' : rating.toStringAsFixed(1);

    return GestureDetector(
      onTap: () => onTap(house.id),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        margin: EdgeInsets.symmetric(vertical: 8),
        color: AppColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  house.city,
                  style: TextStyle(
                    fontFamily: 'BloggerSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
              ),
              if (dateRange != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "${DateFormat('dd.MM.yyyy').format(dateRange!.start)} - ${DateFormat('dd.MM.yyyy').format(dateRange!.end)}",
                    style: TextStyle(
                      fontFamily: 'BloggerSans',
                      fontSize: 16,
                      color: AppColors.background,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  house.address,
                  style: TextStyle(
                    fontFamily: 'BloggerSans',
                    fontSize: 16,
                    color: AppColors.background,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        house.description,
                        style: TextStyle(
                          fontFamily: 'BloggerSans',
                          fontSize: 16,
                          color: AppColors.background,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        displayRating,
                        style: TextStyle(
                          fontFamily: 'BloggerSans',
                          fontSize: 16,
                          color: AppColors.background,
                        ),
                      ),
                      SizedBox(width: 25.0),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
