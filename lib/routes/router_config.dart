class RouterConfiguration {
  RouterConfiguration.init();

  final String kRootRoute = '/';
  final applicationRoutes = _ApplicationRoutes();

}

class _ApplicationRoutes{
  final String test='/test';
  final String kBasePage = '/BasePage';
  final String kWebView = '/WebView';
  final String kRoomCallPage = '/RoomCallPage';
  final String kAnswerCall = '/AnswerCall';
  final String kSinglePageChatPageName = 'SinglePageChatPage';
  final String kSinglePageChatPagePath = '/BasePage/SinglePageChatPage';
  final String kLoginPage = '/LoginPage';
  final String kRegistrationPageName = 'RegistrationPage';
  final String kRegistrationPagePath = '/BasePage/RegistrationPage';
  final String kMyContactsPageName = 'MyContacts';
  final String kMyContactsPagePath = '/BasePage/MyContacts';
  final String kLoginSuccessfullyPage = '/LoginSuccessfullyPage';
  final String kUserExistName = 'UserExist';
  final String kNumberNotRegisteredName = 'NumberNotRegistered';
  final String kNumberNotRegisteredPage = '/BasePage/RegistrationPage/NumberNotRegistered';
  final String kUserExistPage = '/BasePage/RegistrationPage/UserExist';
  final String kHomePage = '/HomePage';
  final String kChatPage = '/ChatPage';
  final String kRegistrationPage = '/RegistrationPage';
  final String kRegistrationCompletedPage = '/RegistrationCompletedPage';
  final String kFeedBackPageName = 'FeedBackPage';
  final String kFeedBackPagePath = '/BasePage/FeedBackPage';
  final String kSharedPreferencePageName = 'SharedPreferencePage';
  final String kSharedPreferencePagePath = '/BasePage/SharedPreferencePage';
  // final String kPageViewStoryCollectionsPageName = 'PageViewStoryCollectionsPage';
  // final String kPageViewStoryCollectionsPagePath = '/BasePage/PageViewStoryCollectionsPage';
}

