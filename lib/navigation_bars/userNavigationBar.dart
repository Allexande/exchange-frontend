import 'package:flutter/material.dart';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';

class UserNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(PageType) onItemSelected;

  UserNavigationBar({
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  _UserNavigationBarState createState() => _UserNavigationBarState();
}

class _UserNavigationBarState extends State<UserNavigationBar> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = (widget.currentIndex < 0 || widget.currentIndex > 3) ? 0 : widget.currentIndex;
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    PageType selectedPage;
    switch (index) {
      case 0:
        selectedPage = PageType.user_page; 
        break;
      case 1:
        selectedPage = PageType.filters_page; 
        break;
      case 2:
        selectedPage = PageType.deals_page; 
        break;
      case 3:
        selectedPage = PageType.notification_page; 
        break;
      default:
        selectedPage = PageType.filters_page; 
    }

    widget.onItemSelected(selectedPage);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(
              Icons.person,
              color: selectedIndex == 0 ? AppColors.secondary : AppColors.background,
              size: 30,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(
              Icons.search,
              color: selectedIndex == 1 ? AppColors.secondary : AppColors.background,
              size: 30,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(
              Icons.check_circle,
              color: selectedIndex == 2 ? AppColors.secondary : AppColors.background,
              size: 30,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(
              Icons.notifications,
              color: selectedIndex == 3 ? AppColors.secondary : AppColors.background,
              size: 30,
            ),
          ),
          label: '',
        ),
      ],
      backgroundColor: AppColors.primary,
      unselectedItemColor: AppColors.background,
      selectedItemColor: AppColors.secondary,
      type: BottomNavigationBarType.fixed,
    );
  }
}
