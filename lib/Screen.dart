/*
  The screen of the app

  The app made up with SPA pattern, Screen.dart is the only page that users see
*/

import 'package:flutter/material.dart';
import 'navigation_bars/userNavigationBar.dart';
import 'navigation_bars/moderatorNavigationBar.dart';
import 'ads/advertisementBar.dart';
import 'controllers/NavigationController.dart';
import 'controllers/pageSettings.dart';
import 'widgets/messageOverlay.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  ScreenState createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  final NavigationController _navigationController = NavigationController();

  @override
  void initState() {
    super.initState();
    _navigationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _navigationController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSettings = _navigationController.currentPageSettings;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: AnimatedBuilder(
                  animation: _navigationController,
                  builder: (_, __) => _navigationController.currentPage,
                ),
              ),
              if (currentSettings.navigationBarType == NavigationBarType.userNavigationBar)
                UserNavigationBar(
                  currentIndex: _navigationController.currentPageIndex,
                  onItemSelected: (page) => _navigationController.loadPage(page),
                ),
              if (currentSettings.navigationBarType == NavigationBarType.moderatorNavigationBar)
                ModeratorNavigationBar(
                  currentIndex: _navigationController.currentPageIndex,
                  onItemSelected: (page) => _navigationController.loadPage(page),
                ),
              if (currentSettings.showAds)
                const AdvertisementBar(),
            ],
          ),
          MessageOverlayManager.createOverlay(),
        ],
      ),
    );
  }
}
