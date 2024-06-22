import 'package:flutter/material.dart';
import '../styles/theme.dart';

class MessageOverlay extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onDismiss;

  MessageOverlay({
    required this.message,
    required this.buttonText,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: TextStyles.mainText),
              SizedBox(height: 20.0),
              MainButton(
                text: buttonText,
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageOverlayManager {
  static final GlobalKey<_MessageOverlayContainerState> _overlayKey = GlobalKey<_MessageOverlayContainerState>();

  static void showMessageOverlay(String message, String buttonText) {
    _overlayKey.currentState?.addMessageToQueue(message, buttonText);
  }

  static void removeOverlay() {
    _overlayKey.currentState?.hideMessage();
  }

  static Widget createOverlay() {
    return _MessageOverlayContainer(key: _overlayKey);
  }
}

class _MessageOverlayContainer extends StatefulWidget {
  const _MessageOverlayContainer({Key? key}) : super(key: key);

  @override
  _MessageOverlayContainerState createState() => _MessageOverlayContainerState();
}

class _MessageOverlayContainerState extends State<_MessageOverlayContainer> {
  final List<Map<String, String>> _messageQueue = [];
  String _message = '';
  String _buttonText = '';
  bool _isVisible = false;

  void addMessageToQueue(String message, String buttonText) {
    _messageQueue.add({'message': message, 'buttonText': buttonText});
    if (!_isVisible) {
      _showNextMessage();
    }
  }

  void _showNextMessage() {
    if (_messageQueue.isNotEmpty) {
      final nextMessage = _messageQueue.removeAt(0);
      setState(() {
        _message = nextMessage['message']!;
        _buttonText = nextMessage['buttonText']!;
        _isVisible = true;
      });
    }
  }

  void hideMessage() {
    setState(() {
      _isVisible = false;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      _showNextMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_isVisible,
      child: Visibility(
        visible: _isVisible,
        child: MessageOverlay(
          message: _message,
          buttonText: _buttonText,
          onDismiss: hideMessage,
        ),
      ),
    );
  }
}
