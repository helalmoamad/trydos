import 'package:flutter/foundation.dart';

import '../models/my_chats_response_model.dart';
import '../models/my_contacts_response_model.dart';

/// Off-main-isolate parsing for the chat feature's heaviest responses.
///
/// The bottleneck is building the model object graph (`Model.fromJson`), which
/// otherwise runs on the UI isolate and janks the chat/contacts lists. Each
/// `parse*` helper hands the raw decoded response to a top-level function via
/// [compute] so the object construction happens on a background isolate; only
/// the finished (immutable) model is copied back.
///
/// Unlike the home feature's parsers, none of these models read startup globals
/// (`mediaServerIsS3` / `dotenv`) in their `fromJson` — they store server
/// strings verbatim — so no global seeding is needed and the raw map can travel
/// into the worker as-is. If any of these models ever starts building media
/// URLs from those globals, it must seed them inside the worker first.

// ---------------------------------------------------------------------------
// Top-level isolate entry points (must be top-level/static for `compute`).
// ---------------------------------------------------------------------------

MyContactsResponseModel _parseContacts(Map<String, dynamic> raw) =>
    MyContactsResponseModel.fromJson(raw);

MyChatsResponseModel _parseChats(Map<String, dynamic> raw) =>
    MyChatsResponseModel.fromJson(raw);

// ---------------------------------------------------------------------------
// Public API — call these from the data source with the raw decoded response.
// ---------------------------------------------------------------------------

/// Build the contacts model (contacts + nested users) off-thread.
Future<MyContactsResponseModel> parseContactsInBackground(
  Map<String, dynamic> raw,
) => compute(_parseContacts, raw);

/// Build the chats model (chats + last messages + media content) off-thread.
Future<MyChatsResponseModel> parseChatsInBackground(Map<String, dynamic> raw) =>
    compute(_parseChats, raw);
