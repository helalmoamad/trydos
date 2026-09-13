

class Constants {
  static const String urlPioneerGooglePlay = 'https://play.google.com/store/apps/details?id=com.nbs.alphamealprovider';
  static const String urlPioneerAppStore = 'https://apps.apple.com/tr/humy/humy-pioneer/id1592514883';
  // The Agora App ID used to live here. It was only referenced by the
  // commented-out RtcEngine code in room_call_page.dart, and a credential must
  // not sit in source anyway. Calls run through the Agora webview, which gets
  // its token from the backend. If native Agora comes back, read the App ID
  // from `.env` via dotenv.
}