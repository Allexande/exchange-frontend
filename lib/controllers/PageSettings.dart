enum NavigationBarType {
  none,
  userNavigationBar,
  moderatorNavigationBar,
}

class PageSettings {
  final NavigationBarType navigationBarType;
  final bool showAds;

  PageSettings({required this.navigationBarType, required this.showAds});
}
