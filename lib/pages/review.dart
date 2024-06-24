import 'dart:convert';

import 'package:flutter/material.dart';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/connectionController.dart';

class ReviewPage extends StatefulWidget {
  final void Function(PageType, {int? reviewId}) onPageChange;
  final VoidCallback goBack;
  final int reviewId;

  ReviewPage({required this.onPageChange, required this.reviewId, required this.goBack});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  Map<String, dynamic> reviewData = {};

  @override
  void initState() {
    super.initState();
    loadReviewData();
  }

  Future<void> loadReviewData() async {
    final endpoint = '/reviews/${widget.reviewId}';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      setState(() {
        reviewData = json.decode(response.body);
      });
    } else {
      MessageOverlayManager.showMessageOverlay(
          'Ошибка ${response.statusCode}: Не удалось загрузить данные отзыва', "Понятно");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      
    });
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
              Text('Сделка:', style: TextStyles.mainHeadline),
              InkWell(
                onTap: () {
                  widget.onPageChange(PageType.deal_page, reviewId: widget.reviewId);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(reviewData['deal']?['icon'] ?? Icons.swap_horiz, size: 50),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${reviewData['deal']?['cities']?[0] ?? ''} - ${reviewData['deal']?['cities']?[1] ?? ''}', style: TextStyles.subHeadline),
                          Text('${reviewData['deal']?['people']?[0] ?? ''} и ${reviewData['deal']?['people']?[1] ?? ''}', style: TextStyles.mainText),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Отзыв:', style: TextStyles.mainHeadline),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (reviewData['rating'] ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              SizedBox(height: 10),
              Text(reviewData['text'] ?? '', style: TextStyles.mainText),
              SizedBox(height: 20),
              Text('Автор:', style: TextStyles.mainHeadline),
              InkWell(
                onTap: () {
                  // Пока никуда не ведет
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(reviewData['author']?['avatar'] ?? Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    reviewData['author']?['nickname'] ?? '',
                    style: TextStyles.subHeadline,
                  ),
                ),
              ),
              SizedBox(height: 20),
              MainButton(
                text: 'Жалоба/удаление',
                onPressed: () {
                  // Add handling
                },
              ),
              SizedBox(height: 10),
              MainButton(
                text: 'Назад',
                onPressed: () {
                  widget.goBack();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
