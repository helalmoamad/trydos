import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/features/authentication/data/models/send_otp_response_model.dart';

import '../../../../helpers_for_testing/json_reader.dart';

void main() {

  SendOtpResponseModel sendOtpResponseModel = SendOtpResponseModel();
  test(
      'should return a valid model from json',
          () async {

        final Map < String, dynamic > jsonMap = json.decode(
          readJson('helpers_for_testing/dummy_data/send_otp_response_model.json'),
        );

        final result = SendOtpResponseModel.fromJson(jsonMap);


        // the class SendOtpResponseModel must override the operator == method
        expect(result, equals(sendOtpResponseModel));

      }
  );


  test(
    'should return a json map containing proper data',
        () async {

      final result = sendOtpResponseModel.toJson();

      final expectedJsonMap = {
        'isSuccessful': null,
        'hasContent': null,
        'code': null,
        'message': null,
        'detailed_error': null,
        'data': null
      };

      expect(result, equals(expectedJsonMap));

    },
  );

}