

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:trydos/features/authentication/data/models/send_otp_response_model.dart';
import 'package:trydos/features/authentication/domain/use_cases/send_otp_usecase.dart';


import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers_for_testing/test_helpers.mocks.dart';
void main(){
   MockAuthRepository mockAuthRepository = MockAuthRepository();
   SendOtpUseCase sendOtpUseCase  = SendOtpUseCase(mockAuthRepository);

  // object represents the expected result of usecase
 SendOtpResponseModel sendOtpResponseModel = SendOtpResponseModel();

   // the usecase test parameters
   int isViaWhatsApp = 1;
   String phone = '+963994014438';

  test('should return the SendOtpResponse model', () async{

     when(mockAuthRepository.sendOtp({
       "phone" :'${phone}',
       "is_via_whatsapp" :isViaWhatsApp.toString(),
     })).thenAnswer((realInvocation) async => Right(sendOtpResponseModel));

     final result = await sendOtpUseCase(SendOtpParams(phone: phone, isViaWhatsApp: isViaWhatsApp));

     expect(result, Right(sendOtpResponseModel));

  });
}