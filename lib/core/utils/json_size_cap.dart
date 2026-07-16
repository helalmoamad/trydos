import 'dart:convert';

/// Signals that JSON stringification passed the size cap and can stop early.
class _CapExceeded implements Exception {
  const _CapExceeded();
}

/// Counts encoded JSON chars and aborts stringification as soon as [limit] is
/// passed, so an oversized payload is never encoded in full just to measure it.
class _CapCountingSink implements Sink<String> {
  _CapCountingSink(this.limit);

  final int limit;
  int count = 0;

  @override
  void add(String chunk) {
    count += chunk.length;
    if (count > limit) throw const _CapExceeded();
  }

  @override
  void close() {}
}

/// Whether [value]'s JSON encoding is longer than [limit] characters.
///
/// Stops encoding the moment the cap is passed instead of encoding the whole
/// payload just to measure it. The caller only ever asks "is it over the cap?",
/// so for a 1 MB payload this walks ~[limit] chars rather than all 1 M — and it
/// runs on the main thread for every request and response.
///
/// Throws whatever [JsonEncoder] throws for values it cannot encode (e.g.
/// `FormData`); callers that log arbitrary payloads should catch that.
bool jsonExceedsCap(dynamic value, int limit) {
  final input = const JsonEncoder().startChunkedConversion(
    _CapCountingSink(limit),
  );
  try {
    input.add(value);
    input.close();
    return false;
  } on _CapExceeded {
    return true;
  }
}
