import 'package:flutter/foundation.dart' show compute;

import '../models/get_stories_model.dart';

/// Off-main-isolate parsing for the (large) stories response.
///
/// `GetStoriesModel.fromJson` is pure — it reads no globals / `dotenv` / `GetIt`
/// — so, unlike the home-feature parsers, no state needs re-seeding inside the
/// worker isolate. If that ever changes, seed it here before `fromJson`.
GetStoriesModel _parseStories(dynamic raw) => GetStoriesModel.fromJson(raw);

/// Build the stories model on a background isolate (keeps `fromJson` off the
/// UI thread for the large stories payload).
Future<GetStoriesModel> parseStoriesInBackground(dynamic raw) =>
    compute(_parseStories, raw);
