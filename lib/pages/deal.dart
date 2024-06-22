import 'package:exchange/models/user.dart';
import 'package:exchange/styles/buttons.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../models/house.dart';
import '../controllers/connectionController.dart';

class DealPage extends StatefulWidget {
  final void Function(PageType, {int? userId, int? dealId}) onPageChange;
  final int? dealId;

  DealPage({required this.onPageChange, this.dealId});

  @override
  _DealPageState createState() => _DealPageState();
}

class _DealPageState extends State<DealPage> {
  late String dateRange;
  House? firstHouse;
  House? secondHouse;
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
    if (widget.dealId != null) {
      loadDealData(widget.dealId!);
    }
    // Инициализация mockup данных
    mockupData();
  }

  Future<void> loadUserId() async {
    final response = await ConnectionController.getRequest('/user/me');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userId = data['id'];
      });
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка", "Не удалось загрузить данные пользователя");
    }
  }

  Future<void> loadDealData(int dealId) async {
    final response = await ConnectionController.getRequest('/houses/trades');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      final deal = responseData.firstWhere((deal) => deal['id'] == dealId, orElse: () => null);

      if (deal != null) {
        setState(() {
          dateRange = '${deal['startDate']} - ${deal['endDate']}';
          firstHouse = House.fromJson(deal['givenHouse']);
          secondHouse = House.fromJson(deal['receivedHouse']);
        });
      } else {
        MessageOverlayManager.showMessageOverlay("Сделка не найдена", "Понятно");
      }
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  void mockupData() {
    setState(() {
      dateRange = '01.09.2024 - 10.09.2024';
      firstHouse = House(
        id: 1,
        city: 'Москва',
        address: 'ул. Ленина, д. 1',
        description: 'Уютный дом в центре Москвы',
        user: UserModel(
          id: 1,
          name: 'Иван',
          surname: 'Иванов',
          login: 'ivanov@example.com',
          totalReviews: 10,
          ratingSum: 50,
        ),
      );
      secondHouse = House(
        id: 2,
        city: 'Санкт-Петербург',
        address: 'ул. Невский пр., д. 10',
        description: 'Прекрасная квартира в Санкт-Петербурге',
        user: UserModel(
          id: 2,
          name: 'Петр',
          surname: 'Петров',
          login: 'petrov@example.com',
          totalReviews: 5,
          ratingSum: 25,
        ),
      );
    });
  }

  Future<void> updateDealStatus(int dealId, String status) async {
    final body = {
      'id': dealId,
      'status': status,
    };

    final response = await ConnectionController.putRequest('/houses/trade', body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      MessageOverlayManager.showMessageOverlay("Статус сделки обновлен", "Понятно");
      widget.onPageChange(PageType.deals_page);
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: firstHouse == null || secondHouse == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Сделка совершилась!',
                          style: TextStyles.subHeadline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildHouseSection(firstHouse!, 'Полученное жилье:'),
                      SizedBox(height: 20),
                      _buildHouseSection(secondHouse!, 'Ваше жилье:'),
                      SizedBox(height: 20),
                      if (userId != null && firstHouse!.user.id == userId)
                        Column(
                          children: [
                            MainButton(
                              onPressed: () => updateDealStatus(widget.dealId!, 'COMPLETED'),
                              text: 'Принять',
                            ),
                            SizedBox(height: 10),
                            MainButton(
                              onPressed: () => updateDealStatus(widget.dealId!, 'REJECTED'),
                              text: 'Отклонить',
                            ),
                          ],
                        ),
                      SizedBox(height: 20),
                      MainButton(
                        onPressed: () {
                          widget.onPageChange(PageType.deals_page);
                        },
                        text: 'Сделать предложение',
                      ),
                      SubButton(
                        onPressed: () {
                          widget.onPageChange(PageType.deals_page);
                        },
                        text: 'Назад',
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHouseSection(House house, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyles.smallHeadline,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            house.city,
            style: TextStyles.subHeadline,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          height: 200,
          color: Colors.grey, // Заглушка для изображения
          child: Center(
            child: Text(
              'Фото жилья',
              style: TextStyles.subHeadline,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            dateRange,
            style: TextStyles.mainText,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            house.description,
            textAlign: TextAlign.center,
            style: TextStyles.mainText,
          ),
        ),
        InkWell(
          onTap: () {
            widget.onPageChange(PageType.user_page, userId: house.user.id);
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              "${house.user.name} ${house.user.surname}",
              textAlign: TextAlign.center,
              style: TextStyles.subHeadline,
            ),
            subtitle: Text(
              'Рейтинг: ${house.user.ratingSum}',
              textAlign: TextAlign.center,
              style: TextStyles.mainText,
            ),
          ),
        ),
      ],
    );
  }
}
