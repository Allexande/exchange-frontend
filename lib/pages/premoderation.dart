import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

class PremoderationPage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  PremoderationPage({required this.onPageChange});

  @override
  _PremoderationPageState createState() => _PremoderationPageState();
}

class _PremoderationPageState extends State<PremoderationPage> {
  List<Map<String, dynamic>> houses = [];

  @override
  void initState() {
    super.initState();
    loadHouses();
  }

  Future<void> loadHouses() async {
    final response = await ConnectionController.getRequest('/moderator/houses');

    if (response.statusCode == 200) {
      setState(() {
        houses = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      MessageOverlayManager.showMessageOverlay(
          "Ошибка", "Не удалось загрузить дома");
    }
  }

  Future<void> _handleAction(int houseId, bool isApproved, String decision) async {
    final body = {
      'id': houseId,
      'isApproved': isApproved,
      'decision': decision,
    };

    final response = await ConnectionController.putRequest('/moderator/house', body);

    if (response.statusCode == 200) {
      setState(() {
        houses.removeWhere((house) => house['id'] == houseId);
      });
      MessageOverlayManager.showMessageOverlay(
          "Успех", "Действие выполнено успешно");
    } else {
      MessageOverlayManager.showMessageOverlay(
          "Ошибка", "Не удалось выполнить действие");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Премодерация домов'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Список домов для премодерации',
                style: TextStyles.mainHeadline,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: houses.length,
                itemBuilder: (context, index) {
                  var house = houses[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.home, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${house['city']}, ${house['address']}',
                                    style: TextStyles.subHeadline,
                                  ),
                                  Text(
                                    'Описание: ${house['description']}',
                                    style: TextStyles.mainText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Пользователь: ${house['user']['login']}',
                            style: TextStyles.mainText,
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DefaultButton(
                                text: 'Отклонить',
                                color: AppColors.primary, // Используйте цвет для ошибки или красный цвет
                                onPressed: () => _handleAction(house['id'], false, 'Отклонено'),
                              ),
                              SizedBox(width: 10),
                              DefaultButton(
                                text: 'Опубликовать',
                                color: AppColors.secondary, // Используйте цвет для успеха или зеленый цвет
                                onPressed: () => _handleAction(house['id'], true, 'Опубликовано'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
