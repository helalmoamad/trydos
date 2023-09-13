class RouterConfiguration {
  RouterConfiguration.init();

  final String kRootRoute = '/';
  final applicationRoutes = _ApplicationRoutes();

}

class _ApplicationRoutes{
  final String kBasePage = '/BasePage';
  final String kSinglePageChatPageName = 'SinglePageChatPage';
  final String kSinglePageChatPagePath = '/BasePage/SinglePageChatPage';
  final String kLoginPage = '/LoginPage';
  final String kLoginPageName = 'LoginPage';
  final String kLoginPagePath = '/BasePage/LoginPage';
  final String kMyContactsPageName = 'MyContacts';
  final String kMyContactsPagePath = '/BasePage/MyContacts';
  final String kLoginSuccessfullyPage = '/LoginSuccessfullyPage';
  final String kHomePage = '/HomePage';
  final String kChatPage = '/ChatPage';
  final String kRegistrationPage = '/RegistrationPage';
  final String kRegistrationCompletedPage = '/RegistrationCompletedPage';
  final String kFeedBackPageName = 'FeedBackPage';
  final String kFeedBackPagePath = '/BasePage/FeedBackPage';
}

