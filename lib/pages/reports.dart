import 'package:flutter/material.dart';
import 'dart:convert';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/tokenStorage.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';

class ReportsPage extends StatefulWidget {
  final void Function(PageType) onPageChange;

  ReportsPage({required this.onPageChange});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      MessageOverlayManager.showMessageOverlay("Ошибка", "Не удалось получить токен");
      return;
    }

    final response = await ConnectionController.getRequest('/moderator/reported-users');

    if (response.statusCode == 200) {
      setState(() {
        reports = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      MessageOverlayManager.showMessageOverlay(
          "Ошибка", "Не удалось загрузить отчеты");
    }
  }

  Future<void> _handleAction(int reportId, int userId, String action) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      MessageOverlayManager.showMessageOverlay("Ошибка", "Не удалось получить токен");
      return;
    }

    final body = {
      'id': reportId,
      'userId': userId,
    };

    final response = await ConnectionController.putRequest('/moderator/$action', body);

    if (response.statusCode == 200) {
      setState(() {
        reports.removeWhere((report) => report['id'] == reportId);
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
        title: Text('Отчеты модератора'),
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
                'Список отчетов',
                style: TextStyles.mainHeadline,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  var report = reports[index];
                  var reportedUser = report['reportedUser'];
                  var reporter = report['reporter'];
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
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${reportedUser['name']} ${reportedUser['surname']}',
                                    style: TextStyles.subHeadline,
                                  ),
                                  Text(
                                    'Логин: ${reportedUser['login']}',
                                    style: TextStyles.mainText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Жалоба от: ${reporter['login']}',
                            style: TextStyles.mainText,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Причина жалобы: ${report['complaintReason']}',
                            style: TextStyles.mainText,
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DefaultButton(
                                text: 'Отклонить',
                                color: AppColors.primary,
                                onPressed: () => _handleAction(report['id'], reportedUser['id'], 'reject'),
                              ),
                              SizedBox(width: 10),
                              DefaultButton(
                                text: 'Забанить',
                                color: AppColors.secondary,
                                onPressed: () => _handleAction(report['id'], reportedUser['id'], 'ban'),
                              ),
                            ]
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
