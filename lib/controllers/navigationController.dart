import 'package:flutter/material.dart';
import '../pages/loading.dart';
import '../pages/authorization.dart';
import '../pages/login.dart';
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
  late final Map<PageType, Widget Function()> pages;
  late final Map<PageType, PageSettings> pageSettings;
  String? selectedCity;
  DateTimeRange? dateRange;
  House? selectedHouse;
  int? selectedUserId;
  int? selectedDealId;
  int? selectedReviewId;
  int? selectedHouseId; 

  NavigationController() {
    pages = {
      PageType.loading_page: () => LoadingPage(onPageChange: loadPage),
      PageType.authorization_page: () => AuthorizationPage(onPageChange: loadPage),
      PageType.login_page: () => LoginPage(onPageChange: loadPage),
      PageType.register_page: () => RegistrationPage(onPageChange: loadPage),
      PageType.confirm_page: () => ConfirmPage(onPageChange: loadPage),
      PageType.filters_page: () => FiltersPage(onPageChange: loadPage),
      PageType.results_page: () => SearchResultsPage(onPageChange: loadPage, selectedCity: selectedCity, dateRange: dateRange),
      PageType.create_declaration_page: () => CreateDeclarationPage(onPageChange: loadPage),
      PageType.declaration_page: () => selectedHouse != null ? DeclarationPage(house: selectedHouse!, onPageChange: loadPage) : Placeholder(),
      PageType.user_page: () => selectedUserId != null ? UserProfilePage(onPageChange: loadPage, userId: selectedUserId) : Placeholder(),
      PageType.redact_page: () => RedactProfilePage(onPageChange: loadPage),
      PageType.deals_page: () => ActiveDealsPage(onPageChange: loadPage),
      PageType.deal_page: () => selectedDealId != null ? DealPage(onPageChange: loadPage, dealId: selectedDealId) : Placeholder(),
      PageType.notification_page: () => NotificationsPage(onPageChange: loadPage),
      PageType.review_page: () => ReviewPage(onPageChange: loadPage, reviewId: selectedReviewId!),
      PageType.create_review_page: () => selectedHouseId != null ? CreateReviewPage(onPageChange: loadPage, houseId: selectedHouseId) : Placeholder(),
      PageType.moderator_profile_page: () => ModerProfilePage(onPageChange: loadPage),
      PageType.reports_page: () => ReportsPage(onPageChange: loadPage),
      PageType.premoderation_page: () => PremoderationPage(onPageChange: loadPage),
    };

    pageSettings = {
      PageType.loading_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.authorization_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
      PageType.login_page: PageSettings(navigationBarType: NavigationBarType.none, showAds: false),
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

  void loadPage(PageType page, {String? city, DateTimeRange? dateRange, House? house, int? userId, int? dealId, int? reviewId, int? houseId}) {
    selectedCity = city;
    this.dateRange = dateRange;
    selectedHouse = house;
    selectedUserId = userId;
    selectedDealId = dealId;
    selectedReviewId = reviewId;
    selectedHouseId = houseId;

    if (page != _currentPage) {
      _currentPage = page;
      print("Loading page: $page with userId: $userId, house: $house, dealId: $dealId, reviewId: $reviewId, houseId: $houseId");

      if (page == PageType.user_page) {
        pages[PageType.user_page] = () => UserProfilePage(onPageChange: loadPage, userId: selectedUserId);
      } else if (page == PageType.deal_page) {
        pages[PageType.deal_page] = () => DealPage(onPageChange: loadPage, dealId: selectedDealId);
      } else if (page == PageType.review_page) {
        pages[PageType.review_page] = () => ReviewPage(onPageChange: loadPage, reviewId: selectedReviewId!);
      } else if (page == PageType.create_review_page) {
        pages[PageType.create_review_page] = () => CreateReviewPage(onPageChange: loadPage, houseId: selectedHouseId);
      }

      notifyListeners();
    }
  }
}
