import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';
import '../controllers/tokenStorage.dart';

class NotificationsPage extends StatefulWidget {
  final void Function(PageType, {int? dealId}) onPageChange;

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

    final response = await ConnectionController.getRequest('/houses/trades');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        pendingDeals = responseData.where((deal) {
          return deal['status'] == 'PENDING' && deal['givenHouse']['user']['id'] == userId;
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
                child: ListView.builder(
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    var deal = deals[index];
                    return InkWell(
                      onTap: () {
                        widget.onPageChange(PageType.deal_page, dealId: deal['id']);
                      },
                      child: Card(
                        color: AppColors.primary,
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
                            'От ${deal["givenHouse"]["user"]["name"]} ${deal["givenHouse"]["user"]["surname"]}',
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
            children: [
              buildDealList(pendingDeals, "Предложения:"),
            ],
          ),
        ),
      ),
    );
  }
}
