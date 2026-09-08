import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/utils/media_display_url.dart';

/// Test ledger · wave 01 Core runtime · unit "Media urls".
///
/// Every image and video in the app is addressed through this. It carries a
/// migration: newly uploaded media is stored as a sub-path that already knows
/// its folder, while older rows hold a bare file name and the app has to add
/// the folder back. Break the old-row branch and every historic image goes
/// blank at once, with no error anywhere.
void main() {
  const String base = 'https://media.test/image/upload';

  test('a value that is already a url is returned untouched', () {
    for (final String ready in <String>[
      'https://cdn.example.com/a/b/photo.jpg',
      'http://cdn.example.com/photo.jpg',
      // Cloudinary is recognised even without a scheme.
      'res.cloudinary.com/demo/image/upload/v1/photo.jpg',
    ]) {
      expect(
        mediaDisplayUrl(ready, legacyFolder: 'rating_orders', baseUrl: base),
        ready,
        reason: 'nothing may be built on top of a finished url',
      );
    }
  });

  test('a sub-path keeps its own folder and gets no legacy folder', () {
    expect(
      mediaDisplayUrl(
        'rating_orders/uuid.jpg',
        legacyFolder: 'should_not_appear',
        baseUrl: base,
      ),
      '$base/rating_orders/uuid.jpg',
    );
  });

  test('a bare file name is given the legacy folder', () {
    // The old-records path. Losing it blanks every image stored before the
    // upload flow changed.
    expect(
      mediaDisplayUrl('uuid.jpg', legacyFolder: 'rating_orders', baseUrl: base),
      '$base/rating_orders/uuid.jpg',
    );

    // With no legacy folder to add, the file sits directly under the base.
    expect(
      mediaDisplayUrl('uuid.jpg', legacyFolder: '', baseUrl: base),
      '$base/uuid.jpg',
    );
  });

  test('empty input stays empty and slashes never double up', () {
    expect(mediaDisplayUrl('', legacyFolder: 'x', baseUrl: base), '');
    expect(mediaDisplayUrl('   ', legacyFolder: 'x', baseUrl: base), '',
        reason: 'whitespace is not a file name');

    // A trailing slash on the base, a leading slash on the value, and slashes
    // around the folder must all collapse to exactly one separator.
    expect(
      mediaDisplayUrl(
        '/uuid.jpg',
        legacyFolder: '/rating_orders/',
        baseUrl: '$base///',
      ),
      '$base/rating_orders/uuid.jpg',
    );

    // With no baseUrl the value comes from the environment.
    dotenv.testLoad(fileInput: 'Media_S3_Server=$base/');
    expect(
      mediaDisplayUrl('uuid.jpg', legacyFolder: 'rating_orders'),
      '$base/rating_orders/uuid.jpg',
    );
  });
}
