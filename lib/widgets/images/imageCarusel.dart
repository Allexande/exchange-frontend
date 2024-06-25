import 'package:flutter/material.dart';
import 'dart:typed_data';

class ImageCarousel extends StatefulWidget {
  final List<Uint8List> images;

  ImageCarousel({required this.images});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFullscreen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        _animation = Tween<double>(begin: 1.0, end: 1.0).animate(_animationController);
      } else {
        _animation = Tween<double>(begin: 1.0, end: 1.0).animate(_animationController);
      }
      _animationController.forward(from: 0);
    });
  }

  void _nextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.images.length;
    });
  }

  void _previousImage() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleFullscreen,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_isFullscreen ? 0 : 16.0),
                  child: Image.memory(
                    widget.images[_currentIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: _isFullscreen ? MediaQuery.of(context).size.height : 200.0,
                  ),
                ),
              );
            },
          ),
        ),
        if (!_isFullscreen && widget.images.length > 1)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _previousImage,
            ),
          ),
        if (!_isFullscreen && widget.images.length > 1)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: _nextImage,
            ),
          ),
        if (!_isFullscreen)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key ? Colors.blueAccent : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
