import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../styles/theme.dart';
import '../../models/user.dart' as user_model;
import '../../controllers/connectionController.dart';
import '../../widgets/messageOverlay.dart';

class UserCard extends StatefulWidget {
  final user_model.UserModel user;
  final void Function() onTap;

  UserCard({required this.user, required this.onTap});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Uint8List? avatarImage;

  @override
  void initState() {
    super.initState();
    loadAvatar();
  }

  Future<void> loadAvatar() async {
    final endpoint = '/users/${widget.user.id}/avatar';
    final response = await ConnectionController.getRequest(endpoint);

    if (response.statusCode == 200) {
      try {
        if (mounted) {
          setState(() {
            avatarImage = response.bodyBytes;
          });
        }
      } catch (e) {
        MessageOverlayManager.showMessageOverlay("Ошибка при обработке аватара: $e", "Понятно");
      }
    }
  }

  Widget _buildUserAvatar() {
    if (avatarImage != null) {
      return Padding(
        padding: const EdgeInsets.all(1.0), 
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.memory(
                avatarImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(1.0), 
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2), 
          borderRadius: BorderRadius.circular(50.0), 
        ),
        child: ListTile(
          leading: _buildUserAvatar(),
          title: Text(
            "${widget.user.name} ${widget.user.surname}",
            style: TextStyles.subHeadline,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            widget.user.login,
            style: TextStyles.mainText,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
