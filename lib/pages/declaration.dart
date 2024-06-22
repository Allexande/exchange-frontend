import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../models/house.dart';
import '../controllers/connectionController.dart';

class DeclarationPage extends StatefulWidget {
  final House house;
  final void Function(PageType) onPageChange;

  DeclarationPage({required this.house, required this.onPageChange});

  @override
  _DeclarationPageState createState() => _DeclarationPageState();
}

class _DeclarationPageState extends State<DeclarationPage> {
  bool isOwner = false;
  int? userId;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    final response = await ConnectionController.getRequest('/user/me');

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      userId = userData['id'];
      setState(() {
        isOwner = widget.house.user.id == userId;
      });
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  Future<void> respondToHouse() async {
    final housesResponse = await ConnectionController.getRequest('/houses');

    if (housesResponse.statusCode == 200) {
      final housesData = json.decode(housesResponse.body);
      int? givenHouseId;

      for (var house in housesData) {
        if (house['user']['id'] == userId) {
          givenHouseId = house['id'];
          break;
        }
      }

      if (givenHouseId == null) {
        MessageOverlayManager.showMessageOverlay("У вас нет домов для обмена", "Понятно");
        return;
      }

      final tradeBody = {
        'givenHouseId': givenHouseId,
        'receivedHouseId': widget.house.id,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      };

      final tradeResponse = await ConnectionController.postRequest('/houses/trade', tradeBody);

      if (tradeResponse.statusCode == 200) {
        await ConnectionController.deleteRequest('/houses/${widget.house.id}');
        await ConnectionController.deleteRequest('/houses/$givenHouseId');

        widget.onPageChange(PageType.results_page);
      } else {
        final errorData = json.decode(tradeResponse.body);
        String errorMessage = 'Ошибка ${tradeResponse.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      }
    } else {
      final errorData = json.decode(housesResponse.body);
      String errorMessage = 'Ошибка ${housesResponse.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  Future<void> deleteHouse() async {
    final response = await ConnectionController.deleteRequest('/houses/${widget.house.id}');

    if (response.statusCode == 200) {
      widget.onPageChange(PageType.results_page);
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                    'Предложение',
                    style: TextStyles.mainHeadline,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 200,
                  color: Colors.grey, 
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
                    widget.house.city,
                    style: TextStyles.subHeadline,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Описание',
                    style: TextStyles.subHeadline,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    widget.house.description,
                    textAlign: TextAlign.center,
                    style: TextStyles.mainText,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/user',
                      arguments: widget.house.user, 
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      "${widget.house.user.name} ${widget.house.user.surname}",
                      textAlign: TextAlign.center,
                      style: TextStyles.subHeadline,
                    ),
                    subtitle: Text(
                      'Рейтинг: ${widget.house.user.ratingSum}',
                      textAlign: TextAlign.center,
                      style: TextStyles.mainText,
                    ),
                  ),
                ),
                isOwner
                    ? MainButton(
                        onPressed: deleteHouse,
                        text: 'Удалить',
                      )
                    : MainButton(
                        onPressed: respondToHouse,
                        text: 'Откликнуться',
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
