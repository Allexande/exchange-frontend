import 'package:exchange/widgets/images/imageCarusel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../models/house.dart';
import '../controllers/connectionController.dart';
import '../widgets/userCard/userCard.dart';
//import '../widgets/images/imageCarusel.dart';  

class DealPage extends StatefulWidget {
  final void Function(PageType, {int? userId, int? houseId, int? givenHouseId, int? recievedHouseId, int? reviewId}) onPageChange;
  final int recievedHouseId;
  final int givenHouseId;
  final VoidCallback goBack;

  DealPage({required this.onPageChange, required this.recievedHouseId, required this.givenHouseId, required this.goBack});

  @override
  _DealPageState createState() => _DealPageState();
}

class _DealPageState extends State<DealPage> {
  String? startDate;
  String? endDate;
  House? firstHouse;
  House? secondHouse;
  List<Uint8List> firstHouseImages = [];
  List<Uint8List> secondHouseImages = [];
  int? userId;
  String dealStatus = 'PENDING';
  int? dealId;
  bool hasReviewed = false;
  Map<String, dynamic>? userReview;

  @override
  void initState() {
    super.initState();
    loadUserId();
    loadDealData(widget.recievedHouseId, widget.givenHouseId);
  }

  Future<void> loadUserId() async {
    final response = await ConnectionController.getRequest('/user/me');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userId = data['id'];
      });
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

  Future<void> loadDealData(int recievedHouseId, int givenHouseId) async {
    final houseResponse = await ConnectionController.getRequest('/houses/$recievedHouseId');
    final givenHouseResponse = await ConnectionController.getRequest('/houses/$givenHouseId');
    final dealResponse = await ConnectionController.getRequest('/houses/trades?givenHouseId=$givenHouseId&receivedHouseId=$recievedHouseId');

    if (houseResponse.statusCode == 200 && givenHouseResponse.statusCode == 200 && dealResponse.statusCode == 200) {
      var deals = json.decode(utf8.decode(dealResponse.bodyBytes));
      if (deals.isNotEmpty) {
        var latestDeal = deals.last;
        dealStatus = latestDeal['status'];
        dealId = latestDeal['id'];
        startDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(latestDeal['startDate']));
        endDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(latestDeal['endDate']));
      }
      setState(() {
        firstHouse = House.fromJson(json.decode(utf8.decode(houseResponse.bodyBytes)));
        secondHouse = House.fromJson(json.decode(utf8.decode(givenHouseResponse.bodyBytes)));
        loadHouseImages(widget.recievedHouseId, widget.givenHouseId);
        checkIfReviewed(widget.recievedHouseId);
      });
    } else {
      try {
        final errorData = json.decode(utf8.decode(houseResponse.bodyBytes));
        String errorMessage = 'Ошибка ${houseResponse.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        MessageOverlayManager.showMessageOverlay('Ошибка ${houseResponse.statusCode}: ${utf8.decode(houseResponse.bodyBytes)}', "Понятно");
      }
    }
  }

  Future<void> loadHouseImages(int recievedHouseId, int givenHouseId) async {
    final firstHouseImagesResponse = await ConnectionController.getRequest('/houses/$recievedHouseId/images');
    final secondHouseImagesResponse = await ConnectionController.getRequest('/houses/$givenHouseId/images');

    if (firstHouseImagesResponse.statusCode == 200) {
      List<String> imagePaths = List<String>.from(json.decode(firstHouseImagesResponse.body).map((image) => image['path']));
      for (String path in imagePaths) {
        final imageResponse = await ConnectionController.getRequest('/houses/$recievedHouseId/image?path=$path');
        if (imageResponse.statusCode == 200) {
          setState(() {
            firstHouseImages.add(imageResponse.bodyBytes);
          });
        } else {
          showErrorOverlay(imageResponse.body, imageResponse.statusCode);
        }
      }
    } else {
      showErrorOverlay(firstHouseImagesResponse.body, firstHouseImagesResponse.statusCode);
    }

    if (secondHouseImagesResponse.statusCode == 200) {
      List<String> imagePaths = List<String>.from(json.decode(secondHouseImagesResponse.body).map((image) => image['path']));
      for (String path in imagePaths) {
        final imageResponse = await ConnectionController.getRequest('/houses/$givenHouseId/image?path=$path');
        if (imageResponse.statusCode == 200) {
          setState(() {
            secondHouseImages.add(imageResponse.bodyBytes);
          });
        } else {
          showErrorOverlay(imageResponse.body, imageResponse.statusCode);
        }
      }
    } else {
      showErrorOverlay(secondHouseImagesResponse.body, secondHouseImagesResponse.statusCode);
    }
  }

  void showErrorOverlay(String responseBody, int statusCode) {
    try {
      final errorData = json.decode(responseBody);
      String errorMessage = 'Ошибка $statusCode: ${errorData['message'] ?? 'Неизвестная ошибка'}';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    } catch (e) {
      String errorMessage = 'Ошибка $statusCode: $responseBody';
      MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
    }
  }

  Future<void> checkIfReviewed(int houseId) async {
    final reviewsResponse = await ConnectionController.getRequest('/houses/$houseId/reviews');

    if (reviewsResponse.statusCode == 200) {
      var reviews = json.decode(utf8.decode(reviewsResponse.bodyBytes));
      setState(() {
        userReview = reviews.firstWhere(
            (review) => review['userDtoResponse']['id'] == userId,
            orElse: () => null);
        hasReviewed = userReview != null;
      });
    } else {
      try {
        final errorData = json.decode(utf8.decode(reviewsResponse.bodyBytes));
        String errorMessage = 'Ошибка ${reviewsResponse.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        MessageOverlayManager.showMessageOverlay('Ошибка ${reviewsResponse.statusCode}: ${utf8.decode(reviewsResponse.bodyBytes)}', "Понятно");
      }
    }
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
      try {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        MessageOverlayManager.showMessageOverlay('Ошибка ${response.statusCode}: ${utf8.decode(response.bodyBytes)}', "Понятно");
      }
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
                          dealStatus == 'COMPLETED' ? 'Сделка совершилась!' : dealStatus == 'PENDING' ? 'Предложение на рассмотрении' : 'Сделка не состоялась',
                          style: TextStyles.subHeadline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (startDate != null && endDate != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Начало сделки: $startDate',
                            style: TextStyles.mainText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Конец сделки: $endDate',
                            style: TextStyles.mainText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      SizedBox(height: 10),
                      _buildHouseSection(firstHouse!, 'Полученное жилье:', firstHouseImages),
                      SizedBox(height: 20),
                      _buildHouseSection(secondHouse!, 'Ваше жилье:', secondHouseImages),
                      SizedBox(height: 20),
                      if (dealStatus == 'PENDING' && userId != null && firstHouse!.user.id == userId)
                        Column(
                          children: [
                            MainButton(
                              onPressed: () => updateDealStatus(dealId!, 'COMPLETED'),
                              text: 'Принять',
                            ),
                            SizedBox(height: 10),
                            MainButton(
                              onPressed: () => updateDealStatus(dealId!, 'REJECTED'),
                              text: 'Отклонить',
                            ),
                          ],
                        )
                      else if (dealStatus == 'PENDING' && userId != null && firstHouse!.user.id != userId)
                        MainButton(
                          onPressed: () => updateDealStatus(dealId!, 'REJECTED'),
                          text: 'Удалить сделку',
                        )
                      else if (dealStatus == 'COMPLETED')
                        Column(
                          children: [
                            if (!hasReviewed)
                              SizedBox(
                                width: double.infinity,
                                child: MainButton(
                                  onPressed: () {
                                    widget.onPageChange(PageType.create_review_page, houseId: secondHouse!.id);
                                  },
                                  text: 'Оставить отзыв',
                                ),
                              )
                            else
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Вы оставили отзыв на этот дом:',
                                      style: TextStyles.mainText,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      widget.onPageChange(PageType.review_page, reviewId: userReview!['id']);
                                    },
                                    child: Card(
                                      color: AppColors.secondary,
                                      child: ListTile(
                                        title: Text(
                                          userReview!['description'],
                                          style: TextStyles.mainText,
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, color: Colors.amber),
                                            SizedBox(width: 4),
                                            Text(
                                              userReview!['rating'].toString(),
                                              style: TextStyles.mainText,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        )
                      else if (dealStatus == 'REJECTED')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Сделка не состоялась.',
                            style: TextStyles.mainText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(height: 20),
                      SubButton(
                        onPressed: () {
                          widget.goBack();
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

  Widget _buildHouseSection(House house, String title, List<Uint8List> houseImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyles.subHeadline,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            house.city,
            style: TextStyles.smallHeadline,
            textAlign: TextAlign.center,
          ),
        ),
        houseImages.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Фото для данного дома отсутствуют',
                  style: TextStyles.mainText,
                  textAlign: TextAlign.center,
                ),
              )
            : ImageCarousel(images: houseImages), 
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
          child: UserCard(
            user: house.user,
            onTap: () {
              widget.onPageChange(PageType.user_page, userId: house.user.id);
            },
          ),
        ),
      ],
    );
  }
}
