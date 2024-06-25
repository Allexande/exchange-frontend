import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';
import '../controllers/tokenStorage.dart';
import '../widgets/dealCard/dealCardList.dart'; // Импортируйте виджет DealCardList

class NotificationsPage extends StatefulWidget {
  final void Function(PageType, {int? houseId, int? givenHouseId, int? recievedHouseId}) onPageChange;

  NotificationsPage({required this.onPageChange});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> pendingDeals = [];

  @override
  void initState() {
    super.initState();
    loadDeals();
  }

  Future<void> loadDeals() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      MessageOverlayManager.showMessageOverlay("Токен не найден", "Понятно");
      return;
    }

    final userId = await loadUserId(token);
    if (userId == null) return;

    final response = await ConnectionController.getRequest('/user/trades');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        pendingDeals = responseData.where((deal) {
          return deal['status'] == 'PENDING' && deal['receivedHouse']['user']['id'] == userId;
        }).map((deal) => deal as Map<String, dynamic>).toList();

        if (pendingDeals.isEmpty) {
          MessageOverlayManager.showMessageOverlay("Сделки не найдены", "Понятно");
        }
      });
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  Future<int?> loadUserId(String token) async {
    final response = await ConnectionController.getRequest('/user/me');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка", "Не удалось загрузить данные пользователя");
      return null;
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
                child: DealCardList(
                  deals: deals,
                  onTap: (receivedHouseId, givenHouseId) {
                    widget.onPageChange(PageType.deal_page, recievedHouseId: receivedHouseId, givenHouseId: givenHouseId);
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
            children: [
              buildDealList(pendingDeals, "Предложения:"),
            ],
          ),
        ),
      ),
    );
  }
}
