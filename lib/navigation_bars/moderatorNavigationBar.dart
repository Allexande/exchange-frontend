import 'package:flutter/material.dart';
import '../styles/theme.dart';
import '../controllers/pagesList.dart';

class ModeratorNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(PageType) onItemSelected;

  ModeratorNavigationBar({
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  _ModeratorNavigationBarState createState() => _ModeratorNavigationBarState();
}

class _ModeratorNavigationBarState extends State<ModeratorNavigationBar> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = (widget.currentIndex < 0 || widget.currentIndex > 2) ? 0 : widget.currentIndex;
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    PageType selectedPage;
    switch (index) {
      case 0:
        selectedPage = PageType.moderator_profile_page; 
        break;
      case 1:
        selectedPage = PageType.reports_page; 
        break;
      case 2:
        selectedPage = PageType.premoderation_page; 
        break;
      default:
        selectedPage = PageType.moderator_profile_page; 
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
              size: 40,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(
              Icons.report,
              color: selectedIndex == 1 ? AppColors.secondary : AppColors.background,
              size: 40,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(
              Icons.list,
              color: selectedIndex == 2 ? AppColors.secondary : AppColors.background,
              size: 40,
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
