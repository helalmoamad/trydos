import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';
import 'package:trydos/features/authentication/data/data_sources/auth_remote_datasource.dart';

void main() async {
  late Dio dio;
  late DioAdapter dioAdapter;

  Response<dynamic>? response;

  group('Accounts', () {
    const baseUrl = 'https://chating_staging_trydos.trydos.tech';

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
          {
            "mobile_phone": "09343308589",
            "name": "hellal llskkfjejk",
            "username": null,
            "updated_at": "2024-05-08T08:07:40.000000Z",
            "created_at": "2024-05-08T08:07:40.000000Z",
            "id": 112,
            "its_record_in_my_contact": null
          },
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

      // تأكد من أن الرد ليس فارغًا قبل التحقق من الكود
      expect(response, isNotNull);

      // التحقق من الكود في حالة وجود رد
      if (response != null) {
        expect(response!.statusCode, 200);
      }
    });
  });
}

/*    test('signs in user and fetches account information', () async {
      const signInRoute = '/signin';
      const accountRoute = '/account';

      const accessToken = <String, dynamic>{
        'token': 'ACCESS_TOKEN',
      };

      final headers = <String, dynamic>{
        'Authentication': 'Bearer $accessToken',
      };

      const userInformation = <String, dynamic>{
        'id': 1,
        'email': 'test@example.com',
        'password': 'password',
        'email_verified': false,
      };

      dioAdapter
        ..onPost(
          signInRoute,
          (server) => server.throws(
            401,
            DioException(
              requestOptions: RequestOptions(
                path: signInRoute,
              ),
            ),
          ),
        )
        ..onPost(
          signInRoute,
          (server) => server.reply(200, accessToken),
          data: userCredentials,
        )
        ..onGet(
          accountRoute,
          (server) => server.reply(200, userInformation),
          headers: headers,
        );

      // Throws without user credentials.
      expect(
        () async => await dio.post(signInRoute),
        throwsA(isA<DioException>()),
      );

      // Returns an access token if user credentials are provided.
      response = await dio.post(signInRoute, data: userCredentials);

      expect(response.data, accessToken);

      // Returns user information if an access token is provided in headers.
      response = await dio.get(
        accountRoute,
        options: Options(headers: headers),
      );

      expect(response.data, userInformation);
    });*/

  /*group('Get method', () {
    test('canbe used to get responses for any url', () async {
      final responsepayload = jsonEncode({"response_code": "1000"});
      final httpResponse = ResponseBody.fromString(
        responsepayload,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      when(dioAdapterMock.fetch(any, any, any))
          .thenAnswer((_) async => httpResponse);

      final response = await tapi.get("/any url");
      final expected = {"response_code": "1000"};

      expect(response, equals(expected));
    });
  });*/

 