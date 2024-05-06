import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/authentication/data/data_sources/auth_remote_datasource.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:trydos/features/authentication/data/models/send_otp_response_model.dart';

import '../../../../helpers_for_testing/json_reader.dart';
void main() {

   Dio dio = GetIt.I<Dio>();
   final dioAdapter = DioAdapter(dio: dio);
   AuthRemoteDatasource authRemoteDatasource  = AuthRemoteDatasource();



  const params = {
    "phone" :'+963994014438',
    "is_via_whatsapp" :'1',
  };

  group('send otp', () {

    test('should return  SendOtpResponseModel when the response code is 200', () async {

      dioAdapter.onGet(
       MarketUrls.baseUrl + MarketEndPoints.sendOtpEP,
            data: params,
            (request) => request.reply(200, readJson('helpers_for_testing/dummy_data/send_otp_response_model.json'),),
      );

      final result = await authRemoteDatasource.sendOtp(params);

      expect(result, isA<SendOtpResponseModel>());

    });


    test(
      'should throw a ServerFailure when the response code is not 200',
          () async {

            dioAdapter.onGet(
              MarketUrls.baseUrl + MarketEndPoints.sendOtpEP,
              queryParameters: params,
                  (request) => request.reply(404, {})
            );

            final result = await authRemoteDatasource.sendOtp(params);

        expect(result, throwsA(isA<Failure>()));

      },
    );


  });
}