import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

class ActiveDealsPage extends StatefulWidget {
  final void Function(PageType, {int? houseId, int? givenHouseId, int? recievedHouseId}) onPageChange;

  ActiveDealsPage({required this.onPageChange});

  @override
  _ActiveDealsPageState createState() => _ActiveDealsPageState();
}

class _ActiveDealsPageState extends State<ActiveDealsPage> {
  List<Map<String, dynamic>> myDealsData = [];
  List<Map<String, dynamic>> completedDealsData = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final response = await ConnectionController.getRequest('/user/me');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          userId = data['id'];
        });
      }
      loadActiveDeals();
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка при загрузке данных пользователя", "Понятно");
    }
  }

  Future<void> loadActiveDeals() async {
    if (userId == null) {
      return;
    }

    final response = await ConnectionController.getRequest('/user/trades');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));

      if (mounted) {
        setState(() {
          myDealsData = responseData.where((deal) {
            return deal['status'] == 'PENDING' && deal['givenHouse']['user']['id'] == userId;
          }).map((deal) => deal as Map<String, dynamic>).toList();

          completedDealsData = responseData.where((deal) {
            return deal['status'] == 'COMPLETED' &&
                (deal['givenHouse']['user']['id'] == userId || deal['receivedHouse']['user']['id'] == userId);
          }).map((deal) => deal as Map<String, dynamic>).toList();
        });
      }

      if (myDealsData.isEmpty && completedDealsData.isEmpty) {
        MessageOverlayManager.showMessageOverlay("Сделки не найдены", "Понятно");
      }
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  Widget buildDealList(List<Map<String, dynamic>> deals, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyles.subHeadline.copyWith(color: AppColors.primary),
            textAlign: TextAlign.left,
          ),
        ),
        deals.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Такие события не найдены',
                  style: TextStyles.mainText,
                  textAlign: TextAlign.center,
                ),
              )
            : Container(
                height: 200,
                child: ListView.builder(
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    var deal = deals[index];
                    return InkWell(
                      onTap: () {
                        widget.onPageChange(PageType.deal_page, recievedHouseId: deal['receivedHouse']['id'], givenHouseId: deal['givenHouse']['id']);
                      },
                      child: Card(
                        color: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            deal["givenHouse"]["city"],
                            style: TextStyles.subHeadline.copyWith(color: AppColors.background),
                          ),
                          subtitle: Text(
                            deal["startDate"],
                            style: TextStyles.mainText.copyWith(color: AppColors.background),
                          ),
                          trailing: Icon(Icons.swap_horiz, color: AppColors.background),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDealList(myDealsData, "Мои сделки:"),
              buildDealList(completedDealsData, "Завершенные сделки:"),
            ],
          ),
        ),
      ),
    );
  }
}
