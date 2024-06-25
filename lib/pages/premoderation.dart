import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';
import '../widgets/images/imageCarusel.dart';

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
        houses = List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
      });
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка", "Не удалось загрузить дома");
    }
  }

  Future<List<Uint8List>> loadHouseImages(int houseId) async {
    final imagePathsResponse = await ConnectionController.getRequest('/houses/$houseId/images');
    List<Uint8List> houseImages = [];
    if (imagePathsResponse.statusCode == 200) {
      List<String> imagePaths = List<String>.from(json.decode(utf8.decode(imagePathsResponse.bodyBytes)).map((image) => image['path']));
      for (String path in imagePaths) {
        final imageResponse = await ConnectionController.getRequest('/houses/$houseId/image?path=$path');
        if (imageResponse.statusCode == 200) {
          houseImages.add(imageResponse.bodyBytes);
        }
      }
    }
    return houseImages;
  }

  Future<void> _handleAction(int houseId, bool isApproved, String decision) async {
    final body = {
      'id': houseId,
      'isApproved': isApproved,
      'decision': decision,
    };

    final response = await ConnectionController.putRequest('/moderator/house', jsonEncode(body) as Map<String, dynamic>);

    if (response.statusCode == 200) {
      setState(() {
        houses.removeWhere((house) => house['id'] == houseId);
      });
      MessageOverlayManager.showMessageOverlay("Успех, действие выполнено успешно", "Понятно");
    } else {
      MessageOverlayManager.showMessageOverlay("Ошибка, не удалось выполнить действие", "Понятно");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Список домов для премодерации',
                style: TextStyles.smallHeadline,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: houses.length,
                itemBuilder: (context, index) {
                  var house = houses[index];
                  return FutureBuilder<List<Uint8List>>(
                    future: loadHouseImages(house['id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Ошибка при загрузке изображений'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      child: Icon(Icons.home, color: Colors.white),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${house['city']}, ${house['address']}',
                                            style: TextStyles.smallHeadline,
                                          ),
                                          Text(
                                            'Описание: ${house['description']}',
                                            style: TextStyles.mainText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Фото не загружены',
                                  style: TextStyles.subText,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Пользователь: ${house['user']['name']} ${house['user']['surname']} (${house['user']['login']})',
                                  style: TextStyles.mainText,
                                ),
                                Text(
                                  'Контакты: ${house['user']['description']}',
                                  style: TextStyles.mainText,
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: DefaultButton(
                                        text: 'Отклонить',
                                        color: AppColors.primary,
                                        onPressed: () => _handleAction(house['id'], false, 'Отклонено'),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: DefaultButton(
                                        text: 'Опубликовать',
                                        color: AppColors.secondary,
                                        onPressed: () => _handleAction(house['id'], true, 'Опубликовано'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      child: Icon(Icons.home, color: Colors.white),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${house['city']}, ${house['address']}',
                                            style: TextStyles.smallHeadline,
                                          ),
                                          Text(
                                            'Описание: ${house['description']}',
                                            style: TextStyles.mainText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                ImageCarousel(images: snapshot.data!),
                                SizedBox(height: 10),
                                Text(
                                  'Пользователь: ${house['user']['name']} ${house['user']['surname']} (${house['user']['login']})',
                                  style: TextStyles.mainText,
                                ),
                                Text(
                                  'Контакты: ${house['user']['description']}',
                                  style: TextStyles.mainText,
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: DefaultButton(
                                        text: 'Отклонить',
                                        color: AppColors.primary,
                                        onPressed: () => _handleAction(house['id'], false, 'Отклонено'),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: DefaultButton(
                                        text: 'Опубликовать',
                                        color: AppColors.secondary,
                                        onPressed: () => _handleAction(house['id'], true, 'Опубликовано'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
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
