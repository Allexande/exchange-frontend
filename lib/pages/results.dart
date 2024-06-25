/*
  Results page

  Shows the houses avilable during a pireod of time
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../models/house.dart';
import '../controllers/connectionController.dart';
import '../widgets/houseCard/housesCardList.dart';

class SearchResultsPage extends StatefulWidget {
  final void Function(PageType, {String? city, DateTimeRange? dateRange, int? houseId}) onPageChange;
  final String? selectedCity;
  final DateTimeRange? dateRange;

  SearchResultsPage({
    Key? key,
    required this.onPageChange,
    this.selectedCity,
    this.dateRange,
  }) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<House> houses = [];

  Future<void> loadDataWithFilters() async {
    String endpoint = '/houses/find';
    Map<String, String> queryParams = {};

    if (widget.selectedCity != null && widget.selectedCity!.isNotEmpty) {
      queryParams['c'] = widget.selectedCity!;
    }
    if (widget.dateRange != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      queryParams['startDate'] = formatter.format(widget.dateRange!.start);
      queryParams['endDate'] = formatter.format(widget.dateRange!.end);
    }

    if (queryParams.isNotEmpty) {
      endpoint += '?' + Uri(queryParameters: queryParams).query;
    }

    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      var jsonData = utf8.decode(response.bodyBytes);
      List<dynamic> responseData = json.decode(jsonData);
      if (responseData.isEmpty) {
        MessageOverlayManager.showMessageOverlay("Похоже, никто не предлагает домов с такими параметрами", "Понятно");
      } else {
        setState(() {
          houses = responseData.map<House>((house) => House.fromJson(house)).toList();
        });
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        MessageOverlayManager.showMessageOverlay('Ошибка ${response.statusCode}: ${response.body}', "Понятно");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadDataWithFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Результаты поиска',
              style: TextStyles.subHeadline,
            ),
            SizedBox(height: 8),
            Expanded(
              child: houses.isEmpty
                  ? Center(
                      child: Text(
                        "Дома не найдены",
                        style: TextStyles.mainText,
                      ),
                    )
                  : HousesCardList(
                      houses: houses,
                      dateRange: widget.dateRange,
                      onTap: (houseId) {
                        widget.onPageChange(PageType.declaration_page, houseId: houseId);
                      },
                    ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: MainButton(
                onPressed: () {
                  widget.onPageChange(PageType.filters_page);
                },
                text: 'Фильтры поиска',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
