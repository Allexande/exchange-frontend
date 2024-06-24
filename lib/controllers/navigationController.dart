import 'package:flutter/material.dart';
import '../pages/loading.dart';
import '../pages/authorization.dart';
import '../pages/login.dart';
import '../pages/_testLogin.dart';
import '../pages/register.dart';
import '../pages/confirm.dart';
import '../pages/filters.dart';
import '../pages/results.dart';
import '../pages/createDeclaration.dart';
import '../pages/declaration.dart';
import '../pages/user.dart';
import '../pages/redact.dart';
import '../pages/deals.dart';
import '../pages/deal.dart';
import '../pages/notifications.dart';
import '../pages/review.dart';
import '../pages/createReview.dart';
import '../pages/moderatorProfile.dart';
import '../pages/reports.dart';
import '../pages/premoderation.dart';
import 'pagesList.dart';
import 'pageSettings.dart';
import '../models/house.dart';

class NavigationController extends ChangeNotifier {
  PageType _currentPage = PageType.loading_page;
  List<Map<String, dynamic>> _pageStack = [];
  late final Map<PageType, Widget Function()> pages;
  late final Map<PageType, PageSettings> pageSettings;
  String? selectedCity;
  DateTimeRange? dateRange;
  House? selectedHouse;
  int? selectedUserId;
  int? selectedReviewId;
  int? selectedHouseId;
  int? selectedGivenHouseId;
  int? selectedRecievedHouseId;

  NavigationController() {
    pages = {
      PageType.loading_page: () => LoadingPage(onPageChange: loadPage),
      PageType.authorization_page: () => AuthorizationPage(onPageChange: loadPage),
      PageType.login_page: () => LoginPage(onPageChange: loadPage, goBack: goBack),
      PageType.testLogin: () => TestLoginPage(onPageChange: loadPage),
      PageType.register_page: () => RegistrationPage(onPageChange: loadPage, goBack: goBack),
      PageType.confirm_page: () => ConfirmPage(onPageChange: loadPage, goBack: goBack),
      PageType.filters_page: () => FiltersPage(onPageChange: loadPage),
      PageType.results_page: () => SearchResultsPage(onPageChange: loadPage, selectedCity: selectedCity, dateRange: dateRange),
      PageType.create_declaration_page: () => CreateDeclarationPage(onPageChange: loadPage, goBack: goBack),
      PageType.declaration_page: () => selectedHouseId != null ? DeclarationPage(houseId: selectedHouseId!, onPageChange: loadPage) : Placeholder(),
      PageType.user_page: () => selectedUserId != null ? UserProfilePage(onPageChange: loadPage, userId: selectedUserId) : Placeholder(),
      PageType.redact_page: () => RedactProfilePage(onPageChange: loadPage, goBack: goBack),
      PageType.deals_page: () => ActiveDealsPage(onPageChange: loadPage),
      PageType.deal_page: () => selectedHouseId != null && selectedGivenHouseId != null && selectedRecievedHouseId != null ? DealPage(onPageChange: loadPage, recievedHouseId: selectedRecievedHouseId!, givenHouseId: selectedGivenHouseId!, goBack: goBack) : Placeholder(),
      PageType.notification_page: () => NotificationsPage(onPageChange: loadPage),
      PageType.review_page: () => selectedReviewId != null ? ReviewPage(onPageChange: loadPage, reviewId: selectedReviewId!, goBack: goBack) : Placeholder(),
      PageType.create_review_page: () => selectedHouseId != null ? CreateReviewPage(onPageChange: loadPage, houseId: selectedHouseId, goBack: goBack) : Placeholder(),
      PageType.moderator_profile_page: () => ModerProfilePage(onPageChange: loadPage),
      PageType.reports_page: () => ReportsPage(onPageChange: loadPage),
      PageType.premoderation_page: () => PremoderationPage(onPageChange: loadPage),
    };

    pageSettings = {
      PageType.loading_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.authorization_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.login_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.testLogin: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.register_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.confirm_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.filters_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.results_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.create_declaration_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.declaration_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.user_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.redact_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.deals_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.deal_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.notification_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.review_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.create_review_page: PageSettings(navigationBarType: NavigationBarType.userNavigationBar, showAds: true),
      PageType.moderator_profile_page: PageSettings(navigationBarType: NavigationBarType.moderatorNavigationBar, showAds: false),
      PageType.reports_page: PageSettings(navigationBarType: NavigationBarType.moderatorNavigationBar, showAds: false),
      PageType.premoderation_page: PageSettings(navigationBarType: NavigationBarType.moderatorNavigationBar, showAds: false),
    };
  }

  Widget get currentPage => pages[_currentPage]!();
  PageSettings get currentPageSettings => pageSettings[_currentPage]!;

  int get currentPageIndex {
    return PageType.values.indexOf(_currentPage);
  }

  void loadPage(PageType page, {String? city, DateTimeRange? dateRange, House? house, int? userId, int? reviewId, int? houseId, int? givenHouseId, int? recievedHouseId}) {
    // Сохраняем текущие параметры в стек
    _pageStack.add({
      'page': _currentPage,
      'city': selectedCity,
      'dateRange': this.dateRange,
      'house': selectedHouse,
      'userId': selectedUserId,
      'reviewId': selectedReviewId,
      'houseId': selectedHouseId,
      'givenHouseId': selectedGivenHouseId,
      'recievedHouseId': selectedRecievedHouseId,
    });

    // Обновляем параметры для новой страницы
    selectedCity = city;
    this.dateRange = dateRange;
    selectedHouse = house;
    selectedUserId = userId;
    selectedReviewId = reviewId;
    selectedHouseId = houseId;
    selectedGivenHouseId = givenHouseId;
    selectedRecievedHouseId = recievedHouseId;

    if (page != _currentPage) {
      _currentPage = page;
      print("Loading page: $page with userId: $userId, house: $house, reviewId: $reviewId, houseId: $houseId, givenHouseId: $givenHouseId, recievedHouseId: $recievedHouseId");

      if (page == PageType.user_page) {
        pages[PageType.user_page] = () => UserProfilePage(onPageChange: loadPage, userId: selectedUserId);
      } else if (page == PageType.deal_page) {
        if (selectedRecievedHouseId != null && selectedGivenHouseId != null) {
          pages[PageType.deal_page] = () => DealPage(onPageChange: loadPage, recievedHouseId: selectedRecievedHouseId!, givenHouseId: selectedGivenHouseId!, goBack: goBack);
        } else {
          print("Error: recievedHouseId or givenHouseId is null");
          return;
        }
      } else if (page == PageType.review_page) {
        pages[PageType.review_page] = () => ReviewPage(onPageChange: loadPage, reviewId: selectedReviewId!, goBack: goBack);
      } else if (page == PageType.create_review_page) {
        pages[PageType.create_review_page] = () => CreateReviewPage(onPageChange: loadPage, houseId: selectedHouseId, goBack: goBack);
      }

      notifyListeners();
    }
  }

  void goBack() {
    if (_pageStack.isNotEmpty) {
      var previous = _pageStack.removeLast();
      _currentPage = previous['page'];
      selectedCity = previous['city'];
      dateRange = previous['dateRange'];
      selectedHouse = previous['house'];
      selectedUserId = previous['userId'];
      selectedReviewId = previous['reviewId'];
      selectedHouseId = previous['houseId'];
      selectedGivenHouseId = previous['givenHouseId'];
      selectedRecievedHouseId = previous['recievedHouseId'];

      notifyListeners();
    }
  }
}
