import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/utils/json_size_cap.dart';

/// Builds a payload shaped like a real listing response: a big list of maps.
Map<String, dynamic> buildPayload(int itemCount) => {
  'data': List.generate(
    itemCount,
    (i) => {
      'id': i,
      'name': 'product-$i',
      'image': 'https://example.com/images/product-$i.png',
      'description': 'x' * 200,
    },
  ),
};

void main() {
  group('jsonExceedsCap', () {
    test('returns false for a payload under the cap', () {
      final small = buildPayload(1);
      expect(jsonEncode(small).length, lessThan(8000));
      expect(jsonExceedsCap(small, 8000), isFalse);
    });

    test('returns true for a payload over the cap', () {
      final big = buildPayload(500);
      expect(jsonEncode(big).length, greaterThan(8000));
      expect(jsonExceedsCap(big, 8000), isTrue);
    });

    test('agrees with a full encode across sizes', () {
      for (final count in [0, 1, 5, 20, 100, 500]) {
        final payload = buildPayload(count);
        expect(
          jsonExceedsCap(payload, 8000),
          jsonEncode(payload).length > 8000,
          reason: 'disagreed at itemCount=$count',
        );
      }
    });

    // The whole point of the helper: it must NOT encode the entire payload just
    // to discover it is oversized. If `startChunkedConversion` ever buffered the
    // string instead of emitting it incrementally, this would silently regress
    // into a full encode and the test below would fail.
    test('stops encoding shortly after passing the cap', () {
      final big = buildPayload(5000);
      final fullLength = jsonEncode(big).length;
      expect(fullLength, greaterThan(1000000), reason: 'payload should be ~MBs');

      var charsSeen = 0;
      final probe = _ProbeSink((chunk) => charsSeen += chunk.length);
      final input = const JsonEncoder().startChunkedConversion(probe);
      try {
        input.add(big);
        input.close();
      } on _StopProbe {
        // expected: aborted once past the cap
      }

      // Should have walked ~the cap, not the whole multi-MB payload.
      expect(charsSeen, lessThan(8000 * 2));
      expect(charsSeen, lessThan(fullLength ~/ 10));
    });
  });
}

class _StopProbe implements Exception {
  const _StopProbe();
}

/// Mirrors the counting sink the helper uses, but reports what it saw so the
/// test can assert the encoder really streams.
class _ProbeSink implements Sink<String> {
  _ProbeSink(this.onChunk);

  final void Function(String) onChunk;
  int _count = 0;

  @override
  void add(String chunk) {
    onChunk(chunk);
    _count += chunk.length;
    if (_count > 8000) throw const _StopProbe();
  }

  @override
  void close() {}
}
