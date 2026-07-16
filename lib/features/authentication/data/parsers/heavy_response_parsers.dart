import 'package:flutter/foundation.dart';

import '../models/verify_otp_sign_up_and_in_response_model.dart';

/// Off-main-isolate parsing for the authentication feature's heaviest
/// responses.
///
/// Building the model object graph (`Model.fromJson`) otherwise runs on the UI
/// isolate. Each `parse*` helper hands the raw decoded response to a top-level
/// function via [compute] so the object construction happens on a background
/// isolate; only the finished (immutable) model is copied back.
///
/// The [User] model reads no startup globals (`mediaServerIsS3` / `dotenv`) in
/// its `fromJson` — it stores server strings verbatim — so no global seeding is
/// needed and the raw map can travel into the worker as-is. If it ever starts
/// building media URLs from those globals, it must seed them inside the worker
/// first.

// ---------------------------------------------------------------------------
// Top-level isolate entry point (must be top-level/static for `compute`).
// ---------------------------------------------------------------------------

/// Runs inside the worker isolate. Mirrors the original call site, which reads
/// the customer object out of `data.customer_info` before building [User].
User _parseCustomerInfo(Map<String, dynamic> raw) =>
    User.fromJson(raw['data']['customer_info']);

// ---------------------------------------------------------------------------
// Public API — call this from the data source with the raw decoded response.
// ---------------------------------------------------------------------------

/// Build the customer-info [User] model off-thread from the full response map.
Future<User> parseCustomerInfoInBackground(Map<String, dynamic> raw) =>
    compute(_parseCustomerInfo, raw);
