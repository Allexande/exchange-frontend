import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../styles/theme.dart';
import '../widgets/messageOverlay.dart';
import '../controllers/pagesList.dart';
import '../controllers/connectionController.dart';
import '../controllers/tokenStorage.dart';

class RedactProfilePage extends StatefulWidget {
  final void Function(PageType) onPageChange;
  final VoidCallback goBack;

  const RedactProfilePage({super.key, required this.onPageChange, required this.goBack});

  @override
  _RedactProfilePageState createState() => _RedactProfilePageState();
}

class _RedactProfilePageState extends State<RedactProfilePage> {
  final TextEditingController _infoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _currentDescription;

  @override
  void initState() {
    super.initState();
    _loadCurrentDescription();
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentDescription() async {
    const endpoint = '/user/me';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _currentDescription = data['description'];
        _infoController.text = _currentDescription ?? '';
      });
    } else {
      print('Ошибка при загрузке текущего описания: ${response.body}');
    }
  }

  Future<void> _updateProfile() async {
    const endpoint = '/user/edit';

    final body = {
      'description': _infoController.text.isEmpty ? _currentDescription : _infoController.text,
    };

    print('Request Endpoint: $endpoint');
    print('Request Body: $body');

    final response = await ConnectionController.putRequest(endpoint, body);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (_selectedImage != null) {
        await _uploadAvatar();  // Загружаем аватар после успешного обновления профиля
      }
      if (mounted) {
        MessageOverlayManager.showMessageOverlay("Профиль успешно обновлен", "ОК");
        widget.onPageChange(PageType.user_page);
      }
    } else {
      if (mounted) {
        try {
          final errorData = json.decode(response.body);
          String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
          MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
        } catch (e) {
          String errorMessage = 'Ошибка ${response.statusCode}: ${response.body}';
          MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = pickedFile;
    });
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    final token = await TokenStorage.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ConnectionController.baseUrl}/user/avatar'),
    );
    request.headers['Authorization'] = '$token';
    request.headers['Content-Type'] = 'multipart/form-data';

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      _selectedImage!.path,
      contentType: MediaType('image', 'jpeg'), // указываем тип файла
    ));

    // Logging the request body
    for (var file in request.files) {
      print('File field: ${file.field}');
      print('File length: ${await file.length}');
    }
    print('Request headers: ${request.headers}');

    var response = await request.send();

    // Logging the response status and body
    print('Response status: ${response.statusCode}');
    final responseBody = await response.stream.bytesToString();
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      MessageOverlayManager.showMessageOverlay("Аватар успешно обновлен", "ОК");
    } else {
      try {
        final errorData = json.decode(responseBody);
        String errorMessage = 'Ошибка ${response.statusCode}: ${errorData['message'] ?? 'Неизвестная ошибка'}';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      } catch (e) {
        String errorMessage = 'Ошибка ${response.statusCode}: $responseBody';
        MessageOverlayManager.showMessageOverlay(errorMessage, "Понятно");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Редактирование профиля",
              style: TextStyles.subHeadline,
              textAlign: TextAlign.center,
            ),
            MainButton(
              onPressed: _pickImage,
              text: 'Загрузить аватар',
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(File(_selectedImage!.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: 130, // Немного больше, чтобы окружность была видна
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Text(
              "Контакты:",
              style: TextStyles.subHeadline,
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: DefaultTextField(
                hintText: 'Описание',
                controller: _infoController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: MainButton(
                onPressed: _updateProfile,
                text: 'Подтвердить',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: SubButton(
                onPressed: () {
                  widget.onPageChange(PageType.user_page);
                },
                text: 'Назад',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
