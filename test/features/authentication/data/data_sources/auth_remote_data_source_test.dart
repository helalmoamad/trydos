import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/mockito.dart';

import 'package:http/http.dart' as http;

import '../../../../helpers_for_testing/json_reader.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  Response<dynamic>? response;

  setUp(() {});

  const testCityName = 'New York';
  group('Accounts', () {
    const baseUrl = 'https://chating_staging_trydos.antiksef.online';

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: baseUrl));
      dioAdapter = DioAdapter(dio: dio);
    });

    test('create user', () async {
      const route = '/api/v1/create_user';

      dioAdapter.onPost(
        route,
        (server) => server.reply(
          200,
          readJson('helpers/dummy_data/dummy_weather_response.json'),
          delay: const Duration(seconds: 1),
        ),
        data: {
          "name": "hellal llskkfjejk",
          "mobile_phone":
              "09343308589", // تم تعديل " mobilePhone" إلى "mobilePhone"
          "password": "2233366535"
        },
      );

      // Returns a response with 201 Created success status response code.
      response = await dio.post(route, data: {
        "name": "hellal llskkfjejk",
        "mobile_phone": "09343308589",
        "password": "2233366535"
      });
      expect(jsonDecode(response!.data)["mobile_phone"], '09343308589');
      // تأكد من أن الرد ليس فارغًا قبل التحقق من الكود

      // التحقق من الكود في حالة وجود رد
      if (response != null) {
        expect(response!.statusCode, 200);
      }
    });
  });
}
